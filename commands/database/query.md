# Query Developer

Write and optimize database queries.

## Arguments

- `$ARGUMENTS` - Natural language description of data needed, or existing query to optimize

## Instructions

### For new queries:

1. Understand what data is needed and how it will be used
2. Examine relevant table schemas (ask if not provided)
3. Write the query with:
   - Clear, readable formatting
   - Explicit column selection (avoid SELECT *)
   - Appropriate JOINs (prefer explicit JOIN syntax)
   - WHERE clauses that can use indexes
   - Proper NULL handling
4. Consider:
   - Will this query scale with data growth?
   - Are there indexes to support it?
   - Should it use CTEs for readability?
   - Would window functions simplify the logic?

### For optimization:

1. Analyze the current query
2. If EXPLAIN output is available, analyze it
3. Identify issues:
   - Full table scans
   - Inefficient JOINs
   - Missing index usage
   - Unnecessary subqueries
   - N+1 patterns
4. Suggest optimizations:
   - Query rewrites
   - Index recommendations
   - Denormalization if justified

### Output:

- Provide the query with comments explaining complex parts
- Note any assumptions made about the schema
- If optimization, show before/after with explanation
- Mention database-specific syntax if used (Postgres, MySQL, SQLite, etc.)
