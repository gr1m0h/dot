---
name: security-scan
description: Comprehensive security audit based on OWASP 2025 Top 10 with automated checks
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: security-auditor
argument-hint: "[target-dir]"
hooks:
  - type: command
    command: |
      node -e "
        const { execSync } = require('child_process');
        const fs = require('fs');
        const warnings = [];
        if (fs.existsSync('package.json')) {
          try { execSync('npx --yes npm-audit-resolver --version', { stdio: 'pipe', timeout: 10000 }); }
          catch { warnings.push('npm audit available but npm-audit-resolver not found (optional).'); }
        }
        if (fs.existsSync('requirements.txt') || fs.existsSync('pyproject.toml')) {
          try { execSync('pip-audit --version', { stdio: 'pipe', timeout: 5000 }); }
          catch { warnings.push('pip-audit not installed. Run pip install pip-audit for Python dependency scanning.'); }
        }
        if (fs.existsSync('Cargo.toml')) {
          try { execSync('cargo audit --version', { stdio: 'pipe', timeout: 5000 }); }
          catch { warnings.push('cargo-audit not installed. Run cargo install cargo-audit for Rust dependency scanning.'); }
        }
        if (warnings.length > 0) {
          console.log(JSON.stringify({additionalContext: 'Audit Tool Warnings:\\n' + warnings.map(w => '- ' + w).join('\\n')}));
        }
      "
    once: true
---

# Security Scan: $ARGUMENTS

## Dynamic Context

- Dependency audit: !`npm audit --json 2>/dev/null | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log('Vulnerabilities:',JSON.stringify(d.metadata?.vulnerabilities||'N/A'))" 2>/dev/null || pip-audit 2>/dev/null | tail -5 || cargo audit 2>/dev/null | tail -5 || echo "No dependency audit tool found"`
- Recently changed files: !`git diff --name-only HEAD~10 2>/dev/null || echo "N/A"`
- Project type: !`ls package.json requirements.txt Cargo.toml go.mod pyproject.toml 2>/dev/null | head -3 || echo "Unknown"`
- Environment files: !`find . -name '.env*' -o -name '*.env' 2>/dev/null | head -5 || echo "None"`

## Scan Checklist (OWASP 2025 Aligned)

### A01: Broken Access Control
- [ ] Default deny for all protected resources
- [ ] RBAC/ABAC consistently applied
- [ ] CORS configuration restrictive (not `*`)
- [ ] Directory traversal prevention (`../` in paths)
- [ ] Rate limiting on sensitive endpoints

### A02: Cryptographic Failures
- [ ] No MD5/SHA1 for password hashing (use bcrypt/argon2/scrypt)
- [ ] TLS enforced for all external communication
- [ ] No hardcoded encryption keys or salts
- [ ] Secure random number generation (not Math.random)

### A03: Injection
- [ ] Parameterized queries for all database operations
- [ ] No string concatenation in SQL/NoSQL queries
- [ ] Command injection prevention (no shell=True with user input)
- [ ] Path traversal sanitization
- [ ] LDAP/XPath injection prevention

### A05: Security Misconfiguration
- [ ] Debug mode disabled in production configs
- [ ] Default credentials removed
- [ ] Unnecessary features/endpoints disabled
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)

### A07: Authentication Failures
- [ ] Strong password policies enforced
- [ ] Session management secure (httpOnly, secure, sameSite)
- [ ] No credentials in URLs or logs
- [ ] Brute-force protection (lockout/rate-limit)

### A08: Data Integrity Failures
- [ ] Input validation on all trust boundaries
- [ ] Deserialization safety (no `eval`, no `pickle.loads` on untrusted data)
- [ ] CI/CD pipeline integrity

### A09: Logging & Monitoring Failures
- [ ] No PII/secrets in log output
- [ ] Security events logged (auth failures, access denied)
- [ ] Log injection prevention

### A10: SSRF
- [ ] URL validation for user-supplied URLs
- [ ] Allowlist for external service calls
- [ ] No internal network access from user input

## Secret Detection Patterns

Scan for these patterns in source code:
- API keys: `(api[_-]?key|apikey)\s*[:=]\s*["'][^"']+`
- AWS credentials: `AKIA[0-9A-Z]{16}`
- Private keys: `-----BEGIN (RSA |EC )?PRIVATE KEY-----`
- JWT tokens: `eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+`
- Connection strings: `(mongodb|postgres|mysql|redis):\/\/[^\s]+`
- Generic secrets: `(password|secret|token)\s*[:=]\s*["'][^"']{8,}`

## Output Format

Deliver a structured Security Audit Report with:
1. Executive Summary (scope, overall risk level, finding counts)
2. Critical/High findings with file:line references and CVSS scores
3. Medium/Low findings
4. Remediation recommendations (priority-ordered)
5. Dependency vulnerability summary
