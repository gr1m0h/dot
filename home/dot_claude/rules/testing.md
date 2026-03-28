# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright / Capybara / Laravel Dusk)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist

## Test Frameworks by Language

| Language | Unit | Integration | E2E | Runner |
|----------|------|-------------|-----|--------|
| TypeScript | Vitest / Jest | Supertest | Playwright | `npx vitest` |
| Ruby | RSpec / Minitest | RSpec (request specs) | Capybara | `bundle exec rspec` |
| PHP | PHPUnit / Pest | PHPUnit (feature tests) | Laravel Dusk | `./vendor/bin/phpunit` |
| Go | testing + testify | httptest | chromedp | `go test ./...` |

## Test File Conventions

| Language | Pattern | Example |
|----------|---------|---------|
| TypeScript | `*.test.ts`, `*.spec.ts` | `user.test.ts` |
| Ruby | `*_spec.rb`, `*_test.rb` | `user_spec.rb` |
| PHP | `*Test.php` | `UserTest.php` |
| Go | `*_test.go` | `user_test.go` |
