# Forbidden APIs (per-language)

On-demand reference. Loaded by security skills (`/security-review`, `/security-scan`)
and when working in a specific language — NOT always-loaded.
The critical patterns here are also enforced mechanically by `hooks/pre-tool-guard.js`.

Universal rules live in `~/.claude/docs/security.md`:
dynamic code execution with untrusted input, insecure deserialization of
untrusted data, and `Math.random()`/`rand()`/`mt_rand()` for security-critical values.

## TypeScript / JavaScript
- `eval()`, `Function()`, `exec()` with dynamic input
- `dangerouslySetInnerHTML` without sanitization

## Python
- `pickle.loads()`, `yaml.load()` on untrusted data
- `shell=True` with user input

## Ruby
- `eval()`, `send()`, `public_send()` with user input
- `system()`, `exec()`, backticks, `%x{}` with unsanitized input
- `Marshal.load()`, `YAML.load()` on untrusted data (use `YAML.safe_load`)
- `constantize` / `safe_constantize` with user input
- `render inline:` with user-controlled content

## PHP
- `eval()`, `assert()` with dynamic input
- `exec()`, `system()`, `shell_exec()`, `passthru()`, `proc_open()` with user input
- `unserialize()` on untrusted data (use `json_decode()`)
- `extract()` on user input (mass assignment)
- `include()` / `require()` with user-controlled paths (LFI/RFI)
- `$$variable` (variable variables) with user input
- `preg_replace()` with `/e` modifier

## Go
- `unsafe` package without explicit justification
- `os/exec.Command()` with unsanitized user input
- `reflect` for dynamic dispatch with user input
- `cgo` without security review
- `encoding/gob` for untrusted data (use `encoding/json`)
