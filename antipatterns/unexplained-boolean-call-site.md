---
id: unexplained-boolean-call-site
category: readability
severity: low
tags: [readability, naming, refactoring, clarity]
detect:
  # Mechanical tier: cheap pre-filter for known offending shapes. Not exhaustive.
  grep: 'if\s*\(\s*!?\s*[\w.]+\.(Remove|Add|MoveNext|IsMatch|TryPop|TryTake)\s*\('
  globs: ['**/*.{cs,java,ts,tsx,js,jsx,go,cpp,cc}']
  # Judgment tier: this is the primary detection mode; the grep above only
  # catches a handful of known method-name shapes.
  heuristic: >
    A call returns a bool whose meaning is not conveyed by the callee's name,
    and that value is consumed inline — typically as an if condition — at the
    point where the mutation happens. The reader must already know the API's
    semantics to understand the branch. The tell: you'd need a comment to
    explain what the condition *means*, not what the code *does*. The grep
    pattern only flags a few known offending method names; this heuristic is
    the general case and should be applied broadly, including to methods the
    grep doesn't list.
---
# Unexplained boolean at the call site

**Antipattern:** Consuming a bool return value inline — typically as an `if`
condition — where its meaning is not conveyed by the callee's name. Also
known as a "naked" or "magic" boolean return, a specific case of boolean
blindness. The textbook shape is `if (_cells.Remove(cell))`: `Remove` sounds
like a command, so the fact that its return value means "the key was
actually present" is invisible at the point of use.

**Correct form:** Extract the expression into a local variable whose name
states the semantics the callee's name omits, then branch on the named
local:

```csharp
bool removed = _cells.Remove(cell);   // name carries the meaning
if (!removed)
    return;
```

The variable name is the documentation — it lives in the code, can't drift
out of sync like a comment, and turns the condition into something that
reads as prose. Apply the same move anywhere a call's return type is
"truthier" than its name suggests: `.Remove`, `.Add` on a set,
`.TryGetValue`, `.MoveNext`, a `Regex.IsMatch` buried in a larger expression.

**Why agents fall into it:** The inline form is terser and locally "works."
The model already knows the callee's semantics, so the branch reads fine to
it — but it's writing for a reader who doesn't have that context loaded.

**Impact:** Readability and maintainability. The branch is opaque to anyone
without prior knowledge of the specific API. Low severity because it's
cosmetic and cheaply fixed — but high-frequency.

**False positives:**

- Calls whose name already reads as a question, so the boolean meaning *is*
  the name: `if (list.Contains(x))`, `if (str.StartsWith(...))`,
  `if (dict.ContainsKey(k))`.
- Idiomatic `TryGetValue`/`TryParse`-style patterns, where the `Try` prefix
  already signals "returns whether this succeeded."
