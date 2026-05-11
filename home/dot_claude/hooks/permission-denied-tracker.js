#!/usr/bin/env node
/**
 * Permission Denied Tracker Hook
 * - Tracks denied tool calls to identify permission gaps
 * - Logs patterns for settings.json optimization
 * - Suggests permission adjustments after repeated denials
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const dataDir = path.join(projectDir, ".claude/memory/local");
const trackFile = path.join(dataDir, "permission-denials.jsonl");
const summaryFile = path.join(dataDir, "permission-denial-summary.json");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const now = new Date();

    // Create directory
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }

    // Log denial event
    const event = {
      timestamp: now.toISOString(),
      toolName: data.tool_name || "unknown",
      toolInput: sanitizeInput(data.tool_input || {}),
      sessionId: process.env.CLAUDE_SESSION_ID || "unknown",
    };

    fs.appendFileSync(trackFile, JSON.stringify(event) + "\n");

    // Update summary for pattern analysis
    let summary = { denials: {}, lastUpdated: null };
    if (fs.existsSync(summaryFile)) {
      summary = JSON.parse(fs.readFileSync(summaryFile, "utf8"));
    }

    const key = buildDenialKey(data);
    if (!summary.denials[key]) {
      summary.denials[key] = { count: 0, firstSeen: now.toISOString() };
    }
    summary.denials[key].count++;
    summary.denials[key].lastSeen = now.toISOString();
    summary.lastUpdated = now.toISOString();

    // Suggest permission adjustment if denied 3+ times
    if (summary.denials[key].count >= 3) {
      console.log(
        `PERMISSION_PATTERN: "${key}" denied ${summary.denials[key].count} times.`,
      );
      console.log(
        `Consider adding to permissions.allow or permissions.ask in settings.json.`,
      );
    }

    fs.writeFileSync(summaryFile, JSON.stringify(summary, null, 2));
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});

function buildDenialKey(data) {
  const tool = data.tool_name || "unknown";
  const input = data.tool_input || {};

  if (tool === "Bash" && input.command) {
    // Extract command prefix (first word)
    const cmd = input.command.trim().split(/\s+/)[0];
    return `Bash(${cmd} *)`;
  }
  if ((tool === "Read" || tool === "Edit" || tool === "Write") && input.file_path) {
    // Extract directory pattern
    const dir = path.dirname(input.file_path);
    return `${tool}(${dir}/**)`;
  }
  return `${tool}(*)`;
}

function sanitizeInput(input) {
  // Remove potentially sensitive data from logged input
  const sanitized = { ...input };
  if (sanitized.content) sanitized.content = "[REDACTED]";
  if (sanitized.new_string) sanitized.new_string = "[REDACTED]";
  if (sanitized.old_string) sanitized.old_string = "[REDACTED]";
  return sanitized;
}
