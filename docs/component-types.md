# Component Types

This guide explains the different types of components in the Claude Toolbox and when to use each.

## Commands

**Location:** `~/.claude/commands/` or `.claude/commands/`
**Invocation:** `/command-name` or `/command-name arguments`

Commands are markdown files that define reusable prompts invoked via slash commands. They're the most common component type.

### Structure

```markdown
# Command Title

Brief description of what the command does.

## Arguments

- `$ARGUMENTS` - Description of expected arguments

## Instructions

Step-by-step instructions for Claude to follow.

## Output

What the command should produce.
```

### Example

```markdown
# Generate Tests

Generate tests for the specified code.

## Arguments

- `$ARGUMENTS` - File path or function name to test

## Instructions

1. Read the specified file or function
2. Identify the testing framework
3. Generate comprehensive tests
```

### When to Use

- Reusable prompts you invoke frequently
- Domain-specific workflows (API design, database migrations)
- Standardized processes (code review, commits)

## Skills

**Location:** `~/.claude/skills/`
**Purpose:** Reusable context and expertise

Skills provide background knowledge and context that Claude can draw upon. Unlike commands (which are explicitly invoked), skills are automatically available as context.

### Structure

Skills are markdown files containing:
- Domain knowledge
- Best practices
- Code patterns
- Framework-specific guidance

### Example

```markdown
# Python Best Practices

## Code Style
- Follow PEP 8
- Use type hints for function signatures
- Prefer f-strings over .format()

## Testing
- Use pytest as the test framework
- Name test files test_*.py
- Use fixtures for common setup
```

### When to Use

- Language-specific knowledge
- Framework conventions
- Team/project standards
- Domain expertise

## Agents

**Location:** Custom definitions
**Purpose:** Specialized task handlers

Agents are specialized subagents that handle specific types of tasks. They can have their own tool access and expertise.

### Types

- **Specialists:** Deep expertise in one area (security reviewer, performance analyst)
- **Workflows:** Multi-step automated processes (PR reviewer, test generator)

### When to Use

- Complex multi-step tasks
- Tasks requiring specialized tools
- Automated workflows

## Plugins

**Location:** Installable packages
**Installation:** `claude plugin install ./path`

Plugins bundle multiple components (commands, rules, configs) into installable packages.

### Structure

```
my-plugin/
├── plugin.json        # Plugin manifest
├── commands/          # Bundled commands
├── rules/             # Bundled rules
└── README.md          # Plugin documentation
```

### When to Use

- Distributing a set of related commands
- Sharing complete workflows with others
- Packaging project-specific tooling

## Rules

**Location:** `CLAUDE.md` or `.claude/rules/`
**Purpose:** Project-specific instructions

Rules tell Claude how to behave in a specific project. They're automatically loaded when Claude Code starts in a directory.

### Structure

```markdown
# Project Rules

## Code Style
- Use 2-space indentation
- Prefer async/await over callbacks

## Architecture
- Follow the repository pattern
- Keep business logic in services/

## Testing
- All PRs require tests
- Use mock for external services
```

### When to Use

- Project conventions
- Architecture guidelines
- Team standards
- Codebase-specific knowledge

## Configs

**Location:** `~/.claude/`
**Purpose:** Claude Code configuration

Configs customize Claude Code's behavior, keybindings, and integrations.

### Types

- **settings.json:** Behavior configuration (permissions, defaults)
- **keybindings.json:** Keyboard shortcuts
- **\*.mcp.json:** MCP server configurations

### When to Use

- Customizing Claude Code behavior
- Setting up integrations
- Personal preferences

## Bundles

**Location:** `bundles/`
**Purpose:** Curated collections

Bundles combine multiple components for specific roles or workflows.

### Example

A "fullstack-developer" bundle might include:
- API commands
- Frontend commands
- Database commands
- Fullstack CLAUDE.md template

### When to Use

- Setting up for a new project type
- Onboarding to a specific role
- Complete workflow packages

## Summary

| Component | Invocation | Scope | Use Case |
|-----------|------------|-------|----------|
| Commands | `/name` | Explicit | Reusable prompts |
| Skills | Automatic | Context | Background knowledge |
| Agents | Task-based | Automatic | Complex workflows |
| Plugins | Install | Package | Bundled functionality |
| Rules | Automatic | Project | Project instructions |
| Configs | Settings | Global | Customization |
| Bundles | Copy | Collection | Role-based setup |
