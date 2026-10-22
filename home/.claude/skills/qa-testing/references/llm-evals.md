# LLM and Agent Evaluations

Use for model-backed behavior or agent outcomes. Establish the task distribution, user contract, success/failure criteria, model/provider settings, tool versions, and cost/time limits. Use existing evaluation tools; no paid calls or service activation without authorization.

Build a small representative set from actual tasks, known failures, boundary cases, and relevant adversarial inputs. Keep calibration/development examples separate from held-out checks; isolate trial state and do not expose answer keys to the evaluated agent. Decide repeats according to variability and stakes, not a universal count.

Prefer deterministic checks for structured fields, executed actions, persisted state, and side effects. For subjective quality use explicit rubrics and calibrated human or model judgments; allow unknown/abstain. A model judge's agreement is not ground truth. Inspect a sample of traces for grading errors and unexpected behavior.

Report per-task/per-slice outcomes, trial counts, uncertainty appropriate to sample size, latency, cost when observable, and unauthorized or unintended actions. Separate tool/environment failures from behavior and model/configuration drift. Do not claim reliability from one pass or compare scores from different graders and environments as if equivalent.

Preserve reproducible non-secret fixtures, settings, and results. Compare changed and baseline configurations under comparable conditions; report no measurable improvement or untested dimensions honestly.

Sources: [agent evaluations](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) and [AlphaEval](https://arxiv.org/abs/2604.12162v1). The latter motivates real-task evaluation; it does not validate this local harness.
