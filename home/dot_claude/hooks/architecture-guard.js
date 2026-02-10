#!/usr/bin/env node
/**
 * Hook: architecture-guard
 * Event: PostToolUse (matcher: Edit|Write)
 * Purpose: Detect architecture violations after code changes.
 * Non-blocking (exit 0), informational only via additionalContext.
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

// Layer violation rules: [source pattern, forbidden import pattern, message]
const LAYER_RULES = [
  {
    source: /\/(tests?|spec|__tests__)\//,
    forbidden: /from\s+['"]\.\.\/src\/.*\/internal/,
    message: 'Test file imports from src internals. Use public API instead.',
  },
  {
    source: /\/(frontend|client|components|pages)\//,
    forbidden: /from\s+['"](\.\.\/)*(?:backend|server|api\/internal)/,
    message: 'Frontend imports from backend. Use API layer instead.',
  },
  {
    source: /\/(backend|server|api)\//,
    forbidden: /from\s+['"](\.\.\/)*(?:frontend|client|components|pages)\//,
    message: 'Backend imports from frontend. This breaks separation of concerns.',
  },
];

// Forbidden import patterns
const FORBIDDEN_IMPORTS = [
  {
    pattern: /from\s+['"](\.\.\/?){4,}/,
    message: 'Deep relative import (4+ levels). Consider using path aliases or restructuring.',
  },
  {
    pattern: /from\s+['"]node_modules\//,
    message: 'Direct import from node_modules/. Use package name instead.',
  },
  {
    pattern: /require\s*\(\s*['"]node_modules\//,
    message: 'Direct require from node_modules/. Use package name instead.',
  },
];

// File placement rules
const PLACEMENT_RULES = [
  {
    filePattern: /\/(utils?|helpers?|lib)\/.+\.(tsx|jsx)$/,
    message: 'React component in utils/. Components should be in components/ or a feature directory.',
  },
  {
    filePattern: /\/(components|pages)\/.+\.(sql|prisma)$/,
    message: 'Database file in UI layer. Database files belong in db/, prisma/, or migrations/.',
  },
  {
    filePattern: /\/(routes?|api)\/.+\.css$/,
    message: 'CSS file in API/routes directory. Styles belong in styles/, css/, or alongside components.',
  },
];

function checkFile(filePath, content) {
  const warnings = [];

  // Check layer violations
  for (const rule of LAYER_RULES) {
    if (rule.source.test(filePath) && rule.forbidden.test(content)) {
      warnings.push(`[Layer Violation] ${rule.message}`);
    }
  }

  // Check forbidden imports
  for (const rule of FORBIDDEN_IMPORTS) {
    if (rule.pattern.test(content)) {
      warnings.push(`[Import] ${rule.message}`);
    }
  }

  // Check file placement
  for (const rule of PLACEMENT_RULES) {
    if (rule.filePattern.test(filePath)) {
      warnings.push(`[Placement] ${rule.message}`);
    }
  }

  return warnings;
}

async function main() {
  const input = await readStdin();
  const filePath = input.tool_input?.file_path || input.tool_input?.filePath || '';

  if (!filePath) return;

  // Skip non-source files
  if (/\.(md|json|yaml|yml|toml|lock|txt|log|csv)$/i.test(filePath)) return;
  if (/node_modules|\.git|dist|build|\.next|__pycache__/.test(filePath)) return;

  let content = '';
  try {
    const absPath = path.isAbsolute(filePath) ? filePath : path.resolve(filePath);
    content = fs.readFileSync(absPath, 'utf8');
  } catch {
    return;
  }

  const warnings = checkFile(filePath, content);

  if (warnings.length > 0) {
    const context = [
      '--- Architecture Guard ---',
      `File: ${filePath}`,
      ...warnings.map((w) => `⚠ ${w}`),
      '--------------------------',
    ].join('\n');
    console.log(JSON.stringify({ additionalContext: context }));
  }
}

main().catch(() => {});
