---
name: property-test
description: Design and implement property-based tests that verify invariants across randomized inputs. Use when user says "property test", "invariant test", "fuzz inputs", or wants to discover edge cases that example-based tests miss.
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
context: fork
agent: property-tester
argument-hint: "[target-module-or-function]"
---

Design and implement property-based tests for the specified target.

## Context

Existing test framework:
!`ls jest.config* vitest.config* pytest.ini pyproject.toml Cargo.toml 2>/dev/null | head -5`

## Target: $ARGUMENTS

## Instructions

1. Analyze target code and identify algebraic properties (roundtrip, idempotency, invariants, etc.)
2. Design generators for input types
3. Implement property tests using the project's framework
4. Run tests and verify all properties hold
5. Report any counterexamples found
