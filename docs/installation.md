# Installation Methods

This guide covers all the ways to install and use components from the Claude Toolbox.

## Commands

### User-Level Installation

Commands in `~/.claude/commands/` are available in all projects:

```bash
# Single command
cp commands/api/api-design.md ~/.claude/commands/

# Multiple commands
cp commands/api/*.md ~/.claude/commands/

# Entire category
cp -r commands/database/* ~/.claude/commands/
```

### Project-Level Installation

Commands in `.claude/commands/` (relative to project root) are available only in that project:

```bash
# In your project root
mkdir -p .claude/commands
cp commands/security/security-audit.md .claude/commands/
```

### Priority

When the same command exists in both locations, the project-level version takes precedence.

## Plugins

Plugins are complete packages that can be installed with the Claude CLI:

```bash
# Install from local path
claude plugin install ./plugins/api-toolkit

# List installed plugins
claude plugin list

# Uninstall a plugin
claude plugin uninstall api-toolkit
```

## Rules (CLAUDE.md)

Rules provide project-specific instructions to Claude:

### Project Root

Create `CLAUDE.md` in your project root:

```bash
cp rules/project-types/python-project.md ./CLAUDE.md
```

### Rules Directory

For multiple rule files, use `.claude/rules/`:

```bash
mkdir -p .claude/rules
cp rules/conventions/commit-messages.md .claude/rules/
cp rules/conventions/code-style.md .claude/rules/
```

## Configuration

### Settings

Copy settings templates to configure Claude Code behavior:

```bash
cp configs/settings/permissive.json ~/.claude/settings.json
```

### Keybindings

Customize keyboard shortcuts:

```bash
cp configs/keybindings/vim-style.json ~/.claude/keybindings.json
```

### MCP Servers

Configure Model Context Protocol servers:

```bash
cp configs/mcp/github.mcp.json ~/.claude/
```

## Bundles

Bundles are curated collections of components for specific workflows:

```bash
# Copy all components from a bundle
cp -r bundles/fullstack-developer/commands/* ~/.claude/commands/
cp bundles/fullstack-developer/CLAUDE.md ./CLAUDE.md
```

## Verification

After installation, verify commands are available:

```bash
# Start Claude Code
claude

# List available commands
/help

# Test a specific command
/commit
```

## Updating

To update components, simply copy the new versions over existing files:

```bash
# Update all commands
cp commands/**/*.md ~/.claude/commands/
```

## Uninstalling

Remove installed components:

```bash
# Remove a command
rm ~/.claude/commands/api-design.md

# Remove all commands
rm -rf ~/.claude/commands/*

# Uninstall a plugin
claude plugin uninstall api-toolkit
```
