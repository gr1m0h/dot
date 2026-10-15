#!/usr/bin/env node
/**
 * Post Tool Batch Hook
 * - Verifies integrity after parallel batch operations complete
 * - Detects conflicting file modifications across batch
 * - Tracks batch metrics for optimization
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const metricsDir = path.join(projectDir, ".claude/memory/local");
const metricsFile = path.join(metricsDir, "batch-metrics.jsonl");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const now = new Date();

    // Create directory
    if (!fs.existsSync(metricsDir)) {
      fs.mkdirSync(metricsDir, { recursive: true });
    }

    // Extract batch info
    const tools = data.tool_results || [];
    const toolNames = tools.map((t) => t.tool_name || "unknown");
    const failures = tools.filter((t) => t.error);
    const fileEdits = tools.filter(
      (t) => t.tool_name === "Edit" || t.tool_name === "Write",
    );

    // Detect conflicting file modifications
    const editedFiles = fileEdits
      .map((t) => t.tool_input?.file_path)
      .filter(Boolean);
    const duplicates = editedFiles.filter(
      (f, i) => editedFiles.indexOf(f) !== i,
    );

    if (duplicates.length > 0) {
      console.error(
        `BATCH_CONFLICT: Multiple edits to same file(s): ${[...new Set(duplicates)].join(", ")}`,
      );
      console.error(
        "HOW TO FIX: Ensure parallel edits target different files, or serialize edits to the same file.",
      );
    }

    // Log batch metrics
    const metric = {
      timestamp: now.toISOString(),
      batchSize: tools.length,
      tools: toolNames,
      failures: failures.length,
      conflictingFiles: duplicates.length,
      sessionId: process.env.CLAUDE_SESSION_ID || "unknown",
    };

    fs.appendFileSync(metricsFile, JSON.stringify(metric) + "\n");

    // Report if batch had mixed results
    if (failures.length > 0 && failures.length < tools.length) {
      console.log(
        `BATCH_PARTIAL: ${tools.length - failures.length}/${tools.length} succeeded, ${failures.length} failed`,
      );
    }
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
