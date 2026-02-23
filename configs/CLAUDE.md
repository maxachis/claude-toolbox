# Global Instructions

<!-- This file is linked to ~/.claude/CLAUDE.md by setup.sh -->
<!-- These instructions apply to all Claude Code sessions. -->

When committing to git, default to ssh rather than HTTPS.

## Learning from Mistakes

When you encounter an error that a future Claude agent could reasonably also make (e.g., running `python3` instead of `uv run`, using the wrong test runner, missing a project-specific convention), update the project's CLAUDE.md with a concise note to prevent the same mistake. Keep entries short and actionable, e.g.:

- "Use `uv run` instead of `python3` to run scripts in this project."
- "Tests require the dev database to be running — see `docker compose up db`."

Only add entries for non-obvious, project-specific gotchas — not general programming knowledge.