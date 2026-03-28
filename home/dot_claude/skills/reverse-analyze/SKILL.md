---
name: reverse-analyze
description: Perform reverse engineering analysis on code or binary for security research. Use when user says "reverse engineer", "analyze binary", "decompile", or investigating undocumented systems and legacy code.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: reverse-engineer
argument-hint: "[target-file-or-directory]"
---

Perform reverse engineering analysis for security research.

## Context

Target files:
!`file $1 2>/dev/null || echo "Target not specified"`

## Target: $ARGUMENTS

## Instructions

1. Identify the target type (source code, binary, protocol capture)
2. Perform appropriate static analysis
3. Document architecture and key components
4. Identify security-relevant behaviors
5. Extract indicators of compromise if applicable
6. Generate structured analysis report
