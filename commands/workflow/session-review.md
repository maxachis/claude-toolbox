# Session Review

Analyze the current conversation to identify inefficiencies and suggest durable improvements.

## Arguments

- `$ARGUMENTS` - (Optional) Focus area: `tools`, `search`, `context`, `approach`, `workflow`, or leave blank for full review

## Instructions

Review the entire conversation history above this invocation point. Analyze it in three passes:

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

### Pass 2: User Workflow Patterns

Scan the user's side of the conversation for recurring patterns that suggest automation opportunities:

**Repetitive Multi-Step Requests**
- Sequences of instructions the user gave repeatedly that could be a single slash command (e.g., "commit and push" → `/ship`)
- Manual orchestration of steps that always go together (e.g., "run tests, fix lint, then commit")

**Clarification Overhead**
- Prompts that required back-and-forth to clarify intent, where a CLAUDE.md rule or convention could have made the intent obvious
- Ambiguous requests that led to wrong-direction work before correction

**Automation Candidates**
- Tasks the user performed manually that could be scripted (setup steps, environment checks, repeated file operations)
- Workflows that followed a consistent shape across multiple sessions, suggesting a reusable command or agent

**Missing Tooling**
- Moments where the user described a workflow that an existing skill or command could have handled, but neither knew about it
- Gaps in the current command/skill set revealed by what the user actually needed

### Pass 3: Quantify and Prioritize

For each pattern found in Pass 1 and Pass 2, estimate:
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

### Workflow Findings

#### 1. [Pattern Name]
- **Occurrences**: [count] instances
- **Time saved if automated**: [Low / Medium / High]
- **Examples**: [cite specific user prompts or sequences]
- **Suggested solution**: [slash command, CLAUDE.md rule, script, or skill]

[Repeat for each finding]

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
