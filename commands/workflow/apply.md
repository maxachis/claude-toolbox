---
description: Pull rules, conventions, or bundles from the toolbox into this project
argument-hint: <rule|convention|bundle> <name>
---

# Apply

Pull knowledge from the Claude toolbox into the current project — rules, conventions, or bundles.

## Arguments
- $ARGUMENTS — what to apply: `rule <name>`, `convention <name>`, `bundle <name>`, or `list [type]`

## Instructions

1. If the user says "list" or no arguments are given, list what's available:
   - Scan `${TOOLBOX_ROOT}/rules/project-types/` for project-type templates
   - Scan `${TOOLBOX_ROOT}/rules/conventions/` for convention snippets
   - Scan `${TOOLBOX_ROOT}/bundles/` for curated bundles
   - Present a categorized summary and ask what to apply
2. If the user specifies a type and name, apply it:
   - **rule**: Read `${TOOLBOX_ROOT}/rules/project-types/<name>.md`, review it with the user, then write to `./CLAUDE.md`
   - **convention**: Read `${TOOLBOX_ROOT}/rules/conventions/<name>.md`, review it with the user, then write to `.claude/rules/<name>.md`
   - **bundle**: Read the bundle's `CLAUDE.md` and list its commands, review with the user, then copy `CLAUDE.md` → `./CLAUDE.md` and commands → `.claude/commands/`
3. Before overwriting any existing file, show a diff and ask for confirmation.
4. After applying, summarize what was written and where.

## Output format
A summary of applied content with file paths.
