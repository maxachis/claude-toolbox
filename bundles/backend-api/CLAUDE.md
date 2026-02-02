# Project Rules

## Overview

Backend API project.

## Architecture

- Framework: [FastAPI/Express/Django/Rails]
- Database: [PostgreSQL/MySQL]
- Authentication: [JWT/Session]

## API Design

- RESTful conventions
- Consistent URL patterns: `/resource/{id}`
- Proper HTTP methods and status codes
- Versioning via URL prefix: `/api/v1/`

## Code Structure

```
src/
├── api/           # Route handlers
├── models/        # Database models
├── schemas/       # Request/response schemas
├── services/      # Business logic
└── utils/         # Helpers
```

## Database

- Use migrations for all schema changes
- Never modify production data directly
- Index foreign keys and frequently queried columns
- Use transactions for multi-step operations

## Security

- Validate all inputs
- Use parameterized queries
- Hash passwords (bcrypt, cost 10+)
- Rate limit authentication endpoints
- Log security events

## Testing

- Unit tests for services
- Integration tests for endpoints
- Test auth and permissions
- Mock external services

## Git

- Conventional commits
- PR reviews required
