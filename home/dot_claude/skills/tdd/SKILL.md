---
name: tdd
description: Execute a test-driven development workflow with mutation testing and coverage tracking. Ensures high-quality, well-tested code through Red-Green-Refactor cycles.
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
argument-hint: "[feature-name]"
metadata:
  version: "3.0.0"
  updated: "2025-02"
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

# Test-Driven Development

Implement **$ARGUMENTS** using strict TDD methodology.

**Reference:** [Test-Driven Development by Example (Kent Beck)](https://www.oreilly.com/library/view/test-driven-development/0321146530/)

## TDD Strategy

The TDD workflow follows a strict cycle:

1. **RED** - Write a failing test first
2. **GREEN** - Write minimal code to pass
3. **REFACTOR** - Clean up while keeping tests green
4. **REPEAT** - Add next behavior

## Dynamic Context

- Test framework: !`ls package.json 2>/dev/null && node -e "const p=require('./package.json');const d={...p.devDependencies,...p.dependencies};const f=['vitest','jest','mocha','ava','playwright','cypress'].find(t=>d[t]);console.log(f||'unknown')" 2>/dev/null || ls pytest.ini setup.cfg pyproject.toml Cargo.toml go.mod 2>/dev/null | head -1 || echo "unknown"`
- Existing test patterns: !`find . -name '*.test.*' -o -name '*.spec.*' -o -name '*_test.*' 2>/dev/null | head -5 || echo "No tests found"`
- Source structure: !`ls src/ app/ lib/ 2>/dev/null | head -10 || echo "N/A"`
- Coverage config: !`cat jest.config.* vitest.config.* pytest.ini pyproject.toml 2>/dev/null | grep -i coverage | head -3 || echo "N/A"`

## References

| Topic | Reference | Use for |
| --- | --- | --- |
| Red-Green-Refactor | [references/red-green-refactor.md](references/red-green-refactor.md) | Full TDD protocol with JS/Python examples, cycle discipline rules |
| Test Patterns | [references/test-patterns.md](references/test-patterns.md) | Test types, naming conventions, test doubles, common pitfalls |
| Coverage & Reporting | [references/coverage-and-reporting.md](references/coverage-and-reporting.md) | Coverage targets, per-cycle reports, completion criteria, summary template |

## Related Skills

- [mutation-test](/mutation-test) - Verify test quality
- [property-test](/property-test) - Property-based testing
- [review-code](/review-code) - Code review

## Resources

- [Test-Driven Development by Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- [Growing Object-Oriented Software, Guided by Tests](http://www.growing-object-oriented-software.com/)
- [The Art of Unit Testing](https://www.manning.com/books/the-art-of-unit-testing-third-edition)

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
