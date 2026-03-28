#!/usr/bin/env node
/**
 * Hook: prompt-validator
 * Event: UserPromptSubmit
 * Purpose: Validate user prompts for clarity and inject guidance when issues detected.
 * Non-blocking (always exit 0), only injects additionalContext.
 */

const fs = require('fs');

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

const INJECTION_PATTERNS = [
  /ignore\s+(all\s+)?(previous|above|prior)\s+(instructions|prompts)/i,
  /you\s+are\s+now\s+/i,
  /system\s*:\s*/i,
  /\<\/?system\>/i,
  /pretend\s+you\s+are/i,
  /act\s+as\s+if\s+you/i,
  /forget\s+(everything|all|your)\s+(you|instructions|rules)/i,
  /override\s+(your|the|all)\s+(instructions|rules|settings)/i,
];

function validatePrompt(prompt) {
  const warnings = [];

  if (!prompt || typeof prompt !== 'string') {
    return warnings;
  }

  const trimmed = prompt.trim();
  const wordCount = trimmed.split(/\s+/).filter(Boolean).length;

  // Check overly vague prompts
  if (wordCount < 3 && !trimmed.startsWith('/')) {
    warnings.push('Prompt is very short. Consider adding more context for better results.');
  }

  // Check for potential injection patterns
  for (const pattern of INJECTION_PATTERNS) {
    if (pattern.test(trimmed)) {
      warnings.push('Prompt contains a pattern that may conflict with system instructions.');
      break;
    }
  }

  // Check for token budget warning
  if (trimmed.length > 2000) {
    warnings.push(
      `Prompt is ${trimmed.length} characters. Consider breaking into smaller requests for better focus.`
    );
  }

  // Check for prompts with no verb (likely incomplete)
  if (wordCount >= 3 && wordCount <= 6) {
    const hasVerb = /\b(fix|add|update|create|delete|remove|change|implement|refactor|debug|test|check|find|search|show|explain|help|run|build|deploy|configure|setup|install|move|rename|merge|revert|write|read|analyze|review|scan|audit)\b/i.test(trimmed);
    if (!hasVerb && !trimmed.startsWith('/') && !trimmed.endsWith('?')) {
      warnings.push('Consider starting with an action verb (fix, add, update, etc.) for clearer intent.');
    }
  }

  return warnings;
}

async function main() {
  const input = await readStdin();
  const prompt = input.user_prompt || '';
  const warnings = validatePrompt(prompt);

  if (warnings.length > 0) {
    const context = [
      '--- Prompt Validation Hints ---',
      ...warnings.map((w) => `- ${w}`),
      '-------------------------------',
    ].join('\n');
    console.log(JSON.stringify({ additionalContext: context }));
  }
}

main().catch(() => {});
