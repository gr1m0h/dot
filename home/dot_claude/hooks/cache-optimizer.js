#!/usr/bin/env node
/**
 * Cache Optimizer Hook
 * - Maintains cache-friendly context structure
 * - Monitors prefix stability
 */

const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const cacheStateFile = path.join(
  projectDir,
  ".claude/memory/local/cache-state.json",
);

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const event = data.event || "";

    // Create directory
    const cacheDir = path.dirname(cacheStateFile);
    if (!fs.existsSync(cacheDir)) {
      fs.mkdirSync(cacheDir, { recursive: true });
    }

    // Load state
    let cacheState = {
      staticSectionHash: null,
      lastCheck: null,
      cacheHitEstimate: 0,
      warnings: [],
    };

    if (fs.existsSync(cacheStateFile)) {
      cacheState = JSON.parse(fs.readFileSync(cacheStateFile, "utf8"));
    }

    if (event === "SessionStart") {
      // Calculate hash of CLAUDE.md static sections
      const claudeFile = path.join(projectDir, ".claude/CLAUDE.md");

      if (fs.existsSync(claudeFile)) {
        const content = fs.readFileSync(claudeFile, "utf8");

        // Extract static sections (parts enclosed by [STATIC] markers)
        const staticMatch = content.match(
          /## \[STATIC\][\s\S]*?(?=## \[SEMI-STATIC\]|## \[DYNAMIC\]|$)/g,
        );
        const staticContent = staticMatch
          ? staticMatch.join("")
          : content.substring(0, 2000);

        const newHash = crypto
          .createHash("md5")
          .update(staticContent)
          .digest("hex");

        if (
          cacheState.staticSectionHash &&
          cacheState.staticSectionHash !== newHash
        ) {
          console.log(
            `CACHE_WARNING: Static section changed. Cache invalidation likely.`,
          );
          console.log(
            `HINT: Minimize changes to [STATIC] sections for better cache performance.`,
          );
          cacheState.warnings.push({
            time: new Date().toISOString(),
            type: "static_section_change",
          });
        }

        cacheState.staticSectionHash = newHash;
      }
    }

    if (event === "ContextUpdate") {
      // Estimate cache efficiency during context update
      const changePosition = data.change_position || 0;
      const totalLength = data.total_length || 1;

      // Cache hit rate is higher when changes are further back
      const estimatedHitRate = changePosition / totalLength;
      cacheState.cacheHitEstimate = estimatedHitRate;

      if (estimatedHitRate < 0.5) {
        console.log(
          `CACHE_WARNING: Change at early position (${((changePosition / totalLength) * 100).toFixed(1)}%).`,
        );
        console.log(
          `HINT: Move dynamic content to the end of context for better caching.`,
        );
      }
    }

    cacheState.lastCheck = new Date().toISOString();
    fs.writeFileSync(cacheStateFile, JSON.stringify(cacheState, null, 2));
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
