---
name: audit-supply-chain
description: Analyze the software supply chain for security risks AND license compliance. Use when user says "audit supply chain", "dependency security", "check for typosquatting", "audit licenses", "check license compliance", "dependency licenses", before adding new dependencies, or before releasing open source software. Checks provenance, signatures, known vulnerabilities, and classifies licenses by risk level.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: supply-chain-auditor
argument-hint: "[--deep] [--ci] [--licenses-only] [--strict]"
---

Run a supply chain audit on this project: security risks and, when relevant or requested,
license compliance. `--licenses-only` skips the security half; `--strict` tightens license
classification.

## Context

Lockfile status:
!`ls package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock go.sum poetry.lock 2>/dev/null || echo "No lockfile found"`

Known vulnerability scan:
!`npm audit --json 2>/dev/null | head -50 || pip-audit 2>/dev/null | head -30 || echo "No native audit tool available"`

Project license:
!`cat LICENSE 2>/dev/null | head -5 || echo "No LICENSE file found"`

## Security audit

1. Verify lockfile integrity and freshness
2. Scan for known CVEs in all dependencies
3. Check for typosquatting risks
4. Audit install scripts for suspicious behavior
5. Evaluate dependency maintainer activity

## License compliance (when releasing OSS, `--licenses-only`, or license issues surface)

1. Identify all direct and transitive dependencies
2. Extract license information for each dependency
3. Classify by risk level (Permissive / Weak Copyleft / Strong Copyleft / Unknown)
4. Check compatibility with the project license
5. Flag any violations or missing licenses

## Output

One risk-scored audit report covering both halves (omit whichever was skipped),
with severity → action per `rules/_core.md` (Critical/High = BLOCK, Medium = warn+document,
Low = allow+monitor).

$ARGUMENTS
