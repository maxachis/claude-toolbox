# Global Instructions

<!-- This file is linked to ~/.claude/CLAUDE.md by setup.sh -->
<!-- These instructions apply to all Claude Code sessions. -->

When committing to git, default to ssh rather than HTTPS.

## Commit Messages

Write commit subject lines in [Conventional Commits](https://www.conventionalcommits.org/) format: `type(optional-scope): description`.

- Common types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, `perf`.
- Keep the subject in the imperative mood and under ~72 characters.
- Use the body to explain *what* and *why* when the change isn't self-evident from the subject.

## Reporting Avoidable Obstacles

While executing a request, you may hit friction that is both **substantial and preventable** — e.g. a straightforward change trips a footgun, or you spend significant effort hunting for something that should have been easy to find, or a tool/setup behaves surprisingly.

When this happens, note it in your final remarks before returning control to the user. For each obstacle, briefly state:

- **What** the obstacle was
- **A concrete recommendation** to avoid it next time (a doc or comment to add, a config to change, a convention to record)

Keep the bar high: report only friction that was meaningful and avoidable, not routine work or expected effort. If an obstacle is a recurring project gotcha, also record it per **Learning from Mistakes** below.

## Test-Driven Development

When implementing new functionality or fixing bugs, follow red-green TDD:

1. **Red**: Write a failing test that defines the expected behavior before writing any implementation code.
2. **Green**: Write the minimum implementation code to make the test pass.
3. **Refactor**: Clean up the implementation while keeping tests green.

- Run the failing test first to confirm it fails for the right reason.
- Do not write implementation code without a corresponding test.
- Keep the red-green-refactor cycles small and focused.

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