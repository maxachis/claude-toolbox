# Workflow Commands

Commands for analyzing and improving Claude Code session efficiency.

## Commands

| Command | Description |
|---------|-------------|
| `devcontainer-init` | Scaffold a `.devcontainer/` setup for the current project |
| `session-review` | Analyze conversation for inefficiencies and suggest improvements |

## Usage

```bash
# Full session review
/session-review

# Focus on tool usage
/session-review tools

# Focus on search patterns
/session-review search

# Focus on missing context
/session-review context

# Focus on approach/backtracking
/session-review approach
```

## Installation

```bash
# Install all workflow commands
cp commands/workflow/*.md ~/.claude/commands/

# Install a single command
cp commands/workflow/session-review.md ~/.claude/commands/
```

## What It Analyzes

- **Redundant operations** - repeated file reads, duplicate searches
- **Search thrashing** - overly broad queries that require narrowing
- **Wrong tool choice** - using Bash when dedicated tools exist
- **Backtracking** - abandoned approaches, rework, failed edits
- **Missing context** - information available but not used

## Output

The review produces:
1. A prioritized list of inefficiency patterns found in the session
2. Concrete CLAUDE.md additions to prevent recurrence
3. Suggestions for new skills or commands if repeated workflows are identified
4. Prompting tips specific to what happened in the session
