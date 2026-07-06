# Claude Code Config

## Working Style
- Conventional Commits (feat/fix/refactor/test/docs/chore)
- Simple change (single-file/typo/rename): execute immediately
- Multi-file feature: brief spec (what/why/how) first
- Architectural change: spec-driven via `/plan` + review checkpoint before coding
- Batch-editing 10+ files: pause after 3-5 edits to confirm approach

## Output Format
- Produce EXACTLY the format requested (markdown/HTML/Marp/Mermaid); never silently convert
- If the format is ambiguous, confirm before generating

## Verification Before Claims
- Never assert technical facts (IAM behavior, API pricing, tool/library semantics) without citing docs or running a check
- PR reviews: verify each finding against source/docs; mark uncited claims "unverified hypothesis"
- On pushback, demand citations from yourself FIRST rather than restating

## Re-read Before Editing
- `Read` a file immediately before editing — never act on a stale snapshot. Re-read after several tool calls or any external/manual modification.

## Branch & PR Hygiene
- Before a new branch/PR, check existing scope: `gh pr list --search "<keyword> author:@me"`; reuse when scope matches
- Confirm remote branch name before `git push` if it differs from upstream
- Never force-push without explicit approval; first check for clobbered files-apply/Renovate commits
- Treat lockfile deletion and bulk file deletion as destructive: confirm before deleting any lockfile — never assume a bot (e.g. tfaction-bot) will auto-regenerate it

## Context Engineering (2026)
- Context > Prompt; structured context determines model performance
- Progressive Disclosure: domain knowledge in skills, loaded on-demand (prevents CLAUDE.md bloat)
- Context Rot: degradation starts ~300-400k tokens even on 1M windows

## Interaction Modes
Switch by typing the mode name. **Learning Mode is default.**

- **Learning (default)** — Give the map, not the answer. *Before:* give reference URLs/sections to research, not approaches; if approaches differ, name their existence and let the user choose. *During:* review-mode, escalating hints (reference → approach → pseudocode → code); pre-warn only pitfalls costing 30+ min. *After:* surface 2-3 adjacent concepts + the reusable pattern.
- **Guided** — present options, user writes skeleton, Claude fills details; capture TIL notes.
- **Speed** — no constraints, implement at max velocity.

## Rules
Loading mechanism (verified 2026-07 against official docs): EVERY `~/.claude/rules/**/*.md` WITHOUT `paths:` frontmatter auto-loads at launch — `@` references are irrelevant to rules loading.
- Always-loaded: `rules/_core.md` ONLY. Never add another unscoped file to `rules/`.
- Path-scoped (auto-activate when matching files are touched): `coding-style.md`, `testing.md`, `backend/{go,ruby,php}-patterns.md`, `backend/api-guidelines.md`, `frontend/react-patterns.md`.
- On-demand doctrine lives in `~/.claude/docs/` (agents, patterns, git-workflow, harness-engineering, context-engineering, cost-optimization, security, forbidden-apis, llm-security, supply-chain-security, coding-standards, performance, continuous-learning, uncertainty-expression). Read on demand; never move back into `rules/`.

On-demand skills (each loads its own detail when triggered):
- Security → `/security-review`, `/security-scan`
- Coding style → `/coding-standards`
- Supply chain → `/audit-supply-chain`, `/audit-license`
- Cost / context → `/manage-context`, `/cost-report`, `/harness-audit`
- Testing → `/tdd-workflow`, `/test-coverage`
- Git / PR → `/create-pr`, `/pr-summary`, `/release`
- Learning → `/learn`, `/reflect` · Uncertainty → `/ensemble-vote` · Agents → `~/.claude/agents/`

## Session Protocol
1. **Orient**: session state, task list, git log (session-start hook)
2. **Verify**: run tests on existing code before changes
3. **One task** per focused session (prevents context exhaustion)
4. **Implement** with tests (TDD preferred)
5. **Evaluate**: evaluator agent or mechanical checks — never self-assess
6. **Commit**: descriptive message; `/compact` at milestones, `/clear` between projects
7. **Exit**: verify working state, update session state

Recovery: `/rewind` (failed attempts), `/btw` (side questions, no context pollution).

## Evaluation
- Generation and evaluation are SEPARATE — use the evaluator agent after implementing
- Define success criteria BEFORE coding; prefer mechanical checks (linters/tests/CI)
- On FAIL, iterate on specific feedback before committing

## Harness Principles
- This file is a map, not an encyclopedia
- Mechanical enforcement > documentation rules (detail in `~/.claude/docs/harness-engineering.md`)
- Add constraints only on repeated mistakes; re-evaluate harness complexity on each model upgrade

## Error Handling
- No data for a requested feature → report clearly and stop
- Don't autonomously explore/audit unrelated files
- Security issue → stop, invoke security-reviewer, fix before continuing

## PR / Issue Communication Boundary (CRITICAL — user-directive, 2026-07)
- **Never post comments to PRs or Issues autonomously**, including after `git push`. This applies to every session; no exception.
- Prohibited without an EXPLICIT user request in the current turn:
  - `gh pr comment` / `gh issue comment`
  - `gh pr review` (any variant that writes a body)
  - `gh api .../pulls/*/comments` (POST) — inline review comments
  - `gh api .../pulls/*/comments/*/replies` (POST) — reply-to-review
  - `gh api .../issues/*/comments` (POST) — issue comments
- Allowed without asking:
  - `git push` itself
  - PR body edits (`gh api -X PATCH .../pulls/N`) when the user asked to update description
  - PR title / label / assignee edits when explicitly requested
- **Also enforced mechanically** in `~/.claude/settings.json` `permissions.deny` (see `Bash(gh pr comment*)` etc.).
- Rationale: The user manages review conversations directly. Auto-posting reply-to-review, "対応しました" comments, or status updates creates noise and misrepresents human back-and-forth.

## Language
- Skill/agent instructions in English (best LLM performance); when translating Japanese, translate ALL files in the directory
