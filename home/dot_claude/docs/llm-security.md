# LLM Security

CRITICAL: Mandatory when building AI-integrated applications.

## Prompt Injection Defense (OWASP LLM01:2025)

- Isolate system prompts from user input (locked vault principle)
- Never concatenate user input into system prompts
- Layered defense: inference-time filtering + independent detection + model hardening
- Assume breach: design tool access so malicious AI output can't cause harm
- Prefix matching: place static content first, dynamic last (cache control breakpoints)

## Tool & MCP Security

- Validate all tool outputs before acting on them
- Limit tool permissions to minimum required scope
- Use `permissions.deny` for dangerous operations (file deletion, network access)
- MCP servers: audit before enabling, prefer CLI tools when possible
- Never pass untrusted MCP output to `eval()` or shell execution

## AI Output Verification

- Never trust AI-generated code without review
- Validate AI-suggested file paths (path traversal risk)
- Sanitize AI output before rendering in HTML/UI
- Check AI-generated SQL for injection patterns
- Verify AI-generated URLs before fetching

## Agent Safety

- Limit subagent depth (`CLAUDE_CODE_MAX_SUBAGENT_DEPTH=3`)
- Use `isolation: "worktree"` for risky modifications
- Monitor agent resource usage (circuit-breaker pattern)
- Never grant agents persistent credentials
- Sandbox agents that execute untrusted code

## Forbidden in AI Context

- Passing user input directly to `system` prompt without sanitization
- Using AI output as code input without escaping
- Granting AI agents unrestricted file system access
- Storing API keys in CLAUDE.md or agent definitions
- Disabling security hooks for convenience
