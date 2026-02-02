# Authentication Implementation

Implement authentication and authorization flows.

## Arguments

- `$ARGUMENTS` - Auth feature needed (e.g., "JWT login", "OAuth Google", "role-based access")

## Instructions

1. **Understand requirements**:
   - Authentication method (password, OAuth, magic link, etc.)
   - Session strategy (JWT, server sessions, cookies)
   - Authorization model (RBAC, ABAC, simple checks)
   - Multi-tenancy considerations

2. **Detect existing auth setup**:
   - Auth libraries in use (Passport, NextAuth, Auth.js, etc.)
   - Session storage (Redis, database, cookies)
   - Current user model structure
   - Middleware patterns

3. **Implement securely**:

   **Passwords:**
   - Hash with bcrypt/argon2 (cost factor 10+)
   - Never log or expose passwords
   - Enforce minimum complexity
   - Implement rate limiting

   **Sessions/Tokens:**
   - Use secure, httpOnly cookies
   - Implement CSRF protection
   - Set appropriate expiration
   - Rotate tokens on privilege changes
   - Secure token storage (not localStorage for sensitive)

   **OAuth:**
   - Validate state parameter
   - Use PKCE for public clients
   - Verify token signatures
   - Handle token refresh

   **Authorization:**
   - Check permissions server-side (never trust client)
   - Fail closed (deny by default)
   - Log access control failures
   - Use middleware for consistency

4. **Include**:
   - Protected route middleware/guards
   - User context/session handling
   - Logout and session invalidation
   - Error handling (don't leak info)

## Output

- Implementation code following project patterns
- Database migrations if needed
- Environment variables required
- Security considerations and warnings
- Testing suggestions
