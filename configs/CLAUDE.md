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

## Delegate Implementation to Cheaper Models When Running on a Premium Tier

When you are running as a premium-tier model — Opus, Fable, or any future model
priced above Sonnet — act as the planner/reviewer and delegate mechanical
implementation to a cheaper subagent (the `Agent` tool with an explicit
`model:`). Rough price ladder (per MTok in/out, as of mid-2026): Fable $10/$50,
Opus $5/$25, Sonnet $3/$15, Haiku $1/$5. The gap is largest at the top — a
Fable session typing boilerplate is the most expensive way to produce it in the
whole lineup — and delegating also keeps the premium session's context clean
and shortens its wall-clock time.

The delegation ladder:

- **Keep on the premium model:** understanding the problem, designing the
  approach, architecture decisions against hard constraints, and reviewing the
  subagent's diff before it lands.
- **Delegate to Sonnet (the default target):** implementation that is
  well-specified and largely pattern-following — mirror an existing module, add
  a CRUD endpoint, wire a flag through, write tests to a stated spec. Give the
  subagent a tight brief: the files/patterns to mirror, the exact test/build
  commands, and the constraints it must honor.
- **From Fable, delegate to Opus (`model: opus`)** when implementation is
  scoped and well-specified but still judgment-heavy — a subtle refactor, a
  tricky-but-bounded algorithm — work that would strain Sonnet but doesn't need
  Fable-level reasoning.
- Use a fresh `general-purpose` (or task-specific) agent with an explicit
  `model:`. A `fork` cannot downgrade the model (it always inherits the
  parent), so it saves no tokens — and a fork of a Fable session bills at Fable
  rates.
- **Skip delegation** when the work is trivial (a one-line edit costs more to
  brief than to do) or when the implementation itself needs the premium model's
  sustained judgment (subtle concurrency, security-critical logic, or a design
  still being discovered while coding). When running as Opus, the Sonnet price
  gap is modest (~1.7×), so lean on delegation mainly for context hygiene and
  parallelism rather than as a strict cost rule.
- Always review what the subagent returns — you own the result.

## Named Arguments at Call Sites

When a function takes more than ~two parameters, any boolean flag, or two adjacent same-typed parameters, bind its arguments by name at the call site by construction — via keyword-only parameters where the language supports them, or an options object / config struct / builder where it doesn't.

## No Magic Strings or Numbers

A literal that carries domain meaning — a status value, a key or column name, a route, an env var, an error code, a feature-flag name, a threshold, a duration, a limit — belongs in a named constant defined once, with every use referencing that name.

Strings are the more urgent half, because they fail quietly. A mistyped number usually blows up; a mistyped `"pending"` just silently never matches, and the bug surfaces as absent behavior somewhere far away. So prefer the strongest construct the language offers — an enum, a literal union type, a frozen constants module — over a bare string repeated at call sites, and let the compiler or type checker catch the typo instead of a user.

- **Name the *why*, not the *what*.** `RETRY_BACKOFF_CEILING_SECONDS = 30` earns its place; `THIRTY = 30` doesn't.
- **Define it where the concept lives**, and import it — a constant duplicated across three modules is the same magic value with extra steps.
- **Leave inline:** genuinely self-evident values (`0`, `1`, `-1` as bounds or increments, empty checks), one-off literals inside the module that owns the concept, human-facing log and error message text, and test fixtures where spelling the value out *is* what makes the assertion readable.
- For code you're **authoring**, extract as you write — no need to ask. For **existing** code, follow the sibling rules below: surface the duplication and propose the extraction rather than silently refactoring.

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

## Look at Visual Changes Before Calling Them Done

When a change alters what actually renders, capture the affected view and look at it before reporting the work complete. Passing tests and a clean diff say nothing about overlapping text, a collapsed container, or an element that silently failed to appear — those are only visible in a picture.

**What triggers this** is a change to rendered output: layout, spacing, sizing, color, typography, new or restructured UI, responsive behavior, or anything whose visual result you are predicting rather than observing. Editing a file that happens to contain UI is not the trigger — a rename, an extracted subcomponent, a logic fix that leaves the render byte-identical needs no screenshot.

**What the look is for** is screening for breakage, not approving the design. Report what is plainly wrong — overlap, clipping, misalignment, a missing or unstyled element, text spilling its container. Do not report back that a design "looks good"; that judgment is mine to make, and a confident all-clear from you is worth less than a specific observation.

**When you can't capture it, say so.** A view may need a running server, a route behind auth, a particular data state, or a browser tool that isn't available. Do not spend meaningful effort fighting the harness to get an image. Stop, state plainly that you could not see the change render, and name what you'd want me to check by eye instead. Silently skipping the check is the failure mode to avoid — an unverified change reported as verified is worse than an honest gap.

Use the project's own way of launching the app where one exists (the `/run` skill, or a documented dev-server command) rather than improvising a harness. Then delete the image per the rule below.

## Debugging Screenshots

After reading a debugging screenshot (e.g. one taken via Playwright MCP, or captured to verify a visual change), delete the file immediately. Do not leave screenshot files on disk after they have served their purpose.

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

## Hold the Primary Goal, and Report Against It

A session has one **primary goal**: the objective set by my most recent goal-setting
instruction. It stays in force until I replace it. Nothing you encounter while
working promotes itself into a new primary goal — not an interesting discovery, not
a bug you trip over, not a failing test in unrelated code, not a refactor that would
obviously help. Those are *side observations*, and the response to a side
observation is to record it and keep going. Ask me before changing course; don't
infer a new goal from what you found.

When you return control after an **extended batch of autonomous work** — several
tool calls, or any change to files — lead your response with two headers, then
whatever prose the situation needs:

**Primary Goal** — restate the goal in one line, then say concretely what moved
between my last instruction and now, and what remains. A few sentences at most.
Write it in behavioral terms per *Lead with Behavior, Not Identifiers* above: what
the system does differently now, not which files you touched. If nothing moved, say
that plainly and say why. If what you did doesn't match the goal you just restated,
that mismatch is the most important thing on the screen — name it rather than
letting the prose smooth it over.

**Side Observations** — a numbered list, each item a sentence or two. **Zero side
observations is a normal, expected outcome**; when there are none, write "None" and
move on. Do not pad this section to look thorough — a manufactured observation is
worse than an empty list, because it costs me a read to discard.

After the two headers, use ordinary prose for anything longer: detail, evidence,
open questions, obstacles per *Reporting Avoidable Obstacles* above.

Scope this to real work batches. A question, a short answer, a one-line edit, or a
conversational turn gets a normal reply — a rule applied ceremonially to trivial
turns is one that erodes into being ignored on the turns that matter.

**Relationship to the worklog below:** the report is the *surface* — what I see now,
then scroll past. The worklog is the *durable record*. A side observation worth
keeping gets filed as a worklog entry at the moment you notice it, and the report
cites the path. One that isn't worth keeping just gets its line in the report and
dies there. Don't maintain the same item as prose in both.

## Park Open Items in the Repo's Worklog

When you surface something outside the current task — a bug noticed in passing, a
design concern, a question you want me to answer — do not leave it in prose alone.
Prose gets compacted away or buried as the conversation drifts. Write it to disk in
the repo, as a **worklog entry**, so it survives the session that found it.

**Write the entry when you discover the item, not when you start working on it.**
This is the whole point, and it is the part that gets skipped: discovery-time is
when the context is free. You have just run the command, read the file, seen why it
looked wrong. An hour later — or after a compaction — that same entry costs a
re-investigation to write, and the second version is worse because it reconstructs
the reasoning instead of recording it.

The entry is one file, and it is **both** the open-item and the record of thinking.
Do not treat those as separate artifacts:

- **What was observed**, in behavioral terms — what the system does that it
  shouldn't, or what I have to decide.
- **The evidence**, concretely: the commands run and their relevant output, the
  `path/to/file.py:42` references. Enough that the next reader does not re-derive it.
- **Why it matters**, or why it might not — including "this looks alarming and
  isn't," which is a valuable entry.
- **Approaches considered and rejected, with the reason** — and **who** rejected
  it. "Ruled out polling; too slow" reads the same whether I decided it or you did,
  but the two mean opposite things to the next session: my call is settled, yours is
  a hypothesis a later agent with better information should feel free to overturn.
  This never survives in a diff, and it is what makes an old entry useful: it is how
  a wrong approach gets diagnosed after the fact, and how trends across many entries
  become visible.
- **The resolution**, recorded when it lands — the PR, or the decision not to act.

**Updating an entry is two motions, not one.** New facts append at the bottom; the
claims at the top get rewritten *in the same pass*. Appending alone is the natural
motion and it silently rots the entry: an update arrives as "here is what happened
on the 12th", lands at the bottom, and the paragraph three screens up goes on
asserting the opposite in the present tense with nothing marking it stale. So when
the bottom of an entry contradicts the top, **the top is what's wrong** — go fix
that sentence. Do not add a third paragraph reconciling the first two. This is
**Corrections rewrite in place** from the memory section below, and it binds here
for the same reason: a reader who stops halfway down must not be misinformed.

Record the *shape* of a correction, not just the corrected fact. A line naming how
the mistake was possible — "the root of both errors was reading a code default as
though it were the deployed value" — is the most useful thing an entry can carry,
because it generalizes and the fact doesn't.

**An entry is one item.** Two things follow, and both are maintenance you have to
do deliberately because neither happens on its own. When investigation moves and
the title no longer describes what the entry is about, rename the file to match and
fix the inbound links — a stale slug is how the next reader fails to find the entry
that already explains their problem. And when two items are sharing a file because
they share a *resource* rather than a cause, split them; otherwise the resolved
half can never be archived without burying the open half with it.

**Mark what I told you, not what you found.** Your own observations arrive with
commands and file references attached — inherently re-checkable, so their
authorship is implied and uninteresting. The default is "agent-derived and
re-derivable," and restating that on every entry is noise. Label the exception:

- **Constraints and environment facts I supplied** that can't be verified from the
  repo — a deadline, a hand-edited firewall rule, a platform we're not supporting.
  Give these a `> Stated by Max; not verifiable from the repo` line where they
  appear. It tells the next reader not to go hunting for confirmation, and not to
  weigh its own inference as equally authoritative.
- **Decisions I made**, per the bullet above — name me, rather than writing them in
  the same first-person voice as your own reasoning.

Attribution is not permanence: something I stated about mutable external state is
still a lead to re-verify, not a fact. And never add an `author:` field or a
human-vs-agent tag to every entry — a label that's the same on 95% of entries
carries no signal and makes provenance look handled while the two cases above go
unmarked anyway.

Rules for filing:

- **Where:** the repo's worklog directory if it has one (`docs/worklog/`, or
  wherever its `CLAUDE.md` says). The entry belongs in the repo whose code it
  describes, so it travels with that code. **In a repo that has no worklog
  convention, ask before creating one** — don't invent a top-level directory
  mid-task. Until I answer, the session task list is the fallback.
- **Check the existing entries before filing** so the same observation doesn't
  accumulate three times, and so you find the entry that already explains it.
- **File it, don't pursue it.** Writing an entry is not permission to act on it,
  and it doesn't license a detour from what I actually asked for.
- **Never resolve an entry on your own.** Open items are mine to close. Leave them
  open until I say otherwise.
- Only file what's worth keeping. Passing thoughts, and things you already handled
  inside the task, don't belong here.

**When to escalate an item to the issue tracker instead:** the test is not size or
effort, it's **whether someone outside this session needs to act on it**. Tracker
if it needs scheduling, review, acceptance criteria, or I track it as a
deliverable. Worklog for everything else — including things that will never be
done, which the tracker has no good resting place for.

**Promote by link, not by copy.** When an entry graduates to a tracked task, the
task points at the worklog path and the entry records the task id. The tracker owns
status and scheduling; the repo owns evidence and reasoning. Copying the reasoning
into both creates two systems of record, and the interesting half then lives in
whichever one was updated last.

A worklog entry is a durable record, not memory — see **Memory: Cache Rediscovery,
Not State** below. The same rule applies within an entry: record the check and the
evidence, and date any claim about mutable state rather than asserting it flatly.

## Test-Driven Development

When implementing new functionality or fixing bugs, follow red-green TDD:

1. **Red**: Write a failing test that defines the expected behavior before writing any implementation code.
2. **Green**: Write the minimum implementation code to make the test pass.
3. **Refactor**: Clean up the implementation while keeping tests green.

- Run the failing test first to confirm it fails for the right reason.
- Do not write implementation code without a corresponding test.
- Keep the red-green-refactor cycles small and focused.

## Memory: Cache Rediscovery, Not State

Memory exists to spare me *rediscovery* — where a thing lives, how it's checked, what the convention is — not to spare a cheap verification call. The expensive part of "is staging deployed?" was never the `curl`; it's knowing which box and which endpoint. Cache the hunt, not the answer.

Before writing a memory, ask: **can this become false without a commit?** If yes it is state, not knowledge — someone can fix a webhook at 2am and nothing in the repo changes, so there is no moment where I could have noticed it drift. Don't assert it.

- **Record the check, not the result.** Not "staging auto-deploy is broken" but "to check whether staging deployed: `curl -s https://staging/…/version`, compare the SHA to origin/main." The endpoint is durable; the verdict isn't.
- **The `description:` states a topic, never a claim.** It is the recall surface — the one line matched for relevance before the body is ever opened — so a description asserting mutable state goes on asserting it long after the body has been corrected. Write "how SSH ingress is configured on X", not "SSH on X is hardened".
- **Corrections rewrite in place.** Never append a fix below a stale claim; a memory is not a changelog. When a file's top contradicts its own bottom, the top is what gets believed.
- **Delete superseded memories** rather than annotating them as superseded.
- **Don't lean on metadata to stay safe.** Dates, re-check commands, and "delete once verified" markers do not make a stale claim safe — nothing runs them at recall time. If a fact needs a freshness caveat to be trustworthy, it doesn't belong in memory as a claim.

**Read-time counterpart:** a memory describing mutable external state — deploy status, service health, credentials, resource config, DB contents — is a **lead, not a fact**. Verify it before acting, and fix the memory in the same pass. Memories describing conventions, locations, architecture, and my preferences are trusted without re-checking.

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