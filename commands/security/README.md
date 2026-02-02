# Security Commands

Commands for security auditing and authentication implementation.

## Commands

| Command | Description |
|---------|-------------|
| `security-audit` | Audit code for security vulnerabilities |
| `auth` | Implement authentication and authorization flows |

## Usage

```bash
# Audit specific file
/security-audit src/api/users.ts

# Full security audit
/security-audit full

# Implement JWT auth
/auth JWT login

# Implement OAuth
/auth OAuth Google

# Implement role-based access
/auth role-based access control
```

## Installation

```bash
# Install all security commands
cp commands/security/*.md ~/.claude/commands/

# Install a single command
cp commands/security/security-audit.md ~/.claude/commands/
```

## OWASP Top 10 Coverage

The `security-audit` command checks for:

1. Injection (SQL, Command, XSS, Template)
2. Broken Authentication
3. Sensitive Data Exposure
4. Broken Access Control
5. Security Misconfiguration
6. And more...

## Auth Methods Supported

- Password-based authentication
- JWT tokens
- OAuth (Google, GitHub, etc.)
- Magic links
- Session-based auth
- Role-based access control (RBAC)
