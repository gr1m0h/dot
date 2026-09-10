#!/usr/bin/env node
/**
 * Hook: subagent-monitor
 * Event: SubagentStart, SubagentStop (async: true)
 * Purpose: Monitor subagent lifecycle for metrics and optimization.
 * Pure logging hook, no additionalContext output.
 */

const fs = require('fs');
const path = require('path');

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

const METRICS_DIR = path.resolve('.claude', 'memory', 'local');
const METRICS_FILE = path.join(METRICS_DIR, 'agent-metrics.jsonl');
const MAX_ENTRIES = 200;

function ensureDir() {
  try { fs.mkdirSync(METRICS_DIR, { recursive: true }); }
  catch {}
}

function appendEntry(entry) {
  ensureDir();
  try {
    fs.appendFileSync(METRICS_FILE, JSON.stringify(entry) + '\n');
  } catch {}
}

function rotateIfNeeded() {
  try {
    const content = fs.readFileSync(METRICS_FILE, 'utf8');
    const lines = content.split('\n').filter(Boolean);
    if (lines.length > MAX_ENTRIES) {
      const kept = lines.slice(-Math.floor(MAX_ENTRIES / 2));
      fs.writeFileSync(METRICS_FILE, kept.join('\n') + '\n');
    }
  } catch {}
}

function findStartRecord(agentId) {
  try {
    const content = fs.readFileSync(METRICS_FILE, 'utf8');
    const lines = content.split('\n').filter(Boolean).reverse();
    for (const line of lines) {
      const entry = JSON.parse(line);
      if (entry.event === 'start' && entry.agentId === agentId) {
        return entry;
      }
    }
  } catch {}
  return null;
}

async function main() {
  const input = await readStdin();

  // Determine event type from hook_event_name or session_id presence
  const hookEvent = input.hook_event_name || '';
  const agentId = input.agent_id || input.subagent_id || 'unknown';
  const agentName = input.agent_name || input.subagent_name || '';
  const agentType = input.agent_type || input.subagent_type || '';

  if (hookEvent === 'SubagentStart' || hookEvent === 'subagent_start') {
    appendEntry({
      event: 'start',
      timestamp: new Date().toISOString(),
      agentId,
      agentName,
      agentType,
    });
  } else if (hookEvent === 'SubagentStop' || hookEvent === 'subagent_stop') {
    const startRecord = findStartRecord(agentId);
    const duration = startRecord
      ? Date.now() - new Date(startRecord.timestamp).getTime()
      : null;

    appendEntry({
      event: 'stop',
      timestamp: new Date().toISOString(),
      agentId,
      agentName: agentName || (startRecord && startRecord.agentName) || '',
      agentType: agentType || (startRecord && startRecord.agentType) || '',
      durationMs: duration,
      status: input.status || 'completed',
    });

    rotateIfNeeded();
  }
}

main().catch(() => {});
