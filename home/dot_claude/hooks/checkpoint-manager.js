#!/usr/bin/env node
/**
 * Checkpoint Manager
 * - Saves checkpoints of task progress
 * - Resumes from latest checkpoint when failures occur
 */

const fs = require("fs");
const path = require("path");

const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const checkpointDir = path.join(projectDir, ".claude/memory/local/checkpoints");

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  try {
    const data = JSON.parse(input);
    const event = data.event || "";

    // Create directory
    if (!fs.existsSync(checkpointDir)) {
      fs.mkdirSync(checkpointDir, { recursive: true });
    }

    if (event === "CreateCheckpoint") {
      // Create checkpoint
      const checkpoint = {
        id: `cp-${Date.now()}`,
        timestamp: new Date().toISOString(),
        taskId: data.task_id,
        phase: data.phase,
        completedSteps: data.completed_steps || [],
        pendingSteps: data.pending_steps || [],
        state: data.state || {},
        recoverable: true,
      };

      const checkpointFile = path.join(checkpointDir, `${checkpoint.id}.json`);
      fs.writeFileSync(checkpointFile, JSON.stringify(checkpoint, null, 2));

      // Update link to latest checkpoint
      const latestFile = path.join(checkpointDir, "latest.json");
      fs.writeFileSync(
        latestFile,
        JSON.stringify({ latest: checkpoint.id }, null, 2),
      );

      console.log(
        `CHECKPOINT: Created ${checkpoint.id} at phase "${data.phase}"`,
      );
    }

    if (event === "RecoverFromCheckpoint") {
      // Restore from latest checkpoint
      const latestFile = path.join(checkpointDir, "latest.json");

      if (fs.existsSync(latestFile)) {
        const latest = JSON.parse(fs.readFileSync(latestFile, "utf8"));
        const checkpointFile = path.join(
          checkpointDir,
          `${latest.latest}.json`,
        );

        if (fs.existsSync(checkpointFile)) {
          const checkpoint = JSON.parse(
            fs.readFileSync(checkpointFile, "utf8"),
          );

          console.log(`RECOVERY: Restoring from checkpoint ${checkpoint.id}`);
          console.log(`RECOVERY: Phase: ${checkpoint.phase}`);
          console.log(
            `RECOVERY: Completed: ${checkpoint.completedSteps.length} steps`,
          );
          console.log(
            `RECOVERY: Pending: ${checkpoint.pendingSteps.length} steps`,
          );

          // Output restoration information
          console.log(
            `CONTEXT_REMINDER: Resume from phase "${checkpoint.phase}"`,
          );
          if (checkpoint.pendingSteps.length > 0) {
            console.log(
              `CONTEXT_REMINDER: Next steps: ${checkpoint.pendingSteps.slice(0, 3).join(", ")}`,
            );
          }
        }
      } else {
        console.log(`RECOVERY: No checkpoint found. Starting fresh.`);
      }
    }
  } catch (error) {
    // Ignore errors
  }

  process.exit(0);
});
