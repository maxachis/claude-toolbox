---
description: Analyze project for reusable patterns and capture them into the toolbox
argument-hint: "[rules|conventions|commands|skills|all]"
---

# Capture

Analyze the current project and session to identify reusable patterns, then capture them into the Claude toolbox.

## Arguments
- $ARGUMENTS — optional focus area: `rules`, `conventions`, `commands`, `skills`, or `all` (default: `all`)

## Instructions

1. Read the project's `./CLAUDE.md` and scan `.claude/rules/` for convention files.
2. Read the toolbox's existing content to understand what's already captured:
   - `${TOOLBOX_ROOT}/rules/project-types/` for project-type templates
   - `${TOOLBOX_ROOT}/rules/conventions/` for convention snippets
   - `${TOOLBOX_ROOT}/skills/` for skill files
3. Identify novel patterns in this project that are NOT yet in the toolbox:
   - Project rules that could become reusable templates
   - Convention snippets worth sharing across projects
   - Workflow commands that solve common problems
   - Skills or knowledge that other projects would benefit from
4. Present findings as a numbered list with:
   - What was found and where
   - What type it would be captured as (rule, convention, command, skill)
   - Whether it's genuinely reusable or too project-specific
5. Ask which items to capture.
6. For each selected item, write it as a properly-formatted toolbox file:
   - Rules go to `${TOOLBOX_ROOT}/rules/project-types/<name>.md`
   - Conventions go to `${TOOLBOX_ROOT}/rules/conventions/<name>.md`
   - Commands follow the standard command template format
   - Skills use concise bullet-point guidelines
7. Update the relevant `_index.md` catalog files after writing.

## Output format
A summary of what was captured and where, with paths to the new files.
