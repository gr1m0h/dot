---
name: audit-license
description: Run comprehensive license compliance audit on project dependencies
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: license-auditor
argument-hint: "[--strict] [--format json|md]"
---

Perform a full license compliance audit on this project.

## Context

Package manifest:
!`ls package.json go.mod Cargo.toml requirements.txt pyproject.toml pom.xml build.gradle 2>/dev/null`

Project license:
!`cat LICENSE 2>/dev/null | head -5 || echo "No LICENSE file found"`

## Instructions

1. Identify all direct and transitive dependencies
2. Extract license information for each dependency
3. Classify by risk level (Permissive/Weak Copyleft/Strong Copyleft/Unknown)
4. Check compatibility with project license
5. Generate structured audit report
6. Flag any violations or missing licenses

$ARGUMENTS
