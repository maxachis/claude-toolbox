# Security Audit

Audit code for security vulnerabilities.

## Arguments

- `$ARGUMENTS` - File, feature, or area to audit (or "full" for broader review)

## Instructions

1. **Check for OWASP Top 10**:

   **Injection:**
   - SQL injection (use parameterized queries)
   - Command injection (avoid shell commands with user input)
   - XSS (sanitize/escape output, use CSP)
   - Template injection

   **Broken Authentication:**
   - Weak password requirements
   - Missing brute force protection
   - Session fixation vulnerabilities
   - Insecure session storage

   **Sensitive Data Exposure:**
   - Secrets in code or logs
   - Sensitive data in URLs
   - Missing encryption for sensitive data
   - Overly verbose error messages

   **Broken Access Control:**
   - Missing authorization checks
   - IDOR vulnerabilities
   - Privilege escalation paths
   - CORS misconfigurations

   **Security Misconfiguration:**
   - Debug mode in production
   - Default credentials
   - Unnecessary features enabled
   - Missing security headers

2. **Language-specific checks**:
   - Prototype pollution (JavaScript)
   - Deserialization issues (Java, Python)
   - Path traversal
   - Race conditions
   - Memory safety (if applicable)

3. **Dependency review**:
   - Known vulnerable packages
   - Outdated dependencies
   - Unnecessary dependencies

## Output

- Vulnerabilities by severity (Critical, High, Medium, Low)
- Specific location (file:line)
- Attack scenario explanation
- Remediation with code examples
- References (CWE, CVE if applicable)
