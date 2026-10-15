# Security Audit Output Format

## Report Template

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
