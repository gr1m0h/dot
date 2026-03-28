# Claude Code Config

## Working Style
- Conventional Commits format (feat: / fix: / refactor: / test: / docs: / chore:)
- Simple changes (single-file, typo, rename): execute immediately
- Multi-file features: write a brief spec (what/why/how) before implementation
- Architectural changes: full spec-driven with `/plan` and review checkpoint before coding
- Batch editing 10+ files: pause after first 3-5 edits to confirm approach
- `/compact` at task milestones; `/clear` between unrelated projects

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
@rules/git-workflow.md
@rules/patterns.md
@rules/performance.md
@rules/testing.md
@rules/agents.md
@rules/frontend/react-patterns.md
@rules/backend/api-guidelines.md
@rules/cognitive/uncertainty-expression.md
@rules/token-optimization.md
@rules/multi-agent.md
@rules/continuous-learning.md

## Token Optimization

| Strategy | Action |
|----------|--------|
| Exploration / trivial fixes | Route to Haiku (`/quick-fix`) |
| Implementation | Sonnet (default) |
| Architecture / security audit | Opus |
| Subagent workers | `CLAUDE_CODE_SUBAGENT_MODEL=haiku` |
| Thinking budget | `MAX_THINKING_TOKENS=10000` (default); 31999 for deep reasoning only |
| MCP servers | Fewer than 10 per project |
| Compaction | Strategic (`/compact`) > auto; trigger at task milestones |
| Context pollution | Delegate exploration to subagents; use `Task(Explore)` |
| Token tracking | `/context-budget` for real-time usage; `/model-route` for auto-selection |

Auto-compaction threshold: 50%. Prefer manual `/compact` with summary prompt before that limit.

## Multi-Agent Orchestration

- **Parallel execution**: Always run independent operations in parallel (never sequential when avoidable)
- **Iterative retrieval**: Start broad (`Glob`/`Grep`), narrow progressively — avoid full-file reads
- **Subagent isolation**: Delegate to subagents to prevent main context pollution
- **Git worktree isolation**: Use `git worktree` for risky or experimental operations
- **Cascade pipeline**: plan → implement → test → review (never skip stages)
- **chief-of-staff agent**: Use for complex multi-step coordination across multiple files or services
- **loop-operator agent**: Use for autonomous iteration loops (retry, self-correction, convergence checks)
- Use agent teams only when parallelism provides clear, measurable value

## Workflow Patterns

| Workflow | Pipeline |
|----------|----------|
| Feature | `/plan` → planner → architect → `/tdd` → `/review-code` |
| Bugfix | `/build-fix` → build-error-resolver → `/tdd` → `/review-code` |
| TDD | `/tdd` → tdd-guide → test-writer → `/review-code` |
| Security | `/security-scan` → security-reviewer → `/review-code` |
| Refactor | `/refactor-clean` → refactor-cleaner → `/review-code` |
| Multi-Agent | `/multi-plan` → `/multi-execute` → `/quality-gate` |
| Loop | `/loop-start` → loop-operator → `/loop-status` → `/quality-gate` |
| Learning | `/learn` → `/instinct-status` → `/evolve` → `/promote` |
| Database | architect → database-reviewer → `/tdd` → `/review-code` |

## Continuous Learning

- **Pattern extraction**: Run `/learn` after solving any non-trivial problem
- **Instinct system**: Confidence scoring 0.0–1.0 for learned patterns
- **Skill evolution**: Instincts graduate to skills when confidence > 0.8
- **Management commands**: `/instinct-status`, `/instinct-export`, `/instinct-import`
- **Session memory**: Persist via hooks to `.claude/memory/local/`
- **Cross-session context**: Reference memory files at session start for continuity

## Harness Optimization

- `/harness-audit` to score current setup quality
- Hook runtime profile: `ECC_HOOK_PROFILE=minimal|standard|strict`
- Strategic compaction: always `/compact` with a targeted summary prompt rather than relying on auto-compaction
- Background process management: use `run_in_background` for long-running tasks; poll with check commands, never sleep loops
- System prompt slimming: remove redundant rules, consolidate duplicates, keep CLAUDE.md under 200 lines

## Cost Optimization

- Use `/quick-fix` for trivial changes (Haiku model)
- Use `/clear` between major unrelated tasks
- Prefer `Glob`/`Grep` over full file reads
- Use `Task(Explore)` for open-ended searches
- `/context-budget` for real-time token tracking
- `CLAUDE_CODE_SUBAGENT_MODEL=haiku` for worker agents in multi-agent systems
- `/model-route` for automatic model selection per task type

## Security

- SSRF protection: ssrf-guard hook on WebFetch
- Secret protection: pre-tool-guard on Bash/Edit/Write
- Architecture enforcement: architecture-guard on Edit/Write
- Supply chain: `npm audit` / `pip-audit` before adding dependencies
- AgentShield: validate agent inputs/outputs at trust boundaries
- Pre-compact protection: snapshot sensitive context before `/compact`
- Circuit breaker: halt cascading failures after 3 consecutive tool errors
- PostToolUseFailure recovery hooks: log, alert, and roll back on critical failures

## Skills Format
- Flat directory layout: `.claude/skills/<skill-name>/SKILL.md`
- Do not nest skills in subdirectories beyond one level

## Error Handling
- When no data exists for a requested feature, report clearly and stop
- Do not autonomously explore or audit unrelated files
- On security issue: stop immediately, invoke security-reviewer, fix before continuing

## Language
- All skill and agent instructions written in English for best LLM performance
- When translating Japanese content, translate ALL files in the directory
