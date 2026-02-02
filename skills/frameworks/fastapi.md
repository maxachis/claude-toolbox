# FastAPI Best Practices

## Project Structure

```
app/
├── main.py           # FastAPI app creation
├── api/
│   ├── routes/       # Route handlers
│   └── deps.py       # Dependencies
├── core/
│   ├── config.py     # Settings
│   └── security.py   # Auth utilities
├── models/           # SQLAlchemy models
├── schemas/          # Pydantic schemas
└── services/         # Business logic
```

## Routes

- Group related endpoints in routers
- Use path parameters for resources: `/users/{user_id}`
- Use query parameters for filtering: `/users?active=true`
- Return appropriate status codes
- Use response models for documentation

## Schemas (Pydantic)

- Separate schemas for create, update, response
- Use `Field()` for validation and documentation
- Enable `orm_mode` for database models
- Use `Optional` for nullable fields

## Dependencies

- Use `Depends()` for dependency injection
- Create reusable dependencies for auth, db sessions
- Keep dependencies focused and testable

## Error Handling

- Use `HTTPException` for expected errors
- Create custom exception handlers for consistency
- Return structured error responses
- Don't expose internal errors to clients

## Database

- Use async database drivers when possible
- Create database sessions as dependencies
- Use transactions for multi-step operations
- Close connections properly

## Security

- Use OAuth2 with password bearer for auth
- Hash passwords with bcrypt
- Validate all inputs via Pydantic
- Use CORS middleware appropriately
