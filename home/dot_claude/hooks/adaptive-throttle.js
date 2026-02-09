#!/usr/bin/env node
/**
 * Adaptive Throttle Hook
 * - Tracks token usage
 * - Auto-adjusts based on usage patterns
 * - Balances burst tolerance with long-term limits
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const usageFile = path.join(projectDir, ".claude/memory/local/api-usage.json");

// Configuration
const CONFIG = {
  // Short-term burst limit (1 minute)
  burstWindow: 60000,
  burstLimit: 20,

  // Medium-term limit (5 minutes)
  mediumWindow: 300000,
  mediumLimit: 50,

  // Long-term limit (1 hour)
  longWindow: 3600000,
  longLimit: 200,

  // Backoff settings
  baseDelayMs: 1000,
  maxDelayMs: 30000,

  // Adaptive adjustment
  adaptiveEnabled: true,
  successRateThreshold: 0.8, // Tighten limits when success rate drops below this
};

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const toolName = data.tool_name || "unknown";
    const now = Date.now();

    // Create directory
    const usageDir = path.dirname(usageFile);
    if (!fs.existsSync(usageDir)) {
      fs.mkdirSync(usageDir, { recursive: true });
    }

    // Load usage data
    let usage = {
      calls: [],
      successCount: 0,
      failureCount: 0,
      currentDelay: 0,
      lastCall: null,
    };

    if (fs.existsSync(usageFile)) {
      usage = JSON.parse(fs.readFileSync(usageFile, "utf8"));
    }

    // Remove old entries (older than 1 hour)
    usage.calls = usage.calls.filter(
      (call) => now - call.timestamp < CONFIG.longWindow,
    );

    // Count calls in each window
    const burstCalls = usage.calls.filter(
      (c) => now - c.timestamp < CONFIG.burstWindow,
    ).length;
    const mediumCalls = usage.calls.filter(
      (c) => now - c.timestamp < CONFIG.mediumWindow,
    ).length;
    const longCalls = usage.calls.length;

    // Calculate success rate
    const totalCalls = usage.successCount + usage.failureCount;
    const successRate = totalCalls > 0 ? usage.successCount / totalCalls : 1;

    // Adaptive limit adjustment
    let effectiveBurstLimit = CONFIG.burstLimit;
    let effectiveMediumLimit = CONFIG.mediumLimit;

    if (CONFIG.adaptiveEnabled && successRate < CONFIG.successRateThreshold) {
      // Tighten limits when success rate is low
      const reductionFactor = successRate / CONFIG.successRateThreshold;
      effectiveBurstLimit = Math.floor(CONFIG.burstLimit * reductionFactor);
      effectiveMediumLimit = Math.floor(CONFIG.mediumLimit * reductionFactor);
      console.log(
        `THROTTLE: Adaptive limit reduction (success rate: ${(successRate * 100).toFixed(1)}%)`,
      );
    }

    // Limit check
    let shouldThrottle = false;
    let throttleReason = "";
    let suggestedDelay = 0;

    if (burstCalls >= effectiveBurstLimit) {
      shouldThrottle = true;
      throttleReason = "burst limit";
      suggestedDelay =
        CONFIG.burstWindow -
        (now - usage.calls[usage.calls.length - effectiveBurstLimit].timestamp);
    } else if (mediumCalls >= effectiveMediumLimit) {
      shouldThrottle = true;
      throttleReason = "medium-term limit";
      suggestedDelay =
        CONFIG.mediumWindow -
        (now -
          usage.calls[usage.calls.length - effectiveMediumLimit].timestamp);
    } else if (longCalls >= CONFIG.longLimit) {
      shouldThrottle = true;
      throttleReason = "long-term limit";
      suggestedDelay = CONFIG.longWindow - (now - usage.calls[0].timestamp);
    }

    if (shouldThrottle) {
      // Exponential backoff
      usage.currentDelay = Math.min(
        usage.currentDelay * 2 || CONFIG.baseDelayMs,
        CONFIG.maxDelayMs,
      );

      console.log(`THROTTLE: Rate limit approaching (${throttleReason})`);
      console.log(
        `THROTTLE: Suggested delay: ${Math.ceil(suggestedDelay / 1000)}s`,
      );
      console.log(
        `HINT: Consider batching operations or using /clear to reduce context`,
      );

      // Warning only (do not block)
    } else {
      // Reset delay on success
      usage.currentDelay = 0;
    }

    // Record the call
    usage.calls.push({
      timestamp: now,
      tool: toolName,
      success: !data.error,
    });

    // Update success/failure count
    if (data.error) {
      usage.failureCount++;
    } else {
      usage.successCount++;
    }

    usage.lastCall = now;

    // Save usage data
    fs.writeFileSync(usageFile, JSON.stringify(usage, null, 2));

    // Output usage summary (for debugging)
    if (process.env.DEBUG_THROTTLE) {
      console.log(
        `DEBUG: Burst ${burstCalls}/${effectiveBurstLimit}, Medium ${mediumCalls}/${effectiveMediumLimit}, Long ${longCalls}/${CONFIG.longLimit}`,
      );
    }
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
