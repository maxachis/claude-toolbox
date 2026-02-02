# Backend API Bundle

A curated collection of commands for backend API development.

## Included Components

### Commands
- API design and implementation
- Database design, migrations, queries
- Security and authentication
- Testing and debugging
- Git workflow

### Rules
- Backend API project conventions

## Installation

```bash
# Copy commands
cp -r bundles/backend-api/commands/* ~/.claude/commands/

# Copy project rules
cp bundles/backend-api/CLAUDE.md ./CLAUDE.md
```

## Commands Included

| Command | Purpose |
|---------|---------|
| `/api-design` | Design API endpoints |
| `/api-endpoint` | Implement endpoints |
| `/api-docs` | Generate documentation |
| `/api-test` | Test APIs |
| `/db-architect` | Database design |
| `/db-migrate` | Generate migrations |
| `/query` | Write queries |
| `/security-audit` | Security review |
| `/auth` | Implement auth |
| `/test` | Generate tests |
| `/debug` | Debug issues |
| `/commit` | Git commits |
| `/pr` | Create PRs |
| `/review` | Code review |

## Workflow

1. Design your API with `/api-design`
2. Create database schema with `/db-architect`
3. Generate migrations with `/db-migrate`
4. Implement endpoints with `/api-endpoint`
5. Add authentication with `/auth`
6. Security check with `/security-audit`
7. Write tests with `/test` and `/api-test`
8. Document with `/api-docs`
