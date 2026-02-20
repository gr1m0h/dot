# Review Dimensions

## 1. Correctness

Verify the code functions as intended:

**Checklist:**
- [ ] Fulfills stated requirements from PR/issue description
- [ ] Edge cases handled (null, empty, boundary values)
- [ ] Error paths properly managed with appropriate types
- [ ] Async/concurrent behavior correct (no race conditions)
- [ ] State mutations are intentional and controlled

### Example: Edge Case Handling

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

## 2. Security (OWASP 2025 Top 10)

Scan for common vulnerabilities:

| Category | What to Check |
|----------|--------------|
| A01: Broken Access Control | Authorization checks, CORS, directory traversal |
| A02: Cryptographic Failures | Proper encryption, no hardcoded secrets |
| A03: Injection | Parameterized queries, input sanitization |
| A05: Security Misconfiguration | Debug mode, default credentials |
| A07: Authentication Failures | Session management, password policies |

### Example: SQL Injection Prevention

```typescript
// Bad - Vulnerable to SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Good - Parameterized query
const query = 'SELECT * FROM users WHERE id = $1';
const result = await db.query(query, [userId]);
```

### Example: XSS Prevention

```typescript
// Bad - Vulnerable to XSS
element.innerHTML = userInput;

// Good - Safe text content or sanitized HTML
element.textContent = userInput;
// OR with sanitization
element.innerHTML = DOMPurify.sanitize(userInput);
```

## 3. Performance

Identify potential bottlenecks:

**Checklist:**
- [ ] No unnecessary computations in hot paths
- [ ] No N+1 query patterns
- [ ] Proper pagination for large datasets
- [ ] Resources properly closed (connections, streams)
- [ ] No memory leaks (event listeners, subscriptions)

### Example: N+1 Query Problem

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

## 4. Maintainability

Assess code quality:

**Checklist:**
- [ ] Single Responsibility Principle followed
- [ ] No code duplication (DRY)
- [ ] Appropriate abstraction level
- [ ] Clear naming (variables, functions, types)
- [ ] Adequate test coverage for new/modified code

### Example: Clear Naming

```typescript
// Bad - Unclear naming
const d = new Date();
const x = users.filter(u => u.a);

// Good - Descriptive naming
const currentDate = new Date();
const activeUsers = users.filter(user => user.isActive);
```

## 5. Architecture Consistency

Ensure changes align with codebase:

**Checklist:**
- [ ] Follows existing project patterns and conventions
- [ ] Proper separation of concerns
- [ ] API contracts maintained (backward compatible)
- [ ] No circular dependencies introduced
- [ ] Error handling consistent with codebase patterns
