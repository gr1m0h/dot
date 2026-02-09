---
name: tdd
description: Execute a test-driven development workflow with mutation testing and coverage tracking
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
argument-hint: "[feature-name]"
hooks:
  - type: command
    command: |
      node -e "
        const fs = require('fs');
        const found = ['package.json','pytest.ini','pyproject.toml','Cargo.toml','go.mod'].filter(f => { try { fs.accessSync(f); return true; } catch { return false; } });
        if (found.length === 0) { console.log(JSON.stringify({additionalContext:'WARNING: No test framework config found. Install a test framework before starting TDD.'})); }
        else if (found.includes('package.json')) {
          const pkg = JSON.parse(fs.readFileSync('package.json','utf8'));
          const deps = {...pkg.devDependencies,...pkg.dependencies};
          const fw = ['vitest','jest','mocha','ava'].find(t => deps && deps[t]);
          if (!fw) console.log(JSON.stringify({additionalContext:'WARNING: No JS test framework in dependencies. Run npm install -D vitest (or jest) first.'}));
        }
      "
    once: true
---

# Test-Driven Development Workflow

Implement **$ARGUMENTS** using strict TDD methodology.

## Dynamic Context

- Test framework: !`ls package.json 2>/dev/null && node -e "const p=require('./package.json');const d={...p.devDependencies,...p.dependencies};const f=['vitest','jest','mocha','ava','playwright','cypress'].find(t=>d[t]);console.log(f||'unknown')" 2>/dev/null || ls pytest.ini setup.cfg pyproject.toml Cargo.toml go.mod 2>/dev/null | head -1 || echo "unknown"`
- Existing test patterns: !`find . -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' 2>/dev/null | head -5 || echo "No tests found"`
- Source structure: !`ls src/ app/ lib/ 2>/dev/null | head -10 || echo "N/A"`

## Red-Green-Refactor Protocol

### Phase 1: RED - Write Failing Test

1. Create test file following project naming convention
2. Write **one** test case for the simplest expected behavior
3. Run test suite — confirm the test **fails** with expected error
4. If test passes without implementation, the test is wrong — rewrite it

### Phase 2: GREEN - Minimal Implementation

1. Write the **minimum** code to make the failing test pass
2. No optimization, no generalization, no cleanup
3. Run test suite — confirm **all** tests pass (new + existing)
4. If any test fails, fix implementation (not the test)

### Phase 3: REFACTOR - Improve Design

1. Remove duplication in both test and production code
2. Improve naming, extract methods, simplify logic
3. Run test suite after **every** change — maintain green
4. Apply SOLID principles where applicable

### Phase 4: REPEAT

Return to Phase 1 with the next behavior. Continue until feature is complete.

## Cycle Discipline

- **One assertion per test** (except closely related state checks)
- **No production code without a failing test first**
- **No refactoring while red** — get green first, then refactor
- **Commit after each green phase** (small, reversible increments)

## Completion Criteria

Before declaring done:

- [ ] All acceptance criteria covered by tests
- [ ] Edge cases tested (null, empty, boundary, invalid input)
- [ ] Error paths tested (exceptions, failure modes)
- [ ] No skipped or commented-out tests
- [ ] All tests pass in isolation and as suite
- [ ] Existing tests unbroken (no regressions)

## Per-Cycle Report

After each Red-Green-Refactor cycle, report:

```
Cycle [N]:
  Test: [test name and file]
  Status: RED → GREEN → REFACTORED
  Implementation: [file:line changed]
  Tests passing: [X/Y]
```

## Final Summary

```
Feature: $ARGUMENTS
Cycles completed: [N]
Tests added: [N]
Files created: [list]
Files modified: [list]
All tests passing: YES/NO
```
