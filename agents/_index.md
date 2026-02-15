# Agents Index

Custom subagent definitions for Claude Code.

## Installation

Copy agents to your Claude config:

```bash
# User-level (available in all projects)
cp agents/*.md ~/.claude/agents/

# Project-level (available only in this project)
mkdir -p .claude/agents
cp agents/*.md .claude/agents/
```

## Available Agents

| Agent | Description |
|-------|-------------|
| `python-init` | Python project initialization and setup |
| `astro-vue-init` | Astro + Vue islands project setup |
| `db-architect` | Relational database schema design |
| `security-reviewer` | Security audits and vulnerability analysis |
| `performance-analyst` | Performance optimization and profiling |
| `pr-reviewer` | Pull request code review |
| `refactorer` | Code restructuring and cleanup |
| `test-generator` | Comprehensive test generation |

## How Agents Work

Agents are **automatically activated** based on:
1. The `description` field matching your task
2. Explicit requests like "use the security-reviewer agent"

## Agent File Format

Agents use YAML frontmatter in Markdown files:

```markdown
---
name: my-agent
description: When Claude should use this agent. Be specific.
tools: Read, Grep, Glob, Bash
model: sonnet
---

System prompt for the agent goes here.

## When Invoked
1. First step
2. Second step
...
```

## Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When to delegate to this agent |
| `tools` | No | Allowed tools (comma-separated) |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `bypassPermissions` |

## Creating Custom Agents

You can also create agents interactively:

```bash
claude
> /agents
```

This opens an interface to create and configure agents with Claude's help.
