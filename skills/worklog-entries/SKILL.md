---
name: worklog-entries
description: How to compose, update, and maintain a worklog entry — entry anatomy, rewriting stale claims in place, marking human-supplied facts, renaming and splitting entries, and promoting one to a tracker task. Load when writing a new entry under a repo's worklog directory, appending to or correcting an existing one, or deciding whether an item belongs in the worklog or the issue tracker.
---

# Writing a Worklog Entry

The global rules say *when* to file and *where*. This is *how* to write the thing.
Voice: "I" and "me" are Max; "you" is the agent writing the entry.

## What an entry contains

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

These sections are the entry's maximum shape, not a checklist. An item with one
obvious approach has no "approaches considered", and a straw man written to fill
the heading is worse than the omission.

## Updating an entry is two motions, not one

New facts append at the bottom; the claims at the top get rewritten *in the same
pass*. Appending alone is the natural motion and it silently rots the entry: an
update arrives as "here is what happened on the 12th", lands at the bottom, and the
paragraph three screens up goes on asserting the opposite in the present tense with
nothing marking it stale. So when the bottom of an entry contradicts the top, **the
top is what's wrong** — go fix that sentence. Do not add a third paragraph
reconciling the first two. This is **Corrections rewrite in place** from the memory
rules, and it binds here for the same reason: a reader who stops halfway down must
not be misinformed.

Record the *shape* of a correction, not just the corrected fact. A line naming how
the mistake was possible — "the root of both errors was reading a code default as
though it were the deployed value" — is the most useful thing an entry can carry,
because it generalizes and the fact doesn't.

## Renaming and splitting

An entry is one item, and two things follow. Both are maintenance you have to do
deliberately because neither happens on its own.

- When investigation moves and the title no longer describes what the entry is
  about, **rename the file to match and fix the inbound links** — a stale slug is how
  the next reader fails to find the entry that already explains their problem.
- When two items are sharing a file because they share a *resource* rather than a
  cause, **split them**; otherwise the resolved half can never be archived without
  burying the open half with it.

## Mark what I told you, not what you found

Your own observations arrive with commands and file references attached —
inherently re-checkable, so their authorship is implied and uninteresting. The
default is "agent-derived and re-derivable," and restating that on every entry is
noise. Label the exception:

- **Constraints and environment facts I supplied** that can't be verified from the
  repo — a deadline, a hand-edited firewall rule, a platform we're not supporting.
  Give these a `> Stated by Max; not verifiable from the repo` line where they
  appear. It tells the next reader not to go hunting for confirmation, and not to
  weigh its own inference as equally authoritative.
- **Decisions I made** — name me, rather than writing them in the same first-person
  voice as your own reasoning.

Attribution is not permanence: something I stated about mutable external state is
still a lead to re-verify, not a fact. And never add an `author:` field or a
human-vs-agent tag to every entry — a label that's the same on 95% of entries
carries no signal and makes provenance look handled while the two cases above go
unmarked anyway.

## Worklog vs. tracker

A tracker item and a worklog entry are not alternatives — the worklog holds things
that will never be done, which the tracker has no good resting place for.

**Promote by link, not by copy.** When an entry graduates to a tracked task, the
task points at the worklog path and the entry records the task id. The tracker owns
status and scheduling; the repo owns evidence and reasoning. Copying the reasoning
into both creates two systems of record, and the interesting half then lives in
whichever one was updated last.

## An entry is a record, not memory

A worklog entry is a durable record — the memory rules' *cache rediscovery, not
state* applies inside it too: record the check and the evidence, and date any claim
about mutable state rather than asserting it flatly.
