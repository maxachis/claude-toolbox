---
description: Help diagnose and fix a bug or issue
argument-hint: "<problem description or error message>"
---

# Debug Issue

Help diagnose and fix a bug or issue.

## Arguments

- `$ARGUMENTS` - Description of the problem or error message

## Instructions

1. Understand the problem from the description/error
2. Reproduce it before theorizing:
   - Find or write the smallest command, test, or input that triggers the failure
   - Record the exact observed output, not a paraphrase of it
   - If you cannot reproduce it, say so plainly and ask for the missing conditions
     (data state, environment, sequence of steps) rather than guessing at a fix
3. Form hypotheses about likely causes
4. Investigate systematically:
   - Search for relevant code
   - Check recent changes (`git log`, `git diff`)
   - Look for similar patterns in the codebase
   - Check logs or error outputs
5. Identify the root cause
6. Write a regression test that fails for the right reason:
   - Assert the correct behavior, and confirm the test fails against the unfixed code
   - A test that passes before the fix is testing the wrong thing
7. Propose a fix with explanation, and confirm the new test passes with it
8. Search for the same mistake elsewhere:
   - Describe the root cause as a pattern (e.g. "unchecked index after a filter",
     "timestamp compared across time zones"), then grep for that shape — not for
     the specific symptom
   - Check the sibling call sites, the other implementations of the same interface,
     and anywhere the buggy code was copied from or to
   - Report each occurrence found. Fix them only if in scope; otherwise list them
     so the user can decide
9. If uncertain, list the top possibilities with how to verify each
