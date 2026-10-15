# Common Architecture Patterns

## Microservices

**Focus Areas:**
- Service-to-service authentication (mTLS, JWT)
- API Gateway security
- Service mesh configuration
- Secrets management
- Container security

### Threat Vectors
| Vector | Risk | Mitigation |
|--------|------|------------|
| Unauthenticated internal calls | Lateral movement | mTLS between all services |
| API Gateway bypass | Direct service access | Network policies, no public service ports |
| Shared secrets | Compromise spreads | Per-service credentials, vault integration |
| Container escape | Host compromise | Read-only filesystems, non-root containers |
| Supply chain | Malicious images | Signed images, registry scanning |

## Serverless

**Focus Areas:**
- Function permissions (least privilege)
- Event injection
- Cold start timing attacks
- Logging and monitoring
- Dependency security

### Threat Vectors
| Vector | Risk | Mitigation |
|--------|------|------------|
| Over-permissioned functions | Privilege abuse | Least privilege IAM roles |
| Event injection | Code execution via triggers | Input validation on all event sources |
| Shared execution environment | Data leakage | Stateless design, no /tmp persistence |
| Third-party dependencies | Supply chain attack | Lock versions, audit dependencies |

## Single Page Application

**Focus Areas:**
- Token storage (no localStorage for sensitive)
- XSS prevention (CSP, sanitization)
- CSRF protection
- API security (rate limiting, CORS)
- Client-side secrets exposure

### Threat Vectors
| Vector | Risk | Mitigation |
|--------|------|------------|
| localStorage token storage | XSS token theft | HttpOnly cookies, in-memory tokens |
| DOM-based XSS | Session hijacking | Strict CSP, DOMPurify |
| Exposed API keys in bundles | Credential theft | Backend proxy for sensitive APIs |
| Deep link manipulation | State injection | Validate route params server-side |
