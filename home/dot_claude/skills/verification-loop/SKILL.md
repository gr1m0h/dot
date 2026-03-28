---
name: verification-loop
description: Run comprehensive build, type, lint, test, and security verification phases. Use when user says "verification loop", "run all checks", "pre-PR verification", or after completing a feature. Reports overall readiness status.
---

# Verification Loop Skill

A comprehensive verification system for Claude Code sessions.

## When to Use

- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification Phases

### Phase 1: Build Verification
```bash
npm run build 2>&1 | tail -20
```
If build fails, STOP and fix before continuing.

### Phase 2: Type Check
```bash
npx tsc --noEmit 2>&1 | head -30
```

### Phase 3: Lint Check
```bash
npm run lint 2>&1 | head -30
```

### Phase 4: Test Suite
```bash
npm run test -- --coverage 2>&1 | tail -50
```
Report: Total tests, Passed, Failed, Coverage %

### Phase 5: Security Scan
Check for hardcoded secrets and console.log statements.

### Phase 6: Diff Review
```bash
git diff --stat
git diff HEAD~1 --name-only
```
Review each changed file for unintended changes, missing error handling, potential edge cases.

## Output Format

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

Run verification after major changes:
- After completing each function
- After finishing a component
- Before moving to next task
- Run: /verify

## Integration with Hooks

This skill complements PostToolUse hooks but provides deeper verification.
Hooks catch issues immediately; this skill provides comprehensive review.
