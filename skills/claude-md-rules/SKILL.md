---
name: claude-md-rules
description: How to write a rule in a CLAUDE.md — what earns a place in an always-loaded file, the anatomy of a rule that survives a long context window, the MUST/SHOULD policy, heading grammar, and voice. Load when adding, editing, or demoting a rule in configs/CLAUDE.md (the global instructions) or a project CLAUDE.md, or when deciding whether guidance belongs there at all.
---

# Writing a Rule in CLAUDE.md

The global instructions are the rules themselves. This is how to write one.
Voice: "I" and "me" are Max; "you" is the agent editing the file.

## First ask whether it belongs here at all

`configs/CLAUDE.md` is read in full on every turn of every session, forever. That is
the entire cost model, and it decides most questions before any style question comes
up. A rule earns its place when it has to be in front of you at the moment you would
otherwise get it wrong — you will not go looking for a rule you don't know exists.

Everything else has a cheaper home:

- **Craft needed only while doing a specific job** — how to compose an entry, how to
  drive a tool — goes in a loadable skill, and the config keeps only what decides
  *whether and when* you do the job. This is the split already made for
  `worklog-entries`, and the reason this file exists.
- **Guidance for editing one file** — including this one — is a skill. Do not park it
  in HTML comments at the top of the config: `<!-- -->` hides text from a markdown
  renderer, not from the model. Commented guidance costs context on every turn and
  is read on almost none.
- **A project-specific convention** goes in that project's `CLAUDE.md`.

## Anatomy of a rule that survives

A directive alone gets followed while it's near the top of the window and quietly
dropped once the session gets long. A rule with a mechanism behind it gets
*reconstructed* — you hit the situation, remember why the failure happens, and act
on it without the sentence in front of you. So a rule that matters carries four
things:

1. **The rule**, in one sentence.
2. **The failure it prevents** — concretely, and preferably the quiet kind. "Two
   layers of quoting will eventually collide, and the failure is usually silent."
   "Swap two same-typed parameters and nothing errors."
3. **The boundary** — what it does *not* cover. Naming the exception is what stops
   a rule from being applied ceremonially to trivial turns, which is how it erodes
   into being ignored on the turns that matter.
4. **A portable test** — a one-line check that reproduces the rule from scratch:
   "if I have no memory of any name in this paragraph, does it still tell me what
   happened?"

This is a maximum shape, not a checklist. "When committing to git, default to ssh
rather than HTTPS" needs none of it — it has no failure worth narrating and no
interesting boundary. Padding a simple rule to fit the shape wastes the budget the
shape exists to protect.

## Priority markers

`MUST` is for rules whose violation is **expensive or hard to undo**. That is the
whole criterion, and its value is scarcity: four MUSTs currently stand in the file,
guarding an unreviewed diff landing, a visual change reported done without anyone
looking, a commit on the wrong branch, and a destroyed branch you didn't create.

- **Before spending one, name what is unrecoverable.** If the worst case is a wasted
  read or a reopened item, it is not a MUST — the bar is recovery cost, not how
  strongly the rule is felt.
- **Prefer "Never" for boundaries that are mine to draw.** "Never resolve an entry on
  your own" binds exactly as hard; the preamble already says unmarked rules are fully
  in force. Marking ownership rules as MUST widens the gate to "I feel strongly about
  this," and then nothing keeps the count at four.
- **`SHOULD` only where a nearby `MUST` gives it meaning.** The one SHOULD in the file
  sits beside its MUST in the same section: delegating is a judgment call, reviewing
  what comes back is not. A SHOULD with no such contrast is just an ordinary rule
  wearing a label.
- **Don't restyle the marker.** Bare capitals mid-sentence; the bold in
  `**You MUST verify…**` belongs to the bullet lead-in convention, not to the marker.

## Headings state the rule

Prefer a heading that carries the rule to one that names the topic — "Complex
Payloads Don't Belong in Shell Strings" over "Shell Quoting," "Bind Arguments by Name
at Call Sites" over "Named Arguments." Scanning the table of contents should be
scanning the rules, and a heading that asserts something is recallable in a way a
noun phrase isn't.

Renaming a heading is cheap but not free: sections cross-reference each other by name
(*per **Lead with Behavior, Not Identifiers** above*). Grep the repo before renaming,
and fix the inbound references in the same commit.

## Mechanics

- **Address me directly.** "I" and "me" are Max, "you" is the agent. A rule written
  about "the user" reads as documentation for someone else and is the clearest sign a
  section predates the current voice.
- **Bold the lead-in of each bullet** in a list of rules, and keep it a clause that
  states the point on its own — the bolded words are what gets read on a skim.
- **Prefer the domain word to the code word**, exactly as the file asks of you
  elsewhere. Rules about tools name the tool; rules about behavior name the behavior.
- **Hard-wrap new prose near 80 columns**, and leave existing sections at whatever
  wrapping they already use. The file is currently split between wrapped and
  single-line paragraphs; rewrapping a section to conform produces a whole-paragraph
  diff that hides the actual edit, which costs more than the inconsistency does.

## Maintenance

- **Corrections rewrite in place.** Never leave a superseded clause standing with a
  qualifier bolted on below it — a reader who stops halfway must not be misinformed.
  Same rule as memory files and worklog entries, same reason.
- **Say the thing once.** When two sections drift toward stating the same boundary,
  hoist it into one section they both reference; that is what the refactoring
  boundary section is for.
- **When a section grows craft, move the craft to a skill** and leave behind the
  trigger — when to load it, and what decides whether you act at all.
- **Demoting a rule is an edit like any other.** A rule that stops earning its place
  is deleted, not annotated as historical.
