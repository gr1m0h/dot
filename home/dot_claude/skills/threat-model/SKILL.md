---
name: threat-model
description: Perform STRIDE threat modeling on the application architecture. Systematically identify threats, assess risks with DREAD scoring, and recommend mitigations.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: threat-modeler
argument-hint: "[target-component or 'full']"
metadata:
  version: "3.0.0"
  updated: "2025-02"
---

# Threat Modeling

Perform systematic threat modeling on $ARGUMENTS using STRIDE methodology.

**Reference:** [Microsoft Threat Modeling](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool)

## Modeling Strategy

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

## References

| Topic | Reference | Use for |
| --- | --- | --- |
| STRIDE Framework | [references/stride-framework.md](references/stride-framework.md) | Full S/T/R/I/D/E categories with attack vectors, mitigations, audit questions |
| DREAD Assessment | [references/dread-assessment.md](references/dread-assessment.md) | Risk scoring methodology, score guides, example calculations |
| Output Format | [references/output-format.md](references/output-format.md) | DFD notation, report template, attack trees |
| Architecture Patterns | [references/architecture-patterns.md](references/architecture-patterns.md) | Microservices, serverless, SPA threat focus areas |

## Related Skills

- [security-scan](/security-scan) - Automated vulnerability scanning
- [review-code](/review-code) - Code-level security review
- [protocol-check](/protocol-check) - Protocol security analysis

## Resources

- [STRIDE Threat Model](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [NIST SP 800-154](https://csrc.nist.gov/publications/detail/sp/800-154/draft)

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
