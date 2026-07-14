# STRIDE Framework

Analyze each component and data flow for these threat categories:

## S - Spoofing Identity

Pretending to be something or someone else.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Session hijacking | Stealing session cookies | HttpOnly, Secure, SameSite cookies |
| Credential theft | Phishing, keylogging | MFA, password policies |
| Token forgery | Creating fake JWTs | Strong signing algorithms (RS256+) |
| IP spoofing | Forged source addresses | Rate limiting, geolocation |

**Questions to Ask:**
- How does the system verify user identity?
- Can authentication be bypassed or forged?
- Are service-to-service calls authenticated?
- Is there mutual TLS for internal services?

## T - Tampering with Data

Modifying data maliciously.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Man-in-the-middle | Intercepting API calls | TLS everywhere |
| Database modification | Direct DB access | Access controls, encryption |
| Log manipulation | Hiding attack evidence | Immutable audit logs |
| Request modification | Changing form values | Input validation, signatures |

**Questions to Ask:**
- Is data integrity verified on input?
- Can data be modified in transit?
- Are database changes audited?
- Is file integrity monitored?

## R - Repudiation

Denying having performed an action.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Log deletion | Removing audit trails | Centralized, immutable logging |
| Unsigned transactions | Denying payments | Digital signatures |
| No audit trail | No record of actions | Comprehensive logging |

**Questions to Ask:**
- Are all critical actions logged?
- Can logs be tampered with?
- Are logs stored separately from application?
- Is there non-repudiation for transactions?

## I - Information Disclosure

Exposing information to unauthorized parties.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Error messages | Stack traces in responses | Sanitized error handling |
| API over-exposure | Returning unnecessary data | Response filtering |
| Insecure storage | Unencrypted PII | Encryption at rest |
| Side channels | Timing attacks | Constant-time comparisons |

**Questions to Ask:**
- What sensitive data exists in the system?
- How is data classified (PII, financial, etc.)?
- Is data encrypted at rest and in transit?
- Are error messages exposing internals?

## D - Denial of Service

Making a system unavailable.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Resource exhaustion | Memory/CPU flooding | Rate limiting, quotas |
| Algorithmic complexity | ReDoS, hash collision | Input validation, timeouts |
| State exhaustion | Connection pool depletion | Connection limits |
| Dependency failure | Third-party service down | Circuit breakers, fallbacks |

**Questions to Ask:**
- What are the rate limits?
- Are there resource quotas per user?
- What happens when dependencies fail?
- Are expensive operations protected?

## E - Elevation of Privilege

Gaining unauthorized capabilities.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| SQL injection | Bypassing auth | Parameterized queries |
| Insecure deserialization | Code execution | Safe deserialization |
| IDOR | Accessing other users' data | Authorization checks |
| Missing function-level access | Admin endpoints exposed | RBAC enforcement |

**Questions to Ask:**
- Is authorization checked at every step?
- Can users access other users' data?
- Are admin functions protected?
- Is there proper input validation?
