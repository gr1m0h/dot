#!/usr/bin/env node
/**
 * Cost Monitor - トークン使用量追跡
 *
 * - ツール使用回数の記録
 * - 推定トークン使用量の追跡
 * - 予算超過警告
 * - セッション統計の生成
 */
const fs = require("fs");
const path = require("path");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const sessionId = process.env.CLAUDE_SESSION_ID || "unknown";

    // コスト推定パラメータ
    const toolCosts = {
      Read: 0.5,      // 低コスト
      Glob: 0.3,
      Grep: 0.5,
      Edit: 1.0,      // 中コスト
      Write: 1.0,
      Bash: 1.5,      // 高コスト（出力による）
      Task: 5.0,      // サブエージェント起動
      WebFetch: 2.0,
      WebSearch: 2.0,
    };

    const toolName = data.tool_name || "unknown";
    const toolInput = data.tool_input || {};
    const toolResult = data.tool_result || "";

    // 入力/出力サイズからトークン推定
    const inputSize = JSON.stringify(toolInput).length;
    const outputSize = typeof toolResult === "string" ? toolResult.length : JSON.stringify(toolResult).length;
    const estimatedTokens = Math.ceil((inputSize + outputSize) / 4); // 概算: 4文字 = 1トークン

    // 基本コスト + サイズベースコスト
    const baseCost = toolCosts[toolName] || 1.0;
    const sizeCost = estimatedTokens * 0.001; // トークンあたり0.001の重み
    const totalCost = baseCost + sizeCost;

    // ログディレクトリ
    const logDir = path.join(projectDir, ".claude/memory/local");
    if (!fs.existsSync(logDir)) {
      try {
        fs.mkdirSync(logDir, { recursive: true });
      } catch {}
    }

    // セッション統計ファイル
    const statsFile = path.join(logDir, "cost-stats.json");
    let stats = {
      sessionId,
      startTime: new Date().toISOString(),
      totalCost: 0,
      toolUsage: {},
      estimatedTokens: 0,
    };

    // 既存の統計を読み込み
    try {
      if (fs.existsSync(statsFile)) {
        const existing = JSON.parse(fs.readFileSync(statsFile, "utf8"));
        if (existing.sessionId === sessionId) {
          stats = existing;
        }
      }
    } catch {}

    // 統計を更新
    stats.totalCost += totalCost;
    stats.estimatedTokens += estimatedTokens;
    stats.toolUsage[toolName] = (stats.toolUsage[toolName] || 0) + 1;
    stats.lastUpdate = new Date().toISOString();

    // 統計を保存
    try {
      fs.writeFileSync(statsFile, JSON.stringify(stats, null, 2));
    } catch {}

    // 詳細ログ
    const detailLog = path.join(logDir, "cost-detail.jsonl");
    const entry = {
      t: new Date().toISOString(),
      tool: toolName,
      inputSize,
      outputSize,
      estimatedTokens,
      cost: totalCost,
    };
    try {
      fs.appendFileSync(detailLog, JSON.stringify(entry) + "\n");
    } catch {}

    // 予算警告（環境変数 COST_BUDGET で設定可能）
    const budget = parseFloat(process.env.COST_BUDGET) || 100;
    if (stats.totalCost > budget * 0.8) {
      console.log(`COST_WARNING: Session cost at ${Math.round(stats.totalCost / budget * 100)}% of budget`);
    }

    // 高コストツール警告
    if (totalCost > 10) {
      console.log(`HIGH_COST_OPERATION: ${toolName} estimated cost: ${totalCost.toFixed(2)}`);
    }

    process.exit(0);
  } catch (e) {
    process.stderr.write(`cost-monitor: ${e.message}\n`);
    process.exit(0);
  }
});
