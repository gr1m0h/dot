# Agent Orchestration

## Available Agents

Located in `~/.claude/agents/`:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| planner | Implementation planning | Complex features, refactoring |
| architect | System design | Architectural decisions |
| evaluator | Skeptical evaluation | After implementation, against success criteria |
| tdd-guide | Test-driven development | New features, bug fixes |
| code-reviewer | Code review | After writing code |
| security-reviewer | Security analysis | Before commits |
| build-error-resolver | Fix build errors | When build fails |
| e2e-runner | E2E testing | Critical user flows |
| refactor-cleaner | Dead code cleanup | Code maintenance |
| doc-updater | Documentation | Updating docs |

## Immediate Agent Usage

No user prompt needed:
1. Complex feature requests → **planner** agent
2. Code just written/modified → **code-reviewer** agent
3. Implementation complete → **evaluator** agent (separate from generator)
4. Bug fix or new feature → **tdd-guide** agent
5. Architectural decision → **architect** agent

## Parallel Execution

ALWAYS parallelize independent operations:
- Multiple file reads → single message, multiple Read calls
- Independent searches → parallel Grep/Glob calls
- Unrelated agent tasks → parallel Task calls
- Review + security → run code-reviewer and security-reviewer in parallel

## Iterative Retrieval

Progressive context refinement (never read entire files upfront):
1. Broad: Glob for file patterns
2. Narrow: Grep for specific content
3. Deep: Read targeted file sections
4. Verify: Cross-reference with related files

## Subagent Strategy

Haiku 4.5 is credible for short-context coding and notably cheaper than Sonnet/Opus.
Confirm current capability/price ratios against official model docs before fixing a tier.

| Task Type | Subagent | Model | Notes |
|-----------|----------|-------|-------|
| Codebase exploration | Explore | haiku | Fresh context per child |
| Implementation plan | planner | sonnet | Balance of capability/cost |
| Architecture review | architect | opus | Complex cross-system reasoning |
| Code review | code-reviewer | sonnet | Standard complexity |
| Skeptical evaluation | evaluator | sonnet | Independent from generator |
| Security analysis | security-reviewer | opus | Thoroughness critical |
| Build error fixing | build-error-resolver | sonnet | Incremental fixing |
| Multi-step coordination | orchestrator | sonnet | Team coordination |
| Simple lookups, Q&A | general-purpose | haiku | Cost-efficient |

## Context Isolation

- Use `isolation: "worktree"` for risky file modifications
- Delegate exploratory work to subagents to preserve main context
- Chain results between agents via Task resume (agent ID)

## Cascade Pipeline

Standard feature pipeline:
1. **Plan** (planner) → implementation strategy + success criteria
2. **Implement** (coder) → write code with tests
3. **Evaluate** (evaluator) → grade against success criteria
4. **Review** (code-reviewer) → quality check
5. **Security** (security-reviewer) → vulnerability scan

Run steps 4 and 5 in parallel. Loop back to 2 if evaluator returns FAIL.

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
