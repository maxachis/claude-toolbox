# API Endpoint Implementation

Implement an API endpoint.

## Arguments

- `$ARGUMENTS` - Endpoint description (e.g., "POST /users to create a user")

## Instructions

1. **Detect the framework** by examining the codebase:
   - Express/Fastify/Hono (Node.js)
   - FastAPI/Flask/Django (Python)
   - Gin/Echo/Chi (Go)
   - Spring Boot (Java)
   - Rails (Ruby)
   - Ask if unclear

2. **Follow existing patterns** in the codebase:
   - File organization (routes, controllers, handlers)
   - Middleware usage
   - Error handling approach
   - Response formatting

3. **Implement with**:
   - Input validation (use framework's validation or a library)
   - Proper error handling with appropriate status codes
   - Authentication/authorization checks if needed
   - Database transactions where appropriate
   - Logging for debugging

4. **Include**:
   - Type definitions (TypeScript, Pydantic, structs, etc.)
   - Request/response DTOs if the project uses them
   - Any necessary service/repository layer calls

5. **Security considerations**:
   - Validate and sanitize all inputs
   - Check authorization (can this user do this action?)
   - Don't expose sensitive data in responses
   - Use parameterized queries

## Output

- The endpoint implementation code
- Any new types/models needed
- Required updates to route registration
- Note any dependencies or middleware needed
