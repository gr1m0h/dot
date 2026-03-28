# Supply Chain Security

Mandatory checks for dependency management.

## Dependency Installation

### Before Adding Dependencies

1. **Audit first**
   ```bash
   npm audit              # Node.js
   pip-audit              # Python
   cargo audit            # Rust
   bundle audit           # Ruby (bundler-audit gem)
   composer audit         # PHP
   govulncheck ./...      # Go
   ```

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
```bash
# Check for install scripts
npm show <package> scripts

# View package contents before install
npm pack <package> && tar -tf <package>-*.tgz

# Check package provenance
npm audit signatures

# Ruby: Check for install hooks
gem contents <gem> | head -20

# PHP: Check for post-install scripts
composer show <package> --all

# Go: Check module info
go mod graph | grep <module>
```

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

## Approved Registries

- npm: registry.npmjs.org (verify SSL)
- PyPI: pypi.org (verify SSL)
- RubyGems: rubygems.org (verify SSL)
- Packagist: packagist.org (verify SSL)
- Go Modules: proxy.golang.org (verify SSL, GONOSUMCHECK only when justified)
- Never use unofficial mirrors in production
