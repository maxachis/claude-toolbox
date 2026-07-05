# Antipatterns Index

Recurring agentic failure modes — things an agent commonly does *wrong* — captured so they can be **audited against repos**, not just read.

Each antipattern is a negative convention with three required parts:

1. **A detection signal** (`detect.grep` and/or `detect.heuristic`) — what makes it auditable.
2. **A sanctioned alternative** — the correct form to steer toward.
3. **A severity** — `low` | `medium` | `high`.

This is an **audit-first** catalog: every entry must carry at least one detection
signal. An entry with no `detect` block is reference-only and does not belong here.

## Detection tiers

| Tier | Field | Cost | Use for |
|------|-------|------|---------|
| Mechanical | `detect.grep` (+ `globs`) | Free, deterministic, CI-able | Literal/regex-detectable: `?p=`, hardcoded hex, `== None` |
| Judgment | `detect.heuristic` | Requires an auditor agent | Subtle: "reinvented a stdlib helper", "nonstandard-but-not-literal name" |

Prefer mechanical when the antipattern has a stable textual fingerprint; fall back
to a heuristic when it needs reading comprehension. Many entries carry both.

## Available Antipatterns

| ID | Category | Severity | Summary |
|----|----------|----------|---------|
| `nonstandard-query-param` | api-conventions | low | Invents a short/idiosyncratic query-param name instead of the conventional one |
| `unexplained-boolean-call-site` | readability | low | Consumes a bool return whose meaning isn't in the callee's name inline as an `if` condition, instead of an explaining variable |

## Auditing a repo

Until a dedicated `antipattern-auditor` agent / `claude-toolbox audit` verb exists:

- **Mechanical pass:** run each entry's `detect.grep` over `detect.globs`, scoped to first-party code.
- **Judgment pass:** hand the catalog to an agent (`Read`/`Grep`/`Glob`) and have it
  apply each `detect.heuristic`, reporting `file:line → id → suggested fix`.
