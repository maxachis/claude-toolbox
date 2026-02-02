# API Commands

Commands for designing, implementing, documenting, and testing APIs.

## Commands

| Command | Description |
|---------|-------------|
| `api-design` | Design RESTful API endpoints and contracts |
| `api-docs` | Generate or update API documentation |
| `api-endpoint` | Implement an API endpoint |
| `api-test` | Generate integration tests for API endpoints |

## Usage

```bash
# Design an API for a feature
/api-design user authentication

# Generate documentation
/api-docs all

# Implement an endpoint
/api-endpoint POST /users to create a user

# Generate tests
/api-test POST /users
```

## Installation

```bash
# Install all API commands
cp commands/api/*.md ~/.claude/commands/

# Install a single command
cp commands/api/api-design.md ~/.claude/commands/
```

## Workflow

A typical API development workflow:

1. `/api-design` - Design the endpoints and contracts
2. `/api-endpoint` - Implement the endpoints
3. `/api-test` - Generate integration tests
4. `/api-docs` - Document the API
