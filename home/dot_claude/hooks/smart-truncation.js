#!/usr/bin/env node
/**
 * Smart Truncation Hook
 * - Intelligently truncates long output
 * - Preserves important information
 */

const fs = require("fs");
const path = require("path");

// Truncation settings
const CONFIG = {
  maxLines: 100,
  preserveFirstLines: 20,
  preserveLastLines: 30,
  preserveErrorLines: true,
  summaryEnabled: true,
};

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const output = data.output || "";

    if (!output) {
      process.exit(0);
    }

    const lines = output.split("\n");

    // Determine if truncation is needed
    if (lines.length <= CONFIG.maxLines) {
      process.exit(0);
    }

    // Identify error lines
    const errorIndices = [];
    if (CONFIG.preserveErrorLines) {
      lines.forEach((line, i) => {
        if (/error|exception|failed|fatal/i.test(line)) {
          // Preserve error lines and 2 surrounding lines
          for (
            let j = Math.max(0, i - 2);
            j <= Math.min(lines.length - 1, i + 2);
            j++
          ) {
            errorIndices.push(j);
          }
        }
      });
    }

    // Determine which lines to preserve
    const preservedIndices = new Set([
      ...Array.from({ length: CONFIG.preserveFirstLines }, (_, i) => i),
      ...Array.from(
        { length: CONFIG.preserveLastLines },
        (_, i) => lines.length - CONFIG.preserveLastLines + i,
      ),
      ...errorIndices,
    ]);

    // Generate truncated output
    const truncatedLines = [];
    let lastIncluded = -1;
    let omittedCount = 0;

    for (let i = 0; i < lines.length; i++) {
      if (preservedIndices.has(i)) {
        if (lastIncluded !== -1 && i - lastIncluded > 1) {
          truncatedLines.push(`... (${omittedCount} lines omitted) ...`);
          omittedCount = 0;
        }
        truncatedLines.push(lines[i]);
        lastIncluded = i;
      } else {
        omittedCount++;
      }
    }

    if (CONFIG.summaryEnabled) {
      console.log(
        `TRUNCATION: Output reduced from ${lines.length} to ${truncatedLines.length} lines`,
      );
    }

    // Return truncated output (as hook output)
    console.log(truncatedLines.join("\n"));
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
