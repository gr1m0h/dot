---
name: project-guidelines-example
description: Example template for project-specific skills showing architecture, code patterns, testing, and deployment conventions. Use as a reference when creating new project-level skills.
---

# Project Guidelines Skill (Example)

This is an example of a project-specific skill. Use this as a template for your own projects.

Based on a real production application: [Zenith](https://zenith.chat) - AI-powered customer discovery platform.

---

## When to Use

Reference this skill when working on the specific project it's designed for. Project skills contain:
- Architecture overview
- File structure
- Code patterns
- Testing requirements
- Deployment workflow

---

## Architecture Overview

**Tech Stack:**
- **Frontend**: Next.js 15 (App Router), TypeScript, React
- **Backend**: FastAPI (Python), Pydantic models
- **Database**: Supabase (PostgreSQL)
- **AI**: Claude API with tool calling and structured output
- **Deployment**: Google Cloud Run
- **Testing**: Playwright (E2E), pytest (backend), React Testing Library

## File Structure

```
project/
├── frontend/
│   └── src/
│       ├── app/              # Next.js app router pages
│       ├── components/       # React components (ui/, forms/, layouts/)
│       ├── hooks/            # Custom React hooks
│       ├── lib/              # Utilities
│       ├── types/            # TypeScript definitions
│       └── config/           # Configuration
├── backend/
│   ├── routers/              # FastAPI route handlers
│   ├── models.py             # Pydantic models
│   ├── main.py               # FastAPI app entry
│   ├── auth_system.py        # Authentication
│   ├── database.py           # Database operations
│   ├── services/             # Business logic
│   └── tests/                # pytest tests
├── deploy/                   # Deployment configs
├── docs/                     # Documentation
└── scripts/                  # Utility scripts
```

## Code Patterns

### API Response Format (FastAPI)

```python
class ApiResponse(BaseModel, Generic[T]):
    success: bool
    data: Optional[T] = None
    error: Optional[str] = None

    @classmethod
    def ok(cls, data: T) -> "ApiResponse[T]":
        return cls(success=True, data=data)

    @classmethod
    def fail(cls, error: str) -> "ApiResponse[T]":
        return cls(success=False, error=error)
```

### Frontend API Calls (TypeScript)

```typescript
async function fetchApi<T>(endpoint: string, options?: RequestInit): Promise<ApiResponse<T>> {
  try {
    const response = await fetch(`/api${endpoint}`, {
      ...options,
      headers: { 'Content-Type': 'application/json', ...options?.headers }
    })
    if (!response.ok) return { success: false, error: `HTTP ${response.status}` }
    return await response.json()
  } catch (error) {
    return { success: false, error: String(error) }
  }
}
```

## Testing Requirements

### Backend (pytest)
```bash
poetry run pytest tests/
poetry run pytest tests/ --cov=. --cov-report=html
```

### Frontend (React Testing Library)
```bash
npm run test
npm run test -- --coverage
npm run test:e2e
```

## Deployment

```bash
cd frontend && npm run build && gcloud run deploy frontend --source .
cd backend && gcloud run deploy backend --source .
```

## Critical Rules

1. No emojis in code, comments, or documentation
2. Immutability - never mutate objects or arrays
3. TDD - write tests before implementation
4. 80% coverage minimum
5. Many small files - 200-400 lines typical, 800 max
6. No console.log in production code
7. Proper error handling with try/catch
8. Input validation with Pydantic/Zod
