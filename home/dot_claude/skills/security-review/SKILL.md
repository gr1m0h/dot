---
name: security-review
description: Use this skill when adding authentication, handling user input, working with secrets, creating API endpoints, or implementing payment/sensitive features. Provides comprehensive security checklist and patterns.
---

# Security Review Skill

Ensures all code follows security best practices and identifies potential vulnerabilities.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Security Checklist

### 1. Secrets Management
- No hardcoded API keys, tokens, or passwords
- All secrets in environment variables
- `.env.local` in .gitignore
- No secrets in git history

### 2. Input Validation
- All user inputs validated with schemas (Zod/Pydantic)
- File uploads restricted (size, type, extension)
- No direct use of user input in queries
- Whitelist validation (not blacklist)

### 3. SQL Injection Prevention
- All queries use parameterized queries or ORM
- No string concatenation in SQL

### 4. Authentication & Authorization
- Tokens stored in httpOnly cookies (not localStorage)
- Authorization checks before sensitive operations
- Row Level Security enabled in Supabase
- Role-based access control implemented

### 5. XSS Prevention
- User-provided HTML sanitized (DOMPurify)
- CSP headers configured
- React's built-in XSS protection used

### 6. CSRF Protection
- CSRF tokens on state-changing operations
- SameSite=Strict on all cookies

### 7. Rate Limiting
- Rate limiting on all API endpoints
- Stricter limits on expensive operations
- IP-based and user-based rate limiting

### 8. Sensitive Data Exposure
- No passwords, tokens, or secrets in logs
- Error messages generic for users
- Detailed errors only in server logs

### 9. Dependency Security
- `npm audit` clean
- Lock files committed
- Dependabot enabled

## Pre-Deployment Checklist

- [ ] Secrets: No hardcoded secrets, all in env vars
- [ ] Input Validation: All user inputs validated
- [ ] SQL Injection: All queries parameterized
- [ ] XSS: User content sanitized
- [ ] CSRF: Protection enabled
- [ ] Authentication: Proper token handling
- [ ] Authorization: Role checks in place
- [ ] Rate Limiting: Enabled on all endpoints
- [ ] HTTPS: Enforced in production
- [ ] Security Headers: CSP, X-Frame-Options configured
- [ ] Error Handling: No sensitive data in errors
- [ ] Logging: No sensitive data logged
- [ ] Dependencies: Up to date, no vulnerabilities
- [ ] CORS: Properly configured
- [ ] File Uploads: Validated (size, type)

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Next.js Security](https://nextjs.org/docs/security)
- [Web Security Academy](https://portswigger.net/web-security)

**Remember**: Security is not optional. One vulnerability can compromise the entire platform.
