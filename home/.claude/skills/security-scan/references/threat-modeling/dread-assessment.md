# DREAD Risk Assessment

Score each identified threat (1-10 per category):

| Factor | Description | Score Guide |
|--------|-------------|-------------|
| **D**amage | How much harm if exploited? | 10=Complete system compromise |
| **R**eproducibility | How easy to reproduce? | 10=Always reproducible |
| **E**xploitability | How easy to exploit? | 10=No skill required |
| **A**ffected users | How many users impacted? | 10=All users |
| **D**iscoverability | How easy to discover? | 10=Public knowledge |

## Risk Score Formula

`(D + R + E + A + D) / 5`

| Score | Risk Level | Priority |
|-------|------------|----------|
| 8-10 | Critical | Immediate |
| 5-7 | High | This sprint |
| 3-4 | Medium | Next sprint |
| 1-2 | Low | Backlog |

## Example Scoring

### JWT Forgery (Critical)
- **D**amage: 9 - Full account takeover
- **R**eproducibility: 8 - Consistent with known algorithm
- **E**xploitability: 9 - Publicly known technique
- **A**ffected: 10 - All authenticated users
- **D**iscoverability: 8 - Detectable via token inspection

**Score: (9+8+9+10+8)/5 = 8.8 (Critical)**

### Missing Rate Limiting (Medium)
- **D**amage: 4 - Service degradation
- **R**eproducibility: 9 - Easy to reproduce
- **E**xploitability: 7 - Simple tooling available
- **A**ffected: 6 - Users during attack window
- **D**iscoverability: 5 - Requires endpoint enumeration

**Score: (4+9+7+6+5)/5 = 6.2 (High)**
