# Mutation Testing

Use to evaluate whether tests detect plausible behavior changes. Confirm the relevant baseline tests pass and inspect existing mutation tooling before configuring a run.

Start with a small behaviorally important module. Run in disposable state, limit workers and duration, and exclude generated code and unrelated targets. Keep a record of the original source state and verify restoration even after interruption. Do not modify the user's original files manually as an improvised mutation campaign.

Classify killed, survived, uncovered, timed-out, and equivalent mutants according to the tool's actual definitions. Inspect surviving changes: distinguish missing assertions, untested behavior, equivalent behavior, and unsuitable mutations. Improve tests to protect the contract rather than to recognize a mutant. State numerator/denominator and exclusions for any reported score; do not impose a universal target percentage or compare unlike configurations.

Primary example: [Stryker mutant states and metrics](https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/). Follow the target framework's current documentation; this reference does not require installing that framework.
