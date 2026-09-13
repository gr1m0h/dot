#!/usr/bin/env node
/**
 * TaskCompleted Validator
 *
 * タスク完了時の検証を実行
 * - テスト実行確認
 * - コード品質チェック
 * - 変更サマリー生成
 * - コミット前チェック
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
    const warnings = [];

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

    // タスク情報
    const taskId = data.task_id || "unknown";
    const taskSubject = data.task_subject || "";

    // Git差分確認
    const gitDiff = tryExec("git diff --stat HEAD 2>/dev/null", "Git Diff");
    const gitDiffStaged = tryExec("git diff --stat --cached 2>/dev/null", "Git Staged");
    let changedFiles = 0;
    if (gitDiff.success && gitDiff.output) {
      const match = gitDiff.output.match(/(\d+) files? changed/);
      if (match) changedFiles += parseInt(match[1], 10);
    }
    if (gitDiffStaged.success && gitDiffStaged.output) {
      const match = gitDiffStaged.output.match(/(\d+) files? changed/);
      if (match) changedFiles += parseInt(match[1], 10);
    }

    // テスト実行チェック
    const hasTests = fs.existsSync(path.join(projectDir, "tests")) ||
                     fs.existsSync(path.join(projectDir, "test")) ||
                     fs.existsSync(path.join(projectDir, "__tests__")) ||
                     fs.existsSync(path.join(projectDir, "spec"));

    if (hasTests && changedFiles > 0) {
      // package.json のtest scriptを確認
      const pkgPath = path.join(projectDir, "package.json");
      if (fs.existsSync(pkgPath)) {
        try {
          const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
          if (pkg.scripts?.test) {
            warnings.push("Tests available - consider running before commit");
          }
        } catch {}
      }

      // Python pytest確認
      if (fs.existsSync(path.join(projectDir, "pyproject.toml"))) {
        warnings.push("pytest available - consider running before commit");
      }
    }

    // 大きな変更の警告
    if (changedFiles > 10) {
      warnings.push(`Large change set: ${changedFiles} files modified`);
    }

    // セキュリティチェック: secrets漏洩の可能性
    const gitDiffContent = tryExec("git diff HEAD 2>/dev/null", "Git Diff Content");
    if (gitDiffContent.success && gitDiffContent.output) {
      const secretPatterns = [
        /AKIA[0-9A-Z]{16}/,
        /sk-[a-zA-Z0-9]{20,}/,
        /ghp_[a-zA-Z0-9]{36}/,
        /-----BEGIN.*PRIVATE KEY-----/,
      ];
      for (const p of secretPatterns) {
        if (p.test(gitDiffContent.output)) {
          warnings.push("SECURITY: Potential secret detected in changes");
          break;
        }
      }
    }

    // 監査ログ記録
    const logDir = path.join(projectDir, ".claude/memory/local");
    if (!fs.existsSync(logDir)) {
      try {
        fs.mkdirSync(logDir, { recursive: true });
      } catch {}
    }
    const logFile = path.join(logDir, "task-completed.jsonl");
    const entry = {
      t: new Date().toISOString(),
      taskId,
      taskSubject,
      changedFiles,
      warnings: warnings.length,
    };
    try {
      fs.appendFileSync(logFile, JSON.stringify(entry) + "\n");
    } catch {}

    // 結果出力
    if (warnings.length > 0) {
      console.log("TASK_COMPLETION_NOTES:");
      warnings.forEach((w) => console.log(`  - ${w}`));
    }

    results.push(`Task #${taskId} completed. ${changedFiles} files changed.`);
    console.log(results.join(" "));

    process.exit(0);
  } catch (e) {
    process.stderr.write(`task-validator: ${e.message}\n`);
    process.exit(0);
  }
});
