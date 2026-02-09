---
name: review-code
description: Perform a comprehensive multi-dimensional code review
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: code-reviewer
argument-hint: "[target: file path, PR number, or 'staged']"
---

# Code Review

Perform a thorough code review on $ARGUMENTS.

## Dynamic Context

- Git status: !`git status --short 2>/dev/null`
- Recent changes: !`git diff --stat HEAD~3 2>/dev/null || echo "N/A"`
- Staged changes: !`git diff --cached --stat 2>/dev/null || echo "N/A"`

## Review Target Resolution

- If `$ARGUMENTS` is a number: treat as PR number, fetch with `gh pr diff $ARGUMENTS`
- If `$ARGUMENTS` is `staged`: review `git diff --cached`
- If `$ARGUMENTS` is a file/directory path: review those files
- If empty: review all uncommitted changes

## Review Dimensions

### 1. Correctness

- Does the code fulfill stated requirements?
- Are edge cases handled (null, empty, boundary, concurrent)?
- Are error paths properly managed with appropriate types?
- Is async/concurrent behavior correct (race conditions, deadlocks)?

### 2. Security (OWASP Top 10)

- Input validation and sanitization at trust boundaries
- Authentication/authorization checks for protected operations
- Injection vulnerabilities (SQL, XSS, Command, Path Traversal)
- Sensitive data exposure (logs, error messages, responses)
- Insecure dependencies (known CVEs)

### 3. Performance

- Unnecessary computations, allocations, or copies
- N+1 query patterns and missing DB indexes
- Unbounded data structures (lists, maps without size limits)
- Memory leak potential (unclosed resources, event listener leaks)
- Hot path optimizations

### 4. Maintainability

- Single Responsibility Principle adherence
- DRY violations (duplicated logic that should be shared)
- Appropriate abstraction level (not too much, not too little)
- Clear naming (variables, functions, types)
- Test coverage for new/modified code

### 5. Architecture Consistency

- Follows existing project patterns and conventions
- Proper separation of concerns (layers, modules)
- API contract compatibility (backward-compatible unless intentional)
- Dependency direction (no circular dependencies)

## Output Format

## Code Review Report

### Summary

<!-- One paragraph: what the changes do, overall quality assessment -->

### 🔴 Critical (Must Fix)

1. **[file:line]** Description → Suggested fix

### 🟠 Important (Should Fix)

1. **[file:line]** Description → Suggested fix

### 🟡 Suggestions (Nice to Have)

1. **[file:line]** Description → Suggested improvement

### ✅ Positive Observations

1. Good patterns or improvements worth noting

### Verdict

<!-- One of: ✅ Approved / ⚠️ Approved with minor changes / ❌ Changes requested -->
