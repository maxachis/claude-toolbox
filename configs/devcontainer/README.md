# Devcontainer Templates

Reusable `.devcontainer/devcontainer.json` templates for common project types.

## Templates

| Template | Base Image | Extensions |
|----------|-----------|------------|
| `python.jsonc` | `python:3.12` | Python, Pylance, Ruff |
| `node.jsonc` | `typescript-node:22` | ESLint, Prettier, TS |
| `rust.jsonc` | `rust:1` | rust-analyzer, CodeLLDB, crates |

All templates include git, GitHub CLI, Claude Code, and openspec. Host `~/.ssh/`, `~/.claude/`, and `~/.claude.json` are bind-mounted for SSH and Claude Code authentication.

## Generator

The `.jsonc` templates are **auto-generated** from source files in `src/`. Do not edit the `.jsonc` files directly — edit the source files and regenerate.

### Source files

| File | Purpose |
|------|---------|
| `src/base.json` | Shared config: features, mounts, CLI tools, forwardPorts |
| `src/python.json` | Python-specific: image, extensions, settings, deps |
| `src/node.json` | Node-specific: image, extensions, settings, deps |
| `src/rust.json` | Rust-specific: image, extensions, settings, deps |

### Running the generator

```bash
# Generate all templates
./configs/devcontainer/generate.sh

# Generate a specific template
./configs/devcontainer/generate.sh python

# Generate multiple specific templates
./configs/devcontainer/generate.sh node rust
```

### What it does

1. Loads `src/base.json` and the language override (`src/{lang}.json`)
2. Merges features, postCreateCommand, and mounts
3. Converts mount templates to devcontainer mount strings (with correct `remoteUser` paths)
4. Injects JSONC comments from the override's `comments` field
5. Validates output by stripping comments and re-parsing as JSON
6. Writes the `.jsonc` file with an auto-generated header

### Adding shared config

To add a new mount, feature, or CLI tool to **all** templates, edit `src/base.json` and regenerate. To add something to a **single** template, edit the corresponding `src/{lang}.json`.

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

## WSL Users

The templates use `${localEnv:HOME}${localEnv:USERPROFILE}` for mount source paths — a standard cross-platform devcontainer pattern where one variable is always empty:

- **Windows (native VS Code):** `USERPROFILE=C:\Users\you`, `HOME` is empty — resolves correctly
- **macOS / Linux:** `HOME=/home/you`, `USERPROFILE` is empty — resolves correctly
- **WSL:** `HOME=/home/you`, `USERPROFILE` is empty — resolves to the **WSL home**, not the Windows home

On WSL, your Claude credentials and SSH keys typically live under your **Windows** home (e.g., `/mnt/c/Users/you/`), not your WSL home (`/home/you/`). The mounts will point to the wrong location.

### Fix: create symlinks

If you ran `./setup.sh`, this is handled automatically — it detects WSL and runs the symlink setup for you.

You can also run it standalone:

```bash
./configs/devcontainer/wsl-setup.sh
```

Or create the symlinks manually:

```bash
ln -s /mnt/c/Users/you/.claude ~/.claude
ln -s /mnt/c/Users/you/.claude.json ~/.claude.json
ln -s /mnt/c/Users/you/.ssh ~/.ssh
```

After this, the `${localEnv:HOME}` resolution will find the correct files via the symlinks.

## Customization Points

Each template has placeholders and comments marking where to customize:

- **`${projectName}`** — replaced with the project directory name
- **`postCreateCommand`** — adjusted based on which dependency files exist
- **`forwardPorts`** — populated by scanning code for common port patterns
- **Image version** — bump the version tag as needed (e.g., `python:3.13`)
