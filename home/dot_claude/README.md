# Claude Code Configuration

Personal Claude Code configuration for development workflows, security enforcement, and AI-assisted coding.

## Directory Structure

```
.claude/
├── CLAUDE.md              # Main instructions & interaction modes
├── agents/                # 34 specialized agent definitions
├── skills/                # 52 reusable slash-command skills
├── rules/                 # 14 policy & guideline documents
├── hooks/                 # 16 JavaScript automation hooks
├── memory/                # Persistent knowledge & session state
└── settings.json          # Claude Code settings
```

## Interaction Modes

Configured in `CLAUDE.md`. Switch by typing the mode name.

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Learning** (default) | — | Hints & references first, code last |
| **Guided** | `guided` | Present options, user writes skeleton, Claude fills in |
| **Speed** | `speed` | Maximum velocity, no constraints |

## Agents

34 agent definitions organized by domain. Agents are spawned via the `Task` tool with `subagent_type`.

### Core (top-level)

| Agent | Purpose |
|-------|---------|
| `planner` | Implementation planning for complex features |
| `architect` | System design & architectural decisions |
| `tdd-guide` | Test-driven development enforcement |
| `code-reviewer` | Multi-dimensional code review |
| `security-reviewer` | Security vulnerability analysis |
| `build-error-resolver` | Build/type error fixes |
| `e2e-runner` | Playwright E2E testing |
| `refactor-cleaner` | Dead code cleanup |
| `doc-updater` | Documentation maintenance |

### Specialized (subdirectories)

| Category | Agents |
|----------|--------|
| **cognitive/** | confidence-calibrator, context-optimizer, ensemble-reasoner, memory-consolidator |
| **iot/** | edge-security, firmware-dev, protocol-analyzer |
| **leader/** | orchestrator, task-planner |
| **oss/** | license-auditor, oss-contributor, supply-chain-auditor |
| **planning/** | tot-planner |
| **qa/** | code-reviewer, debugger, fuzzer, mutation-tester, property-tester, security-auditor |
| **resilience/** | fallback-handler |
| **routing/** | model-selector, tool-router |
| **security/** | reverse-engineer, threat-modeler |
| **worker/** | coder, test-writer |

## Skills

52 slash-command skills invoked via `/skill-name`. Each lives in `skills/<name>/SKILL.md`.

### Development & Quality

| Skill | Description |
|-------|-------------|
| `/plan` | Create implementation plans |
| `/tdd` | TDD workflow with mutation testing |
| `/tdd-workflow` | Test-driven development enforcement |
| `/build-fix` | Incremental TypeScript/build error fixes |
| `/quick-fix` | Lightweight fixes using haiku model |
| `/review-code` | Comprehensive code review |
| `/code-review` | Security-focused review blocking commits |
| `/refactor-clean` | Dead code removal |
| `/test-coverage` | Coverage analysis & missing test generation |
| `/verify` | Codebase verification (quick/full/pre-commit/pre-pr) |
| `/e2e` | Playwright E2E tests |

### Security & Compliance

| Skill | Description |
|-------|-------------|
| `/security-scan` | OWASP 2025 Top 10 audit |
| `/security-review` | Auth, input, secrets checklist |
| `/threat-model` | STRIDE threat modeling |
| `/audit-license` | License compliance audit |
| `/audit-supply-chain` | Supply chain risk analysis |
| `/firmware-audit` | Firmware security audit |

### Analysis & Testing

| Skill | Description |
|-------|-------------|
| `/fuzz` | Fuzz testing setup |
| `/mutation-test` | Mutation testing for test quality |
| `/property-test` | Property-based test design |
| `/protocol-check` | Protocol implementation analysis |
| `/reverse-analyze` | Reverse engineering analysis |
| `/tot` | Tree of Thoughts exploration |
| `/ensemble-vote` | Ensemble voting for decisions |

### Database

| Skill | Description |
|-------|-------------|
| `/postgres` | PostgreSQL best practices |
| `/mysql` | MySQL best practices |
| `/clickhouse-io` | ClickHouse analytics patterns |

### Workflow & Automation

| Skill | Description |
|-------|-------------|
| `/create-pr` | Generate and create PRs |
| `/pr-summary` | PR summary with risk assessment |
| `/fix-issue` | Investigate and fix GitHub Issues |
| `/release` | Semantic versioning & changelog |
| `/orchestrate` | Multi-agent sequential workflows |
| `/parallel` | Execute skills in parallel |
| `/chain` | Execute skills sequentially |
| `/checkpoint` | Git-based workflow checkpoints |
| `/eval` | Eval-driven development |

### Knowledge & Context

| Skill | Description |
|-------|-------------|
| `/update-memory` | Persist knowledge to memory system |
| `/search-memory` | Retrieve from memory system |
| `/update-docs` | Sync documentation |
| `/update-codemaps` | Architecture documentation |
| `/manage-context` | Context window optimization |
| `/learn` | Extract reusable patterns |
| `/continuous-learning` | Auto-extract session patterns |
| `/reflect` | Structured reflection on completed work |
| `/strategic-compact` | Manual context compaction |

### Reference

| Skill | Description |
|-------|-------------|
| `/coding-standards` | Universal coding standards |
| `/frontend-patterns` | React/Next.js patterns |
| `/backend-patterns` | API/server patterns |
| `/cost-report` | Token usage & cost estimates |
| `/dashboard` | Telemetry dashboard |

## Rules

14 policy documents enforced across all sessions.

| File | Scope |
|------|-------|
| `global/security.md` | Secrets, input validation, auth, forbidden patterns |
| `global/coding-standards.md` | Naming, functions, imports, types |
| `global/cost-optimization.md` | Model selection, token conservation |
| `global/supply-chain-security.md` | Dependency auditing, lockfile protection |
| `git-workflow.md` | Conventional commits, PR workflow, feature workflow |
| `coding-style.md` | Immutability, file organization, error handling |
| `patterns.md` | API response format, hooks, repository pattern |
| `performance.md` | Model selection strategy, context management |
| `testing.md` | 80% coverage minimum, TDD mandatory |
| `agents.md` | Agent orchestration & parallel execution |
| `hooks.md` | Hook types & auto-accept permissions |
| `security.md` | Pre-commit checklist, secret management |
| `frontend/react-patterns.md` | Components, hooks, state, a11y |
| `backend/api-guidelines.md` | RESTful design, validation, middleware |
| `cognitive/uncertainty-expression.md` | Confidence-based expression levels |

## Hooks

16 JavaScript hooks for automated enforcement.

### Pre-Tool Guards

| Hook | Purpose |
|------|---------|
| `pre-tool-guard.js` | Block secrets in Bash/Edit/Write |
| `ssrf-guard.js` | SSRF protection on WebFetch |
| `architecture-guard.js` | Enforce architecture rules on Edit/Write |
| `pre-compact-protector.js` | Protect critical context before compaction |
| `prompt-validator.js` | Validate prompts |

### Post-Tool Actions

| Hook | Purpose |
|------|---------|
| `post-tool-verify.js` | Verification after tool execution |
| `test-runner.js` | Run tests after code changes |

### System Monitoring

| Hook | Purpose |
|------|---------|
| `circuit-breaker.js` | Circuit breaker for failing operations |
| `cost-monitor.js` | Track and warn on cost thresholds |
| `quality-gate.js` | Quality enforcement gates |
| `task-validator.js` | Validate task definitions |
| `subagent-monitor.js` | Monitor spawned agents |
| `telemetry-collector.js` | Collect usage telemetry |

### Session Lifecycle

| Hook | Purpose |
|------|---------|
| `session-start.js` | Session initialization |
| `session-end.js` | Session cleanup |
| `on-failure-recover.js` | Recovery on failure |

## Workflow Patterns

Standard workflows combining skills and agents:

```
Feature:  /plan -> planner -> architect -> /tdd -> /review-code
Bugfix:   /build-fix -> build-error-resolver -> /tdd -> /review-code
TDD:      /tdd -> tdd-guide -> test-writer -> /review-code
Security: /security-scan -> security-reviewer -> /review-code
Refactor: /refactor-clean -> refactor-cleaner -> /review-code
```

## Cost Optimization

- Haiku model for trivial changes (`/quick-fix`)
- Sonnet for standard development
- Opus for architecture & security audits
- `/clear` between major tasks
- `Glob`/`Grep` preferred over full file reads
- `Task(Explore)` for open-ended searches
