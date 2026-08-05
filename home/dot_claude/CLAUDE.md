# Claude Code Config

## Working Style
- Conventional Commits (feat/fix/refactor/test/docs/chore)
- Simple change (single-file/typo/rename): execute immediately
- Multi-file feature: brief spec (what/why/how) first
- Architectural change: spec-driven via `/plan` + review checkpoint before coding
- Batch-editing 10+ files: pause after 3-5 edits to confirm approach

### Client work (顧客リポジトリ = 個人 org 以外の org 配下 — org-leak-guard が ghq 兄弟 org を自動識別。登録ファイルは廃止済み 2026-08・org 名は public dotfiles に書かない)
- **Spec-first (enforced)**: any non-trivial task → 3-line spec (what/why/how) **+ 成果物形式 + 完了条件** and wait for approval before working. #1 friction is wrong_approach (24/81 sessions); one approval round is cheaper than five correction rounds.
- **Delegate-first**: if the request is investigation/research/report-shaped, propose running it as a subagent or background task and let the user step away, instead of interactive back-and-forth.
- **Task closure**: when a client-repo task wraps up, suggest `/sreaas:task report` before the session ends — every task leaves a visible artifact (成果の見える化 = 裁量労働の成果証明).

## Output Format
- Produce EXACTLY the format requested (markdown/HTML/Marp/Mermaid); never silently convert
- If the format is ambiguous, confirm before generating
- Written deliverables: match length to what the task needs — no filler sections, redundant summaries, or boilerplate
- Show drafted outbound content (comments, PR bodies, report text) in full BEFORE any post/publish/confirm step

## Verification Before Claims
- Never assert technical facts (IAM behavior, API pricing, tool/library semantics) without citing docs or running a check
- PR reviews: verify each finding against source/docs; mark uncited claims "unverified hypothesis"
- On pushback, demand citations from yourself FIRST rather than restating

## Re-read Before Editing
- `Read` a file immediately before editing — never act on a stale snapshot. Re-read after several tool calls or any external/manual modification.
- Verify the working directory/path before trusting search results — a wrong cwd invalidates the whole search

## Branch & PR Hygiene
- Confirm remote branch name before `git push` if it differs from upstream
- Never force-push without explicit approval; first check for clobbered files-apply/Renovate commits
- PR creation & push only on explicit user request in the current task — draft first (also ask-gated in permissions; scope-check lives in the create-pr skill)
- Bulk file deletion is destructive: confirm first (lockfile deletion is hook-blocked by pre-tool-guard)

## Interaction Modes
**Speed is default** — no constraints, implement at max velocity (throughput first; learning is recaptured via the Learning Loop below, not blended into delivery).
Only other mode: `/mode learning` (map not answers). Switching criterion is time-and-place — client work = Speed, study time (personal repos / `~/learn/`) = learning — never task type. Collaborative styles during work ("I'll write the skeleton") are ad-hoc instructions, not a mode. Details + learn-map/learn-coach routing live in the skill.

## Learning Loop (Speed-mode compensation)
- **Learning flag**: in Speed mode, when work relies on a concept/tool/behavior the user likely hasn't internalized (new tech, non-obvious semantics, a decision they couldn't have articulated themselves), flag it in one line in the final message. No log file — the user picks up flagged topics via `/learn-map` when they choose. Don't flag basics or things the user demonstrably knows.
- **Ship check**: before creating a PR / delivering client-facing work, present a 3-sentence customer-facing explanation (課題 → 打ち手 → 効果) for the user to confirm or correct. If they hesitate, offer a 5-minute explainer instead of shipping blind.
- **Recapture (mechanized 2026-08)**: learn skill owns the human-learning lifecycle (`~/learn/BACKLOG.md`; verbs = add 捕捉 / review 選別 / start 変換 / done 定着, no-arg = status); /batch is execution only. Hook auto-queues `personal: retro-learn` when 7 days past `last-retro:` and surfaces `LEARN_BACKLOG` / retro state every session. Session-pattern skill-ification (→ `skills/learned/`) moved to `/reflect` (absorbed old /learn default). `/reflect` / case-reflect at case milestones.

## Rules
Loading mechanism (verified 2026-07 against official docs): EVERY `~/.claude/rules/**/*.md` WITHOUT `paths:` frontmatter auto-loads at launch — `@` references are irrelevant to rules loading.
- Always-loaded: `rules/_core.md` ONLY. Never add another unscoped file to `rules/`.
- Path-scoped (auto-activate when matching files are touched): `coding-style.md`, `testing.md`, `backend/{go,ruby,php}-patterns.md`, `backend/api-guidelines.md`, `frontend/react-patterns.md`.
- On-demand doctrine lives in `~/.claude/docs/` (agents, patterns, git-workflow, harness-engineering, context-engineering, cost-optimization, security, forbidden-apis, llm-security, supply-chain-security, coding-standards, performance, continuous-learning, uncertainty-expression). Read on demand; never move back into `rules/`.

On-demand skills trigger from their own descriptions; non-obvious routing only:
- SREaaS ops → `/batch` (朝バッチ投入), `/investigation-report` (調査→報告書); 夜間ドラフトは Desktop ルーチンのプロンプトで `/sreaas:task` `/sreaas:monthly` を draft-only 実行
- `/audit-supply-chain` は license compliance 込み · Agents → `~/.claude/agents/`

## Delegation & Parallelism
- Main session = 司令塔 (spec, review, decisions). Execution fans out to background subagents / worktrees / workflows.
- Delegate: investigation, report drafting, batch fixes, independent multi-file tracks. Morning queue → `/batch`; investigation-shaped → `/investigation-report`; multi-phase fan-out → Workflow (opt-in).
- Do NOT delegate: work finishable in a handful of tool calls; verification of your own work (the model self-verifies). One subagent when one suffices; keep spawn counts low (Opus 5 guide, 2026-07).
- Parallel tracks use `isolation: worktree`; every track ends in a reviewable artifact (diff + verification + recommendation) — never auto-published.
- While agents run, the user reviews finished artifacts instead of watching progress — throughput comes from review bandwidth, not typing speed.

## Session Protocol
1. **Orient**: session state, task list, git log (session-start hook)
2. **Verify**: run tests on existing code before changes
3. **One task** per focused session (prevents context exhaustion)
4. **Implement** with tests (TDD preferred)
5. **Evaluate**: mechanical checks (linters/tests/CI) — the model self-verifies; no extra verification passes
6. **Commit**: descriptive message; `/compact` at milestones, `/clear` between projects
7. **Exit**: verify working state, update session state

Recovery: `/rewind` (failed attempts), `/btw` (side questions, no context pollution).

## Evaluation
- Define success criteria BEFORE coding; prefer mechanical checks (linters/tests/CI)
- Opus 5+ / Fable 5 self-verify: do NOT add "verify with a subagent" / "double-check" steps — over-verification wastes tokens with no quality gain (official prompting guide, 2026-07)
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
- **Never post comments to PRs or Issues autonomously**, including after `git push`. Every session; no exception. Prohibited without an EXPLICIT user request in the current turn: `gh pr comment` / `gh issue comment` / `gh pr review` (body-writing variants) / `gh api` POST to `*/comments` or `*/replies`.
- Allowed when explicitly requested (no extra confirmation beyond the permission prompt): `git push`; PR body/title/label/assignee edits.
- Also enforced mechanically in `settings.json` `permissions.deny`. Rationale: the user manages review conversations directly — auto-posted replies and status comments create noise and misrepresent human back-and-forth.

## Language
- Skill/agent instructions in English (best LLM performance); when translating Japanese, translate ALL files in the directory
