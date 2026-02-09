---
name: parallel
description: Execute independent skills in parallel
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
---

# Parallel Skill Execution

Executes independent skills in parallel and integrates the results.

## Syntax

```
/parallel skill1 | skill2 | skill3
```

## Parallel Execution Rules

### 1. Independence Verification

Skills executed in parallel must not depend on each other

### 2. Result Integration

Integrate results after all skills have completed

### 3. Failure Handling

- Default: Entire operation fails if any one fails
- --continue-on-error: Ignore failures and continue

## Usage Examples

```
# Parallel code review
> /parallel code-reviewer | security-auditor | performance-audit

# Parallel investigation
> /parallel search-memory | tot "solution"
```

## Integrated Output Format

```markdown
## Parallel Execution Results

### skill1 (completed in Xs)

[Result 1]

### skill2 (completed in Ys)

[Result 2]

### skill3 (completed in Zs)

[Result 3]

### Summary

- Total time: max(X, Y, Z)s (parallel) vs X+Y+Zs (sequential)
- All succeeded: Yes/No
```
