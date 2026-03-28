# Multi-Agent Orchestration

## Parallel Execution

ALWAYS parallelize independent operations:
- Multiple file reads → single message, multiple Read calls
- Independent searches → parallel Grep/Glob calls
- Unrelated agent tasks → parallel Task calls

## Iterative Retrieval Pattern

Progressive context refinement:
1. Broad search: Glob for file patterns
2. Narrow: Grep for specific content
3. Deep: Read targeted file sections
4. Verify: Cross-reference with related files

## Subagent Strategy

| Task Type | Subagent | Model |
|-----------|----------|-------|
| Codebase exploration | Explore | haiku |
| Implementation plan | planner | sonnet |
| Architecture review | architect | opus |
| Code review | code-reviewer | sonnet |
| Security analysis | security-reviewer | opus |
| Build error fixing | build-error-resolver | sonnet |
| Multi-step coordination | orchestrator | sonnet |

## Context Isolation

- Use `isolation: "worktree"` for risky file modifications
- Delegate exploratory work to subagents to preserve main context
- Chain results between agents via Task resume (agent ID)

## Cascade Pipeline

Standard feature pipeline:
1. **Plan** (planner) → implementation strategy
2. **Implement** (coder) → write code
3. **Test** (tdd-guide) → verify behavior
4. **Review** (code-reviewer) → quality check
5. **Security** (security-reviewer) → vulnerability scan

Run steps 4 and 5 in parallel when possible.
