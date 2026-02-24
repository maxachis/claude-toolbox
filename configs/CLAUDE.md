# Global Instructions

<!-- This file is linked to ~/.claude/CLAUDE.md by setup.sh -->
<!-- These instructions apply to all Claude Code sessions. -->

When committing to git, default to ssh rather than HTTPS.

## Learning from Mistakes

### When to record a mistake

Record a mistake when any of these happen:

- You encounter an error that a future Claude agent could reasonably repeat
- The user corrects you (explicitly or by providing the right approach after you did the wrong one)
- A test, linter, or CI check fails because of something you did wrong
- You discover a project-specific convention only after violating it

Only record non-obvious, project-specific gotchas — not general programming knowledge.

### Where to record it

- **Project-specific** mistakes (tooling, test setup, local conventions): add to the project's CLAUDE.md under a `## Mistakes` section.
- **Cross-project** mistakes (general workflow patterns, common tool pitfalls): add to your auto-memory `mistakes.md` file.

### Format

Use this structured format for each entry:

```
- **[category]**: concise description. `wrong` → `right`.
```

Categories: `tooling`, `testing`, `env`, `convention`, `dependency`

Examples:
- **[tooling]**: Use `uv run` instead of `python3` to run scripts.
- **[env]**: Tests require dev database — run `docker compose up db` first.
- **[convention]**: Generated files in `configs/devcontainer/*.jsonc` must not be edited directly — edit `src/` and run `generate.sh`.

### Maintenance

When editing a Mistakes section, also review existing entries:

- Remove any that are no longer accurate (e.g., tooling or config changed)
- Merge duplicates
- Keep the section under 15 entries — if full, drop the least impactful