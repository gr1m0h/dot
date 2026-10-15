# Supply Chain Security

OWASP 2025 A03: Software Supply Chain Failures (NEW — elevated from component-level to ecosystem-level).

Mandatory checks for dependency management.

## Dependency Installation

### Before Adding Dependencies

1. **Audit first** — run the ecosystem auditor before install:
   `npm audit` / `pip-audit` / `cargo audit` / `bundle audit` / `composer audit` / `govulncheck ./...`

2. **Check package legitimacy**
   - Verify package name (typosquatting risk)
   - Check download counts and maintenance status
   - Review GitHub stars, issues, recent commits

3. **Minimize attack surface**
   - Prefer packages with fewer transitive dependencies
   - Avoid packages that haven't been updated in 2+ years
   - Check for known vulnerabilities on Snyk/GitHub Advisory

### Installation Rules

| Severity | Action |
|----------|--------|
| Critical | BLOCK - Do not install |
| High | BLOCK - Require explicit approval |
| Medium | WARN - Document risk |
| Low | ALLOW - Monitor |

## Lockfile Protection

- **Never edit lockfiles manually**
- Lockfile changes require review of `npm audit`/`pip-audit`/`bundle audit`/`composer audit`
- Commit lockfile changes separately with audit results

## Dependency Update Policy

### Safe Updates
- Patch versions: Auto-approve with passing tests
- Minor versions: Review changelog, run full test suite

### Risky Updates
- Major versions: Full impact analysis required
- Breaking changes: Document migration plan first

## Suspicious Patterns

### Red Flags
- Install scripts (`preinstall`, `postinstall`) in new packages
- Packages requesting filesystem/network access unexpectedly
- Sudden ownership transfers on popular packages
- Typosquatted names (e.g., `lodahs` instead of `lodash`)

### Required Checks
Before installing an unfamiliar package, inspect install scripts, package
contents, and provenance signatures. The `/audit-supply-chain` skill runs the
full per-ecosystem check sequence (npm/gem/composer/go) on demand.

## CI/CD Integration

- Run `npm audit --audit-level=high` in CI
- Run `bundle audit check` in CI (Ruby)
- Run `composer audit` in CI (PHP)
- Run `govulncheck ./...` in CI (Go)
- Fail builds on critical/high vulnerabilities
- Use Dependabot/Renovate for automated updates
- Pin exact versions in production

## Incident Response

If a compromised dependency is detected:
1. Immediately pin to last known safe version
2. Audit git history for when vulnerable version was introduced
3. Check for unexpected file changes or network calls
4. Report to package maintainers and security databases

## AI/LLM-Specific Supply Chain Risks

- Verify AI-suggested package names (LLM hallucination → typosquatting vector)
- Audit MCP servers before enabling (review source, permissions, data access)
- Never install packages solely on AI recommendation — verify on registry first
- Check provenance of AI-generated dependency lists against actual registry data
- Monitor for "dependency confusion" in AI-suggested internal package names

## Provenance Verification

- Verify npm package provenance (`npm audit signatures`)
- Check Sigstore signatures where available
- Prefer packages with build provenance (GitHub Actions attestation)
- Verify container image signatures (cosign/notation)

## Approved Registries

- npm: registry.npmjs.org (verify SSL)
- PyPI: pypi.org (verify SSL)
- RubyGems: rubygems.org (verify SSL)
- Packagist: packagist.org (verify SSL)
- Go Modules: proxy.golang.org (verify SSL, GONOSUMCHECK only when justified)
- Never use unofficial mirrors in production
