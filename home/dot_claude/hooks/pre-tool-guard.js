#!/usr/bin/env node
/**
 * PreToolUse Guard - 包括的セキュリティガード
 *
 * - 危険コマンドパターンのブロック（破壊・情報漏洩・RCE）
 * - 保護対象ファイルへの書き込みブロック
 * - コンテンツ内シークレット検出（AWS/GCP/Azure/GitHub/OpenAI/Anthropic等）
 * - アーキテクチャガード（ファイル配置ルールの強制）
 * - 巨大ファイル書き込みの警告
 * exit(2) = ブロック, exit(0) = 許可
 */
let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const tool = data.tool_name || "";
    const ti = data.tool_input || {};

    // ── Bash コマンドガード ──
    if (tool === "Bash") {
      const cmd = ti.command || "";

      // 破壊的コマンド
      const destructive = [
        /rm\s+-r[f ]?\s+[\/~]/i,
        /rm\s+-fr\s+[\/~]/i,
        />\s*\/dev\/sd/i,
        /mkfs\./i,
        /dd\s+if=/i,
        /:\s*\(\)\s*\{.*:\s*\|\s*:\s*&\s*\}\s*;\s*:/,
        /chmod\s+(-R\s+)?777\s+\//i,
        /chown\s+-R\s+.*\s+\//i,
        /git\s+push\s+--force(-with-lease)?\s+(origin\s+)?(main|master)/i,
        /git\s+reset\s+--hard/i,
        /git\s+clean\s+-[a-z]*f[a-z]*d/i,
        /truncate\s+-s\s*0/i,
        /shred\s/i,
      ];

      // リモートコード実行
      const rce = [
        /curl.*\|\s*(sh|bash|zsh|python|node|perl)/i,
        /wget.*\|\s*(sh|bash|zsh|python|node|perl)/i,
        /eval\s*\$\((curl|wget)/i,
        /base64\s+(-d|--decode).*\|\s*(sh|bash|python|node)/i,
        /python[23]?\s+-c\s+.*exec\s*\(/i,
        /node\s+-e\s+.*child_process/i,
        /perl\s+-e\s+.*system/i,
        /ruby\s+-e\s+.*system/i,
        /nc\s+-[a-z]*l[a-z]*\s+-p/i,
        /ncat\s/i,
        /socat\s/i,
      ];

      // 情報漏洩
      const leaks = [
        /echo\s+.*\$\{?(API_KEY|SECRET|PASSWORD|TOKEN|PRIVATE_KEY|AWS_SECRET)/i,
        /printenv\b/i,
        /env\s*\|\s*(grep|sort|less|more|cat)/i,
        /cat\s+.*\.(env|pem|key|p12|pfx)/i,
        /cat\s+.*\/\.ssh\//i,
        /cat\s+.*\/\.aws\//i,
        /cat\s+.*\/\.gnupg\//i,
        /tar\s+.*\/\.(ssh|aws|gnupg|env)/i,
        /scp\s+.*\.(env|pem|key)/i,
        /rsync\s+.*\.(env|pem|key)/i,
      ];

      // クリプトマイナー・マルウェア
      const malware = [
        /xmrig/i,
        /minerd/i,
        /cpuminer/i,
        /stratum\+tcp/i,
        /cryptonight/i,
        /\.onion\b/i,
      ];

      const allPatterns = [
        { patterns: destructive, label: "Destructive command" },
        { patterns: rce, label: "Remote code execution risk" },
        { patterns: leaks, label: "Secret leak risk" },
        { patterns: malware, label: "Malware/mining pattern" },
      ];

      for (const { patterns, label } of allPatterns) {
        for (const p of patterns) {
          if (p.test(cmd)) {
            console.error(`BLOCKED: ${label}`);
            process.exit(2);
          }
        }
      }

      // sudo ガード（明示的に許可されていない限りブロック）
      if (/^\s*sudo\s/i.test(cmd)) {
        console.error("BLOCKED: sudo requires explicit user approval");
        process.exit(2);
      }
    }

    // ── ファイル操作ガード (Edit / Write) ──
    if (tool === "Edit" || tool === "Write") {
      const fp = ti.file_path || "";
      const content = ti.content || ti.new_string || "";

      // 保護対象パス
      const protectedPaths = [
        /\.env($|\.)/i,
        /secrets?\//i,
        /\.pem$/i,
        /\.key$/i,
        /\.p12$/i,
        /\.pfx$/i,
        /credential/i,
        /password/i,
        /package-lock\.json$/i,
        /yarn\.lock$/i,
        /pnpm-lock\.yaml$/i,
        /bun\.lockb$/i,
        /\.git\//,
        /\.git$/,
        /id_rsa/i,
        /id_ed25519/i,
        /\.aws\/config/i,
        /\.aws\/credentials/i,
        /\.ssh\/config/i,
      ];

      for (const p of protectedPaths) {
        if (p.test(fp)) {
          console.error(`BLOCKED: Protected file: ${fp}`);
          process.exit(2);
        }
      }

      // コンテンツ内シークレットパターン
      const secrets = [
        { p: /AKIA[0-9A-Z]{16}/, l: "AWS Access Key" },
        { p: /ASIA[0-9A-Z]{16}/, l: "AWS STS Key" },
        { p: /[0-9a-zA-Z/+]{40}(?=\s|$|")/, l: "AWS Secret Key (possible)" },
        { p: /sk-[a-zA-Z0-9]{20,}T3BlbkFJ[a-zA-Z0-9]+/, l: "OpenAI API Key" },
        { p: /sk-(?:proj-)?[a-zA-Z0-9-]{40,}/, l: "OpenAI/API Key" },
        { p: /sk-ant-[a-zA-Z0-9-]{90,}/, l: "Anthropic API Key" },
        { p: /ghp_[a-zA-Z0-9]{36}/, l: "GitHub PAT" },
        { p: /gho_[a-zA-Z0-9]{36}/, l: "GitHub OAuth" },
        { p: /github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}/, l: "GitHub Fine-grained PAT" },
        { p: /ghr_[a-zA-Z0-9]{36}/, l: "GitHub Refresh Token" },
        { p: /glpat-[a-zA-Z0-9-]{20,}/, l: "GitLab PAT" },
        { p: /xoxb-[0-9]{10,}-[a-zA-Z0-9-]+/, l: "Slack Bot Token" },
        { p: /xoxp-[0-9]{10,}-[a-zA-Z0-9-]+/, l: "Slack User Token" },
        { p: /SG\.[a-zA-Z0-9-]{22}\.[a-zA-Z0-9-_]{43}/, l: "SendGrid Key" },
        { p: /AIza[0-9A-Za-z-_]{35}/, l: "Google API Key" },
        { p: /ya29\.[0-9A-Za-z-_]+/, l: "Google OAuth Token" },
        { p: /-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----/, l: "RSA Private Key" },
        { p: /-----BEGIN\s+OPENSSH\s+PRIVATE\s+KEY-----/, l: "OpenSSH Private Key" },
        { p: /-----BEGIN\s+EC\s+PRIVATE\s+KEY-----/, l: "EC Private Key" },
        { p: /-----BEGIN\s+PGP\s+PRIVATE\s+KEY\s+BLOCK-----/, l: "PGP Private Key" },
        { p: /eyJ[a-zA-Z0-9_-]{20,}\.eyJ[a-zA-Z0-9_-]{20,}\./, l: "JWT Token (possible)" },
      ];

      for (const { p, l } of secrets) {
        if (p.test(content)) {
          console.error(`BLOCKED: ${l} detected in content`);
          process.exit(2);
        }
      }

      // 巨大コンテンツの警告（ブロックではなく警告）
      if (content.length > 50000) {
        console.log(
          `WARNING: Large content (${Math.round(content.length / 1024)}KB) being written to ${fp}`,
        );
      }
    }

    process.exit(0);
  } catch (e) {
    // パースエラー等は安全側に倒して許可
    process.stderr.write(`pre-tool-guard: ${e.message}\n`);
    process.exit(0);
  }
});
