---
name: security-scan
description: Comprehensive security audit based on OWASP 2025 Top 10 with automated checks. Scans for vulnerabilities, insecure patterns, hardcoded secrets, and dependency risks.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
context: fork
agent: security-auditor
argument-hint: "[target-dir]"
metadata:
  version: "3.0.0"
  updated: "2025-02"
hooks:
  - type: command
    command: |
      node -e "
        const { execSync } = require('child_process');
        const fs = require('fs');
        const warnings = [];
        if (fs.existsSync('package.json')) {
          try { execSync('npx --yes npm-audit-resolver --version', { stdio: 'pipe', timeout: 10000 }); }
          catch { warnings.push('npm audit available but npm-audit-resolver not found (optional).'); }
        }
        if (fs.existsSync('requirements.txt') || fs.existsSync('pyproject.toml')) {
          try { execSync('pip-audit --version', { stdio: 'pipe', timeout: 5000 }); }
          catch { warnings.push('pip-audit not installed. Run pip install pip-audit for Python dependency scanning.'); }
        }
        if (fs.existsSync('Cargo.toml')) {
          try { execSync('cargo audit --version', { stdio: 'pipe', timeout: 5000 }); }
          catch { warnings.push('cargo-audit not installed. Run cargo install cargo-audit for Rust dependency scanning.'); }
        }
        if (warnings.length > 0) {
          console.log(JSON.stringify({additionalContext: 'Audit Tool Warnings:\\n' + warnings.map(w => '- ' + w).join('\\n')}));
        }
      "
    once: true
---

# Security Scan

Perform a comprehensive security audit on $ARGUMENTS.

**Reference:** [OWASP Top 10 2025](https://owasp.org/Top10/)

## Scan Strategy

1. Identify application type and tech stack
2. Run automated dependency vulnerability checks
3. Scan source code for insecure patterns
4. Detect hardcoded secrets and credentials
5. Review configuration files for misconfigurations
6. Assess authentication and authorization flows

## Dynamic Context

- Dependency audit: !`npm audit --json 2>/dev/null | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log('Vulnerabilities:',JSON.stringify(d.metadata?.vulnerabilities||'N/A'))" 2>/dev/null || pip-audit 2>/dev/null | tail -5 || cargo audit 2>/dev/null | tail -5 || echo "No dependency audit tool found"`
- Recently changed files: !`git diff --name-only HEAD~10 2>/dev/null || echo "N/A"`
- Project type: !`ls package.json requirements.txt Cargo.toml go.mod pyproject.toml 2>/dev/null | head -3 || echo "Unknown"`
- Environment files: !`find . -name '.env*' -o -name '*.env' 2>/dev/null | head -5 || echo "None"`

## References

| Topic | Reference | Use for |
| --- | --- | --- |
| OWASP Checklist | [references/owasp-checklist.md](references/owasp-checklist.md) | Full A01-A10 audit checklists with vulnerable/fixed code patterns |
| Secret Detection | [references/secret-detection.md](references/secret-detection.md) | Regex patterns for detecting hardcoded secrets and credentials |
| Output Format | [references/output-format.md](references/output-format.md) | Report template, severity classification (CVSS 3.1) |
| Scanning Tools | [references/scanning-tools.md](references/scanning-tools.md) | Automated tool commands and selection guide |

## Related Skills

- [review-code](/review-code) - General code review
- [threat-model](/threat-model) - STRIDE threat modeling
- [audit-supply-chain](/audit-supply-chain) - Dependency analysis

## Resources

- [OWASP Top 10 2025](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## Guardrails
- Prefer measured evidence over blanket rules of thumb.
- Ask for explicit human approval before destructive data operations (drops/deletes/truncates).
