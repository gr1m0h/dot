---
name: review-code
description: Perform a comprehensive multi-dimensional code review covering correctness, security (OWASP 2025), performance, and maintainability. Use when reviewing pull requests, staged changes, or specific files.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: code-reviewer
argument-hint: "[target: file path, PR number, or 'staged']"
metadata:
  version: "3.0.0"
  updated: "2025-02"
---

# Code Review

Perform a thorough, multi-dimensional code review on $ARGUMENTS.

**Reference:** [Google Engineering Practices](https://google.github.io/eng-practices/review/)

## Review Strategy

When conducting code reviews:

1. Understand the change context (PR description, issue, commit messages)
2. Verify functional correctness against requirements
3. Scan for security vulnerabilities (OWASP Top 10)
4. Evaluate performance implications
5. Assess maintainability and code quality
6. Validate test coverage

## Dynamic Context

- Git status: !`git status --short 2>/dev/null`
- Recent changes: !`git diff --stat HEAD~3 2>/dev/null || echo "N/A"`
- Staged changes: !`git diff --cached --stat 2>/dev/null || echo "N/A"`

## References

| Topic | Reference | Use for |
| --- | --- | --- |
| Review Dimensions | [references/review-dimensions.md](references/review-dimensions.md) | Full 5-dimension review checklists (Correctness, Security, Performance, Maintainability, Architecture) with code examples |
| Output Format | [references/output-format.md](references/output-format.md) | Review target resolution, severity classification, report template, best practices |
| Anti-Patterns | [references/anti-patterns.md](references/anti-patterns.md) | Code smells table, security anti-patterns, performance anti-patterns with examples |

## Related Skills

- [security-scan](/security-scan) - Deep security audit
- [mutation-test](/mutation-test) - Test quality assessment
- [pr-summary](/pr-summary) - PR documentation

## Resources

- [OWASP Top 10 2025](https://owasp.org/Top10/)
- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
