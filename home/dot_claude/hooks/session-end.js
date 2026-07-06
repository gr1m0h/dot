#!/usr/bin/env node
/**
 * SessionEnd Hook - セッション終了・状態永続化
 *
 * - セッション状態スナップショットの保存
 * - Git状態の記録
 * - セッションメトリクスの追記（JSONL）
 * - エラーログのローテーション（100行上限）
 * - 顧客repoセッションが sreaas report なしで終了した場合に ~/batch/unreported.md へ記録
 */
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const memoryDir = path.join(projectDir, ".claude/memory/local");
const stateFile = path.join(memoryDir, "session-state.json");
const metricsFile = path.join(memoryDir, "session-metrics.jsonl");
const errorLog = path.join(memoryDir, "error-log.txt");

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

try {
  if (!fs.existsSync(memoryDir)) fs.mkdirSync(memoryDir, { recursive: true });

  const branch = safeExec("git branch --show-current");
  const dirtyCount = safeExec("git status --porcelain")
    .split("\n")
    .filter(Boolean).length;
  const lastCommit = safeExec("git log -1 --format=%h\\ %s");

  // 1. Merge with previous state
  let prev = {};
  if (fs.existsSync(stateFile)) {
    try {
      prev = JSON.parse(fs.readFileSync(stateFile, "utf8"));
    } catch {}
  }

  const state = {
    ...prev,
    lastSession: new Date().toISOString(),
    lastTask: process.env.CURRENT_TASK || prev.lastTask || "none",
    lastBranch: branch || prev.lastBranch || "",
    lastCommit: lastCommit || prev.lastCommit || "",
    dirtyFiles: dirtyCount,
    pendingItems: prev.pendingItems || [],
  };
  fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));

  // 2. Append metrics (JSONL)
  const metric = {
    t: new Date().toISOString(),
    branch: branch || null,
    dirty: dirtyCount,
    task: state.lastTask,
    commit: lastCommit || null,
  };
  fs.appendFileSync(metricsFile, JSON.stringify(metric) + "\n");

  // 3. Rotate error log (keep last 100 lines)
  if (fs.existsSync(errorLog)) {
    const lines = fs.readFileSync(errorLog, "utf8").split("\n");
    if (lines.length > 100) {
      fs.writeFileSync(errorLog, lines.slice(-100).join("\n"));
    }
  }

  // 4. Rotate metrics (keep last 500 entries)
  if (fs.existsSync(metricsFile)) {
    const mLines = fs.readFileSync(metricsFile, "utf8").split("\n").filter(Boolean);
    if (mLines.length > 500) {
      fs.writeFileSync(metricsFile, mLines.slice(-500).join("\n") + "\n");
    }
  }
} catch (e) {
  process.stderr.write(`session-end: ${e.message}\n`);
}

// 5. Track sessions in tracked orgs that ended without leaving a report
//    (surfaced next morning by /morning-batch and the statusline ⚠ indicator)
try {
  // 追跡 org は非追跡ファイル ~/.claude/tracked-orgs.txt で管理
  // （dotfiles は public のため org 名をコミットしない）。
  // 形式: 1行1エントリ `org` または `org | marker1,marker2`（# はコメント行）。
  // マーカー文字列が transcript に1つも現れないまま終了した session を記録する。
  // マーカー省略時は "sreaas"。ファイルがなければこのトラッカーは何もしない。
  const orgsFile = path.join(process.env.HOME || "", ".claude/tracked-orgs.txt");
  const TRACKED = fs.existsSync(orgsFile)
    ? fs
        .readFileSync(orgsFile, "utf8")
        .split("\n")
        .map((l) => l.trim())
        .filter((l) => l && !l.startsWith("#"))
        .map((l) => {
          const [org, markers] = l.split("|").map((s) => s.trim());
          return {
            org,
            markers: markers
              ? markers.split(",").map((s) => s.trim()).filter(Boolean)
              : ["sreaas"],
          };
        })
        .filter((t) => t.org)
    : [];
  const MIN_TRANSCRIPT_BYTES = 30000; // 起動しただけの軽いセッションは無視

  let payload = {};
  try {
    payload = JSON.parse(fs.readFileSync(0, "utf8") || "{}");
  } catch {}
  const cwd = payload.cwd || projectDir;
  const transcript = payload.transcript_path || "";

  const entry = TRACKED.find((t) => cwd.includes(`/github.com/${t.org}`));
  if (entry && transcript && fs.existsSync(transcript)) {
    const size = fs.statSync(transcript).size;
    let reported = false;
    for (const marker of entry.markers) {
      try {
        execSync(`grep -q -m1 -F '${marker}' '${transcript}'`, {
          timeout: 5000,
        });
        reported = true;
        break;
      } catch {}
    }
    if (size > MIN_TRANSCRIPT_BYTES && !reported) {
      const batchDir = path.join(process.env.HOME || "", "batch");
      if (!fs.existsSync(batchDir)) fs.mkdirSync(batchDir, { recursive: true });
      const line = `- ${new Date().toISOString()} | ${cwd} | ${path.basename(transcript)} | missing: ${entry.markers.join(",")}\n`;
      fs.appendFileSync(path.join(batchDir, "unreported.md"), line);
    }
  }
} catch (e) {
  process.stderr.write(`session-end(report-tracker): ${e.message}\n`);
}
process.exit(0);
