---
name: sre-operations
description: Investigate incidents, SLOs, performance, and operational changes. Own operational evidence and incident reports.
---

# SRE Operations

## Establish the operational question

Identify the service, environment/account/region, time window and timezone, user impact, and success criteria. Reuse known context. Match the depth to the service risk and the user's question.

## Diagnose with evidence

- Use available telemetry and read-only tools. Verify identity and environment before infrastructure commands; do not assume AWS, Kubernetes, or Datadog is present.
- Read a companion only when its tooling is actually in play: [AWS CLI recipes](references/aws-commands.md), [Datadog recipes](references/datadog-commands.md), [analysis patterns](references/analysis-patterns.md), [verification script template](references/verification-script-template.md).
- Correlate symptoms, deployment/configuration changes, logs, metrics, and traces on one timeline. Preserve the distinction between event time and collection time.
- Separate immediate trigger, underlying failure mechanism, and contributing conditions. State competing hypotheses and the check that would distinguish them; do not force five whys or a predetermined hypothesis count.
- For performance, establish a baseline and identify the bottleneck before proposing tuning. For SLOs, define the user-facing SLI, population, window, target, and error-budget interpretation.
- Own the incident report: impact, timeline, evidence, root cause or unresolved hypotheses, mitigation, and follow-up actions. Do not launch a duplicate generic report workflow.

## Recommend or execute a change

Describe expected impact, blast radius, rollback, and observation criteria for operational changes. Read-only investigation is not authorization to deploy, restart, scale, change IAM, or apply infrastructure. Execute changes only within the user's authorized scope.

When the user wants to reason through a diagnosis themselves, ask for their current hypothesis and provide focused evidence or hints. Deliver findings with source references, checks performed, gaps, and actionable priorities.

## Reliability decisions

For SLO work, make the event population, good/total events, window, target, and missing-data treatment explicit. Evaluate error-budget consumption and multi-window burn-rate alerts when appropriate; do not copy thresholds without checking traffic and response time. In low-traffic services, distinguish sparse evidence from reliability and consider suitable alternative signals.

For recovery, separate availability restoration from data integrity and recoverability. Define observable recovery criteria. For releases, name the baseline/control, staged exposure, halt/rollback criteria, and monitoring window. Consider backup/restore evidence, RPO/RTO, capacity, and toil only when relevant; do not manufacture targets.

Sources: [SLO alerting](https://sre.google/workbook/alerting-on-slos/) and [canarying](https://sre.google/workbook/canarying-releases/). These guide decisions, not universal thresholds.
