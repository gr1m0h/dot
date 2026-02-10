#!/usr/bin/env node
/**
 * Telemetry Collector Hook
 * - OpenTelemetry-compatible trace/metrics collection
 * - Tool execution visualization
 * - Performance analysis
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const telemetryDir = path.join(projectDir, ".claude/telemetry");
const tracesFile = path.join(telemetryDir, "traces.jsonl");
const metricsFile = path.join(telemetryDir, "metrics.json");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const now = new Date();

    // Create directory
    if (!fs.existsSync(telemetryDir)) {
      fs.mkdirSync(telemetryDir, { recursive: true });
    }

    // OpenTelemetry-compatible Span format
    const span = {
      traceId: data.trace_id || generateTraceId(),
      spanId: generateSpanId(),
      parentSpanId: data.parent_span_id || null,
      name: `claude.tool.${data.tool_name || "unknown"}`,
      kind: "INTERNAL",
      startTime: data.start_time || now.toISOString(),
      endTime: now.toISOString(),
      attributes: {
        "gen_ai.system": "claude",
        "gen_ai.tool.name": data.tool_name || "unknown",
        "gen_ai.tool.success": !data.error,
        "gen_ai.session.id": process.env.CLAUDE_SESSION_ID || "unknown",
        "gen_ai.project.dir": projectDir,
      },
      status: data.error
        ? { code: "ERROR", message: data.error }
        : { code: "OK" },
      events: [],
    };

    // Add tool-specific attributes
    if (data.tool_input) {
      if (data.tool_input.command) {
        span.attributes["gen_ai.bash.command"] =
          data.tool_input.command.substring(0, 100);
      }
      if (data.tool_input.file_path) {
        span.attributes["gen_ai.file.path"] = data.tool_input.file_path;
      }
    }

    // Append trace in JSONL format
    fs.appendFileSync(tracesFile, JSON.stringify(span) + "\n");

    // Update metrics
    let metrics = {
      toolCalls: {},
      totalCalls: 0,
      totalErrors: 0,
      avgDuration: 0,
      lastUpdated: null,
    };

    if (fs.existsSync(metricsFile)) {
      metrics = JSON.parse(fs.readFileSync(metricsFile, "utf8"));
    }

    const toolName = data.tool_name || "unknown";
    if (!metrics.toolCalls[toolName]) {
      metrics.toolCalls[toolName] = { calls: 0, errors: 0, totalDuration: 0 };
    }

    metrics.toolCalls[toolName].calls++;
    metrics.totalCalls++;

    if (data.error) {
      metrics.toolCalls[toolName].errors++;
      metrics.totalErrors++;
    }

    // Calculate execution time (if available)
    if (data.start_time) {
      const duration = now.getTime() - new Date(data.start_time).getTime();
      metrics.toolCalls[toolName].totalDuration += duration;
    }

    metrics.lastUpdated = now.toISOString();

    fs.writeFileSync(metricsFile, JSON.stringify(metrics, null, 2));
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});

function generateTraceId() {
  return [...Array(32)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");
}

function generateSpanId() {
  return [...Array(16)]
    .map(() => Math.floor(Math.random() * 16).toString(16))
    .join("");
}
