const test = require('node:test');
const assert = require('node:assert/strict');
const { spawnSync, execFileSync } = require('node:child_process');
const { mkdtempSync, writeFileSync, rmSync } = require('node:fs');
const { tmpdir } = require('node:os');
const path = require('node:path');
const hook = process.env.HOOK_UNDER_TEST || path.join(__dirname, 'context.cjs');
function invoke(input, env = process.env) {
  const result = spawnSync(process.execPath, [hook], {
    input: typeof input === 'string' ? input : JSON.stringify(input),
    encoding: 'utf8', env, timeout: 5000, maxBuffer: 16384,
  });
  assert.equal(result.status, 0, result.stderr);
  return { text: result.stdout, json: result.stdout ? JSON.parse(result.stdout) : null };
}
test('non-repository context is valid and does not include prompt content', () => {
  const cwd = mkdtempSync(path.join(tmpdir(), 'codex-hook-'));
  try {
    const r = invoke({ hook_event_name: 'SessionStart', cwd, prompt: 'SECRET_SENTINEL' });
    assert.equal(r.json.hookSpecificOutput.hookEventName, 'SessionStart');
    const context = r.json.hookSpecificOutput.additionalContext;
    assert.ok(context.includes('not-a-repository'));
    assert.ok(!context.includes('SECRET_SENTINEL'));
  } finally { rmSync(cwd, { recursive: true, force: true }); }
});
test('repository status is bounded metadata; no file contents or filenames', () => {
  const cwd = mkdtempSync(path.join(tmpdir(), 'codex-hook-'));
  const env = { ...process.env, GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_NOSYSTEM: '1' };
  try {
    execFileSync('/usr/bin/git', ['init', '-q', cwd], { env });
    writeFileSync(path.join(cwd, 'private-name.txt'), 'SECRET_SENTINEL');
    execFileSync('/usr/bin/git', ['-C', cwd, 'add', 'private-name.txt'], { env });
    const r = invoke({ hook_event_name: 'SessionStart', cwd }, env);
    assert.ok(r.text.includes('tracked_changes'));
    assert.ok(!r.text.includes('private-name.txt'));
    assert.ok(!r.text.includes('SECRET_SENTINEL'));
    assert.ok(r.text.length < 5000);
  } finally { rmSync(cwd, { recursive: true, force: true }); }
});
test('compaction uses supported common output fields', () => {
  const r = invoke({ hook_event_name: 'PreCompact', cwd: '/nonexistent' });
  assert.equal(typeof r.json.systemMessage, 'string');
  assert.ok(!('hookSpecificOutput' in r.json));
  assert.ok(!('continue' in r.json));
});
test('malformed JSON does not block session', () => {
  assert.equal(invoke('{').json, null);
});
test('oversized input does not block session or echo input', () => {
  assert.equal(invoke('x'.repeat(20000)).json, null);
});
test('unknown events do nothing', () => {
  assert.equal(invoke({ hook_event_name: 'PostToolUse', cwd: '/' }).json, null);
});
test('missing and relative cwd do not cause command execution', () => {
  assert.ok(invoke({ hook_event_name: 'SessionStart' }).text.includes('unavailable'));
  assert.ok(invoke({ hook_event_name: 'SessionStart', cwd: 'relative' }).text.includes('unavailable'));
});
test('invalid cwd is reported without echoing command-like text', () => {
  const r = invoke({ hook_event_name: 'SessionStart', cwd: '/missing/$(echo SECRET_SENTINEL)' });
  assert.ok(r.text.includes('unavailable'));
  assert.ok(!r.text.includes('SECRET_SENTINEL'));
});
