#!/usr/bin/env node
/**
 * Org Leak Guard - クロスorg参照の漏洩防止
 *
 * 他案件のPRを参考にした際、その org 名や PR URL が commit message /
 * PR タイトル・本文に混入するのをブロックする。
 * 判定基準: 実行中リポジトリの origin の GitHub org と異なる org への参照。
 *
 * 検査対象:
 * - Bash: git commit / git tag / gh pr|issue|release create|edit
 *   (--body-file / -F 等で渡されるファイルの中身も検査)
 * - MCP: GitHub 系 MCP ツール (mcp__github__* / mcp__claude_ai_GitHub_MCP__* 等) の
 *   body / title / message 系フィールド
 *
 * 検出ルール:
 * 1. github.com/<org>/... URL で org が現在の org と異なる → ブロック
 * 2. <org>/<repo>#123 形式のクロスリポジトリ参照で org が異なる → ブロック
 * 3. 既知 org 名（現在の org 以外）の裸の言及 → ブロック
 *    （URL 化されていない org 名の混入も防ぐ）
 *
 * ルール 3 の「既知 org」は自動識別: cwd の ghq 形式パス
 * (.../github.com/<org>/<repo>) から github.com ディレクトリを特定し、
 * 兄弟 org ディレクトリを列挙する（tracked-orgs.txt は 2026-08 に廃止済み）。
 *
 * exit(2) = ブロック, exit(0) = 許可
 */
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

function currentOrgFromGit(cwd) {
  try {
    const url = execSync("git remote get-url origin", {
      cwd: cwd || process.cwd(),
      stdio: ["ignore", "pipe", "ignore"],
      timeout: 3000,
    })
      .toString()
      .trim();
    const m = url.match(/github\.com[/:]([A-Za-z0-9][A-Za-z0-9-]*)/i);
    return m ? m[1].toLowerCase() : null;
  } catch {
    return null;
  }
}

// ghq 形式レイアウト (.../github.com/<org>/<repo>) の兄弟 org ディレクトリを
// 「ユーザーが関わっている org」として自動識別する
function autoDiscoverOrgs(cwd) {
  try {
    const parts = path.resolve(cwd || process.cwd()).split(path.sep);
    const i = parts.lastIndexOf("github.com");
    if (i < 0) return [];
    const root = parts.slice(0, i + 1).join(path.sep);
    return fs
      .readdirSync(root, { withFileTypes: true })
      .filter((d) => d.isDirectory() && !d.name.startsWith("."))
      .map((d) => d.name.toLowerCase());
  } catch {
    return [];
  }
}

function knownOrgs(cwd) {
  return [...new Set(autoDiscoverOrgs(cwd))];
}

function escapeRe(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function findForeignOrgs(text, currentOrg, trackedOrgs) {
  const hits = new Set();

  if (currentOrg) {
    // github.com URL / SSH 形式 (https://github.com/org/... , git@github.com:org/...)
    for (const m of text.matchAll(/github\.com[/:]([A-Za-z0-9][A-Za-z0-9-]*)/gi)) {
      const org = m[1].toLowerCase();
      if (org !== currentOrg) hits.add(org);
    }
    // org/repo#123 形式のクロスリポジトリ参照
    for (const m of text.matchAll(/\b([A-Za-z0-9][A-Za-z0-9-]*)\/[A-Za-z0-9._-]+#\d+/g)) {
      const org = m[1].toLowerCase();
      if (org !== currentOrg) hits.add(org);
    }
  }

  // 既知 org（自動識別）の裸の言及（org 判定不能時も適用）
  for (const org of trackedOrgs) {
    if (org === currentOrg) continue;
    if (new RegExp(`(^|[^A-Za-z0-9-])${escapeRe(org)}([^A-Za-z0-9-]|$)`, "i").test(text)) {
      hits.add(org);
    }
  }

  return [...hits];
}

function block(orgs, currentOrg) {
  console.error(
    `BLOCKED: Cross-org reference in commit/PR content: ${orgs.join(", ")}` +
      (currentOrg ? ` (current repo org: ${currentOrg})` : "") +
      `\nFix: remove references to other orgs' repos/PRs from the commit message or PR body. ` +
      `Describe the approach in your own words instead of linking or naming another client's work. ` +
      `If the reference is genuinely intended, ask the user to publish it manually.`,
  );
  process.exit(2);
}

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const tool = data.tool_name || "";
    const ti = data.tool_input || {};
    const trackedOrgs = knownOrgs(data.cwd);

    // ── Bash: 公開系コマンドのみ検査 ──
    if (tool === "Bash") {
      const cmd = ti.command || "";
      const publishRe =
        /\bgit\s+(-[^\s]+\s+)*(commit|tag)\b|\bgh\s+(pr|issue|release)\s+(create|edit)\b/;
      if (!publishRe.test(cmd)) process.exit(0);

      let text = cmd;
      // --body-file / --notes-file / git commit -F 等のファイル中身も検査
      for (const m of cmd.matchAll(
        /(?:--body-file|--notes-file|-F|--file)[= ]+["']?([^\s"']+)/g,
      )) {
        const fp = m[1].replace(/^~(?=\/)/, os.homedir());
        try {
          text += "\n" + fs.readFileSync(fp, "utf8");
        } catch {
          /* 読めないものは無視（gh api の -F field=value 等） */
        }
      }

      const currentOrg = currentOrgFromGit(data.cwd);
      const hits = findForeignOrgs(text, currentOrg, trackedOrgs);
      if (hits.length) block(hits, currentOrg);
      process.exit(0);
    }

    // ── GitHub MCP: 本文系フィールドのみ検査 ──
    // ツール名はサーバー登録名に依存する (mcp__github__* / mcp__claude_ai_GitHub_MCP__* 等)
    if (/^mcp__.*github/i.test(tool)) {
      const fields = ["body", "title", "message", "description", "commit_message", "text"];
      let text = "";
      for (const f of fields) if (typeof ti[f] === "string") text += ti[f] + "\n";
      if (Array.isArray(ti.files)) {
        for (const f of ti.files) if (f && typeof f.content === "string") text += f.content + "\n";
      }
      if (!text) process.exit(0);

      const currentOrg =
        (typeof ti.owner === "string" && ti.owner.toLowerCase()) || currentOrgFromGit(data.cwd);
      const hits = findForeignOrgs(text, currentOrg, trackedOrgs);
      if (hits.length) block(hits, currentOrg);
      process.exit(0);
    }

    process.exit(0);
  } catch (e) {
    // パースエラー等は安全側（許可）に倒す — 本ガードは機密性ガードであり可用性を優先
    process.stderr.write(`org-leak-guard: ${e.message}\n`);
    process.exit(0);
  }
});
