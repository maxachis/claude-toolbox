---
description: Audit a repo against the antipatterns catalog across both detection tiers
argument-hint: "<path> [--severity low|medium|high]"
---

# Antipattern Audit

Audit a codebase against the `antipatterns/` catalog of recurring agentic failure
modes, running **both detection tiers** and merging them into one report.

This is a thin orchestrator: the logic lives in `claude-toolbox audit` (the cheap
mechanical pass) and the `antipattern-auditor` agent (the judgment pass). This
command chains them so a single invocation gives confirmed findings, not raw
candidates.

## Arguments

- `$ARGUMENTS` — Optional. A path to audit (default: current directory), and/or
  `--severity low|medium|high` to set the minimum severity. Examples:
  `/audit-antipatterns`, `/audit-antipatterns ./src`, `/audit-antipatterns . --severity medium`.

## Instructions

### Step 1: Mechanical pass (zero-LLM tier)

Run the CLI auditor over the target path, passing through any `--severity` flag:

```bash
claude-toolbox audit <path> [--severity <level>]
```

Interpret the exit code: `0` = no candidates, `2` = candidates found, `1` = setup
error (report it and stop). Capture every reported candidate as
`(id, file:line, matched text)`. These are **candidates, not findings** — the grep
tier deliberately over-captures (e.g. `?q=` where `q` is the conventional search
token).

If the CLI can't find a catalog, say so and stop — do not invent antipatterns.

### Step 2: Judgment pass (delegate to the agent)

Invoke the `antipattern-auditor` agent (via the Task tool) scoped to the **same
path and catalog**. Instruct it to do two things:

1. **Adjudicate the Step 1 candidates** — for each, read the surrounding code and
   the catalog entry's *Correct form* / *False positives* notes, and decide whether
   it is a genuine, first-party, changeable instance. Drop the rest.
2. **Find heuristic-only violations** — scan for catalog entries whose
   `detect.heuristic` describes something grep can't fingerprint (reinvented stdlib
   helpers, nonstandard-but-not-literal names) and judge those directly.

Pass the Step 1 candidate list into the agent prompt so it adjudicates rather than
re-deriving the mechanical tier from scratch.

### Step 3: Merge and report

Combine the agent's confirmed findings (adjudicated candidates + heuristic-only
hits), dedupe by `file:line + id`, and present per the output format below. Always
report how many mechanical candidates were **suppressed** as false positives — a
high suppression rate signals an over-broad `detect.grep` worth tightening in the
catalog.

## Output format

Group confirmed findings by severity (`high` → `medium` → `low`):

```
[high] <id> — <file>:<line>
  what: <offending code / one-line description>
  fix:  <sanctioned alternative from the entry's Correct form>
```

End with a summary line:

- counts per severity,
- mechanical candidates suppressed as false positives,
- a one-line caveat that **catalog coverage bounds the audit** — only defined
  antipatterns are detectable; nothing here implies the absence of other issues.

If there are zero confirmed findings, say so plainly and note how many candidates
were suppressed.
