# Core Rules (always-loaded)

Distilled universals — the ONLY unscoped (always-loaded) rules file; keep it that way. Language/testing detail is path-scoped in `rules/`, doctrine detail lives in `~/.claude/docs/` (on-demand). Critical security rules here are also enforced mechanically by `hooks/pre-tool-guard.js` / `ssrf-guard.js`.

## Security (OWASP 2025 — mandatory every change)

- **Secrets**: never hardcode/commit/log. Use env vars or a secrets manager. Protected: `.env*`, `*.pem`, `*.key`, `secrets/`, `credentials.*`
- **Input**: sanitize ALL external input (params, headers, body, files). Parameterized queries only (no SQL concat). Escape HTML output. Validate paths (no `../`)
- **Auth**: authenticate non-public endpoints; authorize per-request (not just at login); bcrypt/argon2/scrypt for passwords; HTTPS only
- **Deps**: audit before install; no critical/high vulns; pin versions
- **Errors/logging**: no stack traces to users; log security events; no PII/creds in logs
- **Config**: no debug in prod; CSP/HSTS/X-Frame-Options; strict CORS (no `*` in prod); cookies HttpOnly+Secure+SameSite=Strict
- **Exceptions (A10)**: deny by default, never fail open; handle every error branch (no bare catch/rescue)
- **Forbidden (all langs)**: dynamic code execution with untrusted input; insecure deserialization of untrusted data; `Math.random()`/`rand()`/`mt_rand()` for security-critical values
- OWASP 2025 shifts: A01 access control (SSRF here), A02 misconfig, **A03 supply chain (NEW)**, **A10 exceptional conditions (NEW)**

## LLM/AI Security (when building AI-integrated apps)

- Isolate system prompts from user input — never concatenate user input into the system prompt
- Validate all tool/MCP outputs before acting on them; least-privilege tool scopes
- Never trust AI-generated code/paths/SQL/URLs without review

## Coding

- Follow existing project patterns (project style > personal preference); minimal changes (only what's asked); readability > cleverness
- Delete, don't deprecate — no `_unused`, no commented-out code
- **Immutability**: create new objects, never mutate inputs
- Errors: specific catch types, never swallow silently; custom error types for domain failures
- Strong typing; avoid escape hatches (`any`/`interface{}`/`mixed`); type all params/returns
- Many small files (200–400 lines typical, 800 max); high cohesion, low coupling
- Comments explain WHY not WHAT; TODOs need a ticket (`TODO(#123)`)

## Supply Chain (A03:2025)

- Audit before adding deps: `npm audit` / `pip-audit` / `cargo audit` / `bundle audit` / `composer audit` / `govulncheck ./...`
- Severity → action: Critical/High = BLOCK (High needs explicit approval); Medium = warn+document; Low = allow+monitor
- Verify package name (typosquatting); **verify AI-suggested packages on the real registry before install** (hallucination → typosquat vector)
- Never edit lockfiles manually

## Uncertainty

- Express confidence explicitly: 0.8+ assertive · 0.5–0.8 "probably/likely" · 0.3–0.5 "needs verification" · <0.3 "hypothesis". Never "definitely/absolutely" without evidence. (detail: `~/.claude/docs/uncertainty-expression.md`)

## Cost / Model Routing

- haiku: exploration, lookups, simple edits, subagent workers · sonnet: implementation, review, tests · opus: architecture, security audits, multi-file refactoring
- Re-evaluate the tier table on each model upgrade; verify model facts against official docs
- Glob/Grep before Read; delegate exploration to subagents (fresh context, results only); `/clear` between unrelated tasks
