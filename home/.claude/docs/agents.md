# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/` (worker default model: sonnet via `CLAUDE_CODE_SUBAGENT_MODEL`):

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| architect | Grounded design packages for consequential changes | New-feature design, large refactors, irreversible technical decisions |
| code-reviewer | Evidence-based diff review | After writing code, when a fresh-context review is wanted |
| security-reviewer | Scoped security assessment + whole-codebase audits | Input/auth/API/sensitive-data changes; OWASP/LLM Top 10 audits |
| qa-engineer | Targeted acceptance/E2E/property/fuzz/mutation/LLM-eval campaigns | QA campaigns, test-quality questions (pairs with qa-testing skill) |
| sre-investigator | Operational evidence, incident timelines, hypothesis discrimination | Incidents, outages, SLO/error-budget reasoning (pairs with sre-operations skill) |
| doc-editor | Documentation and article editing | Project docs, codemaps, blog editing (pairs with write-article skill) |
| database-reviewer | Schema/query/migration review | After writing migrations or heavy queries |
| batch-worker | Restricted background worker for /batch | Batch dispatch only; never publishes |

Deliberately NOT agents: planning (built-in plan mode), evaluation/verification of your
own work (Fable 5/Opus 4.5+ self-verify — mechanical checks suffice; official guidance
since 2026-07), TDD enforcement and build fixing (main-loop work, coding-workflow skill),
dead-code cleanup (coding-workflow + knip/depcheck/ts-prune).

## Delegation Rules

- Delegate work that benefits from fresh context or parallelism: exploration (Explore),
  investigation, report drafting, independent multi-file tracks, reviews.
- Do NOT delegate: work finishable in a handful of tool calls, or verification of your
  own output. One subagent when one suffices; keep spawn counts low.
- Give every subagent an objective, output format, tool boundaries, and an effort budget
  (multi-agent pays off for breadth-first parallelizable work; tightly-coupled coding
  stays single-agent — Anthropic multi-agent research system post).
- Parallelize independent operations in one message (multiple Reads, Greps, agent calls).
  Agents touching the same working tree: `isolation: "worktree"` or run them serially.

## Iterative Retrieval

Progressive context refinement (never read entire files upfront):
1. Broad: Glob for file patterns
2. Narrow: Grep for specific content
3. Deep: Read targeted file sections
4. Verify: Cross-reference with related files

## Model Routing

Haiku for lookups and bulk simple transforms; sonnet as default worker; opus for
architecture and security depth. Confirm capability/price against official model docs
before fixing a tier (see rules/_core.md Cost / Model Routing).
