#!/usr/bin/env node
/**
 * Hook: test-runner
 * Event: PostToolUse (matcher: Edit|Write, async: true)
 * Purpose: Auto-run related tests after source file changes.
 * Non-blocking background hook.
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

const SKIP_EXTENSIONS = /\.(md|json|yaml|yml|toml|lock|txt|log|csv|svg|png|jpg|gif|ico|env)$/i;
const SKIP_PATHS = /node_modules|\.git|dist|build|\.next|__pycache__|\.claude/;

function findTestFile(srcPath) {
  const dir = path.dirname(srcPath);
  const ext = path.extname(srcPath);
  const base = path.basename(srcPath, ext);

  // Common test file patterns
  const candidates = [
    // Same directory patterns
    path.join(dir, `${base}.test${ext}`),
    path.join(dir, `${base}.spec${ext}`),
    path.join(dir, `${base}_test${ext}`),
    // __tests__ directory
    path.join(dir, '__tests__', `${base}.test${ext}`),
    path.join(dir, '__tests__', `${base}${ext}`),
    // tests/ parallel structure
    srcPath.replace(/^src\//, 'tests/').replace(ext, `.test${ext}`),
    srcPath.replace(/^src\//, 'test/').replace(ext, `.test${ext}`),
    srcPath.replace(/^lib\//, 'tests/').replace(ext, `.test${ext}`),
    srcPath.replace(/^app\//, 'tests/').replace(ext, `.test${ext}`),
    // spec/ parallel structure
    srcPath.replace(/^src\//, 'spec/').replace(ext, `.spec${ext}`),
    // Python patterns
    srcPath.replace(/^src\//, 'tests/test_'),
    path.join(dir, `test_${base}${ext}`),
  ];

  for (const candidate of candidates) {
    const absCandidate = path.isAbsolute(candidate) ? candidate : path.resolve(candidate);
    if (fs.existsSync(absCandidate)) {
      return absCandidate;
    }
  }

  // If the file IS a test file, return itself
  if (/\.(test|spec)\.|test_|_test\./.test(srcPath)) {
    const absSrc = path.isAbsolute(srcPath) ? srcPath : path.resolve(srcPath);
    if (fs.existsSync(absSrc)) return absSrc;
  }

  return null;
}

function detectTestFramework() {
  // Check env var first
  if (process.env.TEST_FRAMEWORK) return process.env.TEST_FRAMEWORK;

  // Detect from project files
  try {
    const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    const deps = { ...pkg.devDependencies, ...pkg.dependencies };
    if (deps.vitest) return 'vitest';
    if (deps.jest) return 'jest';
    if (deps.mocha) return 'mocha';
    if (deps.ava) return 'ava';
  } catch {}

  if (fs.existsSync('pytest.ini') || fs.existsSync('pyproject.toml')) return 'pytest';
  if (fs.existsSync('Cargo.toml')) return 'cargo-test';
  if (fs.existsSync('go.mod')) return 'go-test';

  return null;
}

function buildTestCommand(framework, testFile) {
  const relPath = path.relative(process.cwd(), testFile);
  switch (framework) {
    case 'vitest': return `npx vitest run "${relPath}" --reporter=verbose`;
    case 'jest': return `npx jest "${relPath}" --verbose`;
    case 'mocha': return `npx mocha "${relPath}"`;
    case 'ava': return `npx ava "${relPath}"`;
    case 'pytest': return `python -m pytest "${relPath}" -v`;
    case 'cargo-test': return `cargo test`;
    case 'go-test': return `go test ./...`;
    default: return null;
  }
}

function logResult(entry) {
  const logDir = path.resolve('.claude', 'memory', 'local');
  const logFile = path.join(logDir, 'test-results.jsonl');
  try {
    fs.mkdirSync(logDir, { recursive: true });
    fs.appendFileSync(logFile, JSON.stringify(entry) + '\n');

    // Rotate at 500 lines
    const lines = fs.readFileSync(logFile, 'utf8').split('\n').filter(Boolean);
    if (lines.length > 500) {
      fs.writeFileSync(logFile, lines.slice(-250).join('\n') + '\n');
    }
  } catch {}
}

async function main() {
  const input = await readStdin();
  const filePath = input.tool_input?.file_path || input.tool_input?.filePath || '';

  if (!filePath) return;
  if (SKIP_EXTENSIONS.test(filePath)) return;
  if (SKIP_PATHS.test(filePath)) return;

  const testFile = findTestFile(filePath);
  if (!testFile) return;

  const framework = detectTestFramework();
  if (!framework) return;

  const command = buildTestCommand(framework, testFile);
  if (!command) return;

  const entry = {
    timestamp: new Date().toISOString(),
    sourceFile: filePath,
    testFile: path.relative(process.cwd(), testFile),
    framework,
  };

  try {
    execSync(command, {
      timeout: 30000,
      stdio: ['pipe', 'pipe', 'pipe'],
      encoding: 'utf8',
    });
    entry.status = 'pass';
    logResult(entry);
  } catch (err) {
    entry.status = 'fail';
    entry.output = (err.stdout || '').slice(-500) + (err.stderr || '').slice(-500);
    logResult(entry);

    const context = [
      '--- Test Runner ---',
      `Source: ${filePath}`,
      `Test: ${path.relative(process.cwd(), testFile)}`,
      `Status: FAIL`,
      `Output (last 300 chars): ${entry.output.slice(-300)}`,
      '-------------------',
    ].join('\n');
    console.log(JSON.stringify({ additionalContext: context }));
  }
}

main().catch(() => {});
