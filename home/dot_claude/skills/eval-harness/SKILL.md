---
name: eval-harness
description: Formal evaluation framework implementing eval-driven development principles. Use when user says "setup eval harness", "eval framework", or "evaluation-driven development". Defines capability/regression evals with pass@k metrics and multiple grader types.
---

# Eval Harness Skill

A formal evaluation framework for Claude Code sessions, implementing eval-driven development (EDD) principles.

## Philosophy

Eval-Driven Development treats evals as the "unit tests of AI development":
- Define expected behavior BEFORE implementation
- Run evals continuously during development
- Track regressions with each change
- Use pass@k metrics for reliability measurement

## Eval Types

### Capability Evals
Test if Claude can do something it couldn't before:
```markdown
[CAPABILITY EVAL: feature-name]
Task: Description of what Claude should accomplish
Success Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
Expected Output: Description of expected result
```

### Regression Evals
Ensure changes don't break existing functionality:
```markdown
[REGRESSION EVAL: feature-name]
Baseline: SHA or checkpoint name
Tests:
  - existing-test-1: PASS/FAIL
  - existing-test-2: PASS/FAIL
Result: X/Y passed (previously Y/Y)
```

## Grader Types

1. **Code-Based Grader** - Deterministic checks using code (grep, tests, build)
2. **Model-Based Grader** - Claude evaluates open-ended outputs (score 1-5)
3. **Human Grader** - Flag for manual review with risk level

## Metrics

### pass@k
"At least one success in k attempts"
- pass@1: First attempt success rate
- pass@3: Success within 3 attempts
- Typical target: pass@3 > 90%

### pass^k
"All k trials succeed"
- Higher bar for reliability
- pass^3: 3 consecutive successes
- Use for critical paths

## Eval Workflow

1. **Define** (Before Coding) - Capability + regression evals with success metrics
2. **Implement** - Write code to pass defined evals
3. **Evaluate** - Run capability and regression evals
4. **Report** - Generate report with pass@k metrics and status

## Integration

- `/eval define feature-name` - Creates eval definition
- `/eval check feature-name` - Runs and checks evals
- `/eval report feature-name` - Generates full report

## Eval Storage

```
.claude/evals/
  feature-xyz.md      # Eval definition
  feature-xyz.log     # Eval run history
  baseline.json       # Regression baselines
```

## Best Practices

1. Define evals BEFORE coding
2. Run evals frequently
3. Track pass@k over time
4. Use code graders when possible
5. Human review for security
6. Keep evals fast
7. Version evals with code
