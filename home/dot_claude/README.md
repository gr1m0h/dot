# Claude Code Configuration

A comprehensive guide to the Claude Code setup, agents, skills, rules, and workflows used for software development.

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Agents](#agents)
4. [Skills](#skills)
5. [Rules & Standards](#rules--standards)
6. [Hooks System](#hooks-system)
7. [Environment Configuration](#environment-configuration)
8. [Workflow Examples](#workflow-examples)
9. [Cost Optimization](#cost-optimization)
10. [Security Practices](#security-practices)

## Overview

This Claude Code configuration provides a comprehensive system for software development with:

- **39 agents** specialized in different domains (planning, testing, security, QA, IoT, etc.)
- **58 reusable skills** for common development tasks
- **18 rule sets** defining coding standards and best practices
- **16 hooks** for automated validation, testing, and quality checks
- **14 environment variables** for system configuration

The system is organized by discipline with clear separation of concerns. Agents are orchestrated to work together, skills provide modular workflow execution, and hooks enforce quality gates at critical points.

## Quick Start

### Common Workflows

#### Feature Implementation
```bash
/plan
# (Review plan)
/tdd
# (Write tests, implement, verify)
/review-code
# (Comprehensive code review)
```

#### Bug Fix
```bash
/build-fix
# (Fix errors incrementally)
/tdd
# (Write tests, verify fix)
/review-code
```

#### Security Audit
```bash
/security-scan
# (Run OWASP Top 10 checks)
/audit-supply-chain
# (Check dependencies)
/review-code
```

#### Release
```bash
/release
# (Auto semantic version, changelog, create release)
```

### Quick Commands

| Command | Purpose | Model |
|---------|---------|-------|
| `/plan` | Create implementation plan | Opus |
| `/tdd` | Test-driven development workflow | Sonnet |
| `/review-code` | Multi-dimensional code review | Sonnet |
| `/quick-fix` | Trivial fixes (typos, renames) | Haiku |
| `/security-scan` | OWASP 2025 Top 10 audit | Opus |
| `/release` | Semantic versioning & release | Sonnet |

## Agents

### Root Agents (9)

Core agents used for primary development tasks.

#### 1. **planner.md** - Implementation Planning
- Decomposes complex features into phases
- Identifies dependencies and risks
- Creates step-by-step execution plan
- **Use when**: Tackling complex features or refactoring

#### 2. **architect.md** - System Design
- Evaluates architectural approaches
- Ensures scalability and maintainability
- Reviews technical decisions
- **Use when**: Making architectural decisions or designing new systems

#### 3. **tdd-guide.md** - Test-Driven Development
- Enforces write-tests-first methodology
- Guides RED → GREEN → IMPROVE cycle
- Tracks test coverage (80%+ minimum)
- **Use when**: Implementing new features or fixing bugs

#### 4. **code-reviewer.md** - Code Review
- Multi-dimensional analysis:
  - Functionality & correctness
  - Security (OWASP 2025)
  - Performance
  - Maintainability & readability
- Provides actionable feedback
- **Use immediately after**: Writing or modifying code

#### 5. **security-reviewer.md** - Security Analysis
- Vulnerability detection
- OWASP Top 10 assessment
- Remediation recommendations
- **Use before**: Commits and releases

#### 6. **build-error-resolver.md** - Error Resolution
- Fixes TypeScript and build errors
- Creates minimal diffs
- Provides clear error explanations
- **Use when**: Build or type errors occur

#### 7. **e2e-runner.md** - End-to-End Testing
- Manages Playwright test suites
- Detects and quarantines flaky tests
- Validates critical user journeys
- **Use when**: Testing user workflows

#### 8. **doc-updater.md** - Documentation
- Maintains architecture documentation
- Syncs docs from source files
- Generates codemaps
- **Use when**: Documentation is out of sync

#### 9. **refactor-cleaner.md** - Code Cleanup
- Identifies dead code (knip, depcheck, ts-prune)
- Consolidates duplicate logic
- Removes unused exports
- **Use when**: Cleaning up codebase

### Cognitive Agents (4)

Specialized for reasoning and knowledge management.

- **confidence-calibrator.md** - Evaluates answer confidence, makes uncertainty explicit
- **context-optimizer.md** - Optimizes context without losing important information
- **ensemble-reasoner.md** - Generates multiple reasoning paths, determines answer by vote
- **memory-consolidator.md** - Converts episodic memory into semantic memory

### IoT/Firmware Agents (3)

For embedded systems development.

- **edge-security.md** - Security audits for IoT and edge firmware
- **firmware-dev.md** - Firmware development with RTOS, memory constraints, HAL
- **protocol-analyzer.md** - Communication protocol analysis

### Leader Agents (4)

High-level orchestration for complex tasks.

- **chief-of-staff.md** - Senior orchestrator with phase decomposition and quality gates
- **loop-operator.md** - Autonomous iteration with circuit breaker (max 10 iterations, 3 errors)
- **orchestrator.md** - Coordinates multi-step tasks with parallel execution
- **task-planner.md** - Decomposes requirements into executable task graphs (TDAG)

### OSS Agents (3)

Open source and licensing management.

- **license-auditor.md** - License compliance audit
- **oss-contributor.md** - Release workflows and changelog generation
- **supply-chain-auditor.md** - Supply chain security (typosquatting, integrity)

### QA Agents (6)

Quality assurance and testing specialists.

- **debugger.md** - Error investigation with ReAct + Reflexion, root cause analysis
- **fuzzer.md** - Fuzz testing for edge cases and vulnerabilities
- **mutation-tester.md** - Test suite quality evaluation via code mutations
- **property-tester.md** - Property-based testing with randomized inputs
- **security-auditor.md** - Comprehensive OWASP 2025 + LLM Top 10 audits
- **code-reviewer.md** - QA-focused code review

### Planning Agents (1)

- **tot-planner.md** - Tree of Thoughts algorithm for exploring multiple solution paths

### Worker Agents (4)

Implementation specialists.

- **coder.md** - Feature implementation with quality checks
- **database-reviewer.md** - Schema design (3NF), query optimization, migration safety
- **harness-optimizer.md** - Token efficiency audit, hook quality, permission security
- **test-writer.md** - Comprehensive test suite design with coverage strategies

### Resilience Agent (1)

- **fallback-handler.md** - Provides alternatives during tool/service failures

### Routing Agents (2)

- **model-selector.md** - Selects optimal model (haiku/sonnet/opus) by task complexity
- **tool-router.md** - Selects optimal tool and suggests efficient usage

### Security Agents (2)

- **reverse-engineer.md** - Code reverse engineering for security research
- **threat-modeler.md** - STRIDE threat modeling with DREAD scoring

### Agent Teams

Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to coordinate multiple agents:

```bash
orchestrate [task]
# Launches coordinated multi-agent execution
```

## Skills

58 reusable skills organized by domain.

### Development Workflow (15 skills)

| Skill | Purpose |
|-------|---------|
| `build-fix` | Incrementally fix TypeScript and build errors |
| `chain` | Execute multiple skills sequentially with data passing |
| `checkpoint` | Create/verify workflow checkpoints with git |
| `code-review` | Comprehensive security and quality review |
| `coding-standards` | Universal TS/JS/React/Node best practices |
| `create-pr` | Analyze changes, generate PR via gh CLI |
| `fix-issue` | Investigate and fix GitHub Issues |
| `orchestrate` | Run multi-agent workflows for complex tasks |
| `parallel` | Execute independent skills in parallel |
| `plan` | Create step-by-step implementation plans |
| `pr-summary` | Generate PR summary with risk assessment |
| `quick-fix` | Lightweight fixes (typos, renames) - Haiku model |
| `release` | Semantic versioning, changelog, release automation |
| `review-code` | Multi-dimensional review (security, performance, style) |
| `verify` | Build, types, lint, tests, security verification |

### Testing (9 skills)

| Skill | Purpose |
|-------|---------|
| `e2e` | Playwright end-to-end testing |
| `eval` | Eval-driven development workflow |
| `eval-harness` | Formal evaluation framework |
| `fuzz` | Fuzz testing for edge cases |
| `mutation-test` | Mutation testing quality evaluation |
| `property-test` | Property-based testing |
| `tdd` | Test-driven development with mutation testing |
| `tdd-workflow` | TDD with 80%+ coverage enforcement |
| `test-coverage` | Coverage analysis and gap finding |

### Security (6 skills)

| Skill | Purpose |
|-------|---------|
| `audit-license` | License compliance audit |
| `audit-supply-chain` | Supply chain security analysis |
| `firmware-audit` | Firmware/embedded security audit |
| `protocol-check` | Communication protocol analysis |
| `security-review` | Auth, input, API, secrets checklist |
| `security-scan` | OWASP 2025 Top 10 audit |

### Architecture & Patterns (3 skills)

- `backend-patterns` - Backend, API design, database optimization
- `frontend-patterns` - React, Next.js, state management, performance
- `project-guidelines-example` - Template for project-specific skills

### Database (3 skills)

- `clickhouse-io` - ClickHouse patterns and optimization
- `mysql` - MySQL best practices
- `postgres` - PostgreSQL best practices

### Documentation (2 skills)

- `update-codemaps` - Generate architecture documentation
- `update-docs` - Sync documentation from sources

### Cost & Context (5 skills)

| Skill | Purpose |
|-------|---------|
| `cost-report` | Token usage and session cost report |
| `dashboard` | Session performance telemetry |
| `manage-context` | Context window optimization |
| `model-route` | Automatic model selection |
| `prompt-optimize` | System prompt efficiency |

### Learning & Memory (5 skills)

| Skill | Purpose |
|-------|---------|
| `continuous-learning` | Extract reusable patterns from sessions |
| `instinct-manage` | View, export, import, evolve patterns |
| `learn` | Extract patterns from current session |
| `reflect` | Structured reflection with Reflexion framework |
| `search-memory` | Search cognitive memory |

### Analysis & Reasoning (5 skills)

| Skill | Purpose |
|-------|---------|
| `ensemble-vote` | Ensemble voting with multiple reasoning paths |
| `harness-audit` | Audit harness configuration for optimization |
| `loop-control` | Manage autonomous improvement loops |
| `reverse-analyze` | Reverse engineering and security analysis |
| `tot` | Tree of Thoughts exploration |

### Refactoring (1 skill)

- `refactor-clean` - Safely remove dead code with test verification

### Threat Modeling (1 skill)

- `threat-model` - STRIDE threat modeling with DREAD scoring

## Rules & Standards

### Root Rules (11)

| Rule | Purpose |
|------|---------|
| `agents.md` | Agent orchestration and parallel execution |
| `coding-style.md` | Immutability, file organization, error handling |
| `continuous-learning.md` | Pattern extraction, instinct lifecycle |
| `git-workflow.md` | Conventional Commits, PR workflow |
| `hooks.md` | Hook types, current hooks, auto-accept |
| `multi-agent.md` | Parallel execution, cascade pipelines |
| `patterns.md` | API response format, custom hooks, repositories |
| `performance.md` | Model selection (haiku/sonnet/opus) |
| `security.md` | Secrets, auth, security response protocol |
| `testing.md` | 80% minimum coverage, TDD workflow |
| `token-optimization.md` | Model routing, strategic compaction |

### Global Rules (4)

Located in `/Users/gr1m0h/.claude/rules/global/`

- **coding-standards.md** - Naming conventions, function design, types
- **cost-optimization.md** - Model selection table, token conservation
- **security.md** - Secrets, input validation, auth, dependencies
- **supply-chain-security.md** - Dependency audit, lockfile protection, updates

### Domain-Specific Rules (3)

- **frontend/react-patterns.md** - Component design, hooks, state, accessibility
- **backend/api-guidelines.md** - Endpoint design, validation, error format
- **cognitive/uncertainty-expression.md** - Confidence levels and uncertainty format

### Key Standards

#### Naming Conventions
```typescript
// Variables and functions: camelCase
const userName = 'John'
function getUserEmail() { }

// Classes and types: PascalCase
class UserService { }
interface User { }

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY = 3
```

#### Immutability (CRITICAL)
```typescript
// CORRECT: Use spread operator
const updated = { ...user, name: 'New' }
const newArray = [...items, newItem]

// WRONG: Mutation
user.name = 'New'       // DON'T
items.push(newItem)     // DON'T
```

#### Error Handling
```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('User-friendly message')
}
```

#### Input Validation
```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## Hooks System

Automated validation and quality checks at critical points.

### Hook Lifecycle Events

| Event | Hooks | Purpose |
|-------|-------|---------|
| **SessionStart** | 1 | Initialize session state |
| **SessionEnd** | 1 | Persist session state |
| **Stop** | 1 | Final cleanup |
| **PreToolUse** | 4 | Pre-execution validation (Bash, Edit/Write, Prettier, SSRF) |
| **PostToolUse** | 6 | Post-execution verification and monitoring |
| **UserPromptSubmit** | 1 | Validate user input before processing |
| **PreCompact** | 1 | Protect sensitive context during compaction |
| **SubagentStart** | 1 | Monitor subagent initialization |
| **SubagentStop** | 1 | Track subagent completion |
| **PostToolUseFailure** | 2 | Recovery and circuit breaker |
| **TeammateIdle** | 1 | Quality gates when idle |
| **TaskCompleted** | 1 | Validate completed tasks |

### Active Hooks

**Pre-Tool Execution:**
- `pre-tool-guard.js` (Bash) - Validate bash command safety
- `pre-tool-guard.js` (Edit/Write) - File operation safety
- `prettier --write` (Edit) - Auto-format before editing
- `ssrf-guard.js` (WebFetch) - SSRF protection

**Post-Tool Execution:**
- `post-tool-verify.js` - Verify file operations
- `architecture-guard.js` - Enforce architecture patterns
- `test-runner.js` - Auto-run related tests
- `cost-monitor.js` - Track session costs
- `telemetry-collector.js` - Collect usage telemetry
- `circuit-breaker.js` - Detect cascading failures

**Failure Handling:**
- `on-failure-recover.js` - Attempt recovery
- `circuit-breaker.js` - Halt on cascading failures

## Environment Configuration

Configuration variables in `settings.json`:

| Variable | Value | Purpose |
|----------|-------|---------|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `50` | Auto-compact at 50% context |
| `DISABLE_AUTOUPDATER` | `1` | Disable auto-updates |
| `DISABLE_MICROCOMPACT` | `1` | Disable micro-compaction |
| `DISABLE_ERROR_REPORTING` | `1` | Disable error reporting |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | `1` | Auto-connect to IDE |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | `1` | Skip IDE auto-install |
| `CLAUDE_CODE_IDE_SKIP_VALID_CHECK` | `1` | Skip IDE validation |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `0` | Disable telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | Reduce background traffic |
| `MAX_THINKING_TOKENS` | `31999` | Max extended thinking |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | Enable agent team orchestration |
| `ENABLE_TOOL_SEARCH` | `auto:8` | Tool search with 8 results |
| `MAX_MCP_OUTPUT_TOKENS` | `50000` | Max MCP output |
| `CLAUDE_CODE_ENABLE_COST_TRACKING` | `1` | Cost tracking enabled |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `haiku` | Default subagent model |
| `ECC_HOOK_PROFILE` | `standard` | Hook profile level |
| `CLAUDE_CODE_ENABLE_WORKTREE_ISOLATION` | `1` | Git worktree isolation |
| `CLAUDE_CODE_MAX_SUBAGENT_DEPTH` | `3` | Max nesting depth |

## Workflow Examples

### Complete Feature Implementation

```bash
# 1. Plan the feature
/plan
# Review: phases, dependencies, risks

# 2. Implement with tests
/tdd
# RED: Write tests
# GREEN: Implement
# IMPROVE: Refactor

# 3. Comprehensive review
/review-code
# Functionality, security, performance, style

# 4. Create pull request
/create-pr
# Auto-generates summary and test plan

# 5. Release
/release
# Semantic versioning, changelog, create release
```

### Security-First Development

```bash
# 1. Security planning
/security-scan
# OWASP 2025 Top 10 audit

# 2. Threat modeling
/threat-model
# STRIDE analysis, DREAD scoring

# 3. Supply chain check
/audit-supply-chain
# Dependency security

# 4. License audit
/audit-license
# Compliance verification

# 5. Code review with security focus
/review-code
```

### Bug Fix Workflow

```bash
# 1. Fix build errors
/build-fix
# Increment through errors

# 2. Reproduce and test
/tdd
# Write test for bug
# Fix bug
# Verify test passes

# 3. Review
/review-code
```

### Database Migration

```bash
# 1. Design schema
# (Review existing schema in postgres.md or mysql.md)

# 2. Implement migration
/tdd
# Write migration test first

# 3. Database review
# Use database-reviewer agent
```

### Refactoring

```bash
# 1. Plan refactoring
/plan

# 2. Clean up dead code
/refactor-clean
# Uses knip, depcheck, ts-prune

# 3. Verify no regressions
/verify
# Build, types, lint, tests, security

# 4. Review
/review-code
```

## Cost Optimization

### Model Selection

Choose the right model for the task:

| Task | Model | Rationale |
|------|-------|-----------|
| Typo fixes, simple renames | **Haiku** | Minimal complexity |
| Code explanation, Q&A | **Haiku/Sonnet** | Reading-focused |
| Feature implementation | **Sonnet** | Balance of capability/cost |
| Architecture design | **Opus** | Complex reasoning |
| Security audits | **Opus** | Thoroughness |

### Token Conservation

**DO:**
- Use `/clear` after major tasks
- Prefer `Glob`/`Grep` over reading entire files
- Request specific line ranges for large files
- Use `Task(Explore)` for open-ended searches
- Batch related questions in single prompts

**DON'T:**
- Read entire codebases "just in case"
- Keep stale context across unrelated tasks
- Request verbose explanations for simple operations
- Run redundant searches for same information

### Session Management

- **Short sessions** (<30 min): Direct work, minimal exploration
- **Long sessions** (>1 hr): Use `/clear` between phases
- **Complex projects**: Plan first, then focused bursts

## Security Practices

### Mandatory Before Commit

- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

### Secret Management

```typescript
// NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variables
const apiKey = process.env.OPENAI_API_KEY
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

### Dependency Management

Before adding dependencies:

1. **Audit first**
   ```bash
   npm audit              # Node.js
   pip-audit              # Python
   cargo audit            # Rust
   ```

2. **Check legitimacy**
   - Verify package name (typosquatting risk)
   - Check download counts and maintenance
   - Review recent commits

3. **Minimize attack surface**
   - Fewer transitive dependencies
   - Recent updates (not 2+ years old)
   - Check Snyk/GitHub Advisory

### Security Response

If a vulnerability is found:

1. **STOP immediately**
2. **Use security-reviewer agent**
3. **Fix CRITICAL issues before continuing**
4. **Rotate exposed secrets**
5. **Review codebase for similar issues**

## Advanced Features

### Agent Team Orchestration

Enable experimental agent teams:
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Launch coordinated multi-agent execution:
```bash
orchestrate [complex task]
```

### Extended Thinking

Use for complex problems requiring deep reasoning:
```bash
/ultrathink
# Enhanced thinking with multiple critique rounds
```

### Context Optimization

Monitor and optimize context window:
```bash
/manage-context
# Audit and optimize context usage
```

### Continuous Learning

Extract and persist patterns from sessions:
```bash
/continuous-learning
# Extract reusable patterns
/instinct-manage
# View, export, import learned patterns
```

## File Structure

```
/Users/gr1m0h/.claude/
├── README.md              # This file
├── CLAUDE.md              # User instructions
├── settings.json          # Configuration
├── agents/                # 39 specialized agents
├── skills/                # 58 reusable skills
├── rules/                 # 18 rule sets
├── memory/
│   ├── local/            # Session-local memory
│   └── semantic/         # Long-term memory
└── hooks/                # Automation hooks
```

## Getting Help

### Find Related Documentation

- **Test-driven development**: See `rules/testing.md`
- **Security guidelines**: See `rules/global/security.md`
- **API design**: See `rules/backend/api-guidelines.md`
- **React patterns**: See `rules/frontend/react-patterns.md`
- **Cost optimization**: See `rules/global/cost-optimization.md`

### Use Specialized Agents

- Complex problems: Use `planner` agent
- Code review: Use `code-reviewer` agent
- Security audit: Use `security-reviewer` agent
- Build errors: Use `build-error-resolver` agent

### Clear Context When Needed

For long sessions, clear context between major phases:
```bash
/clear
```

This resets context while preserving important findings.

---

**Last Updated**: 2026-03-27
**Model**: Claude Opus 4.6 for heavy tasks, Sonnet 4.5 for main development, Haiku 4.5 for lightweight tasks
**Total Configuration**: 39 agents + 58 skills + 18 rules + 16 hooks
