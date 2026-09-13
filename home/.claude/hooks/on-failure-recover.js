#!/usr/bin/env node
/**
 * PostToolUseFailure - インテリジェントエラーリカバリ
 *
 * - エラー分類（構文/ランタイム/権限/ネットワーク/タイムアウト/依存関係）
 * - パターンベースの自動修正ヒント
 * - リトライカウント追跡（同一エラー3回で警告）
 * - 構造化エラーコンテキストのLLM注入
 */
const fs = require("fs");
const path = require("path");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name || "unknown";
    const error = data.error || data.tool_input?.error || "unknown error";
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const memDir = path.join(projectDir, ".claude/memory/local");
    const logFile = path.join(memDir, "error-log.txt");
    const retryFile = path.join(memDir, "retry-tracker.json");

    if (!fs.existsSync(memDir)) fs.mkdirSync(memDir, { recursive: true });

    // 1. エラー分類
    const errorStr = String(error);
    const classify = () => {
      if (/SyntaxError|Unexpected token|Parse error/i.test(errorStr))
        return { cat: "SYNTAX", hint: "構文エラー: ファイルのJSON/JS構文を確認してください" };
      if (/ENOENT|no such file|not found/i.test(errorStr))
        return { cat: "NOT_FOUND", hint: "ファイル/コマンドが見つかりません。パスを確認してください" };
      if (/EACCES|Permission denied|EPERM/i.test(errorStr))
        return { cat: "PERMISSION", hint: "権限エラー: ファイル権限またはsandbox設定を確認してください" };
      if (/ECONNREFUSED|ETIMEDOUT|ENOTFOUND|fetch failed/i.test(errorStr))
        return { cat: "NETWORK", hint: "ネットワークエラー: 接続先の可用性を確認してください" };
      if (/timeout|timed out|SIGTERM/i.test(errorStr))
        return { cat: "TIMEOUT", hint: "タイムアウト: コマンドに時間制限を追加するか、処理を分割してください" };
      if (/Cannot find module|Module not found|No module named/i.test(errorStr))
        return { cat: "DEPENDENCY", hint: "依存関係エラー: `npm install` or `pip install` を実行してください" };
      if (/ENOMEM|out of memory|heap/i.test(errorStr))
        return { cat: "MEMORY", hint: "メモリ不足: 処理対象を縮小してください" };
      if (/Type.?Error|is not a function|undefined is not/i.test(errorStr))
        return { cat: "TYPE", hint: "型エラー: 変数の型や引数を確認してください" };
      if (/exit code [1-9]|exited with|non-zero/i.test(errorStr))
        return { cat: "RUNTIME", hint: "実行時エラー: エラー出力の詳細を確認してください" };
      return { cat: "UNKNOWN", hint: "エラーの詳細を調査してください" };
    };

    const { cat, hint } = classify();

    // 2. エラーログに記録
    const logEntry = `[${new Date().toISOString()}] [${cat}] ${toolName}: ${errorStr.slice(0, 200)}\n`;
    fs.appendFileSync(logFile, logEntry);

    // 3. リトライ追跡
    const errorKey = `${toolName}:${cat}:${errorStr.slice(0, 50)}`;
    let retries = {};
    if (fs.existsSync(retryFile)) {
      try {
        retries = JSON.parse(fs.readFileSync(retryFile, "utf8"));
      } catch {}
    }
    retries[errorKey] = (retries[errorKey] || 0) + 1;
    const count = retries[errorKey];

    // 古いエントリをクリーンアップ（50件上限）
    const keys = Object.keys(retries);
    if (keys.length > 50) {
      const toRemove = keys.slice(0, keys.length - 50);
      toRemove.forEach((k) => delete retries[k]);
    }
    fs.writeFileSync(retryFile, JSON.stringify(retries, null, 2));

    // 4. コンテキスト注入
    const output = [`ERROR_RECOVERY [${cat}] (attempt ${count}/3):`, `  Tool: ${toolName}`, `  Hint: ${hint}`];

    if (count >= 3) {
      output.push(
        "  WARNING: 同一エラーが3回発生しています。別のアプローチを試すか、ユーザーに確認してください。",
      );
    }

    // ツール固有のヒント
    if (toolName === "Bash" && cat === "DEPENDENCY") {
      output.push("  SUGGESTION: 先にパッケージインストールを実行してください");
    }
    if (toolName === "Edit" && cat === "NOT_FOUND") {
      output.push("  SUGGESTION: Writeツールで新規作成してください");
    }
    if (toolName === "Bash" && cat === "TIMEOUT") {
      output.push("  SUGGESTION: timeoutパラメータを増やすか、処理を分割してください");
    }

    console.log(output.join("\n"));
  } catch (e) {
    process.stderr.write(`on-failure-recover: ${e.message}\n`);
  }
  process.exit(0);
});
