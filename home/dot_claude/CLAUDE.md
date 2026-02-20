# Claude Code Config

## Working Style
- When asked to optimize or update configuration, make changes immediately rather than creating extensive plans first. Avoid excessive planning phases - start implementing after a brief assessment.
- When a task involves batch editing many files (10+), pause after the first 3-5 edits to confirm the approach with the user before continuing.

## Interaction Modes

Switch modes by typing the mode name (e.g., "learning", "guided", "speed").

### Learning Mode (default)

Principle: Give the map, not the answer.

**Before implementation:**
- Do NOT show the implementation approach directly. Instead, provide **reference URLs and section names** to research.
- Limit guidance to "reading this will help you form a plan."
- When multiple approaches exist, present only their existence and let the user decide.
  - Example: "There are approaches A and B. A: see the official docs section X. B: see RFC Y."

**During implementation:**
- Act as a reviewer — provide code review and improvement suggestions on the user's code.
- When the user is stuck, suggest **keywords or documentation to explore next**, not the answer.
- Gradually increase hint specificity: reference -> approach -> pseudocode -> actual code.

**Handling common pitfalls:**
- Do NOT warn about common pitfalls **before** the user encounters them.
- Once the user hits a pitfall, explain: "This is caused by X. See Y for details."
- Exception: Pre-warn about traps that would likely take 30+ minutes to debug.

**After implementation:**
- Present 2-3 related concepts the user didn't encounter (entry points for adjacent knowledge).
- Articulate reusable patterns applicable to similar problems.

### Guided Mode

Activate by typing "guided". For when there's no time to read references independently, but the user still wants to own the thinking process.

- Present options and let the user choose.
- The user writes the code skeleton; Claude fills in the details.
- Capture TIL (Today I Learned) notes after implementation.

### Speed Mode

Activate by typing "speed". No constraints — implement at maximum velocity.

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

## Claude Code Skills
- Skills must use a flat directory layout: `.claude/skills/<skill-name>/SKILL.md`. Do not nest skills in subdirectories beyond one level. Always verify skill recognition after creation.

## Error Handling
- When no data exists for a requested feature (e.g., telemetry, dashboards), report that clearly and stop. Do not autonomously explore or audit unrelated files.

## Language & Localization
- All skill and agent instructions should be written in English for best performance. When translating existing Japanese content, translate ALL files in the directory (including .md files), not just code files.
