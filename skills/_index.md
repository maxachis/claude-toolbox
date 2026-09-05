# Skills Index

This directory holds two different things. Only the first is loaded by Claude Code.

## Loadable Skills

A directory containing a `SKILL.md` with YAML frontmatter. Claude Code discovers these
at `~/.claude/skills/<name>/SKILL.md` and loads one when its `description` matches the
work at hand, or when invoked explicitly as `/<name>`. The directory name is the slash
name; supporting files beside `SKILL.md` are loaded only when referenced.

| Skill | Loads when |
|-------|------------|
| [background-long-tasks](background-long-tasks/) | Launching a command that may run for minutes |
| [generate-then-separate](generate-then-separate/) | Creating a substantial new module and deciding how to structure it |
| [go-app-distribution](go-app-distribution/) | Setting up releases, auto-update, or installers for a Go app |
| [pdf-scraping](pdf-scraping/) | Extracting structured data from PDFs |
| [playwright-efficient](playwright-efficient/) | Driving a browser through Playwright MCP |
| [worklog-entries](worklog-entries/) | Writing, updating, or correcting a worklog entry |

`go-app-distribution` keeps its three recipes (releases, update check, Windows
packaging) as reference files beside `SKILL.md`, loaded only when linked to.

## Reference Notes

Everything under the category directories below is a browsable library of background
notes, **not** loaded automatically. Read one when it is relevant, or promote it to a
loadable skill by giving it its own directory and a `SKILL.md`.

### [Languages](languages/)
Language-specific knowledge and best practices.
- Python conventions
- TypeScript patterns
- Go idioms (pure-Go SQLite, cross-platform paths, error wrapping)
- Rust idioms
- And more...

### [Frameworks](frameworks/)
Framework-specific guidance and patterns.
- React best practices
- Django conventions
- FastAPI patterns
- Wails (desktop Go + webview; v3 alpha IPC + Linux webkit2gtk gotchas)
- And more...

### [Practices](practices/)
Development practices and methodologies.
- Test-driven development (TDD)
- And more...

## Installation

`setup.sh` symlinks this whole directory to `~/.claude/skills/`, so loadable skills are
discovered and reference notes come along for browsing. No per-file copying needed.

## Creating a Loadable Skill

Make a directory named for the slash command, with a `SKILL.md` whose frontmatter opens
on line 1:

```markdown
---
name: worklog-entries
description: What this covers, and when to load it. Keywords here are what Claude
  matches against the request, so name the trigger conditions explicitly.
---

# Title

Instructions...
```

`name` and `description` are the only fields needed. Useful optional ones:
`allowed-tools`, `model`, `disable-model-invocation` (explicit `/name` only), and
`paths` (limit auto-invocation to matching files).

Keep the body focused on what changes behavior. Guidance that belongs in every session
goes in `configs/CLAUDE.md`; guidance needed only while doing a specific job belongs
here, where it costs nothing until it fires.
