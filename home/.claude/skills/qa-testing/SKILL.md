---
name: qa-testing
description: Assess product quality with targeted acceptance, E2E, property, fuzz, mutation, or LLM evaluations. Use for QA campaigns and test-quality questions.
---

# QA and Testing

## Choose the question and evidence

Identify the user journey, contract or risk, target environment, and observable acceptance criteria. Inspect the existing test setup before selecting tools. Distinguish product acceptance, functional correctness, robustness, and test-suite effectiveness.

Choose only the methods that answer the question:

| Method | Use |
|---|---|
| Acceptance / exploratory QA | User outcomes, confusing behavior, missing requirements, and failure recovery |
| Unit / integration | Boundaries, error paths, state transitions, and component contracts |
| E2E | Critical journeys across real application boundaries; reuse existing Playwright or equivalent tooling |
| Coverage analysis | Locate unexercised meaningful branches; coverage percentage alone is not a quality target |
| Property testing | Domain invariants, roundtrips, idempotency, ordering, and generated valid inputs |
| Fuzzing | Unexpected inputs, crashes, hangs, resource limits, and parser robustness |
| Mutation testing | Whether assertions detect plausible defects; inspect surviving and equivalent mutants |

## Select details only when needed

Keep one entry point so the user can describe the quality question without choosing a testing specialty. Do not run every technique. Read only the relevant companion:

- [E2E and acceptance](references/e2e-acceptance.md): user journeys, exploratory QA, and browser automation.
- [Property tests](references/property-tests.md): generated valid inputs and domain invariants.
- [Fuzzing](references/fuzzing.md): hostile or malformed inputs, crashes, hangs, and bounded resource behavior.
- [Mutation testing](references/mutation-testing.md): assertion effectiveness and surviving mutants.

For ordinary coverage gaps, unit tests, or integration tests, use the main workflow without loading a companion. If the user asks broadly to “QA this,” start with acceptance criteria and high-risk journeys, then select the smallest useful checks. If a named method clearly fits, proceed directly without asking the user to choose it again.

## Run a bounded campaign

- Establish the baseline and prioritize high-impact risks. Use existing tools and configuration; do not install a new stack automatically.
- Keep fixtures isolated from production identities and data. Use local/test targets and bounded resources; do not load-test shared services without authorization.
- For E2E, assert user-visible outcomes, isolate test state, and collect useful failure traces or screenshots. Diagnose flaky behavior instead of hiding it with retries or silent quarantine.
- For generated tests, use domain-valid generators and meaningful independent properties. Record seeds/corpora and minimize counterexamples. For fuzzing, set duration/resource limits.
- Run mutation tools in disposable state and verify original source is restored. Narrow the target before expanding an expensive campaign.
- When the user wants to write tests themselves, help choose properties and interpret failures, leaving the requested implementation to them.

## Deliver

Provide pass/fail/blocked results tied to acceptance criteria, reproducible defects, evidence, and untested risks. State browser, environment, seed, or tool version when it affects reproduction. No observed defect does not imply complete coverage.

Own test harnesses and test-only changes for the campaign. Report application defects for a focused implementation fix rather than silently broadening the campaign into a feature rewrite. Delegate only when authorized; no mandatory review-agent cascade.

## Example requests

- “QA the signup-to-first-use journey and report reproducible defects.”
- “Add a property test for encode/decode roundtripping.”
- “Fuzz this parser for 60 seconds and minimize any failing input.”
- “Check whether these tests detect meaningful defects with a scoped mutation run.”

## LLM and agent outcomes

For model-backed features or agent reliability/cost/latency questions, read [LLM and agent evaluations](references/llm-evals.md). Check actual environment outcomes and side effects, not only the response text. Separate tool/environment failure from model behavior and record untested uncertainty.

Source: [agent evaluation practice](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents). This is a targeted evaluation option, not a requirement to run LLM calls for ordinary software tests.
