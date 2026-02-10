---
name: security-scan
description: Comprehensive security audit based on OWASP 2025 Top 10 with automated checks. Scans for vulnerabilities, insecure patterns, hardcoded secrets, and dependency risks.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: security-auditor
argument-hint: "[target-dir]"
metadata:
  version: "2.0.0"
  updated: "2025-02"
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

# Security Scan

Perform a comprehensive security audit on $ARGUMENTS.

**Reference:** [OWASP Top 10 2025](https://owasp.org/Top10/)

## Scan Strategy

When conducting security scans:

1. Identify application type and tech stack
2. Run automated dependency vulnerability checks
3. Scan source code for insecure patterns
4. Detect hardcoded secrets and credentials
5. Review configuration files for misconfigurations
6. Assess authentication and authorization flows

## Dynamic Context

- Dependency audit: !`npm audit --json 2>/dev/null | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log('Vulnerabilities:',JSON.stringify(d.metadata?.vulnerabilities||'N/A'))" 2>/dev/null || pip-audit 2>/dev/null | tail -5 || cargo audit 2>/dev/null | tail -5 || echo "No dependency audit tool found"`
- Recently changed files: !`git diff --name-only HEAD~10 2>/dev/null || echo "N/A"`
- Project type: !`ls package.json requirements.txt Cargo.toml go.mod pyproject.toml 2>/dev/null | head -3 || echo "Unknown"`
- Environment files: !`find . -name '.env*' -o -name '*.env' 2>/dev/null | head -5 || echo "None"`

## OWASP 2025 Top 10 Checklist

### A01: Broken Access Control

Most common vulnerability category.

```markdown
**Audit Checklist:**
- [ ] Default deny for all protected resources
- [ ] RBAC/ABAC consistently applied
- [ ] CORS configuration restrictive (not `*`)
- [ ] Directory traversal prevention (`../` in paths)
- [ ] Rate limiting on sensitive endpoints
- [ ] JWT token validation (signature, expiry, issuer)
```

#### Vulnerable Pattern: Path Traversal

```javascript
// Bad - Vulnerable to path traversal
app.get('/files/:name', (req, res) => {
  const filePath = `./uploads/${req.params.name}`;
  res.sendFile(filePath);
});

// Good - Sanitized path
const path = require('path');
app.get('/files/:name', (req, res) => {
  const fileName = path.basename(req.params.name);
  const safePath = path.join(__dirname, 'uploads', fileName);

  // Verify path is within allowed directory
  if (!safePath.startsWith(path.join(__dirname, 'uploads'))) {
    return res.status(403).send('Forbidden');
  }
  res.sendFile(safePath);
});
```

### A02: Cryptographic Failures

```markdown
**Audit Checklist:**
- [ ] No MD5/SHA1 for password hashing (use bcrypt/argon2/scrypt)
- [ ] TLS enforced for all external communication
- [ ] No hardcoded encryption keys or salts
- [ ] Secure random number generation (not Math.random)
- [ ] Proper key management (rotation, storage)
```

#### Vulnerable Pattern: Weak Hashing

```python
# Bad - MD5 is cryptographically broken
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# Good - Use bcrypt with proper cost factor
import bcrypt
password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
```

### A03: Injection

```markdown
**Audit Checklist:**
- [ ] Parameterized queries for all database operations
- [ ] No string concatenation in SQL/NoSQL queries
- [ ] Command injection prevention (no shell=True with user input)
- [ ] Path traversal sanitization
- [ ] LDAP/XPath injection prevention
```

#### Vulnerable Pattern: SQL Injection

```java
// Bad - SQL injection vulnerable
String query = "SELECT * FROM users WHERE id = " + userId;
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery(query);

// Good - Parameterized query
String query = "SELECT * FROM users WHERE id = ?";
PreparedStatement pstmt = conn.prepareStatement(query);
pstmt.setInt(1, userId);
ResultSet rs = pstmt.executeQuery();
```

#### Vulnerable Pattern: Command Injection

```python
# Bad - Command injection vulnerable
import subprocess
subprocess.run(f"ping -c 1 {user_input}", shell=True)

# Good - Use array form
import subprocess
import shlex
subprocess.run(["ping", "-c", "1", user_input])
```

### A04: Insecure Design

```markdown
**Audit Checklist:**
- [ ] Threat modeling performed for critical flows
- [ ] Business logic validated (not just technical)
- [ ] Defense in depth applied
- [ ] Fail secure (deny by default)
```

### A05: Security Misconfiguration

```markdown
**Audit Checklist:**
- [ ] Debug mode disabled in production configs
- [ ] Default credentials removed
- [ ] Unnecessary features/endpoints disabled
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] Error messages don't leak sensitive info
```

#### Security Headers Check

```javascript
// Required headers for production
const securityHeaders = {
  'Content-Security-Policy': "default-src 'self'; script-src 'self'",
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'X-Frame-Options': 'DENY',
  'X-Content-Type-Options': 'nosniff',
  'X-XSS-Protection': '1; mode=block',
  'Referrer-Policy': 'strict-origin-when-cross-origin'
};
```

### A06: Vulnerable and Outdated Components

```markdown
**Audit Checklist:**
- [ ] All dependencies up to date
- [ ] No known CVEs in dependency tree
- [ ] Transitive dependencies audited
- [ ] Automated dependency scanning in CI/CD
```

#### Dependency Audit Commands

| Ecosystem | Command |
|-----------|---------|
| npm | `npm audit` |
| Python | `pip-audit` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| Ruby | `bundle-audit check --update` |

### A07: Authentication Failures

```markdown
**Audit Checklist:**
- [ ] Strong password policies enforced
- [ ] Session management secure (httpOnly, secure, sameSite)
- [ ] No credentials in URLs or logs
- [ ] Brute-force protection (lockout/rate-limit)
- [ ] MFA available for sensitive operations
```

#### Secure Session Configuration

```javascript
// Express.js secure session config
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 3600000 // 1 hour
  },
  resave: false,
  saveUninitialized: false
}));
```

### A08: Software and Data Integrity Failures

```markdown
**Audit Checklist:**
- [ ] Input validation on all trust boundaries
- [ ] Deserialization safety (no eval, no pickle.loads on untrusted data)
- [ ] CI/CD pipeline integrity
- [ ] Subresource integrity for CDN resources
```

### A09: Security Logging and Monitoring Failures

```markdown
**Audit Checklist:**
- [ ] No PII/secrets in log output
- [ ] Security events logged (auth failures, access denied)
- [ ] Log injection prevention
- [ ] Audit trail for sensitive operations
```

### A10: Server-Side Request Forgery (SSRF)

```markdown
**Audit Checklist:**
- [ ] URL validation for user-supplied URLs
- [ ] Allowlist for external service calls
- [ ] No internal network access from user input
- [ ] Response type validation
```

#### SSRF Prevention

```python
# Bad - SSRF vulnerable
import requests
url = request.args.get('url')
response = requests.get(url)

# Good - URL validation with allowlist
from urllib.parse import urlparse

ALLOWED_HOSTS = ['api.trusted-service.com', 'cdn.example.com']

def fetch_url(url):
    parsed = urlparse(url)
    if parsed.hostname not in ALLOWED_HOSTS:
        raise ValueError('URL host not in allowlist')
    if parsed.scheme not in ('http', 'https'):
        raise ValueError('Invalid URL scheme')
    return requests.get(url, timeout=5)
```

## Secret Detection Patterns

Scan for these regex patterns in source code:

| Pattern Type | Description |
|-------------|-------------|
| AWS Access Key | Starts with `AKIA` followed by 16 alphanumeric chars |
| AWS Secret Key | 40 character base64-like string |
| GitHub Token | Starts with `ghp_`, `gho_`, `ghu_`, `ghs_`, or `ghr_` |
| Generic API Key | Variable named `api_key` or `apikey` with string value |
| Private Key | PEM formatted private key block |
| JWT Token | Base64 encoded header.payload format |
| Connection String | Database URLs with credentials |
| Generic Secret | Variables named password/secret/token with values |

## Output Format

```markdown
## Security Audit Report

### Executive Summary
- **Scope:** [directories/files scanned]
- **Risk Level:** Critical / High / Medium / Low
- **Findings:** X critical, Y high, Z medium

### Critical Findings (CVSS 9.0+)
1. **[OWASP-A03] SQL Injection** - file.js:42
   - **CVSS:** 9.8
   - **Impact:** Full database access
   - **Remediation:** Use parameterized queries
   - **Code:** `const query = "SELECT * FROM users WHERE id = " + userId`

### High Findings (CVSS 7.0-8.9)
1. **[OWASP-A07] Weak Session Config** - app.js:15
   - **CVSS:** 7.5
   - **Impact:** Session hijacking possible
   - **Remediation:** Add httpOnly, secure flags

### Medium Findings (CVSS 4.0-6.9)
1. **[OWASP-A05] Missing Security Headers** - server.js:1
   - **Remediation:** Add CSP, HSTS headers

### Low Findings (CVSS < 4.0)
1. **[INFO] Debug logging enabled** - config.js:8

### Dependency Vulnerabilities
| Package | Severity | CVE | Fix Version |
|---------|----------|-----|-------------|
| lodash | High | CVE-2021-23337 | 4.17.21 |

### Remediation Priority
1. [Critical] Fix SQL injection in user module
2. [High] Update lodash to 4.17.21+
3. [Medium] Add security headers middleware

### Compliance Notes
- [ ] PCI-DSS applicable
- [ ] GDPR data handling
- [ ] SOC 2 requirements
```

## Severity Classification (CVSS 3.1)

| Severity | CVSS Score | Response Time |
|----------|------------|---------------|
| Critical | 9.0 - 10.0 | Immediate |
| High | 7.0 - 8.9 | Within 7 days |
| Medium | 4.0 - 6.9 | Within 30 days |
| Low | 0.1 - 3.9 | Next release |

## Automated Scanning Tools

| Tool | Purpose | Command |
|------|---------|---------|
| npm audit | Node.js dependencies | `npm audit --json` |
| Snyk | Multi-language deps | `snyk test` |
| Trivy | Container images | `trivy image <name>` |
| Semgrep | SAST scanning | `semgrep --config auto` |
| gitleaks | Secret detection | `gitleaks detect` |
| OWASP ZAP | DAST scanning | `zap-cli quick-scan <url>` |

## Related Skills

- [review-code](/review-code) - General code review
- [threat-model](/threat-model) - STRIDE threat modeling
- [audit-supply-chain](/audit-supply-chain) - Dependency analysis

## Resources

- [OWASP Top 10 2025](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

*Version 2.0.0 - Updated 2025-02*
