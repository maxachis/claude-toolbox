# Agents Index

Custom subagent definitions for specialized tasks.

## Categories

### [Specialists](specialists/)
Deep expertise agents for specific domains.
- Security reviewer
- Performance analyst
- Database expert

### [Workflows](workflows/)
Multi-step automated process agents.
- PR reviewer
- Test generator
- Documentation builder

## What Are Agents?

Agents are specialized subagents that can be invoked for complex tasks. They have:
- Focused expertise in one area
- Access to specific tools
- Multi-step reasoning capabilities

## Creating Agents

Agent definitions specify:
- Name and description
- Available tools
- Specialized prompts
- Task boundaries

## Example Agent Definition

```yaml
name: security-reviewer
description: Reviews code for security vulnerabilities
tools:
  - read
  - grep
  - glob
prompt: |
  You are a security expert. Review the provided code for:
  - OWASP Top 10 vulnerabilities
  - Language-specific security issues
  - Dependency vulnerabilities

  Report findings by severity with remediation advice.
```

## Usage

Agents are typically invoked through the Task tool or as part of automated workflows.
