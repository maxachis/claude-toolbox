---
name: background-long-tasks
description: Run long CLI work — builds, test suites, simulation or balance runs, data jobs, training — in the background and await completion, rather than sleep-polling or racing parallel invocations that contend for the same lock. Load before launching any command that may run for minutes, when deciding how to wait on one, or when a background job needs a time bound or a stray one needs stopping.
---

# Long-Running Tasks: Background, Don't Poll

Some projects have CLI tooling that legitimately runs for minutes — build steps,
test suites, balance/simulation runs, data jobs, training. Handle these by
launching them in the background and waiting for completion, never by polling.

## The Rule

- Launch a multi-minute command with `run_in_background: true`.
- Wait for the completion notification, then read its output file once.
- To wait on a *condition* (not a command you started), use a `Monitor`
  until-loop: `until <check>; do sleep 2; done`.
- **Never** chain `sleep N` with `cat`/`tail` to poll a background job. Harnesses
  block chained sleeps, and each polling attempt that spawns a watcher shell
  leaks a process — these accumulate fast.
- **One job per contended resource.** If the work touches something that
  serializes — a database, a remote host over SSH, a build cache, a device — run
  a single supervised session against it. Do not fan out parallel background
  jobs onto the same resource.

## Bound It, Then Reap It

Backgrounding assumes the job ends. A command that never exits sends no
completion notification, so nothing ever wakes the session up to clean it
up — the process outlives the turn, the task, and often the session itself.
Worse, from inside the session an immortal job is indistinguishable from a slow
one: both look like "still running."

The usual offenders are the ones with no natural end — a dev server, `tail -f`,
a watch-mode build or test runner, `docker compose up` without `-d`, and any
`Monitor` until-loop whose condition never becomes true.

- **Bound anything that could outlive its purpose.** Prefer a form that
  terminates on its own: `timeout 300 <cmd>`, a run-once flag instead of watch
  mode, `--exit-after` / `--single-run` where the tool offers it. Pick the bound
  from the work's real duration — the bound's job is to say "if it ran past
  this, it hung or I forgot about it," not to be generous.
- **Cap the wait, not just the job.** An until-loop needs an iteration ceiling as
  well as a condition, so a condition that never comes true still ends.
- **Stop it in the turn its purpose is served** — screenshot captured, endpoint
  answered, check passed. Use `TaskStop` on the task id the launch returned;
  don't leave the shutdown for the end of the session, because that moment may
  never arrive.
- **Sweep before handing control back.** After work that started anything in the
  background, list what's still live and stop what you no longer need. State
  what you deliberately left running (a dev server the user is about to use) and
  why. The user sees the same list under `/tasks`.
- **Never stop what you didn't start.** Another session's jobs and the user's own
  servers are not yours to reap.

## Anti-Patterns

```bash
# BAD — blocked by the harness, and leaks watcher shells if it weren't
sleep 60 && cat /tmp/.../job.output
sleep 25 && tail -16 /tmp/.../job.output
```

```
GOOD — launch once with run_in_background, await the completion
notification, then read the output file a single time.
```

```bash
# BAD — five sessions racing for the same DB lock; they deadlock, and the
# failure looks like a hang rather than an error
for host in "${HOSTS[@]}"; do ssh "$host" 'load-database.sh' & done
```

Backgrounding is for *waiting without blocking*, not for *doing more at once*.
Parallelism is only safe when the jobs are genuinely independent.

## Document the Runtimes

If a project has long runners, record their expected duration where the run
commands are documented (CLAUDE.md / README). "≈14 min" up front stops every
future session from re-discovering it by trial and error — and stops the
instinct to poll.

## Why It Matters

- Chained-sleep polling is blocked by modern agent harnesses outright.
- Each abandoned polling shell is a leaked process; a long session accumulates
  dozens before anyone notices.
- A backgrounded job with a completion notification is observed exactly once, at
  the moment it actually finishes — no wasted turns, no stale reads.
- A job that never finishes never notifies, so it is never cleaned up — the one
  failure mode backgrounding does not fix on its own, and the one that survives
  the session.
