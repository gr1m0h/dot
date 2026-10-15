#!/usr/bin/env node
/**
 * SSRF Guard - WebFetch URL検証
 *
 * - 内部ネットワークアクセス防止
 * - プライベートIPレンジのブロック
 * - 許可ドメインリスト管理
 * - メタデータエンドポイント保護
 * exit(2) = ブロック, exit(0) = 許可
 */
let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const tool = data.tool_name || "";

    if (tool !== "WebFetch") {
      process.exit(0);
    }

    const url = data.tool_input?.url || "";
    if (!url) {
      process.exit(0);
    }

    let parsed;
    try {
      parsed = new URL(url);
    } catch {
      console.error("BLOCKED: Invalid URL format");
      process.exit(2);
    }

    const hostname = parsed.hostname.toLowerCase();
    const protocol = parsed.protocol;

    // HTTPSのみ許可（HTTPはHTTPSにアップグレードされるが念のため）
    if (protocol !== "https:" && protocol !== "http:") {
      console.error(`BLOCKED: Unsupported protocol: ${protocol}`);
      process.exit(2);
    }

    // ── プライベートIP/ホスト名のブロック ──
    const privatePatterns = [
      // IPv4 プライベート
      /^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$/,
      /^172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}$/,
      /^192\.168\.\d{1,3}\.\d{1,3}$/,
      // Loopback
      /^127\.\d{1,3}\.\d{1,3}\.\d{1,3}$/,
      /^localhost$/,
      /^0\.0\.0\.0$/,
      // Link-local
      /^169\.254\.\d{1,3}\.\d{1,3}$/,
      // IPv6
      /^::1$/,
      /^fe80:/i,
      /^fc00:/i,
      /^fd[0-9a-f]{2}:/i,
    ];

    for (const p of privatePatterns) {
      if (p.test(hostname)) {
        console.error(`BLOCKED: Private/internal network access: ${hostname}`);
        process.exit(2);
      }
    }

    // ── クラウドメタデータエンドポイントのブロック ──
    const metadataHosts = [
      "169.254.169.254", // AWS/GCP/Azure メタデータ
      "metadata.google.internal",
      "metadata.gke.internal",
      "100.100.100.200", // Alibaba Cloud
      "169.254.170.2", // ECS task metadata
    ];

    if (metadataHosts.includes(hostname)) {
      console.error(`BLOCKED: Cloud metadata endpoint: ${hostname}`);
      process.exit(2);
    }

    // ── 危険なパスのブロック ──
    const dangerousPaths = [
      /\/latest\/meta-data/i,
      /\/computeMetadata\//i,
      /\/metadata\/instance/i,
      /\/\.env/i,
      /\/\.git\//i,
      /\/etc\/passwd/i,
      /\/proc\//i,
    ];

    for (const p of dangerousPaths) {
      if (p.test(parsed.pathname)) {
        console.error(`BLOCKED: Dangerous path pattern: ${parsed.pathname}`);
        process.exit(2);
      }
    }

    // ── 許可ドメインリスト（オプション、厳格モード用） ──
    // 環境変数 SSRF_ALLOWED_DOMAINS でカンマ区切りで指定可能
    const allowedDomains = process.env.SSRF_ALLOWED_DOMAINS?.split(",").map(d => d.trim().toLowerCase()) || [];
    if (allowedDomains.length > 0) {
      const isAllowed = allowedDomains.some(d => {
        if (d.startsWith("*.")) {
          return hostname.endsWith(d.slice(1)) || hostname === d.slice(2);
        }
        return hostname === d;
      });
      if (!isAllowed) {
        console.error(`BLOCKED: Domain not in allowlist: ${hostname}`);
        process.exit(2);
      }
    }

    // ── 監査ログ ──
    const fs = require("fs");
    const path = require("path");
    const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
    const logDir = path.join(projectDir, ".claude/memory/local");
    try {
      if (!fs.existsSync(logDir)) {
        fs.mkdirSync(logDir, { recursive: true });
      }
      const logFile = path.join(logDir, "webfetch-audit.jsonl");
      const entry = {
        t: new Date().toISOString(),
        url: url,
        hostname: hostname,
        allowed: true,
      };
      fs.appendFileSync(logFile, JSON.stringify(entry) + "\n");
    } catch {}

    process.exit(0);
  } catch (e) {
    process.stderr.write(`ssrf-guard: ${e.message}\n`);
    process.exit(0);
  }
});
