# Global Instructions

<!-- This file is linked to ~/.claude/CLAUDE.md by setup.sh -->
<!-- These instructions apply to all Claude Code sessions. -->

When committing to git, default to ssh rather than HTTPS.

## Time Zone

When presenting times to me in conversation, use US Eastern Time
(America/New_York, accounting for EST/EDT) rather than UTC. This applies only
to times shown in your responses — do not alter timestamps in code, commits,
logs, or data, which should stay in their native zone (usually UTC).

## Lead with Behavior, Not Identifiers

When you tell me what you did, found, or plan to do, describe it in terms of behavior and domain concepts — what changes about how the system acts, and why. A function, class, module, or file name only communicates to a reader who already holds it in memory. I usually don't: when you wrote the code, its internal names are yours, not mine, and a sentence built around one is a sentence I skim past.

- **Open with the effect.** "Logins now survive a server restart" comes before — and often instead of — "`SessionStore.persist()` now writes to Redis."
- **Identifiers are locators, not subjects.** Once the point has landed in prose, a trailing `path/to/file.py:42` earns its place; I can click it. A sentence whose grammatical subject is a symbol I've never seen has not.
- **Name a symbol when I have to act on it** — I'll call it, configure it, or you're asking me to pick between options — and say in the same breath why it matters to me.
- **Prefer the domain word to the code word.** If the class is `RetryPolicy`, say "the retry rules," unless the gap between the concept and that particular class is itself the point.
- This applies to questions and plans as much as to summaries: "should the cache expire on write or on read?" rather than "should `_invalidate` be called from `put` or `get`?"

A useful test before you send: if I have no memory of any name in this paragraph, does it still tell me what happened? If not, rewrite the first sentence.

## Delegate Implementation to Sonnet When Running as Opus

When you are running as an Opus model, act as the planner/reviewer and delegate
the mechanical implementation to a Sonnet subagent (the `Agent` tool with
`model: sonnet`). Opus tokens cost several times Sonnet's, so reserve Opus for
what needs its judgment and let Sonnet do the typing.

- **Keep on Opus:** understanding the problem, designing the approach,
  architecture decisions against hard constraints, and reviewing the subagent's
  diff before it lands.
- **Delegate to Sonnet:** implementation that is well-specified and largely
  pattern-following — mirror an existing module, add a CRUD endpoint, wire a flag
  through, write tests to a stated spec. Give the subagent a tight brief: the
  files/patterns to mirror, the exact test/build commands, and the constraints it
  must honor.
- Use a fresh `general-purpose` (or task-specific) agent with `model: sonnet`. A
  `fork` cannot downgrade the model (it always inherits the parent), so it saves
  no tokens.
- **Skip delegation** when the work is trivial (a one-line edit costs more to
  brief than to do) or when the implementation itself needs sustained
  Opus-level judgment (subtle concurrency, security-critical logic, or a design
  still being discovered while coding).
- Always review what Sonnet returns — you own the result.

## Named Arguments at Call Sites

When a function takes more than ~two parameters, any boolean flag, or two adjacent same-typed parameters, bind its arguments by name at the call site by construction — via keyword-only parameters where the language supports them, or an options object / config struct / builder where it doesn't.

## Avoid Monolithic Files

When a file you're working in has grown large *and* is mixing unrelated concerns (e.g. IO, business logic, and presentation in one module), don't silently keep adding to it. Surface this to the user: name the distinct concerns you see and propose a concrete split. Do not refactor without approval — file splits ripple through imports and history. Size alone isn't the trigger — a long but cohesive file is fine; the signal is *multiple responsibilities* that have outgrown one module.

This is the file-level sibling of **Keep Code at One Level of Abstraction** below.

## Keep Code at One Level of Abstraction

Within a single function or block, keep statements at a consistent conceptual level. Don't interleave high-level orchestration (named domain steps) with low-level mechanics (loop bookkeeping, string/byte manipulation, manual index math, error-handling plumbing). When a block of low-level detail appears amid high-level steps, extract it behind a descriptively named function so the body reads as one coherent narrative.

- For code you're **authoring**, extract as you write — no need to ask. Apply this conservatively: the trigger is a *block* of low-level detail that obscures the high-level flow, not the mere presence of any lower-level statement. A guard clause, an early return, or a single short loop in an otherwise high-level function is fine. Don't fragment logic into a swarm of one-line functions.
- For **existing** code, treat it like *Avoid Monolithic Files* above: surface the mismatch and propose the extraction rather than silently refactoring.

## Complex Payloads Don't Belong in Shell Strings

When a Bash command carries a payload with its own quoting or line structure — SQL, JSON, a script body, anything with nested or mixed quotes — do not inline it into the command string. Two layers of quoting (the shell's and the payload's) will eventually collide, and the failure is usually silent or misleading rather than a clean syntax error.

Instead, pass it out-of-band:

- **Quoted heredoc** for a literal payload: `sqlite3 db.sqlite <<'SQL' ... SQL`. Quoting the delimiter (`<<'SQL'`) stops the shell from expanding `$`, backticks, and `\` inside the body.
- **A temp file** when the payload is reused, is large, or the tool wants a path.
- The tool's own `--file` / `-f` / stdin flag when it has one.

Use an unquoted heredoc (`<<SQL`) only when you *want* shell interpolation into the body, and never with untrusted content.

This applies to writing files too: prefer the Write tool over `cat > f <<EOF`.

## Debugging Screenshots

After reading a debugging screenshot (e.g. one taken via Playwright MCP), delete the file immediately. Do not leave screenshot files on disk after they have served their purpose.

## Work in Your Own Worktree

A checkout has exactly one HEAD. When two sessions share one, whichever switches
branches moves the other session's branch *and working tree* under it, silently —
the second session then commits onto the first one's branch, or bases a new branch
on unrelated commits. Nothing errors; you just notice later, if at all.

So: **before starting work that will create commits in a repo, check whether
another session may be active in it, and if so work in your own worktree** (the
`EnterWorktree` tool, or `git worktree add`). Signals another session is live:
`git branch --show-current` returns a branch you didn't create, unfamiliar recent
commits or reflog entries, or files changing that you didn't touch.

- **Always verify your branch immediately before committing** — `git branch --show-current`
  — rather than trusting the branch you checked out earlier in the session. This is
  cheap and catches the problem regardless of worktrees.
- **Never** `reset --hard`, force-checkout over, or delete a branch you did not create.
  If you find someone else's work in your way, say so and re-base your own work off it.
- Worktrees share the object store and branch refs but **not** untracked files, so
  `node_modules`/`.venv`/`.env` need reinstalling or symlinking per worktree.
- They do **not** isolate ports. Two dev servers still collide on the same port; that
  is a separate problem needing a separate port.

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