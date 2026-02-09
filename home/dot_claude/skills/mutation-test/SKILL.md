---
name: mutation-test
description: Run mutation testing to evaluate test suite quality
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
agent: mutation-tester
argument-hint: "[target-directory] [--threshold 80]"
---

Run mutation testing to evaluate test suite quality.

## Context

Test suite status:
!`npm test -- --passWithNoTests 2>&1 | tail -5 || pytest --co -q 2>&1 | tail -5 || go test ./... 2>&1 | tail -5 || echo "Could not detect test runner"`

## Target: $ARGUMENTS

## Instructions

1. Verify baseline test suite passes
2. Configure mutation testing tool for the project language
3. Run mutation testing on target directory
4. Analyze survived mutants
5. Report mutation score and identify weak test areas
6. Suggest additional tests to kill survived mutants
