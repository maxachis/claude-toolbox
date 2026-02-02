# API Toolkit Plugin

Complete API development toolkit with commands for design, implementation, testing, and documentation.

## Installation

```bash
claude plugin install ./plugins/api-toolkit
```

## Included Commands

| Command | Description |
|---------|-------------|
| `/api-design` | Design RESTful API endpoints and contracts |
| `/api-docs` | Generate or update API documentation |
| `/api-endpoint` | Implement an API endpoint |
| `/api-test` | Generate integration tests for API endpoints |

## Workflow

1. `/api-design users` - Design the user endpoints
2. `/api-endpoint POST /users` - Implement the create user endpoint
3. `/api-test POST /users` - Generate tests
4. `/api-docs users` - Document the endpoints

## Uninstall

```bash
claude plugin uninstall api-toolkit
```
