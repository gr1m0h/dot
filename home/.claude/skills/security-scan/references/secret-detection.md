# Secret Detection Patterns

Scan for these regex patterns in source code:

| Pattern Type | Description |
|-------------|-------------|
| AWS Access Key | Starts with `AKIA` followed by 16 alphanumeric chars |
| AWS Secret Key | 40 character base64-like string |
| GitHub Token | Starts with `ghp_`, `gho_`, `ghu_`, `ghs_`, or `ghr_` |
| Generic API Key | Variable named `api_key` or `apikey` with string value |
| Private Key | PEM formatted private key block |
| JWT Token | Base64 encoded header.payload format |
| Connection String | Database URLs with credentials |
| Generic Secret | Variables named password/secret/token with values |

## Regex Reference

```regex
# AWS Access Key
AKIA[0-9A-Z]{16}

# AWS Secret Key
[0-9a-zA-Z/+]{40}

# GitHub Token
gh[pousr]_[0-9a-zA-Z]{36}

# Generic API Key assignment
(?i)(api[_-]?key|apikey)\s*[:=]\s*['"][^'"]{8,}['"]

# PEM Private Key
-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----

# JWT Token
eyJ[A-Za-z0-9-_]+\.eyJ[A-Za-z0-9-_]+\.[A-Za-z0-9-_.+/=]+

# Database Connection String
(?i)(postgres|mysql|mongodb|redis)://[^\s'"]+

# Generic Secret assignment
(?i)(password|secret|token|passwd|credentials)\s*[:=]\s*['"][^'"]{4,}['"]
```

## Scanning Strategy

1. **Grep source files** for the patterns above
2. **Check `.env*` files** exist and are in `.gitignore`
3. **Review git history** for accidentally committed secrets: `git log -p --all -S 'AKIA'`
4. **Validate `.gitignore`** includes: `.env*`, `*.pem`, `*.key`, `secrets/`, `credentials.*`
