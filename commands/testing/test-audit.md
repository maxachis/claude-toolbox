---
description: Audit existing tests for coverage gaps and missing edge cases
argument-hint: "<file, module, or test file to audit>"
---

# Audit Tests

Audit the existing tests for a target and report what's **missing** — untested
cases, weak assertions, and gaps that should be covered. This command reports
findings; it does not write tests. Once gaps are confirmed, hand off to `/test`
to fill them.

## Arguments

- `$ARGUMENTS` - File path, module, or function whose tests should be audited.
  If a source file is given, locate its corresponding test file; if a test file
  is given, locate the code under test.

## Instructions

1. Read both the code under test and its existing tests. If either can't be
   found, say so and stop — there's nothing to audit against.
2. Identify the testing framework and the assertion/mocking style already in use.
3. Build the list of behaviors the code *can* exhibit by reading the code, not
   just the tests — branches, loops, early returns, thrown errors, and the
   contract implied by each public function.
4. Compare existing tests against that list and the checklist below. For each
   gap, record: the uncovered case, why it matters, and a one-line sketch of the
   test that would cover it.
5. Also flag tests that exist but are **weak**: assert nothing meaningful, only
   check that no error was thrown, over-mock the code under test, or duplicate
   another test without adding coverage.
6. Do **not** write tests. End by offering to run `/test <target>` to generate
   the missing ones, or to focus on a specific gap.

## Coverage checklist

Use as a prompt-list, not a quota — skip categories that don't apply to the target.

- **Boundaries** — zero, one, many; min/max; off-by-one limits; first/last element.
- **Empty & absent** — empty string/list/map; null/None/undefined; missing optional args.
- **Invalid input** — wrong type, malformed data, out-of-range, violated preconditions.
- **Error paths** — every `throw`/`raise`/error return; does the test assert the *specific* failure, not just "it failed"?
- **State & ordering** — operations out of expected order; idempotency; repeated calls; stale state.
- **Concurrency** — shared mutable state, races, re-entrancy (only if the code is actually concurrent).
- **Side effects** — does the test verify writes/calls/emissions happened (and didn't, when they shouldn't)?
- **Domain-specific cases** — derived from *this* code: the tricky inputs a maintainer would worry about (e.g. timezones for dates, encoding for text, precision for money).

## Output format

Group findings by severity. For each: the uncovered case, why it matters, and a
one-line test sketch.

```
## Test Audit: <target>

Framework: <detected> | Existing tests: <count> covering <brief>

### Gaps — High
- [<category>] <uncovered case>. Why: <impact>. Test: <one-line sketch>.

### Gaps — Medium / Low
- ...

### Weak tests
- <test name> — <what's wrong> (<file:line>).

### Summary
<one line> — N high, M medium/low gaps. Run `/test <target>` to fill them?
```
