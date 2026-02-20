# Code Review Output Format

## Review Target Resolution

| Input | Action |
|-------|--------|
| Number (e.g., `123`) | Fetch PR diff with `gh pr diff 123` |
| `staged` | Review `git diff --cached` |
| File/directory path | Review those files directly |
| Empty | Review all uncommitted changes |

## Severity Classification

| Level | Criteria | Example |
|-------|----------|---------|
| Critical | Security vulnerability, data loss risk, crashes | SQL injection, null pointer in production path |
| Important | Bugs, significant performance issues | Missing error handling, N+1 queries |
| Suggestion | Code quality, minor improvements | Naming, slight refactoring opportunities |
| Positive | Good patterns worth acknowledging | Clean abstractions, comprehensive tests |

## Report Template

```markdown
## Code Review Report

### Summary
<!-- One paragraph: what the changes do, overall quality assessment -->

### Review Scope
- Files reviewed: X
- Lines changed: +Y / -Z
- Test coverage: X%

### Findings

#### Critical (Must Fix)
1. **[file:line]** Description
   - Impact: Why this matters
   - Suggested fix: How to resolve

#### Important (Should Fix)
1. **[file:line]** Description
   - Suggested fix

#### Suggestions (Nice to Have)
1. **[file:line]** Description

#### Positive Observations
1. Good patterns or improvements worth noting

### Verdict
<!-- One of: Approved / Approved with minor changes / Changes requested -->

### Checklist
- [ ] All critical issues resolved
- [ ] Tests pass
- [ ] Documentation updated (if needed)
```

## Review Best Practices

1. **Be Constructive** - Suggest solutions, not just problems
2. **Prioritize** - Focus on critical issues first
3. **Explain Why** - Help the author understand the concern
4. **Be Specific** - Reference exact file:line locations
5. **Acknowledge Good Work** - Positive feedback matters
