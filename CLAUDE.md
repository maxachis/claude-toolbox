# Claude Toolbox

Personal reference repository of reusable Claude Code components: commands, skills, agents, plugins, rules, configs, and bundles.

## Repository Structure

```
claude-toolbox/
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
