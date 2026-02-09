#!/usr/bin/env node
/**
 * SessionStart Hook - 包括的セッション初期化
 *
 * - 前回セッション状態の復元とコンテキスト注入
 * - Git ブランチ・ステータス検出
 * - プロジェクトタイプ・フレームワーク自動検出
 * - CLAUDE_ENV_FILE による環境変数永続化
 * - アクティブTODO・保留タスクの通知
 */
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const memoryDir = path.join(projectDir, ".claude/memory/local");
const stateFile = path.join(memoryDir, "session-state.json");
const envFile = process.env.CLAUDE_ENV_FILE || "";

function safeExec(cmd) {
  try {
    return execSync(cmd, {
      encoding: "utf8",
      timeout: 5000,
      cwd: projectDir,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch {
    return "";
  }
}

function detectProject() {
  const detectors = [
    {
      file: "package.json",
      detect: () => {
        const pkg = JSON.parse(
          fs.readFileSync(path.join(projectDir, "package.json"), "utf8"),
        );
        const deps = { ...pkg.dependencies, ...pkg.devDependencies };
        const fw = [];
        if (deps["next"]) fw.push("Next.js");
        else if (deps["nuxt"]) fw.push("Nuxt");
        else if (deps["@remix-run/react"]) fw.push("Remix");
        else if (deps["react"]) fw.push("React");
        else if (deps["vue"]) fw.push("Vue");
        else if (deps["svelte"] || deps["@sveltejs/kit"]) fw.push("SvelteKit");
        else if (deps["angular"]) fw.push("Angular");
        if (deps["express"]) fw.push("Express");
        else if (deps["fastify"]) fw.push("Fastify");
        else if (deps["hono"]) fw.push("Hono");
        else if (deps["koa"]) fw.push("Koa");
        if (deps["typescript"]) fw.push("TypeScript");
        if (deps["prisma"] || deps["@prisma/client"]) fw.push("Prisma");
        else if (deps["drizzle-orm"]) fw.push("Drizzle");
        const pm = fs.existsSync(path.join(projectDir, "bun.lockb"))
          ? "bun"
          : fs.existsSync(path.join(projectDir, "pnpm-lock.yaml"))
            ? "pnpm"
            : fs.existsSync(path.join(projectDir, "yarn.lock"))
              ? "yarn"
              : "npm";
        const testCmd = pkg.scripts?.test || "";
        const testFw = deps["vitest"]
          ? "vitest"
          : deps["jest"]
            ? "jest"
            : deps["mocha"]
              ? "mocha"
              : deps["playwright"]
                ? "playwright"
                : "";
        return { lang: "JS/TS", fw, pm, testCmd, testFw };
      },
    },
    {
      file: "pyproject.toml",
      detect: () => ({ lang: "Python", fw: [], pm: "uv/pip" }),
    },
    { file: "go.mod", detect: () => ({ lang: "Go", fw: [], pm: "go" }) },
    { file: "Cargo.toml", detect: () => ({ lang: "Rust", fw: [], pm: "cargo" }) },
    {
      file: "build.gradle.kts",
      detect: () => ({ lang: "Kotlin", fw: [], pm: "gradle" }),
    },
    {
      file: "build.gradle",
      detect: () => ({ lang: "Java", fw: [], pm: "gradle" }),
    },
    { file: "pom.xml", detect: () => ({ lang: "Java", fw: [], pm: "maven" }) },
  ];
  for (const { file, detect } of detectors) {
    if (fs.existsSync(path.join(projectDir, file))) {
      try {
        return detect();
      } catch {
        return null;
      }
    }
  }
  return null;
}

try {
  const ctx = [];

  // 1. Previous session state
  if (fs.existsSync(stateFile)) {
    try {
      const state = JSON.parse(fs.readFileSync(stateFile, "utf8"));
      if (state.lastTask && state.lastTask !== "none") {
        ctx.push(`PREVIOUS_TASK: ${state.lastTask}`);
      }
      if (state.lastBranch) {
        ctx.push(`PREVIOUS_BRANCH: ${state.lastBranch}`);
      }
      if (state.dirtyFiles > 0) {
        ctx.push(`PREVIOUS_DIRTY_FILES: ${state.dirtyFiles}`);
      }
      if (state.pendingItems?.length > 0) {
        ctx.push(`PENDING: ${state.pendingItems.join(", ")}`);
      }
    } catch {}
  }

  // 2. Git context
  const branch = safeExec("git branch --show-current");
  if (branch) {
    ctx.push(`GIT_BRANCH: ${branch}`);
    const porcelain = safeExec("git status --porcelain");
    if (porcelain) {
      const lines = porcelain.split("\n").filter(Boolean);
      const m = lines.filter((l) => /^ ?M/.test(l)).length;
      const a = lines.filter((l) => /^A|^\?\?/.test(l)).length;
      const d = lines.filter((l) => /^ ?D/.test(l)).length;
      ctx.push(`GIT_CHANGES: ${m} modified, ${a} added/untracked, ${d} deleted`);
    }
    const unpushed = safeExec(
      `git rev-list --count origin/${branch}..HEAD 2>/dev/null`,
    );
    if (unpushed && parseInt(unpushed) > 0) {
      ctx.push(`UNPUSHED_COMMITS: ${unpushed}`);
    }
    const stash = safeExec("git stash list --format=%gd");
    if (stash) {
      ctx.push(`GIT_STASHES: ${stash.split("\n").filter(Boolean).length}`);
    }
  }

  // 3. Project detection
  const proj = detectProject();
  if (proj) {
    let info = `PROJECT: ${proj.lang}`;
    if (proj.fw?.length) info += ` [${proj.fw.join(", ")}]`;
    info += ` | PM: ${proj.pm}`;
    if (proj.testFw) info += ` | Test: ${proj.testFw}`;
    ctx.push(info);
  }

  // 4. Active TODOs
  const learnings = path.join(memoryDir, "learnings.md");
  if (fs.existsSync(learnings)) {
    const content = fs.readFileSync(learnings, "utf8");
    const todos = content.match(/^- \[ \] .+$/gm);
    if (todos?.length) {
      ctx.push(`ACTIVE_TODOS: ${todos.length} item(s)`);
    }
  }

  // 5. Persist env via CLAUDE_ENV_FILE
  if (envFile) {
    const vars = [];
    if (branch) vars.push(`CURRENT_BRANCH=${branch}`);
    if (proj?.lang) vars.push(`PROJECT_LANG=${proj.lang}`);
    if (proj?.pm) vars.push(`PROJECT_PM=${proj.pm}`);
    if (proj?.testFw) vars.push(`PROJECT_TEST_FW=${proj.testFw}`);
    if (vars.length) {
      try {
        fs.writeFileSync(envFile, vars.join("\n") + "\n");
      } catch {}
    }
  }

  // Output
  if (ctx.length > 0) {
    console.log("SESSION_CONTEXT:");
    ctx.forEach((c) => console.log(`  ${c}`));
  }
} catch (e) {
  process.stderr.write(`session-start: ${e.message}\n`);
}
process.exit(0);
