# Devcontainer Templates

Reusable `.devcontainer/devcontainer.json` templates for common project types.

## Templates

| Template | Base Image | Extensions |
|----------|-----------|------------|
| `python.jsonc` | `python:3.12` | Python, Pylance, Ruff |
| `node.jsonc` | `typescript-node:22` | ESLint, Prettier, TS |
| `rust.jsonc` | `rust:1` | rust-analyzer, CodeLLDB, crates |

All templates include git and GitHub CLI features.

## Manual Usage

Copy a template into your project:

```bash
mkdir -p .devcontainer
cp configs/devcontainer/python.jsonc .devcontainer/devcontainer.json
```

Then edit to replace `${projectName}` with your project name, adjust `postCreateCommand` for your setup, and add any ports to `forwardPorts`.

## Automated Usage

Use the `/devcontainer-init` command to auto-detect your project type, copy the right template, and customize it:

```bash
/devcontainer-init
/devcontainer-init python
/devcontainer-init node
/devcontainer-init rust
```

## Customization Points

Each template has placeholders and comments marking where to customize:

- **`${projectName}`** — replaced with the project directory name
- **`postCreateCommand`** — adjusted based on which dependency files exist
- **`forwardPorts`** — populated by scanning code for common port patterns
- **Image version** — bump the version tag as needed (e.g., `python:3.13`)
