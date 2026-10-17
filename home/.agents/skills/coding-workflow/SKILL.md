---
name: coding-workflow
description: Implement features, fix bugs, and refactor with focused regression checks. Use for assigned code changes, not standalone QA campaigns.
---

# Focused Implementation

## Scope and orient

Verify the repository and working state, read applicable instructions, and identify the requested behavior and completion criteria. Preserve unrelated changes. For multi-file features, state what/why/how first; follow the architectural review checkpoint when applicable.

## Implement

- For bugs, reproduce the symptom and locate the mechanism before changing code. Write a meaningful failing regression test first when practical, then make the focused fix.
- For features, specify observable success and failure behavior and implement a coherent slice. Prefer existing project conventions and dependencies over introducing a new framework.
- For refactoring, preserve behavior and establish suitable checks. Treat dead-code tools as evidence: verify dynamic imports, public exports, configuration, and external consumers before removal.
- Re-read each file immediately before editing. Follow existing architecture, error handling, and observability conventions; explain material tradeoffs rather than enforcing generic rules mechanically.
- Own tests necessary for the implementation. Do not invoke a separate QA workflow for every edit, require a universal coverage percentage, or add tests that merely repeat implementation details.

## Verify and deliver

Run checks appropriate to the changed behavior. Where relevant, confirm a regression test fails against the old behavior and passes after the fix. Separate existing failures from introduced failures. Report the resulting behavior, checks and actual results, and material remaining risks.

When the user wants to implement a part themselves, leave that part to them and provide staged hints or review; carry out the portions assigned to you.

Use `qa-testing` for an explicitly requested broader quality assessment, test strategy, E2E journey, property test, fuzzing, or mutation campaign. Use `pr-review-respond` for existing reviewer comments; it owns that workflow. Do not automatically push, create a PR, publish, or post comments.

## Contracts and operational behavior

For consequential changes, identify observable API/data contracts, timeout/retry behavior, failure recovery, and migration compatibility. Add logging or metrics only where they help detect and diagnose the changed behavior. Do not infer production readiness from local tests.

For LLM features, separate deterministic program contracts from variable model output. Use representative inputs and outcome checks; hand broader reliability/cost/latency assessment to qa-testing when requested. Preserve existing model/provider choices unless changing them is in scope.

Sources: [production-grounded agent evaluation](https://arxiv.org/abs/2604.12162v1) and [focused instructions](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). Applying these to implementation is a design choice, not a measured improvement in this project.
