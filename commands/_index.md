# Commands Index

All slash commands organized by category. Copy individual commands or entire categories to your `~/.claude/commands/` directory.

## Quick Reference

| Command | Category | Description |
|---------|----------|-------------|
| `/api-design` | [api](api/) | Design RESTful API endpoints and contracts |
| `/api-docs` | [api](api/) | Generate or update API documentation |
| `/api-endpoint` | [api](api/) | Implement an API endpoint |
| `/api-test` | [api](api/) | Generate integration tests for API endpoints |
| `/db-architect` | [database](database/) | Design and improve database schemas |
| `/db-migrate` | [database](database/) | Generate database migration files |
| `/query` | [database](database/) | Write and optimize database queries |
| `/component` | [frontend](frontend/) | Create UI components following project patterns |
| `/style` | [frontend](frontend/) | Help with CSS, styling, and design |
| `/a11y` | [frontend](frontend/) | Audit and fix accessibility issues |
| `/commit` | [git](git/) | Generate commit message and commit changes |
| `/pr` | [git](git/) | Create a pull request |
| `/review` | [git](git/) | Review code for issues and improvements |
| `/ship` | [git](git/) | Stage, commit, and push in one step |
| `/security-audit` | [security](security/) | Audit code for security vulnerabilities |
| `/auth` | [security](security/) | Implement authentication and authorization |
| `/test` | [testing](testing/) | Generate tests for code |
| `/debug` | [testing](testing/) | Diagnose and fix bugs |
| `/doc` | [documentation](documentation/) | Generate or update documentation |
| `/explain` | [documentation](documentation/) | Explain how code works |
| `/refactor` | [refactoring](refactoring/) | Refactor code to improve quality |
| `/session-review` | [workflow](workflow/) | Analyze session for inefficiencies and suggest improvements |

## Categories

### [API](api/)
Commands for designing, implementing, documenting, and testing APIs.
- `api-design` - Design RESTful endpoints and contracts
- `api-docs` - Generate OpenAPI/Swagger or markdown documentation
- `api-endpoint` - Implement endpoints in any framework
- `api-test` - Generate integration tests

### [Database](database/)
Commands for database design, migrations, and queries.
- `db-architect` - Design schemas and review structure
- `db-migrate` - Generate migration files for any framework
- `query` - Write and optimize SQL queries

### [Frontend](frontend/)
Commands for UI development and accessibility.
- `component` - Create components for React, Vue, Svelte, etc.
- `style` - CSS, Tailwind, styled-components help
- `a11y` - WCAG accessibility auditing

### [Git](git/)
Commands for git workflow automation.
- `commit` - Conventional commit messages
- `pr` - Create pull requests with summaries
- `review` - Code review with severity ratings
- `ship` - Stage, commit, and push in one step

### [Security](security/)
Commands for security auditing and authentication.
- `security-audit` - OWASP Top 10 vulnerability checking
- `auth` - Implement auth flows (JWT, OAuth, sessions)

### [Testing](testing/)
Commands for testing and debugging.
- `test` - Generate comprehensive test suites
- `debug` - Systematic bug diagnosis

### [Documentation](documentation/)
Commands for code documentation.
- `doc` - Generate docstrings and API docs
- `explain` - Multi-level code explanations

### [Refactoring](refactoring/)
Commands for code improvement.
- `refactor` - Improve code quality without changing behavior

### [Workflow](workflow/)
Commands for analyzing and improving Claude Code session efficiency.
- `session-review` - Analyze conversation for inefficiencies and suggest improvements

## Installation

```bash
# Install all commands
cp commands/**/*.md ~/.claude/commands/

# Install a single category
cp commands/api/*.md ~/.claude/commands/

# Install a single command
cp commands/api/api-design.md ~/.claude/commands/
```
