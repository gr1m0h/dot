# Automated Scanning Tools

| Tool | Purpose | Command |
|------|---------|---------|
| npm audit | Node.js dependencies | `npm audit --json` |
| Snyk | Multi-language deps | `snyk test` |
| Trivy | Container images | `trivy image <name>` |
| Semgrep | SAST scanning | `semgrep --config auto` |
| gitleaks | Secret detection | `gitleaks detect` |
| OWASP ZAP | DAST scanning | `zap-cli quick-scan <url>` |
| pip-audit | Python dependencies | `pip-audit` |
| cargo audit | Rust dependencies | `cargo audit` |
| govulncheck | Go dependencies | `govulncheck ./...` |
| bundle-audit | Ruby dependencies | `bundle-audit check --update` |

## Tool Selection Guide

| Scenario | Recommended Tools |
|----------|-------------------|
| Node.js project | npm audit + Semgrep + gitleaks |
| Python project | pip-audit + Semgrep + gitleaks |
| Go project | govulncheck + Semgrep + gitleaks |
| Rust project | cargo audit + Semgrep + gitleaks |
| Container deployment | Trivy + gitleaks |
| Web application | OWASP ZAP + Semgrep |
| CI/CD integration | Snyk + gitleaks |
