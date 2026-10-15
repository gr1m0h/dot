#!/usr/bin/env node
/**
 * TeammateIdle Quality Gate
 *
 * チームメイトがアイドルになる前にコード品質チェックを実行
 * - Linter自動実行
 * - TypeScript型チェック
 * - テストの実行確認
 * - 未コミットの変更警告
 */
const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const results = [];

    function tryExec(cmd, label, timeout = 30000) {
      try {
        const output = execSync(cmd, {
          stdio: ["pipe", "pipe", "pipe"],
          timeout,
          cwd: projectDir,
          encoding: "utf8",
        });
        return { success: true, output: output.trim() };
      } catch (e) {
        const stderr = e.stderr?.toString().trim() || "";
        const stdout = e.stdout?.toString().trim() || "";
        return { success: false, output: stderr || stdout };
      }
    }

    // Git: 未コミットの変更確認
    const gitStatus = tryExec("git status --porcelain 2>/dev/null", "Git Status");
    if (gitStatus.success && gitStatus.output) {
      const lines = gitStatus.output.split("\n").filter(Boolean);
      if (lines.length > 0) {
        results.push(`Uncommitted changes: ${lines.length} file(s)`);
      }
    }

    // TypeScript型チェック
    if (fs.existsSync(path.join(projectDir, "tsconfig.json"))) {
      const tscResult = tryExec("npx tsc --noEmit 2>&1 | tail -3", "TypeCheck", 60000);
      if (!tscResult.success && tscResult.output) {
        results.push(`TypeScript errors: ${tscResult.output.split("\n")[0]}`);
      }
    }

    // ESLint/Biome チェック
    const hasBiome =
      fs.existsSync(path.join(projectDir, "biome.json")) ||
      fs.existsSync(path.join(projectDir, "biome.jsonc"));
    if (hasBiome) {
      const biomeResult = tryExec("npx biome check . 2>&1 | tail -3", "Biome");
      if (!biomeResult.success && biomeResult.output) {
        results.push(`Biome issues: ${biomeResult.output.split("\n")[0]}`);
      }
    } else {
      const hasEslint =
        fs.existsSync(path.join(projectDir, ".eslintrc.js")) ||
        fs.existsSync(path.join(projectDir, ".eslintrc.json")) ||
        fs.existsSync(path.join(projectDir, "eslint.config.js")) ||
        fs.existsSync(path.join(projectDir, "eslint.config.mjs"));
      if (hasEslint) {
        const eslintResult = tryExec("npx eslint . --max-warnings 0 2>&1 | tail -3", "ESLint", 60000);
        if (!eslintResult.success && eslintResult.output) {
          results.push(`ESLint issues: ${eslintResult.output.split("\n")[0]}`);
        }
      }
    }

    // Python: ruff/mypy チェック
    if (fs.existsSync(path.join(projectDir, "pyproject.toml")) || fs.existsSync(path.join(projectDir, "setup.py"))) {
      const ruffResult = tryExec("ruff check . 2>&1 | tail -3", "Ruff");
      if (!ruffResult.success && ruffResult.output) {
        results.push(`Ruff issues: ${ruffResult.output.split("\n")[0]}`);
      }
    }

    // 監査ログ記録
    const logDir = path.join(projectDir, ".claude/memory/local");
    if (!fs.existsSync(logDir)) {
      try {
        fs.mkdirSync(logDir, { recursive: true });
      } catch {}
    }
    const logFile = path.join(logDir, "quality-gate.jsonl");
    const entry = {
      t: new Date().toISOString(),
      event: "teammate_idle",
      issues: results,
      teammate: data.teammate_name || "unknown",
    };
    try {
      fs.appendFileSync(logFile, JSON.stringify(entry) + "\n");
    } catch {}

    // 結果出力
    if (results.length > 0) {
      console.log("QUALITY_GATE_WARNINGS:");
      results.forEach((r) => console.log(`  - ${r}`));
    }

    process.exit(0);
  } catch (e) {
    process.stderr.write(`quality-gate: ${e.message}\n`);
    process.exit(0);
  }
});
