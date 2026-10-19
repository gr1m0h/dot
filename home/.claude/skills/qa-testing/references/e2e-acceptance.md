# E2E and Acceptance

Use for product acceptance, exploratory QA, or complete user journeys. Read the existing test/browser setup and identify the target environment before launching automation.

Define the journey in user terms: initial state, action, expected visible outcome, and failure recovery. Include the highest-risk alternate path rather than enumerating every screen. For exploratory work, distinguish defects from usability observations and missing requirements.

Prefer stable role/name or existing test-ID selectors. Isolate fixtures and cleanup, avoid arbitrary delays, and assert observable outcomes rather than framework internals. Stub external providers only when the acceptance scope allows it; report which boundaries were simulated. Do not exercise real payments, send messages, or mutate production data as incidental test steps.

When a test fails, capture the minimal screenshot/trace/log evidence, reproduce once when useful, and determine application defect versus harness/environment failure. Report steps, expected/actual behavior, environment, impact, and reproduction frequency. Do not silently change retries, disable tests, quarantine cases, or upload artifacts.

Primary example: [Playwright best practices](https://playwright.dev/docs/best-practices). Follow the target framework's current documentation; this reference does not require installing that framework.
