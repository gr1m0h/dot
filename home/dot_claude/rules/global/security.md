# Security Policy

CRITICAL: Mandatory for all code changes.

## Secrets
- Never hardcode/commit/log secrets
- Use env vars or secrets manager
- Protected: `.env*`, `*.pem`, `*.key`, `secrets/`, `credentials.*`

## Input Validation
- Sanitize ALL external input (params, headers, body, files)
- Use parameterized queries only (no SQL concat)
- Escape HTML output, validate file paths (no `../`)

## Auth
- Authenticate all non-public endpoints
- Authorize per-request, not just at login
- Use established libs (bcrypt/argon2/scrypt for passwords)
- HTTPS only

## Dependencies
- Audit before install (`npm audit`/`pip-audit`/`bundle audit`/`composer audit`/`govulncheck`)
- No critical/high vulnerabilities
- Pin versions, review source

## Errors & Logging
- No stack traces to users
- Log security events (auth failures, denials)
- No PII/credentials in logs

## Config
- No debug in prod
- Security headers: CSP, HSTS, X-Frame-Options
- Strict CORS (no `*` in prod)
- Secure cookies: HttpOnly, Secure, SameSite=Strict

## Forbidden

### All Languages
- Dynamic code execution with untrusted input
- Insecure deserialization of untrusted data
- `Math.random()` / `rand()` / `mt_rand()` for security-critical values

### TypeScript / JavaScript
- `eval()`, `Function()`, `exec()` with dynamic input
- `dangerouslySetInnerHTML` without sanitization

### Python
- `pickle.loads()`, `yaml.load()` on untrusted data
- `shell=True` with user input

### Ruby
- `eval()`, `send()`, `public_send()` with user input
- `system()`, `exec()`, backticks, `%x{}` with unsanitized input
- `Marshal.load()`, `YAML.load()` on untrusted data (use `YAML.safe_load`)
- `constantize` / `safe_constantize` with user input
- `render inline:` with user-controlled content

### PHP
- `eval()`, `assert()` with dynamic input
- `exec()`, `system()`, `shell_exec()`, `passthru()`, `proc_open()` with user input
- `unserialize()` on untrusted data (use `json_decode()`)
- `extract()` on user input (mass assignment)
- `include()` / `require()` with user-controlled paths (LFI/RFI)
- `$$variable` (variable variables) with user input
- `preg_replace()` with `/e` modifier

### Go
- `unsafe` package without explicit justification
- `os/exec.Command()` with unsanitized user input
- `reflect` for dynamic dispatch with user input
- `cgo` without security review
- `encoding/gob` for untrusted data (use `encoding/json`)

## Security Testing
- Requires documented authorization
- CTF/own systems: implicitly authorized
- Follow responsible disclosure
- Use synthetic data only
