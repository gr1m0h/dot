---
name: threat-model
description: Perform STRIDE threat modeling on the application architecture. Systematically identify threats, assess risks with DREAD scoring, and recommend mitigations.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: threat-modeler
argument-hint: "[target-component or 'full']"
metadata:
  version: "2.0.0"
  updated: "2025-02"
---

# Threat Modeling

Perform systematic threat modeling on $ARGUMENTS using STRIDE methodology.

**Reference:** [Microsoft Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool)

## Modeling Strategy

When conducting threat modeling:

1. Identify the system scope and assets
2. Create a Data Flow Diagram (DFD)
3. Identify trust boundaries
4. Apply STRIDE to each component and data flow
5. Assess risk severity using DREAD
6. Prioritize and recommend mitigations

## Dynamic Context

Architecture overview:
!`cat README.md 2>/dev/null | head -50 || cat ARCHITECTURE.md 2>/dev/null | head -50 || echo "No architecture docs found"`

Authentication components:
!`grep -rl "auth\|jwt\|session\|oauth\|passport" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" 2>/dev/null | head -10`

Data stores:
!`grep -rl "database\|redis\|mongo\|postgres\|mysql\|sqlite" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10`

API endpoints:
!`grep -rn "app\.\(get\|post\|put\|delete\|patch\)\|@app\.route\|router\.\|@Get\|@Post" --include="*.py" --include="*.js" --include="*.ts" 2>/dev/null | head -15`

## STRIDE Framework

Analyze each component and data flow for these threat categories:

### S - Spoofing Identity

Pretending to be something or someone else.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Session hijacking | Stealing session cookies | HttpOnly, Secure, SameSite cookies |
| Credential theft | Phishing, keylogging | MFA, password policies |
| Token forgery | Creating fake JWTs | Strong signing algorithms (RS256+) |
| IP spoofing | Forged source addresses | Rate limiting, geolocation |

```markdown
**Questions to Ask:**
- How does the system verify user identity?
- Can authentication be bypassed or forged?
- Are service-to-service calls authenticated?
- Is there mutual TLS for internal services?
```

### T - Tampering with Data

Modifying data maliciously.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Man-in-the-middle | Intercepting API calls | TLS everywhere |
| Database modification | Direct DB access | Access controls, encryption |
| Log manipulation | Hiding attack evidence | Immutable audit logs |
| Request modification | Changing form values | Input validation, signatures |

```markdown
**Questions to Ask:**
- Is data integrity verified on input?
- Can data be modified in transit?
- Are database changes audited?
- Is file integrity monitored?
```

### R - Repudiation

Denying having performed an action.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Log deletion | Removing audit trails | Centralized, immutable logging |
| Unsigned transactions | Denying payments | Digital signatures |
| No audit trail | No record of actions | Comprehensive logging |

```markdown
**Questions to Ask:**
- Are all critical actions logged?
- Can logs be tampered with?
- Are logs stored separately from application?
- Is there non-repudiation for transactions?
```

### I - Information Disclosure

Exposing information to unauthorized parties.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Error messages | Stack traces in responses | Sanitized error handling |
| API over-exposure | Returning unnecessary data | Response filtering |
| Insecure storage | Unencrypted PII | Encryption at rest |
| Side channels | Timing attacks | Constant-time comparisons |

```markdown
**Questions to Ask:**
- What sensitive data exists in the system?
- How is data classified (PII, financial, etc.)?
- Is data encrypted at rest and in transit?
- Are error messages exposing internals?
```

### D - Denial of Service

Making a system unavailable.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| Resource exhaustion | Memory/CPU flooding | Rate limiting, quotas |
| Algorithmic complexity | ReDoS, hash collision | Input validation, timeouts |
| State exhaustion | Connection pool depletion | Connection limits |
| Dependency failure | Third-party service down | Circuit breakers, fallbacks |

```markdown
**Questions to Ask:**
- What are the rate limits?
- Are there resource quotas per user?
- What happens when dependencies fail?
- Are expensive operations protected?
```

### E - Elevation of Privilege

Gaining unauthorized capabilities.

| Attack Vector | Example | Mitigation |
|--------------|---------|------------|
| SQL injection | Bypassing auth | Parameterized queries |
| Insecure deserialization | Code execution | Safe deserialization |
| IDOR | Accessing other users' data | Authorization checks |
| Missing function-level access | Admin endpoints exposed | RBAC enforcement |

```markdown
**Questions to Ask:**
- Is authorization checked at every step?
- Can users access other users' data?
- Are admin functions protected?
- Is there proper input validation?
```

## DREAD Risk Assessment

Score each identified threat (1-10 per category):

| Factor | Description | Score Guide |
|--------|-------------|-------------|
| **D**amage | How much harm if exploited? | 10=Complete system compromise |
| **R**eproducibility | How easy to reproduce? | 10=Always reproducible |
| **E**xploitability | How easy to exploit? | 10=No skill required |
| **A**ffected users | How many users impacted? | 10=All users |
| **D**iscoverability | How easy to discover? | 10=Public knowledge |

**Risk Score Formula:** `(D + R + E + A + D) / 5`

| Score | Risk Level | Priority |
|-------|------------|----------|
| 8-10 | Critical | Immediate |
| 5-7 | High | This sprint |
| 3-4 | Medium | Next sprint |
| 1-2 | Low | Backlog |

## Data Flow Diagram Elements

```
[External Entity]     User, third-party service
(Process)            Application logic, microservice
[Data Store]         Database, cache, file system
─────>               Data flow direction
═════                Trust boundary
```

### Example DFD

```
                    ══════════════════════════════════════
                    │         Trust Boundary              │
                    │                                     │
[User Browser] ────────> (Web Server) ────> [Database]   │
       │            │        │                            │
       │            │        └───> (Auth Service)         │
       │            │              │                      │
       └──── HTTPS ─┼──────────────┘                      │
                    ══════════════════════════════════════
```

## Output Format

```markdown
## Threat Model Report

### System Overview
- **Scope:** [components analyzed]
- **Assets:** [critical data and services]
- **Entry Points:** [user inputs, APIs, external connections]

### Data Flow Diagram
[ASCII or Mermaid DFD]

### Trust Boundaries
1. [Boundary name] - [what it separates]

### Threat Inventory

#### Critical Threats (DREAD 8-10)
| ID | Category | Threat | Component | DREAD | Status |
|----|----------|--------|-----------|-------|--------|
| T1 | Spoofing | JWT forgery | Auth | 9.0 | Open |

**T1: JWT Forgery**
- **Description:** Weak signing algorithm allows token creation
- **Attack Scenario:** Attacker modifies algorithm to 'none'
- **DREAD:** D=9, R=8, E=9, A=10, D=8 = **8.8**
- **Mitigation:** Enforce RS256, validate algorithm

#### High Threats (DREAD 5-7)
[...]

#### Medium/Low Threats
[Summary table]

### Attack Trees

```
Root: Unauthorized Data Access
├── Bypass Authentication
│   ├── Credential Stuffing
│   ├── Session Hijacking
│   └── JWT Forgery [T1]
└── Bypass Authorization
    ├── IDOR Vulnerability
    └── Privilege Escalation
```

### Mitigation Recommendations

| Priority | Threat | Mitigation | Effort |
|----------|--------|------------|--------|
| 1 | T1 | Upgrade JWT library | Low |

### Security Controls Checklist
- [ ] Authentication enforced
- [ ] Authorization per-request
- [ ] Input validation
- [ ] Output encoding
- [ ] Encryption at rest/transit
- [ ] Audit logging
- [ ] Rate limiting
- [ ] Error handling
```

## Common Architecture Patterns

### Microservices

```markdown
**Focus Areas:**
- Service-to-service authentication (mTLS, JWT)
- API Gateway security
- Service mesh configuration
- Secrets management
- Container security
```

### Serverless

```markdown
**Focus Areas:**
- Function permissions (least privilege)
- Event injection
- Cold start timing attacks
- Logging and monitoring
- Dependency security
```

### Single Page Application

```markdown
**Focus Areas:**
- Token storage (no localStorage for sensitive)
- XSS prevention (CSP, sanitization)
- CSRF protection
- API security (rate limiting, CORS)
- Client-side secrets exposure
```

## Related Skills

- [security-scan](/security-scan) - Automated vulnerability scanning
- [review-code](/review-code) - Code-level security review
- [protocol-check](/protocol-check) - Protocol security analysis

## Resources

- [STRIDE Threat Model](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [NIST SP 800-154](https://csrc.nist.gov/publications/detail/sp/800-154/draft)

---

*Version 2.0.0 - Updated 2025-02*
