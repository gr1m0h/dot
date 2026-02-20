# Threat Model Output Format

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

## Report Template

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
