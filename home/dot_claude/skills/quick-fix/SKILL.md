---
name: quick-fix
description: Lightweight fixes for typos, simple renames, and trivial refactoring. Uses haiku model for cost efficiency.
user-invocable: true
allowed-tools: Read, Edit, Glob, Grep
context: fork
model: haiku
argument-hint: "[target: file path or description of fix]"
metadata:
  version: "1.0.0"
  updated: "2026-02"
---

# Quick Fix

Perform a quick, lightweight fix on $ARGUMENTS.

This skill uses the **haiku model** for cost efficiency on simple tasks.

## Scope

This skill is designed for:

| Task Type | Examples |
|-----------|----------|
| Typo fixes | Variable names, comments, strings |
| Simple renames | Function/variable renaming (single file) |
| Trivial refactoring | Extract constant, inline variable |
| Import fixes | Add missing imports, remove unused |
| Comment updates | Fix outdated comments, add JSDoc |

## NOT Suitable For

- Multi-file refactoring
- Logic changes
- Feature implementation
- Security-sensitive code
- Complex architecture changes

Use `/review-code` or full agent for those tasks.

## Workflow

1. **Identify** - Locate the target code
2. **Verify** - Confirm the fix is simple and safe
3. **Apply** - Make the minimal change
4. **Confirm** - Verify no unintended side effects

## Examples

### Typo Fix
```
/quick-fix Fix typo in src/utils.ts line 42
```

### Simple Rename
```
/quick-fix Rename `getUserData` to `fetchUserData` in api.ts
```

### Import Cleanup
```
/quick-fix Remove unused imports in components/Header.tsx
```

## Output Format

```markdown
## Quick Fix Applied

**Target:** [file:line]
**Change:** [brief description]

### Before
[code snippet]

### After
[code snippet]

**Status:** Complete
```

## Cost Efficiency

This skill:
- Uses haiku model (lowest cost tier)
- Minimizes context by reading only necessary files
- Makes single, focused edits
- Avoids unnecessary exploration

Estimated cost: ~0.1-0.3 units per fix

---

*Version 1.0.0 - 2026-02*
