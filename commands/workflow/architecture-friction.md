---
description: Identify recurring friction between Claude Code and the project's architecture
argument-hint: "<focus area>"
---

# Architecture Friction Review

Analyze the current conversation to find places where Claude Code worked *against*
the project's architecture, structure, conventions, or tooling — then propose
durable fixes to the project setup so the friction stops recurring.

This complements `/session-review`: that command targets Claude's tool-use
efficiency; this one targets structural mismatch between how the project is built
and how an agent naturally tries to work in it.

## Arguments

- `$ARGUMENTS` - (Optional) Focus area: `structure`, `conventions`, `tooling`, `boundaries`, `docs`, or leave blank for full review

## Instructions

Review the entire conversation history above this invocation point. Analyze it in
three passes.

### Pass 1: Detect Friction Signals

Scan for evidence that Claude and the project's architecture were pulling in
different directions. Flag every instance:

**Structural Mismatch**
- Code placed in one location, then moved because the project expected it elsewhere
- Hunting across many directories to find where a type of file "belongs"
- Creating a new file when an existing module was the intended home
- Layering or module-boundary guesses that turned out wrong (e.g., importing across a boundary the project forbids)

**Convention Drift**
- Code written in one style, then reworked to match the project's idiom
- Naming, formatting, or error-handling choices corrected after the fact
- Reinventing a helper, pattern, or abstraction the project already provides
- Lint/format/type failures caused by not knowing a project rule up front

**Tooling Resistance**
- Running a command the wrong way before discovering the project's wrapper (`make`, task runner, `uv run`, custom scripts)
- Build/test/run steps that failed because of an undocumented prerequisite (services, env vars, generated files)
- Editing a generated/derived file directly instead of its source
- Fighting the dependency or package manager (wrong tool, wrong lockfile, wrong env)

**Boundary Violations**
- Touching code the project treats as off-limits or auto-generated
- Bypassing an abstraction layer (calling a DB directly when a repository exists, etc.)
- Cross-cutting changes that the architecture intended to be localized

**Discovery Cost**
- Architectural facts learned only by trial and error that a doc could have stated
- Repeated questions to the user about "where does X go" or "how do I run Y"

### Pass 2: Diagnose Root Cause

For each friction signal, classify *why* it happened. Distinguish:

- **Undocumented knowledge** — the architecture is sound, but nothing told the agent. Fix: write it down.
- **Discoverability gap** — the information exists but is buried or far from where the agent looked. Fix: surface it (CLAUDE.md, rule, README near the code).
- **Genuine architectural rough edge** — the structure itself is awkward, inconsistent, or surprising even to a human. Fix: flag for refactor; a doc is only a patch.
- **Agent error** — the project was clear and the agent simply missed it. Fix: nothing structural; note as a `/session-review` concern instead.

Be honest about the last two categories. Not every friction is the project's
fault, and not every fix is a CLAUDE.md line.

### Pass 3: Prioritize and Propose Durable Fixes

For each diagnosed issue, estimate:
- **Recurrence likelihood**: Would a future agent (or human) hit this again? High / Medium / Low
- **Cost per occurrence**: Low (minor rework) / Medium (several wrong steps) / High (significant rework or wrong direction)
- **Fix durability**: Does the proposed fix prevent the class of problem, or just this instance?

Order findings by recurrence × cost.

## Output Format

```
## Architecture Friction Review

### Summary
- Friction points found: [N]
- Dominant root cause: [Undocumented knowledge / Discoverability gap / Architectural rough edge / Agent error]
- Verdict: [Mostly fixable with docs / Needs structural attention / Project is sound, friction was incidental]

### Findings

#### 1. [Friction Name]
- **Signal**: [what happened in the conversation, cited specifically]
- **Root cause**: [one of the four categories from Pass 2]
- **Recurrence × cost**: [High/Med/Low] × [High/Med/Low]
- **Durable fix**: [the specific, concrete change]

[Repeat for each finding, ordered by priority]

### Recommended Project Changes

#### CLAUDE.md / Rules Additions
[Exact lines to add. Each must encode stable architectural knowledge — where
things go, how to run things, what not to touch. Quote them ready to paste.]

#### Documentation Placement
[Where docs belong so a future agent finds them at the point of need — a README
beside a module, a comment header, a rule file in `.claude/rules/`.]

#### Refactor Candidates
[Only for genuine architectural rough edges. Describe the awkwardness and a
direction — do not prescribe a full redesign.]

#### Tooling / Setup Fixes
[Scripts, prerequisite docs, or guards (e.g. "do not edit generated files")
that would prevent tooling resistance.]

### What the Project Got Right
[Architectural decisions that made the agent's work *easier* — clear structure,
good naming, helpful existing docs. Worth preserving.]
```

## Guidelines

- Separate the project's fault from the agent's fault. A friction the agent caused by not reading available docs is a `/session-review` finding, not an architecture finding — say so and move on.
- Prefer fixes that prevent a *class* of friction over fixes for a single instance.
- Keep CLAUDE.md additions concise and specific — "Generated files in `X/` must not be edited; edit `Y/` and run `Z`" beats "be careful with generated files."
- Don't recommend a refactor when a documentation line would do. Reserve refactor calls for friction a human would also stumble on.
- If the session showed little or no architectural friction, say so plainly. Don't manufacture findings.
- Cross-reference `/capture` — if a friction reveals a reusable convention, suggest capturing it into the toolbox.
