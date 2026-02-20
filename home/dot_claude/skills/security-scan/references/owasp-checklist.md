# OWASP 2025 Top 10 Checklist

## A01: Broken Access Control

Most common vulnerability category.

**Audit Checklist:**
- [ ] Default deny for all protected resources
- [ ] RBAC/ABAC consistently applied
- [ ] CORS configuration restrictive (not `*`)
- [ ] Directory traversal prevention (`../` in paths)
- [ ] Rate limiting on sensitive endpoints
- [ ] JWT token validation (signature, expiry, issuer)

### Vulnerable Pattern: Path Traversal

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

## A02: Cryptographic Failures

**Audit Checklist:**
- [ ] No MD5/SHA1 for password hashing (use bcrypt/argon2/scrypt)
- [ ] TLS enforced for all external communication
- [ ] No hardcoded encryption keys or salts
- [ ] Secure random number generation (not Math.random)
- [ ] Proper key management (rotation, storage)

### Vulnerable Pattern: Weak Hashing

```python
# Bad - MD5 is cryptographically broken
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# Good - Use bcrypt with proper cost factor
import bcrypt
password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
```

## A03: Injection

**Audit Checklist:**
- [ ] Parameterized queries for all database operations
- [ ] No string concatenation in SQL/NoSQL queries
- [ ] Command injection prevention (no shell=True with user input)
- [ ] Path traversal sanitization
- [ ] LDAP/XPath injection prevention

### Vulnerable Pattern: SQL Injection

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

### Vulnerable Pattern: Command Injection

```python
# Bad - Command injection vulnerable
import subprocess
subprocess.run(f"ping -c 1 {user_input}", shell=True)

# Good - Use array form
import subprocess
import shlex
subprocess.run(["ping", "-c", "1", user_input])
```

## A04: Insecure Design

**Audit Checklist:**
- [ ] Threat modeling performed for critical flows
- [ ] Business logic validated (not just technical)
- [ ] Defense in depth applied
- [ ] Fail secure (deny by default)

## A05: Security Misconfiguration

**Audit Checklist:**
- [ ] Debug mode disabled in production configs
- [ ] Default credentials removed
- [ ] Unnecessary features/endpoints disabled
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] Error messages don't leak sensitive info

### Security Headers Check

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

## A06: Vulnerable and Outdated Components

**Audit Checklist:**
- [ ] All dependencies up to date
- [ ] No known CVEs in dependency tree
- [ ] Transitive dependencies audited
- [ ] Automated dependency scanning in CI/CD

### Dependency Audit Commands

| Ecosystem | Command |
|-----------|---------|
| npm | `npm audit` |
| Python | `pip-audit` |
| Go | `govulncheck ./...` |
| Rust | `cargo audit` |
| Ruby | `bundle-audit check --update` |

## A07: Authentication Failures

**Audit Checklist:**
- [ ] Strong password policies enforced
- [ ] Session management secure (httpOnly, secure, sameSite)
- [ ] No credentials in URLs or logs
- [ ] Brute-force protection (lockout/rate-limit)
- [ ] MFA available for sensitive operations

### Secure Session Configuration

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

## A08: Software and Data Integrity Failures

**Audit Checklist:**
- [ ] Input validation on all trust boundaries
- [ ] Deserialization safety (no eval, no pickle.loads on untrusted data)
- [ ] CI/CD pipeline integrity
- [ ] Subresource integrity for CDN resources

## A09: Security Logging and Monitoring Failures

**Audit Checklist:**
- [ ] No PII/secrets in log output
- [ ] Security events logged (auth failures, access denied)
- [ ] Log injection prevention
- [ ] Audit trail for sensitive operations

## A10: Server-Side Request Forgery (SSRF)

**Audit Checklist:**
- [ ] URL validation for user-supplied URLs
- [ ] Allowlist for external service calls
- [ ] No internal network access from user input
- [ ] Response type validation

### SSRF Prevention

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
