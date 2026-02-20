# Common Anti-Patterns

## Code Smells

| Pattern | Problem | Solution |
|---------|---------|----------|
| God Class | Single class with too many responsibilities | Split into focused classes |
| Feature Envy | Method uses more data from other classes | Move method to appropriate class |
| Primitive Obsession | Using primitives instead of domain types | Create value objects |
| Long Parameter List | Functions with >3 parameters | Use options object or builder |
| Shotgun Surgery | One change requires edits across many classes | Consolidate related logic |
| Divergent Change | One class changed for many different reasons | Apply SRP, extract classes |
| Data Clumps | Same group of data appears together repeatedly | Extract into a dedicated type/class |
| Dead Code | Unreachable or unused code left in codebase | Delete it entirely |

### Detection Strategy

```bash
# Find large files (potential God Classes)
find . -name "*.ts" -o -name "*.py" | xargs wc -l | sort -rn | head -20

# Find files with many imports (potential high coupling)
grep -c "^import" src/**/*.ts | sort -t: -k2 -rn | head -20

# Find duplicated code patterns
# Use tools like jscpd, PMD CPD, or flay
```

## Security Anti-Patterns

| Pattern | Risk | Solution |
|---------|------|----------|
| `eval()` with user input | Code injection | Use safe alternatives (JSON.parse, AST parsers) |
| Hardcoded credentials | Secret exposure | Use environment variables or secrets manager |
| `dangerouslySetInnerHTML` | XSS | Use DOMPurify sanitization library |
| `shell=True` with user input | Command injection | Use subprocess with array args |
| SQL string concatenation | SQL injection | Use parameterized queries |
| `Math.random()` for tokens | Predictable values | Use `crypto.randomBytes()` or `crypto.getRandomValues()` |
| Logging PII/secrets | Data exposure | Sanitize log output, use structured logging |
| Disabled CSRF protection | Cross-site request forgery | Enable framework CSRF middleware |

### Example: Insecure vs Secure Patterns

```typescript
// Bad - eval with user input
const result = eval(userExpression);

// Good - Safe alternative
const result = JSON.parse(userJson);
// OR use a sandboxed expression parser
const result = mathjs.evaluate(userExpression);
```

```python
# Bad - shell=True with user input
subprocess.run(f"grep {user_query} /var/log/app.log", shell=True)

# Good - subprocess with array
subprocess.run(["grep", user_query, "/var/log/app.log"])
```

```typescript
// Bad - SQL concatenation
const query = `SELECT * FROM users WHERE name = '${name}'`;

// Good - Parameterized query
const query = 'SELECT * FROM users WHERE name = $1';
const result = await db.query(query, [name]);
```

## Performance Anti-Patterns

| Pattern | Problem | Solution |
|---------|---------|----------|
| N+1 Queries | Separate query per item in loop | Use eager loading / batch queries |
| Unbounded Result Sets | No LIMIT on queries | Always paginate |
| Missing Indexes | Full table scans on filtered columns | Add indexes for WHERE/JOIN columns |
| Synchronous I/O in hot paths | Blocks event loop / thread | Use async I/O, move to background |
| Memory leaks | Event listeners / subscriptions not cleaned | Cleanup in componentWillUnmount / useEffect return |
| Unnecessary re-renders | Inline objects/functions as props | Memoize with useMemo/useCallback |
