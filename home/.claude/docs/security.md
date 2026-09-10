# Security Policy

CRITICAL: Mandatory for all code changes. Aligned with OWASP 2025 Top 10.

## OWASP 2025 Alignment

| Rank | Category | Key Change |
|------|----------|------------|
| A01 | Broken Access Control | SSRF consolidated here |
| A02 | Security Misconfiguration | Moved up from #5 |
| A03 | Software Supply Chain Failures | **NEW** — see ~/.claude/docs/supply-chain-security.md |
| A04 | Cryptographic Failures | Dropped from #2 |
| A05 | Injection | Dropped from #3 |
| A06 | Insecure Design | Dropped from #4 |
| A07 | Authentication Failures | Renamed |
| A08 | Software or Data Integrity Failures | Stable |
| A09 | Security Logging and Monitoring Failures | Stable |
| A10 | Mishandling of Exceptional Conditions | **NEW** |

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

## Forbidden (All Languages)
- Dynamic code execution with untrusted input
- Insecure deserialization of untrusted data
- `Math.random()` / `rand()` / `mt_rand()` for security-critical values

Per-language forbidden API lists (TS/JS, Python, Ruby, PHP, Go) live in
`~/.claude/docs/forbidden-apis.md` (on-demand) and are also enforced by
`hooks/pre-tool-guard.js`.

## Exception Handling (A10:2025)

- Never fail open — deny by default on unexpected conditions
- Handle all error branches explicitly (no bare catch/rescue)
- Log abnormal conditions for monitoring
- Validate assumptions at system boundaries
- Use circuit breakers for external service calls

## Security Testing
- Requires documented authorization
- CTF/own systems: implicitly authorized
- Follow responsible disclosure
- Use synthetic data only

## LLM Security
See ~/.claude/docs/llm-security.md for AI-specific security patterns.
