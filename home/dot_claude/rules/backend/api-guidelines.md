---
paths:
    - "src/api/**/*.ts"
    - "src/routes/**/*.ts"
    - "src/server/**/*.ts"
    - "app/api/**/*.ts"
---

# API Development Rules

## Endpoint Design

- RESTful resource naming: plural nouns (`/users`, `/orders`), no verbs in paths
- Use appropriate HTTP methods: GET (read), POST (create), PUT (full replace), PATCH (partial update), DELETE (remove)
- Consistent URL patterns: `/resources/:id/sub-resources`
- Version APIs when breaking changes are unavoidable: `/v1/users`
- Return appropriate status codes: 200, 201, 204, 400, 401, 403, 404, 409, 422, 429, 500

## Input Validation

- Validate **all** input at the controller/handler layer before business logic
- Use schema validation libraries (Zod, Joi, Yup, Pydantic) — not manual checks
- Reject unknown fields (strict mode) to prevent mass assignment
- Validate path parameters, query parameters, headers, and body
- Set maximum payload size limits

## Error Response Format

All error responses must follow a consistent structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

- Use machine-readable error codes (SCREAMING_SNAKE_CASE)
- Include field-level details for validation errors
- Never expose internal implementation details, stack traces, or SQL errors

## Middleware & Cross-Cutting Concerns

- **Authentication**: Verify tokens/sessions before handler execution
- **Authorization**: Check permissions per-endpoint (default deny)
- **Rate limiting**: Apply per-user and per-IP limits on all endpoints
- **Request logging**: Log method, path, status code, duration (not request bodies with PII)
- **CORS**: Configure explicitly per-route, never use wildcard in production
- **Request ID**: Generate and propagate unique request ID for tracing

## Database Access

- Use an ORM or query builder — never raw SQL string concatenation
- Parameterize all queries — no user input interpolation
- Use transactions for multi-step operations that must be atomic
- Paginate list endpoints — never return unbounded result sets
- Add database indexes for frequently queried fields
- Use connection pooling — never open/close connections per request

## Response Design

- Return consistent response shapes per resource type
- Include pagination metadata for list endpoints: `{ data: [], meta: { total, page, pageSize } }`
- Use camelCase for JSON field names
- Return only the fields the client needs — don't expose internal model fields
- Set appropriate `Cache-Control` headers for cacheable responses
