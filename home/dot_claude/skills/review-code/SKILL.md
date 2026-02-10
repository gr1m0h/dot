---
name: review-code
description: Perform a comprehensive multi-dimensional code review covering correctness, security (OWASP 2025), performance, and maintainability. Use when reviewing pull requests, staged changes, or specific files.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: code-reviewer
argument-hint: "[target: file path, PR number, or 'staged']"
metadata:
  version: "2.0.0"
  updated: "2025-02"
---

# Code Review

Perform a thorough, multi-dimensional code review on $ARGUMENTS.

**Reference:** [Google Engineering Practices](https://google.github.io/eng-practices/review/)

## Review Strategy

When conducting code reviews:

1. Understand the change context (PR description, issue, commit messages)
2. Verify functional correctness against requirements
3. Scan for security vulnerabilities (OWASP Top 10)
4. Evaluate performance implications
5. Assess maintainability and code quality
6. Validate test coverage

## Dynamic Context

- Git status: !`git status --short 2>/dev/null`
- Recent changes: !`git diff --stat HEAD~3 2>/dev/null || echo "N/A"`
- Staged changes: !`git diff --cached --stat 2>/dev/null || echo "N/A"`

## Review Target Resolution

| Input | Action |
|-------|--------|
| Number (e.g., `123`) | Fetch PR diff with `gh pr diff 123` |
| `staged` | Review `git diff --cached` |
| File/directory path | Review those files directly |
| Empty | Review all uncommitted changes |

## Review Dimensions

### 1. Correctness

Verify the code functions as intended:

```markdown
**Checklist:**
- [ ] Fulfills stated requirements from PR/issue description
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error paths properly managed with appropriate types
- [ ] Async/concurrent behavior correct (no race conditions)
- [ ] State mutations are intentional and controlled
```

#### Example: Edge Case Handling

```typescript
// Bad - Missing edge cases
function divide(a: number, b: number): number {
  return a / b;
}

// Good - Proper validation
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new DivisionByZeroError('Cannot divide by zero');
  }
  if (!Number.isFinite(a) || !Number.isFinite(b)) {
    throw new InvalidArgumentError('Arguments must be finite numbers');
  }
  return a / b;
}
```

### 2. Security (OWASP 2025 Top 10)

Scan for common vulnerabilities:

| Category | What to Check |
|----------|--------------|
| A01: Broken Access Control | Authorization checks, CORS, directory traversal |
| A02: Cryptographic Failures | Proper encryption, no hardcoded secrets |
| A03: Injection | Parameterized queries, input sanitization |
| A05: Security Misconfiguration | Debug mode, default credentials |
| A07: Authentication Failures | Session management, password policies |

#### Example: SQL Injection Prevention

```typescript
// Bad - Vulnerable to SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Good - Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```

#### Example: XSS Prevention

```typescript
// Bad - Vulnerable to XSS
element.innerHTML = userInput;

// Good - Safe text content or sanitized HTML
element.textContent = userInput;
// OR with sanitization
element.innerHTML = DOMPurify.sanitize(userInput);
```

### 3. Performance

Identify potential bottlenecks:

```markdown
**Checklist:**
- [ ] No unnecessary computations in hot paths
- [ ] No N+1 query patterns
- [ ] Proper pagination for large datasets
- [ ] Resources properly closed (connections, streams)
- [ ] No memory leaks (event listeners, subscriptions)
```

#### Example: N+1 Query Problem

```typescript
// Bad - N+1 queries
const users = await User.findAll();
for (const user of users) {
  const posts = await Post.findAll({ where: { userId: user.id } });
}

// Good - Eager loading
const users = await User.findAll({
  include: [{ model: Post }]
});
```

### 4. Maintainability

Assess code quality:

```markdown
**Checklist:**
- [ ] Single Responsibility Principle followed
- [ ] No code duplication (DRY)
- [ ] Appropriate abstraction level
- [ ] Clear naming (variables, functions, types)
- [ ] Adequate test coverage for new/modified code
```

#### Example: Clear Naming

```typescript
// Bad - Unclear naming
const d = new Date();
const x = users.filter(u => u.a);

// Good - Descriptive naming
const currentDate = new Date();
const activeUsers = users.filter(user => user.isActive);
```

### 5. Architecture Consistency

Ensure changes align with codebase:

```markdown
**Checklist:**
- [ ] Follows existing project patterns and conventions
- [ ] Proper separation of concerns
- [ ] API contracts maintained (backward compatible)
- [ ] No circular dependencies introduced
- [ ] Error handling consistent with codebase patterns
```

## Severity Classification

| Level | Criteria | Example |
|-------|----------|---------|
| Critical | Security vulnerability, data loss risk, crashes | SQL injection, null pointer in production path |
| Important | Bugs, significant performance issues | Missing error handling, N+1 queries |
| Suggestion | Code quality, minor improvements | Naming, slight refactoring opportunities |
| Positive | Good patterns worth acknowledging | Clean abstractions, comprehensive tests |

## Output Format

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

## Common Anti-Patterns to Flag

### Code Smells

| Pattern | Problem | Solution |
|---------|---------|----------|
| God Class | Single class with too many responsibilities | Split into focused classes |
| Feature Envy | Method uses more data from other classes | Move method to appropriate class |
| Primitive Obsession | Using primitives instead of domain types | Create value objects |
| Long Parameter List | Functions with >3 parameters | Use options object or builder |

### Security Anti-Patterns

| Pattern | Risk | Solution |
|---------|------|----------|
| `eval()` with user input | Code injection | Use safe alternatives |
| Hardcoded credentials | Secret exposure | Use environment variables |
| `dangerouslySetInnerHTML` | XSS | Use sanitization library |
| `shell=True` with user input | Command injection | Use subprocess with array |

## Review Best Practices

1. **Be Constructive** - Suggest solutions, not just problems
2. **Prioritize** - Focus on critical issues first
3. **Explain Why** - Help the author understand the concern
4. **Be Specific** - Reference exact file:line locations
5. **Acknowledge Good Work** - Positive feedback matters

## Related Skills

- [security-scan](/security-scan) - Deep security audit
- [mutation-test](/mutation-test) - Test quality assessment
- [pr-summary](/pr-summary) - PR documentation

## Resources

- [OWASP Top 10 2025](https://owasp.org/Top10/)
- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)

---

*Version 2.0.0 - Updated 2025-02*
