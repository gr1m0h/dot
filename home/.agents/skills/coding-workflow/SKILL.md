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
- When repeated fixes relying on the same premise fail the same check, state that premise and test it directly before adding another workaround. Distinguish an incorrect premise from an environmental failure or a legitimate edge case.

## Verify and deliver

Run checks appropriate to the changed behavior. Where relevant, confirm a regression test fails against the old behavior and passes after the fix. Separate existing failures from introduced failures. Report the resulting behavior, checks and actual results, and material remaining risks.

For changes whose safety depends on a non-obvious assumption, identify the one or two facts that matter most. Trace beyond direct callers where relevant: serialized data, configuration consumers, dependency behavior at the pinned version, and lifecycle or cleanup ordering. Use the cheapest meaningful check that invokes the actual implementation to try to disprove the key fact; a copied implementation or a plausible write-up is not execution evidence. Respect existing permission boundaries when choosing that check.

Tie each material safety claim to what was actually established: source inspection, reasoning, an executed test or reproduction, or an observation of the real system. Mark facts that still lack execution evidence as unverified by execution, state the limitation, and distinguish confirmed risks from cases checked and ruled out. Do not require an integration environment or a large report for a routine edit.

When the user wants to implement a part themselves, leave that part to them and provide staged hints or review; carry out the portions assigned to you.

Use `qa-testing` for an explicitly requested broader quality assessment, test strategy, E2E journey, property test, fuzzing, or mutation campaign. Use `pr-review-respond` for existing reviewer comments; it owns that workflow. Do not automatically push, create a PR, publish, or post comments.

## Contracts and operational behavior

For consequential changes, identify observable API/data contracts, timeout/retry behavior, failure recovery, and migration compatibility. Add logging or metrics only where they help detect and diagnose the changed behavior. Do not infer production readiness from local tests.

For LLM features, separate deterministic program contracts from variable model output. Use representative inputs and outcome checks; hand broader reliability/cost/latency assessment to qa-testing when requested. Preserve existing model/provider choices unless changing them is in scope.

Sources: [production-grounded agent evaluation](https://arxiv.org/abs/2604.12162v1) and [focused instructions](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). Applying these to implementation is a design choice, not a measured improvement in this project.

The targeted safety checks and premise revision also draw on pstack's [blast-radius](https://github.com/cursor/plugins/blob/main/pstack/skills/blast-radius/SKILL.md) and [attack-the-premise](https://github.com/cursor/plugins/blob/main/pstack/skills/principle-attack-the-premise/SKILL.md). Adopt the decision criteria without its automatic multi-model execution or broader external-action permissions.
