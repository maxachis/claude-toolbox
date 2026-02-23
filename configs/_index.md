# Configs Index

Configuration templates for Claude Code settings, keybindings, and MCP servers.

## Categories

### [Settings](settings/)
Configuration for Claude Code behavior.
- Permissive mode (fewer prompts)
- Strict mode (more confirmations)

### [Keybindings](keybindings/)
Custom keyboard shortcuts.
- Vim-style bindings
- VS Code-style bindings

### [MCP](mcp/)
Model Context Protocol server configurations.
- GitHub integration
- Database connections

### [Devcontainer](devcontainer/)
`.devcontainer/devcontainer.json` templates for common project types.
- Python (Ruff, Pylance)
- Node/TypeScript (ESLint, Prettier)
- Rust (rust-analyzer, CodeLLDB)

## Installation

### Settings

Copy to your Claude config directory:

```bash
cp configs/settings/permissive.json ~/.claude/settings.json
```

### Keybindings

```bash
cp configs/keybindings/vim-style.json ~/.claude/keybindings.json
```

### MCP Servers

```bash
cp configs/mcp/github.mcp.json ~/.claude/
```

## Configuration Files

| File | Purpose |
|------|---------|
| `settings.json` | Claude Code behavior and permissions |
| `keybindings.json` | Keyboard shortcuts |
| `*.mcp.json` | MCP server configurations |

## Customizing

These templates are starting points. Customize them based on:
- Your workflow preferences
- Security requirements
- Project needs
