# API Design

Design RESTful API endpoints and contracts.

## Arguments

- `$ARGUMENTS` - Feature or resource to design an API for

## Instructions

1. **Understand the requirements**
   - What resources are involved?
   - What operations are needed?
   - Who are the consumers (web, mobile, third-party)?

2. **Design endpoints following REST conventions**
   - Use nouns for resources (`/users`, `/orders`)
   - Use HTTP methods correctly:
     - GET: Read (idempotent)
     - POST: Create
     - PUT: Full update (idempotent)
     - PATCH: Partial update
     - DELETE: Remove (idempotent)
   - Use proper URL hierarchies (`/users/{id}/orders`)
   - Use query params for filtering, sorting, pagination

3. **Design request/response schemas**
   - Define clear JSON structures
   - Use consistent naming (camelCase or snake_case, pick one)
   - Include only necessary fields
   - Design for pagination on list endpoints

4. **Define error responses**
   - Use appropriate HTTP status codes
   - Consistent error body format
   - Helpful error messages

5. **Consider**
   - Authentication requirements per endpoint
   - Rate limiting needs
   - Versioning strategy (URL vs header)
   - HATEOAS if appropriate

## Output format

For each endpoint:
```
METHOD /path
Auth: required/optional/none
Description: What it does

Request:
  Headers: ...
  Body: { schema }

Response 200:
  { schema }

Response 4xx/5xx:
  { error schema }
```
