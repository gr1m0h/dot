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
- Audit before install (`npm audit`/`pip-audit`)
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
- `eval()`, `Function()`, `exec()` with dynamic input
- `dangerouslySetInnerHTML` without sanitization
- `pickle.loads()`, `yaml.load()` on untrusted data
- `shell=True` with user input
- `Math.random()` for security

## Security Testing
- Requires documented authorization
- CTF/own systems: implicitly authorized
- Follow responsible disclosure
- Use synthetic data only
