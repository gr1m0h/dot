#!/usr/bin/env node
/**
 * Working Memory Manager
 * - Manages working memory during sessions
 * - Monitors context capacity
 * - Automatically promotes important information
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const workingMemoryDir = path.join(projectDir, ".claude/memory/working");
const contextFile = path.join(workingMemoryDir, "current-context.json");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const event = data.event || "";

    // Create directory
    if (!fs.existsSync(workingMemoryDir)) {
      fs.mkdirSync(workingMemoryDir, { recursive: true });
    }

    // Load current context
    let context = {
      items: [],
      capacity: 10, // Maximum 10 items
      lastUpdated: null,
    };

    if (fs.existsSync(contextFile)) {
      context = JSON.parse(fs.readFileSync(contextFile, "utf8"));
    }

    // Process based on event
    if (event === "TaskStart") {
      // Clear context when a new task starts
      context.items = [];
      context.currentTask = data.task_description || "unknown";
    }

    if (event === "ImportantInfo") {
      // Add important information to working memory
      const newItem = {
        content: data.content,
        timestamp: new Date().toISOString(),
        importance: data.importance || "medium",
        source: data.source || "unknown",
      };

      // Capacity check
      if (context.items.length >= context.capacity) {
        // Remove items with the lowest importance first
        context.items.sort((a, b) => {
          const importanceOrder = { low: 0, medium: 1, high: 2, critical: 3 };
          return importanceOrder[a.importance] - importanceOrder[b.importance];
        });
        context.items.shift();
      }

      context.items.push(newItem);
    }

    context.lastUpdated = new Date().toISOString();
    fs.writeFileSync(contextFile, JSON.stringify(context, null, 2));
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
