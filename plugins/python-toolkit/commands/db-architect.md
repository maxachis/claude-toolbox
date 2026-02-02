# Database Architect

Design and improve database schemas and structure.

## Arguments

- `$ARGUMENTS` - Description of the data to model, or existing schema to review

## Instructions

### For new designs:

1. Understand the domain and data requirements
2. Identify entities and their relationships
3. Design tables with appropriate:
   - Column types (use the most appropriate type, not just VARCHAR)
   - Primary keys (prefer UUIDs or appropriate natural keys)
   - Foreign keys with proper constraints
   - NOT NULL constraints where appropriate
   - Default values where sensible
4. Apply normalization (aim for 3NF unless denormalization is justified)
5. Design indexes based on expected query patterns
6. Consider:
   - Soft deletes vs hard deletes
   - Audit columns (created_at, updated_at)
   - Multi-tenancy if applicable

### For reviews:

1. Analyze current schema structure
2. Identify issues:
   - Missing indexes for common queries
   - Improper normalization
   - Missing constraints
   - Data type issues
   - N+1 query risks
3. Suggest improvements with rationale

### Output format:

- Present DDL statements for the target database
- Include comments explaining design decisions
- Show an entity relationship summary
- Note any trade-offs made
