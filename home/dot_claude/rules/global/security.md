# Security Rules

IMPORTANT: These rules are mandatory for all code changes.

## Secrets Management

- **Never hardcode secrets** — use environment variables, `.env` files (gitignored), or a secrets manager
- **Never commit secrets** — API keys, tokens, passwords, connection strings, private keys
- **Never log secrets** — mask sensitive values in all log output
- Protected file patterns: `.env*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `secrets/`, `credentials.*`

## Input Validation (Trust Boundaries)

- Validate and sanitize **all** external input: user input, API parameters, query strings, headers, file uploads
- Use parameterized queries for SQL — never concatenate user input into queries
- Escape HTML output to prevent XSS — use framework-provided sanitization
- Validate file paths to prevent directory traversal (`../`)
- Reject unexpected Content-Types and oversized payloads

## Authentication & Authorization

- Enforce authentication on all non-public endpoints
- Apply authorization checks per-request (not just at login)
- Use established libraries — never implement custom crypto or auth
- Hash passwords with bcrypt, argon2, or scrypt (never MD5/SHA1/SHA256 alone)
- Enforce HTTPS for all external communication

## Dependency Security

- Run `npm audit` / `pip-audit` / `cargo audit` before adding dependencies
- Do not install packages with known critical/high vulnerabilities
- Prefer well-maintained packages (recent commits, multiple maintainers)
- Pin dependency versions in lockfiles
- Review new dependency source code for suspicious patterns

## Error Handling & Logging

- Never expose stack traces or internal paths to end users
- Log security events: authentication failures, authorization denials, input validation failures
- Never include PII or credentials in log messages
- Use structured logging with consistent severity levels

## Configuration

- Disable debug mode and verbose errors in production
- Set security headers: Content-Security-Policy, Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options
- Configure CORS restrictively — never use `Access-Control-Allow-Origin: *` in production
- Use secure cookie attributes: HttpOnly, Secure, SameSite=Strict

## Dangerous Operations

- Never use `eval()`, `Function()`, or `exec()` with dynamic input
- Never use `dangerouslySetInnerHTML` without sanitization
- Never use `pickle.loads()` or `yaml.load()` on untrusted data
- Never use `shell=True` in subprocess calls with user-controlled input
- Never use `Math.random()` for security purposes — use `crypto.getRandomValues()`
