# Claude Code Config

## Working Style

- Conventional Commits format (feat: / fix: / refactor: / test: / docs: / chore:)
- Simple changes (single-file, typo, rename): execute immediately
- Multi-file features: write a brief spec (what/why/how) before implementation
- Architectural changes: full spec-driven with `/plan` and review checkpoint before coding
- Batch editing 10+ files: pause after first 3-5 edits to confirm approach

## Output Format Compliance

- When the user explicitly requests a format (markdown, HTML, Marp, Mermaid, etc.), produce EXACTLY that format
- Do not silently convert or substitute formats (e.g., markdown→HTML, or vice versa)
- If the requested format is ambiguous, confirm BEFORE generating rather than guessing

## Verification Before Claims

- Never assert technical facts (AWS IAM behavior, API pricing, tool capabilities, library semantics) without citing official docs or running a check
- For PR reviews, verify each finding against source code or docs before posting; mark uncited claims as "unverified hypothesis"
- When the user pushes back on a claim, demand citations from yourself FIRST rather than restating

## Re-read Before Editing

- Always `Read` a file immediately before editing it, especially in long sessions or after the user mentions making manual changes
- Never act on a stale file snapshot — re-read if more than a few tool calls have passed since the last read
- After a hook reports a file was modified externally, re-read before any further edit

## Branch & PR Hygiene

- Before creating a new branch or PR, check for existing ones covering the same scope: `gh pr list --search "<keyword> author:@me"`
- Reuse the existing PR when scope matches; do not open a duplicate
- Confirm remote branch name with the user before `git push` when it differs from current upstream
- Never force-push without explicit user approval; check for accidental wipe of files-apply / Renovate auto-commits first

## Context Engineering (2026 Core Paradigm)

- Context > Prompt: 構造化されたコンテキスト設計がモデル性能を決定する
- Progressive Disclosure: ドメイン知識はスキルに格納し、オンデマンドでロード（CLAUDE.md肥大化防止）
- Skills-first Loading: 共通パターンを毎回ロードせず、トリガー時のみ展開（トークン30-70%削減）
- Context Rot対策: 1M windowでも300k-400k超でパフォーマンス劣化が始まる

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
@rules/global/llm-security.md
@rules/global/coding-standards.md
@rules/global/cost-optimization.md
@rules/global/supply-chain-security.md
@rules/global/context-engineering.md
@rules/harness-engineering.md
@rules/performance.md

On-demand (loaded by skills when triggered, not always):

- Coding style/patterns → `/coding-standards` skill
- Testing requirements → `/tdd`, `/tdd-workflow`, `/test-coverage` skills
- Git workflow / PR creation → `/create-pr`, `/pr-summary`, `/release` skills
- Continuous learning → `/learn`, `/reflect` skills
- Uncertainty expression → `/ensemble-vote` skill
- Agent orchestration → agents auto-discovered from `~/.claude/agents/`

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

Context recovery: `/rewind` for failed attempts, `/btw` for side questions without context pollution

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
