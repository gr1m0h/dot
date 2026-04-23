# Harness Engineering

Agent = Model + Harness. The bottleneck is never the agent's ability, but the environment design.

## Session Lifecycle Protocol

Every session follows this protocol:
1. **Orient**: Read session-state.json, task list, git log (session-start hook handles this)
2. **Verify baseline**: Run tests on existing code before making changes
3. **Select ONE task**: Focus prevents context exhaustion and maintains recoverability
4. **Implement**: Write code with tests (TDD when applicable)
5. **Evaluate**: Run dedicated evaluation — never self-assess quality
6. **Commit**: Descriptive message; tag known-good states for recovery
7. **Update state**: Mark task complete, document decisions to disk
8. **Clean exit**: Verify working state before ending session

## Evaluation-Driven Development

Generation and evaluation are SEPARATE concerns:
- Never self-assess quality — use evaluator agent or mechanical checks (linters, tests, CI)
- Define success criteria BEFORE implementation (sprint contract with planner)
- Weight evaluation toward agent weaknesses: design completeness, edge cases, feature fidelity
- Evaluator should be tuned to be skeptical — it's easier to calibrate a standalone evaluator than to make a generator self-critical

## Context is a Scarce Resource

"If everything is described as important, the agent stops following the rules." (OpenAI)
- Every token in system prompt competes with working memory
- Load rules progressively: universal rules always, domain rules on-demand
- CLAUDE.md is a navigation map (~100 lines), not an encyclopedia
- Use structured docs/ directory as source of truth; CLAUDE.md points to it

## Mechanical Enforcement Priority

Prefer enforcement that doesn't consume LLM tokens (highest to lowest reliability):
1. **Linter/formatter** — fastest feedback, zero LLM tokens, deterministic
2. **Hook guard** — pre/post tool use, structured error messages with self-correction hints
3. **Agent evaluation** — skeptical reviewer, costs tokens but catches more nuanced issues
4. **Documentation rule** — slowest, least reliable, relies on model attention

If a rule can be a linter check, make it a linter check. If a rule can be a hook, make it a hook.

## Feedback Loop Quality

- Error messages MUST include self-correction instructions (HOW to fix, not just WHAT is wrong)
- Blocked actions should suggest alternatives
- Use structured output (JSON) for cross-session state — JSON resists model-induced corruption better than Markdown
- Task lists: never remove or reorder items, only flip status from incomplete to complete

## Harness Evolution

- Re-evaluate harness complexity with each model upgrade
- Strip scaffolding no longer needed by improved models
- Add constraints only when agents repeatedly make the same mistake
- If a rule never triggers, question whether it's needed
- Test by removing one component at a time — measure impact before restoring

## Anti-Patterns

| Anti-Pattern | Why It Fails |
|--------------|-------------|
| Giant CLAUDE.md (>150 lines) | Model falls back to pattern matching, ignores specific rules |
| Self-assessment of quality | Agents consistently rate their own work too generously |
| Compaction as sole context strategy | "Context anxiety" — agents wrap up prematurely as context fills |
| Documentation without enforcement | Rules without mechanical enforcement are suggestions, not constraints |
| Overloading single agent | Specialized agents outperform generalists on bounded tasks |
