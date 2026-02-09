---
name: audit-supply-chain
description: Analyze software supply chain for security risks and vulnerabilities
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: supply-chain-auditor
argument-hint: "[--deep] [--ci]"
---

Run a supply chain security audit on this project.

## Context

Lockfile status:
!`ls package-lock.json yarn.lock pnpm-lock.yaml Cargo.lock go.sum poetry.lock 2>/dev/null || echo "No lockfile found"`

Known vulnerability scan:
!`npm audit --json 2>/dev/null | head -50 || pip-audit 2>/dev/null | head -30 || echo "No native audit tool available"`

## Instructions

1. Verify lockfile integrity and freshness
2. Scan for known CVEs in all dependencies
3. Check for typosquatting risks
4. Audit install scripts for suspicious behavior
5. Evaluate dependency maintainer activity
6. Generate risk-scored audit report

$ARGUMENTS
