# Claude Code Config

## Working Style
- Conventional Commits format (feat: / fix: / refactor: / test: / docs: / chore:)
- Use `/clear` in long sessions to refresh context
- Make changes immediately rather than creating extensive plans first
- Batch editing 10+ files: pause after first 3-5 edits to confirm approach

## Interaction Modes

Switch modes by typing the mode name (e.g., "learning", "guided", "speed").

### Learning Mode (default)

Principle: Give the map, not the answer.

**Before implementation:**
- Provide **reference URLs and section names** to research, not implementation approaches.
- When multiple approaches exist, present only their existence and let the user decide.

**During implementation:**
- Act as a reviewer — suggest **keywords or documentation to explore next**, not the answer.
- Gradually increase hint specificity: reference -> approach -> pseudocode -> actual code.

**Handling common pitfalls:**
- Do NOT warn about pitfalls **before** the user encounters them.
- Exception: Pre-warn about traps that would likely take 30+ minutes to debug.

**After implementation:**
- Present 2-3 related concepts the user didn't encounter.
- Articulate reusable patterns applicable to similar problems.

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

## Workflow Patterns
- **Feature**: `/plan` → planner → architect → `/tdd` → `/review-code`
- **Bugfix**: `/build-fix` → build-error-resolver → `/tdd` → `/review-code`
- **TDD**: `/tdd` → tdd-guide → test-writer → `/review-code`
- **Security**: `/security-scan` → security-reviewer → `/review-code`
- **Refactor**: `/refactor-clean` → refactor-cleaner → `/review-code`

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

## Skills Format
- Flat directory layout: `.claude/skills/<skill-name>/SKILL.md`
- Do not nest skills in subdirectories beyond one level

## Error Handling
- When no data exists for a requested feature, report clearly and stop
- Do not autonomously explore or audit unrelated files

## Language
- All skill and agent instructions written in English for best performance
- When translating Japanese content, translate ALL files in the directory
