# Git Commands

Commands for git workflow automation.

## Commands

| Command | Description |
|---------|-------------|
| `commit` | Generate commit message and commit staged changes |
| `pr` | Create a pull request |
| `review` | Review code for issues and improvements |
| `ship` | Stage, commit, and push in one step |

## Usage

```bash
# Commit staged changes
/commit

# Create a pull request
/pr

# Create PR against specific branch
/pr develop

# Review recent changes
/review

# Review specific file
/review src/auth/login.ts
```

## Installation

```bash
# Install all git commands
cp commands/git/*.md ~/.claude/commands/

# Install a single command
cp commands/git/commit.md ~/.claude/commands/
```

## Workflow

A typical git workflow:

1. Make changes to your code
2. `/review` - Review your changes for issues
3. `/commit` - Commit with a conventional commit message
4. `/pr` - Create a pull request

Or the fast path:

1. Make changes to your code
2. `/ship` - Stage, commit, and push in one command
