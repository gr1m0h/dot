#!/usr/bin/env node
/**
 * Circuit Breaker Hook
 * - Tracks tool/agent failures
 * - Opens circuit when threshold is exceeded
 * - Supports gradual recovery
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const stateFile = path.join(
  projectDir,
  ".claude/memory/local/circuit-breaker-state.json",
);

// Default configuration
const CONFIG = {
  failureThreshold: 3, // Open after consecutive failures
  successThreshold: 2, // Close after consecutive successes
  openTimeoutMs: 30000, // Duration of OPEN state
  halfOpenMaxAttempts: 3, // Maximum attempts in Half-Open
};

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name || "unknown";
    const success = !data.error;

    // Create state file directory
    const stateDir = path.dirname(stateFile);
    if (!fs.existsSync(stateDir)) {
      fs.mkdirSync(stateDir, { recursive: true });
    }

    // Load current state
    let state = {};
    if (fs.existsSync(stateFile)) {
      state = JSON.parse(fs.readFileSync(stateFile, "utf8"));
    }

    // Initialize per-tool state
    if (!state[toolName]) {
      state[toolName] = {
        status: "CLOSED",
        consecutiveFailures: 0,
        consecutiveSuccesses: 0,
        lastFailure: null,
        openedAt: null,
        totalFailures: 0,
        totalSuccesses: 0,
      };
    }

    const toolState = state[toolName];
    const now = Date.now();

    // State transition logic
    switch (toolState.status) {
      case "CLOSED":
        if (success) {
          toolState.consecutiveFailures = 0;
          toolState.consecutiveSuccesses++;
          toolState.totalSuccesses++;
        } else {
          toolState.consecutiveFailures++;
          toolState.consecutiveSuccesses = 0;
          toolState.lastFailure = now;
          toolState.totalFailures++;

          if (toolState.consecutiveFailures >= CONFIG.failureThreshold) {
            toolState.status = "OPEN";
            toolState.openedAt = now;
            console.log(
              `CIRCUIT_BREAKER: ${toolName} circuit OPENED after ${toolState.consecutiveFailures} failures`,
            );
            console.log(`DEGRADATION: Fallback mode activated for ${toolName}`);
          }
        }
        break;

      case "OPEN":
        // Transition to Half-Open after timeout
        if (now - toolState.openedAt >= CONFIG.openTimeoutMs) {
          toolState.status = "HALF_OPEN";
          toolState.halfOpenAttempts = 0;
          console.log(
            `CIRCUIT_BREAKER: ${toolName} circuit moved to HALF-OPEN (probing)`,
          );
        } else {
          // Still in OPEN state
          const remainingMs = CONFIG.openTimeoutMs - (now - toolState.openedAt);
          console.log(
            `CIRCUIT_BREAKER: ${toolName} circuit still OPEN. Retry in ${Math.ceil(remainingMs / 1000)}s`,
          );
          console.log(`BLOCKED: Tool ${toolName} is currently unavailable`);
          process.exit(2); // Block
        }
        break;

      case "HALF_OPEN":
        toolState.halfOpenAttempts = (toolState.halfOpenAttempts || 0) + 1;

        if (success) {
          toolState.consecutiveSuccesses++;
          toolState.consecutiveFailures = 0;

          if (toolState.consecutiveSuccesses >= CONFIG.successThreshold) {
            toolState.status = "CLOSED";
            toolState.openedAt = null;
            console.log(
              `CIRCUIT_BREAKER: ${toolName} circuit CLOSED (recovered)`,
            );
          }
        } else {
          toolState.consecutiveFailures++;
          toolState.consecutiveSuccesses = 0;
          toolState.totalFailures++;

          if (toolState.halfOpenAttempts >= CONFIG.halfOpenMaxAttempts) {
            toolState.status = "OPEN";
            toolState.openedAt = now;
            console.log(
              `CIRCUIT_BREAKER: ${toolName} circuit re-OPENED after probe failures`,
            );
          }
        }
        break;
    }

    // Save state
    state[toolName] = toolState;
    fs.writeFileSync(stateFile, JSON.stringify(state, null, 2));
  } catch (error) {
    // Ignore errors (to prevent the circuit breaker itself from failing)
  }

  process.exit(0);
});
