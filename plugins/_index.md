# Plugins Index

Complete installable plugins bundling related commands and configurations.

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [api-toolkit](api-toolkit/) | Complete API development toolkit |
| [python-toolkit](python-toolkit/) | Python development essentials |
| [web-development](web-development/) | Frontend and fullstack tools |

## What Are Plugins?

Plugins bundle multiple components into installable packages:
- Commands
- Rules
- Configurations
- Documentation

## Installation

```bash
# Install a plugin
claude plugin install ./plugins/api-toolkit

# List installed plugins
claude plugin list

# Uninstall a plugin
claude plugin uninstall api-toolkit
```

## Plugin Structure

```
my-plugin/
├── plugin.json        # Plugin manifest
├── commands/          # Bundled commands
├── rules/             # Bundled rules
└── README.md          # Documentation
```

## Creating Plugins

### plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My custom plugin",
  "commands": [
    "commands/my-command.md"
  ],
  "rules": [
    "rules/my-rules.md"
  ]
}
```

See individual plugin directories for complete examples.
