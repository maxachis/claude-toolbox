---
name: api-proposal
description: Write an API design proposal (new, changed or removed HTTP endpoints) as a standard review page for Max to approve before any endpoint code is written. Load when a task will add, change or remove an API endpoint in a repo whose CLAUDE.md requires a proposal (Tissue), or when asked to propose, design or review API changes.
---

# API Proposal

Max reviews API changes **before the code exists**, on one standard page, so he
can judge the contract without reading the implementation. The page shows seven
things per endpoint: (1) path, (2) method, (3) what it does, (4) tables read and
written, (5) input with an example, (6) output with an example, (7) who can call
it. For a changed endpoint it shows *now* beside *proposed*, folds unchanged
sections away, and flags anything that breaks existing callers.

Voice: "I" and "me" are Max; "you" is the agent writing the proposal.

## The workflow

1. **Read the current contract from the code, at the base branch.** For every
   endpoint you will change, the *before* side must describe what is running,
   not what you remember. In Tissue the route file declares it directly: the
   TypeBox `schema` (`params`, `querystring`, `body`, `response`) is fields 5–6,
   `config.auth.requires` is field 7 (also committed in
   `api/src/auth/route_matrix.ts`; public routes are listed in
   `api/src/auth/public_surface.ts`). Read via `git show origin/<base>:<path>`,
   per the repo's stale-checkout warnings.
2. **Write the proposal JSON** (format below; `example.json` in this
   directory is a complete worked example to copy from). If the repo's
   CLAUDE.md names a proposals directory, write it there as
   `YYYY-MM-DD-<short-slug>.json`; otherwise use the scratchpad.
3. **Render it:** `python3 ~/.claude/skills/api-proposal/render.py <proposal.json> -o <out.html>`.
   The renderer refuses an invalid proposal and says why.
4. **Publish the HTML as an Artifact** (private by default; only I read these).
   Keep the same file path for revisions so the URL stays put.
5. **Stop and wait for my review.** Do not write endpoint code, tests or
   migrations for the proposed contract until I approve it. My comments may
   arrive in chat or as comments on the artifact; revise the JSON, re-render,
   republish to the same path.
6. **After I approve**, implement to the approved contract. If implementation
   forces a contract change (a field, a status, a permission), say so and
   republish the proposal; don't let the code drift silently from what I signed off.
7. **Commit the approved proposal JSON with the implementing PR** when the
   repo keeps a proposals directory, so the contract I signed off travels with
   the code that implements it. Add the artifact link as a top-level
   `"artifact"` field. Commit the JSON only, never the rendered HTML: it is
   regenerable, and a committed copy would go stale the first time the
   template changes.

## What the renderer computes, and what you write

The renderer, not you, decides which fields were added, removed or changed, and
which changes break callers. You write both sides in full; do not try to
describe the diff yourself. It flags as breaking:

- an output field removed, or its type or nullability changed;
- an input field removed (Tissue **refuses unknown request fields**, so a caller
  still sending it gets a 400), added as required, or changed type/required;
- a permission change;
- a removed endpoint.

A change that keeps the shape but alters the meaning (a field that now means
something different, a default that flips, a list that newly includes drafts)
is invisible to that comparison. Put it in the endpoint's `breaking_notes`.

## Proposal format

```jsonc
{
  "title": "Byline bios and credit lists",   // the page name
  "status": "Draft",                          // free text pill
  "repo": "tissue-core", "base": "staging", "date": "YYYY-MM-DD",
  "task": "docket TASK-123",                  // optional
  "summary": "Plain-English paragraph: what changes for whom, and why.",
  "diagram": "graph LR\n ...",                // optional mermaid; see below
  "endpoints": [
    {
      "change": "new" | "changed" | "removed",
      "method": "GET", "path": "/bylines/:byline_id/credits",
      "before": { ...side },                  // changed + removed
      "after":  { ...side },                  // new + changed
      "breaking_notes": ["..."]               // optional, semantic breaks only
    }
  ],
  "questions": [                               // decisions you need from me
    {"id": "Q1", "question": "...", "context": "...", "options": ["...", "..."]}
  ]
}
```

A **side**:

```jsonc
{
  "purpose": "What it does, in plain English, from the caller's point of view.",
  "tables": [{"table": "bylines", "access": "read" | "write"}],
  "input": {
    "fields": [{"name": "byline_id", "in": "path" | "query" | "body", "type": "uuid",
                "required": true, "notes": ""}],
    "example": {"request": "PATCH /bylines/3c1e…a9", "body": {...}}   // body optional
  },
  "output": {
    "status": "200",
    "fields": [{"name": "items[].title", "type": "string", "required": true, "notes": ""}],
    "example": {...},
    "errors": [{"status": "404", "when": "No byline with that id"}]
  },
  "auth": {"permission": "content:write", "who": "Plain-English description of who holds it",
           "notes": "optional"}
}
```

Conventions that keep the comparison honest:

- **Use identical text for anything that did not change.** The renderer
  compares `type`, `required` and `notes` literally, so rewording an unchanged
  field marks it changed.
- **Types are short and literal:** `uuid`, `string (≤600) | null`,
  `person | organization`, `integer 1–100`, `{ asset_id, url } | null`. Nested
  output uses dotted paths (`items[].url`).
- **`tables` means the database tables the handler and the services it calls
  touch**, traced through to the Prisma calls. Leave out tables touched only by
  the auth layer.
- **Examples use realistic values** in the subject's own vocabulary (council
  meetings, bylines, newsletters), abbreviating ids as `3c1e…a9`.
- **Questions list options without recommending one,** per my global rules.
  A call you can make yourself goes in the summary as a stated assumption.
- **Diagram only when it earns its place:** more than a few tables, or several
  endpoints sharing data. Mermaid `graph LR`, endpoints as boxes, tables as
  `[(cylinders)]`, edges labelled `read`/`write`. The renderer places it so
  the Artifact viewer draws it.

## Maintaining this skill

`test_render.py` is the renderer's spec: `python3 -m unittest discover -s ~/.claude/skills/api-proposal`.
Add a failing test before changing what the renderer computes.
