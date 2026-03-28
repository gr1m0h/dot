#!/usr/bin/env node
/**
 * PostToolUse Verify - 編集後の自動品質チェック
 *
 * - Linter自動実行 (ESLint/Biome, ruff, gofmt, rustfmt, ktlint)
 * - Formatter自動実行 (Prettier, Biome)
 * - TypeScript型チェック (tsc --noEmit、対象ファイルのみ)
 * - 変更の監査ログ記録
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
    const fp = data.tool_input?.file_path || "";
    if (!fp || !fs.existsSync(fp)) {
      process.exit(0);
    }

    const ext = path.extname(fp).toLowerCase();
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const results = [];

    function tryExec(cmd, label) {
      try {
        execSync(cmd, {
          stdio: ["pipe", "pipe", "pipe"],
          timeout: 15000,
          cwd: projectDir,
        });
        return true;
      } catch (e) {
        const stderr = e.stderr?.toString().trim();
        const stdout = e.stdout?.toString().trim();
        const msg = stderr || stdout || "";
        if (msg) {
          results.push(`${label}: ${msg.split("\n").slice(0, 3).join(" | ")}`);
        }
        return false;
      }
    }

    // ── JavaScript / TypeScript ──
    if ([".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs"].includes(ext)) {
      // Biome (優先)
      const hasBiome =
        fs.existsSync(path.join(projectDir, "biome.json")) ||
        fs.existsSync(path.join(projectDir, "biome.jsonc"));
      if (hasBiome) {
        tryExec(`npx biome check --write "${fp}"`, "Biome");
      } else {
        // ESLint
        const hasEslint =
          fs.existsSync(path.join(projectDir, ".eslintrc.js")) ||
          fs.existsSync(path.join(projectDir, ".eslintrc.json")) ||
          fs.existsSync(path.join(projectDir, ".eslintrc.cjs")) ||
          fs.existsSync(path.join(projectDir, ".eslintrc.yml")) ||
          fs.existsSync(path.join(projectDir, "eslint.config.js")) ||
          fs.existsSync(path.join(projectDir, "eslint.config.mjs")) ||
          fs.existsSync(path.join(projectDir, "eslint.config.ts"));
        if (hasEslint) {
          tryExec(`npx eslint --fix "${fp}"`, "ESLint");
        }
        // Prettier
        const hasPrettier =
          fs.existsSync(path.join(projectDir, ".prettierrc")) ||
          fs.existsSync(path.join(projectDir, ".prettierrc.json")) ||
          fs.existsSync(path.join(projectDir, ".prettierrc.js")) ||
          fs.existsSync(path.join(projectDir, "prettier.config.js")) ||
          fs.existsSync(path.join(projectDir, "prettier.config.mjs"));
        if (hasPrettier) {
          tryExec(`npx prettier --write "${fp}"`, "Prettier");
        }
      }
      // TypeScript type check (tsファイルのみ、プロジェクトにtsconfigがある場合)
      if (
        [".ts", ".tsx"].includes(ext) &&
        fs.existsSync(path.join(projectDir, "tsconfig.json"))
      ) {
        tryExec(`npx tsc --noEmit --pretty false 2>&1 | head -5`, "TypeCheck");
      }
    }

    // ── Python ──
    if (ext === ".py") {
      const hasRuff = (() => {
        try {
          execSync("ruff --version", { stdio: "pipe", timeout: 3000 });
          return true;
        } catch {
          return false;
        }
      })();
      if (hasRuff) {
        tryExec(`ruff check --fix "${fp}"`, "Ruff Lint");
        tryExec(`ruff format "${fp}"`, "Ruff Format");
      } else {
        tryExec(`python3 -m black "${fp}" 2>/dev/null`, "Black");
      }
      // mypy (設定ファイルがある場合のみ)
      if (
        fs.existsSync(path.join(projectDir, "mypy.ini")) ||
        fs.existsSync(path.join(projectDir, "setup.cfg")) ||
        fs.existsSync(path.join(projectDir, "pyproject.toml"))
      ) {
        tryExec(`python3 -m mypy "${fp}" --no-error-summary 2>&1 | head -5`, "Mypy");
      }
    }

    // ── Go ──
    if (ext === ".go") {
      tryExec(`gofmt -w "${fp}"`, "gofmt");
      tryExec(`goimports -w "${fp}" 2>/dev/null`, "goimports");
    }

    // ── Rust ──
    if (ext === ".rs") {
      tryExec(`rustfmt "${fp}"`, "rustfmt");
    }

    // ── Kotlin ──
    if ([".kt", ".kts"].includes(ext)) {
      tryExec(`ktlint -F "${fp}" 2>/dev/null`, "ktlint");
    }

    // ── 監査ログ ──
    const logDir = path.join(projectDir, ".claude/memory/local");
    if (!fs.existsSync(logDir)) {
      try {
        fs.mkdirSync(logDir, { recursive: true });
      } catch {}
    }
    const auditFile = path.join(logDir, "edit-audit.jsonl");
    const entry = {
      t: new Date().toISOString(),
      tool: data.tool_name,
      file: fp,
      issues: results.length,
    };
    try {
      fs.appendFileSync(auditFile, JSON.stringify(entry) + "\n");
    } catch {}

    // 問題があれば報告
    if (results.length > 0) {
      console.log("POST_EDIT_ISSUES:");
      results.forEach((r) => console.log(`  ${r}`));
    }
  } catch (e) {
    process.stderr.write(`post-tool-verify: ${e.message}\n`);
  }
  process.exit(0);
});
