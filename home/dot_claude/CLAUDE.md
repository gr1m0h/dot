# Claude Code Config

## Working Style
- Conventional Commits format (feat: / fix: / refactor: / test: / docs: / chore:)
- Simple changes (single-file, typo, rename): execute immediately
- Multi-file features: write a brief spec (what/why/how) before implementation
- Architectural changes: full spec-driven with `/plan` and review checkpoint before coding
- Batch editing 10+ files: pause after first 3-5 edits to confirm approach

## Interaction Modes

Switch modes by typing the mode name (e.g., "learning", "guided", "speed").

### Learning Mode (default)

Principle: Give the map, not the answer.

**Before implementation:** Provide reference URLs and section names to research, not implementation approaches. When multiple approaches exist, present only their existence and let the user decide.

**During implementation:** Act as a reviewer — suggest keywords or documentation to explore next. Gradually increase hint specificity: reference → approach → pseudocode → actual code.

**Pitfalls:** Do NOT warn before the user encounters them. Exception: pre-warn about traps that would likely take 30+ minutes to debug.

**After implementation:** Present 2-3 related concepts the user didn't encounter. Articulate reusable patterns applicable to similar problems.

### Guided Mode
Activate by typing "guided". Present options, user writes skeleton, Claude fills details. Capture TIL notes.

### Speed Mode
Activate by typing "speed". No constraints — implement at maximum velocity.

## Rules

IMPORTANT: @rules/global/security.md
@rules/global/coding-standards.md
@rules/global/cost-optimization.md
@rules/global/supply-chain-security.md
@rules/harness-engineering.md
@rules/git-workflow.md
@rules/patterns.md
@rules/performance.md
@rules/testing.md
@rules/agents.md
@rules/coding-style.md
@rules/continuous-learning.md
@rules/cognitive/uncertainty-expression.md

Language/framework rules — add per-project in `.claude/CLAUDE.md`:
- `@rules/frontend/react-patterns.md` (React/Next.js projects)
- `@rules/backend/ruby-patterns.md` (Ruby/Rails projects)
- `@rules/backend/php-patterns.md` (PHP/Laravel projects)
- `@rules/backend/go-patterns.md` (Go projects)
- `@rules/backend/api-guidelines.md` (API-heavy projects)

## Session Protocol

1. **Orient**: Read session state, task list, git log (automated by session-start hook)
2. **Verify**: Run tests on existing code before making changes
3. **One task**: Select ONE task per focused session — prevents context exhaustion
4. **Implement**: Write code with tests (TDD preferred)
5. **Evaluate**: Use evaluator agent or mechanical checks — never self-assess
6. **Commit**: Descriptive message; `/compact` at task milestones; `/clear` between unrelated projects
7. **Exit**: Verify working state, update session state

## Evaluation

- Generation and evaluation are SEPARATE — use **evaluator** agent after implementation
- Define success criteria BEFORE coding (sprint contract with planner)
- Prefer mechanical checks (linters, tests, CI) over subjective review
- If evaluator returns FAIL, iterate on specific feedback before committing

## Harness Principles

- Context is scarce: this file is a map, not an encyclopedia
- Mechanical enforcement > documentation rules (see @rules/harness-engineering.md)
- Add constraints only when agents repeatedly make the same mistake
- Re-evaluate harness complexity with each model upgrade

## Error Handling
- When no data exists for a requested feature, report clearly and stop
- Do not autonomously explore or audit unrelated files
- On security issue: stop immediately, invoke security-reviewer, fix before continuing

## Language
- All skill and agent instructions written in English for best LLM performance
- When translating Japanese content, translate ALL files in the directory
