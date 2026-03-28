# Go Patterns

## Code Style

- Follow `gofmt` / `goimports` (non-negotiable)
- Keep packages small and focused
- Accept interfaces, return structs
- Use `context.Context` as first parameter
- Prefer composition over inheritance (embedding)

## Project Layout

```
cmd/           # Entry points (main packages)
internal/      # Private application code
pkg/           # Public library code (use sparingly)
api/           # API definitions (proto, OpenAPI)
config/        # Configuration
migrations/    # Database migrations
```

## Error Handling

- Always check errors — never use `_` for error returns
- Wrap errors with context: `fmt.Errorf("operation failed: %w", err)`
- Use sentinel errors for known conditions
- Use custom error types for domain errors

```go
var ErrNotFound = errors.New("not found")

type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}
```

## Interface Pattern

```go
// Define interfaces at the consumer side, not the provider
type UserStore interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Create(ctx context.Context, user *User) error
}

// Implementation
type postgresUserStore struct {
    db *sql.DB
}

func NewUserStore(db *sql.DB) UserStore {
    return &postgresUserStore{db: db}
}
```

## Handler Pattern (net/http)

```go
type Handler struct {
    store  UserStore
    logger *slog.Logger
}

func (h *Handler) GetUser(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    user, err := h.store.FindByID(r.Context(), id)
    if err != nil {
        if errors.Is(err, ErrNotFound) {
            http.Error(w, "user not found", http.StatusNotFound)
            return
        }
        h.logger.Error("failed to find user", "error", err)
        http.Error(w, "internal error", http.StatusInternalServerError)
        return
    }
    json.NewEncoder(w).Encode(user)
}
```

## Concurrency

- Use goroutines + channels for concurrent work
- Use `sync.WaitGroup` for fan-out/fan-in
- Use `errgroup.Group` for concurrent operations with error handling
- Always use `context.Context` for cancellation
- Use `sync.Mutex` only when channels are not appropriate

## Testing

- Use table-driven tests for comprehensive coverage
- Use `testify/assert` for readable assertions
- Use `httptest.NewServer` for HTTP testing
- Use interfaces for dependency injection in tests
- Use `t.Parallel()` for independent tests

```go
func TestGetUser(t *testing.T) {
    tests := []struct {
        name     string
        id       string
        wantCode int
    }{
        {"valid", "123", http.StatusOK},
        {"not found", "999", http.StatusNotFound},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            // test implementation
        })
    }
}
```

## Security

- Use `crypto/rand` for random values (never `math/rand`)
- Use `html/template` for HTML (auto-escapes)
- Use `database/sql` with parameterized queries
- Use `net/http` timeout configuration
- Validate all external input at handler boundary

## Performance

- Use `sync.Pool` for frequently allocated objects
- Use `strings.Builder` for string concatenation
- Profile with `pprof` before optimizing
- Use `context.WithTimeout` to prevent hanging operations
- Prefer `[]byte` over `string` for large data processing
