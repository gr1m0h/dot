---
name: fix-issue
description: Systematically investigate and fix a GitHub Issue with root cause analysis
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
argument-hint: "[issue-number]"
hooks:
  - type: command
    command: |
      node -e "
        const { execSync } = require('child_process');
        try { execSync('gh auth status', { stdio: 'pipe' }); }
        catch { console.log(JSON.stringify({additionalContext:'WARNING: gh CLI is not authenticated. Run gh auth login before using /fix-issue.'})); }
      "
    once: true
---

# Fix Issue: #$ARGUMENTS

## Dynamic Context

- Issue details: !`gh issue view $ARGUMENTS 2>/dev/null || echo "Issue not found. Please verify the issue number."`
- Issue comments: !`gh issue view $ARGUMENTS --comments 2>/dev/null | tail -30 || echo ""`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "N/A"`
- Current branch: !`git branch --show-current 2>/dev/null`

## Phase 1: Issue Analysis

1. Read the issue title, description, and all comments
2. Identify:
   - **Expected behavior** vs **actual behavior**
   - **Reproduction steps** (if provided)
   - **Environment constraints** (OS, version, configuration)
   - **Severity and priority** indicators
3. If information is insufficient, list what's missing before proceeding

## Phase 2: Root Cause Investigation

1. Search codebase for relevant code using issue keywords
2. Trace the execution path related to the bug
3. Form ranked hypotheses:
   - H1: Most likely cause (based on symptoms)
   - H2: Second most likely
   - H3: Less likely but possible
4. For each hypothesis, gather evidence to confirm or refute
5. Apply 5-Why analysis on the confirmed cause:

```
Problem: [symptom from issue]
Why 1: [immediate cause]
Why 2: [cause of Why 1]
Why 3: [deeper cause]
Root cause: [fundamental issue]
```

## Phase 3: Fix Implementation

1. Implement the **minimal change** that addresses the root cause
2. Preserve existing behavior for unaffected code paths
3. Follow existing code patterns and conventions
4. Do not refactor surrounding code — fix the bug only

## Phase 4: Regression Test

1. Write a test that **reproduces the original bug** (fails without fix)
2. Verify the test passes with the fix applied
3. Add edge case tests for related scenarios
4. Run the full test suite to confirm no regressions

## Phase 5: Prepare Commit

1. Stage only the relevant files (fix + test)
2. Craft commit message referencing the issue:

```
fix: [concise description of the fix]

Root cause: [brief explanation]
Closes #$ARGUMENTS
```

## Output

```
Issue: #$ARGUMENTS — [title]
Root Cause: [explanation]
Fix: [file:line] — [description of change]
Test: [test file:line] — [what the test verifies]
Regression suite: PASS / FAIL
```
