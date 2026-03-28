#!/usr/bin/env node
/**
 * Hook: pre-compact-protector
 * Event: PreCompact
 * Purpose: Preserve critical context before compaction.
 * Always exit 0, outputs additionalContext with session state.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (chunk) => { data += chunk; });
    process.stdin.on('end', () => {
      try { resolve(JSON.parse(data)); }
      catch { resolve({}); }
    });
    setTimeout(() => resolve({}), 3000);
  });
}

function safeReadFile(filePath) {
  try { return fs.readFileSync(filePath, 'utf8'); }
  catch { return null; }
}

function safeExec(cmd) {
  try { return execSync(cmd, { encoding: 'utf8', timeout: 5000, stdio: ['pipe', 'pipe', 'pipe'] }).trim(); }
  catch { return null; }
}

function getSessionState() {
  const stateFile = path.resolve('.claude', 'memory', 'local', 'session-state.json');
  const raw = safeReadFile(stateFile);
  if (!raw) return null;
  try { return JSON.parse(raw); }
  catch { return null; }
}

function getRecentLearnings(count) {
  const learningsFile = path.resolve('.claude', 'memory', 'local', 'learnings.md');
  const raw = safeReadFile(learningsFile);
  if (!raw) return [];

  // Split by ## headers to get individual entries
  const entries = raw.split(/^## /m).filter(Boolean).slice(-count);
  return entries.map((e) => `## ${e.trim()}`);
}

function getGitContext() {
  const branch = safeExec('git branch --show-current');
  const dirtyCount = safeExec('git status --porcelain 2>/dev/null | wc -l');
  const recentCommits = safeExec('git log --oneline -5 2>/dev/null');

  return { branch, dirtyCount: dirtyCount ? parseInt(dirtyCount.trim(), 10) : 0, recentCommits };
}

async function main() {
  await readStdin();

  const sections = [];
  sections.push('=== Pre-Compaction Context Snapshot ===');
  sections.push(`Timestamp: ${new Date().toISOString()}`);

  // Current task from env
  const currentTask = process.env.CURRENT_TASK;
  if (currentTask) {
    sections.push(`\nCurrent Task: ${currentTask}`);
  }

  // Git context
  const git = getGitContext();
  if (git.branch) {
    sections.push(`\nGit Branch: ${git.branch}`);
    if (git.dirtyCount > 0) {
      sections.push(`Dirty Files: ${git.dirtyCount}`);
    }
    if (git.recentCommits) {
      sections.push(`Recent Commits:\n${git.recentCommits}`);
    }
  }

  // Session state
  const state = getSessionState();
  if (state) {
    sections.push('\nSession State:');
    if (state.currentPhase) sections.push(`  Phase: ${state.currentPhase}`);
    if (state.activeFiles) sections.push(`  Active Files: ${JSON.stringify(state.activeFiles)}`);
    if (state.decisions) {
      sections.push('  Key Decisions:');
      for (const d of state.decisions.slice(-5)) {
        sections.push(`    - ${typeof d === 'string' ? d : JSON.stringify(d)}`);
      }
    }
    if (state.pendingItems) {
      sections.push('  Pending Items:');
      for (const p of state.pendingItems) {
        sections.push(`    - ${typeof p === 'string' ? p : JSON.stringify(p)}`);
      }
    }
  }

  // Recent learnings
  const learnings = getRecentLearnings(5);
  if (learnings.length > 0) {
    sections.push('\nRecent Learnings (preserve these):');
    sections.push(learnings.join('\n\n'));
  }

  sections.push('\n==========================================');

  const context = sections.join('\n');
  console.log(JSON.stringify({ additionalContext: context }));
}

main().catch(() => {});
