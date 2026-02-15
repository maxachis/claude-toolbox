# Session Review

Analyze the current conversation to identify inefficiencies and suggest durable improvements.

## Arguments

- `$ARGUMENTS` - (Optional) Focus area: `tools`, `search`, `context`, `approach`, or leave blank for full review

## Instructions

Review the entire conversation history above this invocation point. Analyze it in two passes:

### Pass 1: Identify Inefficiency Patterns

Scan for these specific anti-patterns and flag every instance you find:

**Redundant Operations**
- Reading the same file more than once (without edits in between)
- Running equivalent searches with slightly different terms
- Spawning a subagent for a task that a single Glob/Grep could have resolved
- Re-reading files that were already provided in context (e.g., in CLAUDE.md or a skill)

**Search Thrashing**
- Broad searches that returned too many results, followed by narrower refinements
- Multiple sequential searches to locate a single file, class, or function
- Using `Grep` across the entire codebase when the target directory was knowable
- Searching for something already visible in prior tool output

**Wrong Tool Choice**
- Using `Bash` with `cat`/`grep`/`find` instead of `Read`/`Grep`/`Glob`
- Using `Read` on an entire large file when a targeted `Grep` would suffice
- Spawning heavyweight `Task` agents for simple lookups
- Reading files sequentially when they could have been read in parallel

**Backtracking and Rework**
- Starting an implementation, then abandoning it for a different approach
- Editing code, then reverting or re-editing the same section
- Writing code before reading existing patterns, leading to style mismatches
- Making changes that fail (lint, type errors, tests) and require correction

**Missing Context**
- Asking the user for information that could have been found in the codebase
- Not leveraging project config files (package.json, pyproject.toml, tsconfig, etc.) to infer conventions
- Ignoring or not reading CLAUDE.md, README, or other documentation that would have guided the approach
- Failing to check git history when understanding existing decisions

### Pass 2: Quantify and Prioritize

For each pattern found, estimate:
- **Frequency**: How many times it occurred in this session
- **Waste level**: Low (minor extra read), Medium (several unnecessary steps), High (major rework or wrong direction)
- **Preventability**: Whether better prompting, CLAUDE.md rules, skills, or commands could have avoided it

### Output Format

Structure your analysis as follows:

```
## Session Efficiency Review

### Summary
- Estimated overhead: [X] unnecessary tool calls out of [Y] total
- Primary waste category: [category name]
- Session complexity: [Simple / Moderate / Complex] (to contextualize — some exploration is expected in complex tasks)

### Findings

#### 1. [Pattern Name]
- **Occurrences**: [count] instances
- **Waste level**: [Low / Medium / High]
- **Examples**: [cite specific moments in the conversation]
- **Impact**: [what this cost in terms of extra steps or wrong directions]

[Repeat for each finding, ordered by waste level descending]

### Suggested Improvements

#### CLAUDE.md Additions
[Specific lines to add to CLAUDE.md that would prevent the identified issues. Only suggest these if they represent stable, reusable project knowledge — not one-off fixes.]

#### New Skills or Commands
[If a repeated workflow pattern was identified, describe a skill or command that would streamline it. Include a brief outline of what the skill would contain.]

#### Prompting Tips
[Advice for the user on how to phrase requests to avoid the inefficiencies found. Be specific — reference actual moments from this session.]

### What Went Well
[Briefly note efficient patterns worth repeating — parallel tool calls, good search strategies, effective use of subagents, etc.]
```

## Guidelines

- Be honest but constructive. The goal is improvement, not blame.
- Distinguish between **avoidable waste** (could have been prevented with better approach) and **necessary exploration** (the task genuinely required discovery). Not all multi-step searches are inefficient.
- Focus on patterns, not individual missteps. A single failed search is noise; three in a row is a pattern.
- Keep suggested CLAUDE.md additions concise and specific. Vague rules like "be more efficient" are useless.
- If the session was already efficient, say so. Don't manufacture findings.
