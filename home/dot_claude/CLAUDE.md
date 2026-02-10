# Claude Code Config

## Rules
IMPORTANT: @rules/global/security.md
@rules/global/coding-standards.md
@rules/global/cost-optimization.md
@rules/global/supply-chain-security.md

## Context-Aware Rules
@rules/frontend/react-patterns.md
@rules/backend/api-guidelines.md
@rules/cognitive/uncertainty-expression.md

## Active Hooks
- **Pre**: pre-tool-guard (Bash/Edit/Write), ssrf-guard (WebFetch), prompt-validator (UserPromptSubmit)
- **Post**: post-tool-verify, architecture-guard, test-runner(async), cost-monitor(async), telemetry-collector(async), circuit-breaker(async)
- **Lifecycle**: session-start, session-end, pre-compact-protector (PreCompact), subagent-monitor(async)
- **Recovery**: on-failure-recover, circuit-breaker (PostToolUseFailure)
- **Team**: quality-gate (TeammateIdle), task-validator (TaskCompleted)

## Skills

### Development
- `/quick-fix` - Lightweight fixes (haiku model)
- `/tdd` - Test-driven development (Red-Green-Refactor)
- `/fix-issue` - GitHub Issue investigation and fix
- `/create-pr` - Generate and create PR via gh CLI
- `/pr-summary` - PR summary with risk assessment
- `/release` - Semantic versioning and changelog

### Quality & Testing
- `/review-code` - Multi-dimensional code review
- `/security-scan` - OWASP 2025 security audit
- `/threat-model` - STRIDE threat modeling
- `/mutation-test` - Test suite quality evaluation
- `/property-test` - Property-based test design
- `/fuzz` - Fuzz testing for edge cases

### Analysis
- `/cost-report` - Token usage and cost analysis
- `/dashboard` - Telemetry data visualization
- `/audit-license` - License compliance audit
- `/audit-supply-chain` - Supply chain security analysis
- `/reverse-analyze` - Reverse engineering analysis
- `/protocol-check` - Protocol correctness analysis
- `/firmware-audit` - Firmware security audit

### Cognitive
- `/tot` - Tree of Thoughts problem solving
- `/ensemble-vote` - Ensemble voting for decisions
- `/reflect` - Structured reflection (Reflexion framework)
- `/search-memory` - Cognitive memory search
- `/update-memory` - Cognitive memory persistence and update

### Orchestration
- `/chain` - Sequential skill execution (e.g., `/chain feature`)
- `/parallel` - Parallel skill execution
- `/manage-context` - Context window optimization

## Workflow Patterns
- **Feature**: `/chain feature` -> task-planner -> coder -> test-writer -> code-reviewer
- **Bugfix**: `/chain bugfix` -> debugger -> coder -> test-writer -> code-reviewer
- **Security**: `/chain security-review` -> security-auditor -> code-reviewer -> coder -> security-auditor

## Cost Optimization
- Use `/quick-fix` for trivial changes (haiku model)
- Use `/clear` between major tasks
- Prefer Glob/Grep over full file reads
- Use Task(Explore) for open-ended searches

## Security
- SSRF protection: ssrf-guard hook on WebFetch
- Secret protection: pre-tool-guard on Bash/Edit/Write
- Architecture enforcement: architecture-guard on Edit/Write
- Supply chain: `npm audit` / `pip-audit` before dependencies
