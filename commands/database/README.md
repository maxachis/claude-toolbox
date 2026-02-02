# Database Commands

Commands for database design, migrations, and queries.

## Commands

| Command | Description |
|---------|-------------|
| `db-architect` | Design and improve database schemas |
| `db-migrate` | Generate database migration files |
| `query` | Write and optimize database queries |

## Usage

```bash
# Design a new schema
/db-architect user system with roles and permissions

# Generate a migration
/db-migrate add email_verified column to users

# Write a query
/query get all users with their order counts from the last 30 days
```

## Installation

```bash
# Install all database commands
cp commands/database/*.md ~/.claude/commands/

# Install a single command
cp commands/database/query.md ~/.claude/commands/
```

## Supported Frameworks

### Migrations
- Alembic (Python/SQLAlchemy)
- Prisma (Node.js)
- Knex (Node.js)
- Rails ActiveRecord
- Django migrations
- Supabase

### Databases
- PostgreSQL
- MySQL
- SQLite
- SQL Server
