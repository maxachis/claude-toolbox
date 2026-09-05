---
name: background-long-tasks
description: Run long CLI work — builds, test suites, simulation or balance runs, data jobs, training — in the background and await completion, rather than sleep-polling or racing parallel invocations that contend for the same lock. Load before launching any command that may run for minutes, or when deciding how to wait on one.
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
