---
id: nonstandard-query-param
category: api-conventions
severity: low
tags: [http, naming, web, api]
detect:
  # Mechanical tier: cheap, high-precision grep. Scope to first-party code.
  grep: '[?&](p|q|pg|pp)='
  globs: ['**/*.{ts,tsx,js,jsx,py,go,rb,java}']
  # Judgment tier: for cases the grep misses or over-matches.
  heuristic: >
    A query parameter, route segment, or public identifier uses an abbreviated
    or idiosyncratic name where a well-established convention exists
    (p→page, pp→per_page, q→query/search). Flag only first-party endpoints the
    project owns, not calls into third-party APIs whose names are fixed.
---
# Nonstandard query parameter names

**Antipattern:** Inventing a short or idiosyncratic query-parameter name
(`?p=2`, `?pp=50`) instead of the conventional spelled-out name (`?page=2`,
`?per_page=50`).

**Correct form:** Use the established convention for the domain:

- Pagination: `page`, `per_page` (or `limit` / `offset`)
- Search/filter: `q` is acceptable as the *conventional* search token; `query` is clearer
- Sorting: `sort`, `order`

When the surrounding codebase already has a convention, match it over any default.

**Why agents fall into it:** With no existing usage to pattern-match against, the
model picks the first plausible token rather than the idiomatic one. The choice
looks locally reasonable but diverges from what every consumer of the API expects.

**Impact:** Consumers, docs, and tooling assume the conventional name; a nonstandard
one forces per-endpoint lookups and breaks copy-paste from other services. Low
severity because it's cosmetic and easily aliased — but high-frequency.

**False positives:**

- Third-party APIs you call but don't own (`?p=` may be *their* contract).
- Legacy first-party endpoints with established external consumers — renaming is a
  breaking change, so flag for *new* endpoints only.
- Single-letter params inside short-lived internal redirects.
