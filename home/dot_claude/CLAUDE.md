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
IMPORTANT: @rules/_core.md — the ONLY always-loaded rule file. Everything below is on-demand (no leading `@` = no auto-load); context/harness/performance doctrine is summarized inline above.

On-demand skills (each loads its own `rules/` detail when triggered):
- Security → `/security-review`, `/security-scan`
- Coding style → `/coding-standards`
- Supply chain → `/audit-supply-chain`, `/audit-license`
- Cost / context → `/manage-context`, `/cost-report`, `/harness-audit`
- Testing → `/tdd`, `/tdd-workflow`, `/test-coverage`
- Git / PR → `/create-pr`, `/pr-summary`, `/release`
- Learning → `/learn`, `/reflect` · Uncertainty → `/ensemble-vote` · Agents → `~/.claude/agents/`

Per-project: in the project `.claude/CLAUDE.md`, load the relevant language file with a leading at-sign — `rules/backend/go-patterns.md` (also ruby/php), `rules/frontend/react-patterns.md`, `rules/backend/api-guidelines.md`.

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
- Mechanical enforcement > documentation rules (detail in `rules/harness-engineering.md`)
- Add constraints only on repeated mistakes; re-evaluate harness complexity on each model upgrade

## Error Handling
- No data for a requested feature → report clearly and stop
- Don't autonomously explore/audit unrelated files
- Security issue → stop, invoke security-reviewer, fix before continuing

## Language
- Skill/agent instructions in English (best LLM performance); when translating Japanese, translate ALL files in the directory
