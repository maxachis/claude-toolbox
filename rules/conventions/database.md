# Database Conventions

## JSONB Usage

Prefer proper relational columns and tables over JSONB when the data has a known, stable structure.

### When to avoid JSONB

- Data has a consistent schema across rows (e.g., address fields, user preferences with known keys)
- Fields are queried, filtered, or joined on regularly
- Data integrity matters — foreign keys, NOT NULL, CHECK constraints can't protect JSONB internals
- You need indexing beyond simple GIN — B-tree range queries, unique constraints, etc.

### When JSONB is appropriate

- Truly dynamic or user-defined data where the schema varies per row (e.g., form builder responses, plugin metadata)
- Opaque blobs passed through but rarely queried (e.g., external API payloads stored for auditing)
- Rapid prototyping where the schema is still being discovered — with a plan to normalize later
- Sparse optional attributes where most rows would have NULLs for dozens of columns

### General rule of thumb

If you can name the keys at design time, they should be columns. If only the user or an external system can name the keys, JSONB is reasonable.
