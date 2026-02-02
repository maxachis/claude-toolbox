# Database Migration Generator

Generate database migration files for schema changes.

## Arguments

- `$ARGUMENTS` - Description of the schema change needed

## Instructions

1. **Detect the migration framework** by checking:
   - `alembic/` directory → Alembic (Python/SQLAlchemy)
   - `prisma/` directory → Prisma (Node.js)
   - `migrations/` + `knexfile` → Knex (Node.js)
   - `db/migrate/` → Rails ActiveRecord
   - `migrations/` + Django → Django migrations
   - `supabase/migrations/` → Supabase
   - Ask if unclear

2. **Examine current schema** to understand existing structure

3. **Generate the migration** following framework conventions:
   - Use the framework's CLI command if appropriate
   - Or create the migration file directly
   - Include both `up` and `down` migrations
   - Use descriptive migration names with timestamps

4. **For destructive changes**, include safety measures:
   - Data backups or preservation
   - Multi-step migrations for zero-downtime
   - Warnings about data loss

5. **Consider**:
   - Foreign key constraints (add after data, drop before)
   - Index creation (CONCURRENTLY for Postgres if large table)
   - Default values for new NOT NULL columns
   - Data migrations if needed alongside schema changes

## Output:

- The migration file(s) content
- Command to run the migration
- Any manual steps required
- Rollback instructions
