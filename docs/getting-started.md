# Getting Started

This guide helps you quickly install and use components from the Claude Toolbox.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed
- Terminal access

## Quick Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/claude-toolbox.git
cd claude-toolbox
```

### 2. Install Your First Command

Copy a command to your user-level Claude config:

```bash
# Create the commands directory if it doesn't exist
mkdir -p ~/.claude/commands

# Copy a command
cp commands/git/commit.md ~/.claude/commands/
```

### 3. Use the Command

In any project with Claude Code:

```bash
claude
> /commit
```

## Installation Locations

Claude Code looks for commands in two locations:

| Location | Scope | Use Case |
|----------|-------|----------|
| `~/.claude/commands/` | All projects | Personal commands you use everywhere |
| `.claude/commands/` | Current project | Project-specific commands |

Project-level commands override user-level commands with the same name.

## Recommended First Commands

Start with these commonly used commands:

```bash
# Git workflow
cp commands/git/commit.md ~/.claude/commands/
cp commands/git/pr.md ~/.claude/commands/
cp commands/git/review.md ~/.claude/commands/

# Code quality
cp commands/testing/test.md ~/.claude/commands/
cp commands/testing/debug.md ~/.claude/commands/

# Documentation
cp commands/documentation/explain.md ~/.claude/commands/
```

## Installing a Plugin

Plugins bundle related commands together:

```bash
claude plugin install ./plugins/api-toolkit
```

## Setting Up Project Rules

Copy a CLAUDE.md template to your project root:

```bash
# For a Python project
cp rules/project-types/python-project.md ./CLAUDE.md

# Edit to customize for your project
```

## Next Steps

- Browse [commands/_index.md](../commands/_index.md) to see all available commands
- Read [component-types.md](component-types.md) to understand different component types
- Check [installation.md](installation.md) for advanced installation options
