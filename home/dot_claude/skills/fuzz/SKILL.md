---
name: fuzz
description: Set up and run fuzz testing on target functions or modules
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
agent: fuzzer
argument-hint: "<target-function-or-file> [--iterations N] [--strategy mutation|generation]"
---

Set up and run fuzz testing for the specified target.

## Context

Project language:
!`ls *.go go.mod 2>/dev/null && echo "Go" || ls Cargo.toml 2>/dev/null && echo "Rust" || ls package.json 2>/dev/null && echo "JavaScript/TypeScript" || ls *.py pyproject.toml 2>/dev/null && echo "Python" || echo "Unknown"`

## Target: $ARGUMENTS

## Instructions

1. Identify the target function/module and its input types
2. Select appropriate fuzzing framework for the language
3. Create fuzz harness with seed corpus
4. Configure fuzzing parameters (iterations, timeout)
5. Run fuzz campaign
6. Triage and report findings with minimized reproductions
