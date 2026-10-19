---
name: audit-supply-chain
description: Audit dependency vulnerabilities, provenance, and license obligations. Use for dependency checks and OSS release preparation.
---

# Dependency and License Audit

## Establish scope

Identify the manifests, lockfiles, package managers, project license, distributed artifact, and requested security/license scope. Distinguish runtime, development, build, and vendored dependencies. This is a dependency audit, not a full application or infrastructure security audit.

## Inspect dependencies

- Prefer the ecosystem's existing audit and inventory tools. Record tool/database freshness and scan scope. Do not install dependencies or execute package-controlled hooks merely to inspect them.
- Check resolved versions, source registries, integrity metadata, suspicious naming or source changes, and install-script behavior where relevant.
- For vulnerability results, distinguish database matches from demonstrated application exploitability. Explain reachability evidence and unresolved conditions without dismissing a match merely because exploitation was not demonstrated.
- Missing scan access, unsupported ecosystems, or stale databases are coverage gaps, not clean results.

## Inspect licenses when requested or preparing distribution

Inventory direct and transitive license expressions and inspect actual license files for missing or ambiguous metadata. Evaluate obligations against how the project uses and distributes the dependency; a license category alone does not establish compatibility or a violation.

Cite applicable license text for conclusions. Flag unresolved interpretation rather than inventing a definitive legal conclusion. Keep copyright, notices, source obligations, and distribution conditions visible in recommendations.

## Report and boundaries

Deliver the dependency/version, evidence, affected artifact or usage, uncertainty, and recommended action. Keep vulnerability severity, exploitability confidence, and license concerns separate.

Do not alter lockfiles, upgrade packages, or publish artifacts as part of an audit unless authorized. Do not claim CI authorization, signing-chain, or application vulnerability coverage. If a dedicated security-audit skill is installed and that deeper review is requested, hand that scope to it rather than running duplicate audits. When the user wants to understand a finding, explain the evidence and tradeoffs.

## Reproducible dependency findings

Record the advisory URL/identifier, affected and fixed ranges, database/update/check date when available, resolved version, runtime/build/dev usage, and evidence of reachability. Verify AI-suggested package names and provenance against the actual registry or upstream repository before proposing installation. Do not run automatic audit-fix commands during an audit.

For licenses, cite actual upstream license/notice text and the distributed artifact or usage that creates an obligation. SPDX metadata supports identification; it does not alone prove legal compatibility. Report unknowns and needed interpretation.

Sources: [npm audit](https://docs.npmjs.com/cli/v11/commands/npm-audit/), [Go vulnerability management](https://go.dev/doc/security/vuln/), and [SPDX license texts](https://spdx.org/licenses/). Use the target ecosystem's current primary documentation for other tools.
