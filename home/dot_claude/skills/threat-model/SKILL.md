---
name: threat-model
description: Perform STRIDE threat modeling on the application architecture
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: threat-modeler
argument-hint: "[target-component or 'full']"
---

Perform threat modeling on the specified target.

## Context

Architecture overview:
!`cat README.md 2>/dev/null | head -50 || cat ARCHITECTURE.md 2>/dev/null | head -50 || echo "No architecture docs found"`

Authentication:
!`grep -rl "auth\|jwt\|session\|oauth\|passport" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" 2>/dev/null | head -10`

Data stores:
!`grep -rl "database\|redis\|mongo\|postgres\|mysql\|sqlite" --include="*.py" --include="*.js" --include="*.ts" --include="*.go" --include="*.yaml" --include="*.yml" 2>/dev/null | head -10`

## Target: $ARGUMENTS

## Instructions

1. Decompose the system into components and data flows
2. Identify trust boundaries
3. Apply STRIDE analysis to each component and data flow
4. Score risks using DREAD
5. Recommend mitigations for identified threats
6. Generate comprehensive threat model report
