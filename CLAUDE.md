# Claude Toolbox

Personal reference repository of reusable Claude Code components: commands, skills, agents, plugins, rules, configs, and bundles.

## Repository Structure

```
claude-toolbox/
├── bin/            # CLI entrypoint (claude-toolbox)
├── lib/            # CLI command modules (cmd-*.sh, common.sh)
├── tests/          # bats-core tests
├── commands/       # Slash commands organized by domain (api, git, testing, etc.)
├── skills/         # Background context: languages, frameworks, practices
├── agents/         # Custom subagent definitions (YAML frontmatter + markdown)
├── plugins/        # Installable bundles with plugin.json manifests
├── rules/          # CLAUDE.md templates (project-types/) and convention snippets (conventions/)
├── configs/        # Settings, keybindings, and MCP server templates
├── bundles/        # Curated role-based component collections
└── docs/           # Project documentation
```

## File Conventions

- All content files are Markdown (`.md`), except plugin manifests (`plugin.json`) and config templates (`.json`)
- Filenames: lowercase with hyphens (`api-design.md`, `python-init.md`)
- Every top-level directory has an `_index.md` catalog file
- Category subdirectories have a `README.md` with category-specific guidance

## Component Formats

**Commands** follow this structure:
```
# Title
Brief description.
## Arguments
## Instructions
## Output format
```

**Agents** use YAML frontmatter with fields: `name`, `description`, `tools`, `model`, `permissionMode`, followed by a system prompt and `## When Invoked` section.

**Plugins** have a `plugin.json` manifest (`name`, `version`, `description`, `commands`, `rules`, `dependencies`) alongside their bundled commands.

**Rules** are organized as project-type templates or standalone convention snippets with concise bullet-point guidelines.

## Editing Guidelines

- Preserve existing format conventions when editing or adding components
- Keep commands actionable with numbered step-by-step instructions
- Keep rules and skills concise — bullet points over paragraphs
- Update the relevant `_index.md` or `README.md` when adding or removing components
- Cross-reference related components where appropriate

## CLI

The `claude-toolbox` CLI (`bin/claude-toolbox`) provides a unified interface for all toolbox operations. `setup.sh` symlinks it to `~/.local/bin/claude-toolbox`.

| Command | Description |
|---------|-------------|
| `claude-toolbox install [--skip-validation]` | Link toolbox into `~/.claude/` (delegates to `setup.sh`) |
| `claude-toolbox uninstall` | Remove links and restore backups |
| `claude-toolbox status` | Show link health, settings, credentials, component counts |
| `claude-toolbox validate` | Validate agent frontmatter (delegates to `validate.sh`) |
| `claude-toolbox list [type]` | List components (agents, commands, plugins, skills) |
| `claude-toolbox add agent <name>` | Scaffold agent .md, update `_index.md` |
| `claude-toolbox add command <cat/name>` | Scaffold command .md, update catalogs |
| `claude-toolbox remove agent <name>` | Remove agent, update `_index.md` |
| `claude-toolbox remove command <cat/name>` | Remove command, update catalogs |
| `claude-toolbox apply rule <name>` | Copy project-type template → `./CLAUDE.md` |
| `claude-toolbox apply convention <name>` | Copy convention snippet → `.claude/rules/` |
| `claude-toolbox apply bundle <name>` | Copy bundle CLAUDE.md + commands into project |
| `claude-toolbox apply --list [type]` | List available rules/conventions/bundles |
| `claude-toolbox capture rule <name>` | Save `./CLAUDE.md` as project-type template |
| `claude-toolbox capture convention <name>` | Save `.claude/rules/` file as reusable convention |
| `claude-toolbox capture command <cat/name>` | Copy `.claude/commands/` file into toolbox |
| `claude-toolbox capture skill <cat/name>` | Copy `.claude/skills/` file into toolbox |
| `claude-toolbox devcontainer init [--lang X] [--with addon]` | Copy template into `.devcontainer/`, optionally apply addons |
| `claude-toolbox devcontainer check` | Verify mounts/credentials inside a container |
| `claude-toolbox devcontainer generate [lang...]` | Regenerate `.jsonc` templates |

Architecture: `bin/claude-toolbox` dispatches to command modules in `lib/claude-toolbox/`. Tests use bats-core in `tests/`.

## Shell Scripts

- **`setup.sh`** — Links the toolbox (`commands/`, `skills/`, `agents/`, `CLAUDE.md`) into `~/.claude/`, merges `configs/settings/global.json` into `~/.claude/settings.json`, and symlinks the CLI to `~/.local/bin/`. Runs `validate.sh` first. Flags: `--unlink` (remove links, restore backups), `--skip-validation` (bypass agent validation). On WSL, also runs `configs/devcontainer/wsl-setup.sh`.
- **`validate.sh`** — Validates agent frontmatter in `agents/`. Checks required fields (`name`, `description`), name format, tool/model/permissionMode values, and name-filename consistency. Requires Python. Accepts an optional directory argument (defaults to `agents/`).

## Testing

Tests use [bats-core](https://github.com/bats-core/bats-core) (git submodule in `tests/bats/`):

```bash
./tests/bats/bin/bats tests/          # Run all tests
./tests/bats/bin/bats tests/cli.bats  # Run specific test file
```

## Generated Files

- **Devcontainer templates** (`configs/devcontainer/*.jsonc`) are auto-generated. Do not edit them directly — edit `configs/devcontainer/src/` and run `./configs/devcontainer/generate.sh` to regenerate.
