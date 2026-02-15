# Claude Toolbox

A personal reference repository of reusable Claude Code components: commands, skills, agents, plugins, and configs organized for easy discovery and installation.

## Quick Start

```bash
# Copy a single command
cp commands/api/api-design.md ~/.claude/commands/

# Copy an entire category
cp -r commands/git/* ~/.claude/commands/

# Install a complete plugin
claude plugin install ./plugins/api-toolkit
```

## Repository Structure

```
claude-toolbox/
├── commands/          # Slash commands organized by domain
├── skills/            # Reusable prompts and context
├── agents/            # Custom subagent definitions
├── plugins/           # Complete installable plugins
├── rules/             # CLAUDE.md templates and snippets
├── configs/           # Configuration templates
├── bundles/           # Curated component collections
└── docs/              # Documentation
```

## Commands by Category

| Category | Commands | Description |
|----------|----------|-------------|
| [api/](commands/api/) | `api-design`, `api-docs`, `api-endpoint`, `api-test` | API design and development |
| [database/](commands/database/) | `db-architect`, `db-migrate`, `query` | Database schema and queries |
| [frontend/](commands/frontend/) | `component`, `style`, `a11y` | UI components and styling |
| [git/](commands/git/) | `commit`, `pr`, `review` | Git workflow automation |
| [security/](commands/security/) | `security-audit`, `auth` | Security auditing and auth |
| [testing/](commands/testing/) | `test`, `debug` | Testing and debugging |
| [documentation/](commands/documentation/) | `doc`, `explain` | Code documentation |
| [refactoring/](commands/refactoring/) | `refactor` | Code refactoring |
| [workflow/](commands/workflow/) | `session-review` | Session efficiency analysis |

## Installation Methods

### Individual Commands

Copy specific commands to your Claude config:

```bash
# User-level (available in all projects)
cp commands/api/api-design.md ~/.claude/commands/

# Project-level (available only in this project)
cp commands/api/api-design.md .claude/commands/
```

### Complete Plugins

Install plugins that bundle related commands:

```bash
claude plugin install ./plugins/api-toolkit
```

### Project Rules

Copy CLAUDE.md templates to your project:

```bash
cp rules/project-types/python-project.md ./CLAUDE.md
```

## Component Types

| Type | Location | Purpose |
|------|----------|---------|
| **Commands** | `~/.claude/commands/` or `.claude/commands/` | Slash commands invoked with `/command-name` |
| **Skills** | `~/.claude/skills/` | Reusable context and prompts |
| **Agents** | Custom subagent definitions | Specialized task handlers |
| **Plugins** | Installable via `claude plugin install` | Bundled functionality |
| **Rules** | `CLAUDE.md` or `.claude/rules/` | Project-specific instructions |
| **Configs** | `~/.claude/settings.json` | Claude Code configuration |

See [docs/component-types.md](docs/component-types.md) for detailed explanations.

## Documentation

- [Getting Started](docs/getting-started.md) - Quick start guide
- [Installation Methods](docs/installation.md) - Detailed installation options
- [Component Types](docs/component-types.md) - Commands vs skills vs agents

## Directory Index

- [commands/_index.md](commands/_index.md) - All commands catalog
- [skills/_index.md](skills/_index.md) - Skills catalog
- [agents/_index.md](agents/_index.md) - Agents catalog
- [plugins/_index.md](plugins/_index.md) - Plugins catalog
- [rules/_index.md](rules/_index.md) - Rules catalog
- [configs/_index.md](configs/_index.md) - Configs catalog
