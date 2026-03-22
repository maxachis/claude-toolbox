#!/usr/bin/env bash
#
# cmd-devcontainer.sh — Devcontainer management (init, check, generate)
#

cmd_devcontainer() {
  local subcmd="${1:-}"

  case "$subcmd" in
    ""|-h|--help)
      cat << EOF
Usage: claude-toolbox devcontainer <subcommand>

Subcommands:
  init [options]          Copy template into .devcontainer/, auto-detect language
  check                   Verify mounts and credentials inside a running container
  generate [lang...]      Regenerate .jsonc templates (delegates to generate.sh)

Init options:
  --lang <lang>           Language template (python, node, rust)
  --with <addon>          Apply addon (repeatable). See --list-addons for options.
  --list-addons           List available addons

Supported languages: python, node, rust
EOF
      return 0
      ;;
    init)     shift; devcontainer_init "$@" ;;
    check)    shift; devcontainer_check "$@" ;;
    generate) shift; devcontainer_generate "$@" ;;
    *)
      error "Unknown subcommand: $subcmd"
      return 1
      ;;
  esac
}

devcontainer_generate() {
  local generate_sh="${TOOLBOX_ROOT}/configs/devcontainer/generate.sh"

  if [[ ! -x "$generate_sh" ]]; then
    error "generate.sh not found at ${generate_sh}"
    return 1
  fi

  "$generate_sh" "$@"
}

devcontainer_init() {
  local lang=""
  local -a addons=()
  local list_addons=false

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lang) lang="$2"; shift 2 ;;
      --with) addons+=("$2"); shift 2 ;;
      --list-addons) list_addons=true; shift ;;
      *) error "Unknown option: $1"; return 1 ;;
    esac
  done

  # Handle --list-addons
  if [[ "$list_addons" == true ]]; then
    devcontainer_list_addons
    return $?
  fi

  # Validate addon names before doing anything else
  local addons_dir="${TOOLBOX_ROOT}/configs/devcontainer/src/addons"
  for addon in "${addons[@]}"; do
    if [[ ! -f "${addons_dir}/${addon}.json" ]]; then
      error "Unknown addon: ${addon}. Use --list-addons to see available addons."
      return 1
    fi
  done

  # Auto-detect language if not specified
  if [[ -z "$lang" ]]; then
    lang=$(detect_language)
    if [[ -z "$lang" ]]; then
      error "Could not detect project language. Use --lang <python|node|rust>"
      return 1
    fi
    info "Auto-detected language: ${lang}"
  fi

  local template="${TOOLBOX_ROOT}/configs/devcontainer/${lang}.jsonc"
  if [[ ! -f "$template" ]]; then
    error "No template found for language: ${lang}"
    return 1
  fi

  # Check for existing .devcontainer/
  if [[ -d ".devcontainer" ]]; then
    error ".devcontainer/ already exists. Remove it first or use /devcontainer-init for smart updates."
    return 1
  fi

  # Determine project name from current directory
  local project_name
  project_name="$(basename "$(pwd)")"

  # Create .devcontainer/ and copy template
  mkdir -p .devcontainer

  if [[ ${#addons[@]} -gt 0 ]]; then
    # Use Python to merge addons into the template
    local addon_args=()
    for addon in "${addons[@]}"; do
      addon_args+=("${addons_dir}/${addon}.json")
    done

    devcontainer_apply_addons "$template" "$project_name" \
      .devcontainer/devcontainer.json "${addon_args[@]}"

    info "Created .devcontainer/devcontainer.json from ${lang} template with addons: ${addons[*]}"
  else
    # No addons — use the existing sed path
    sed -e '/^\/\/ AUTO-GENERATED/d' -e "s/\${projectName}/${project_name}/g" \
      "$template" > .devcontainer/devcontainer.json

    info "Created .devcontainer/devcontainer.json from ${lang} template"
  fi

  # Add .devcontainer/.env.secrets to .gitignore if not already there
  if [[ -f .gitignore ]]; then
    if ! grep -q '.devcontainer/.env.secrets' .gitignore 2>/dev/null; then
      echo '.devcontainer/.env.secrets' >> .gitignore
      info "Added .devcontainer/.env.secrets to .gitignore"
    fi
  fi

  # Check credential mount sources
  local mount_issues=0
  if [[ ! -d "${HOME}/.claude" ]]; then
    warn "~/.claude/ not found — container mount will fail"
    mount_issues=1
  fi
  if [[ ! -f "${HOME}/.claude.json" ]]; then
    warn "~/.claude.json not found — container mount will fail"
    mount_issues=1
  fi

  if [[ $mount_issues -eq 0 ]]; then
    info "Credential mount sources verified"
  fi

  echo ""
  info "Done! Review .devcontainer/devcontainer.json and customize as needed."
  info "For intelligent customization, run: /devcontainer-init"
}

devcontainer_list_addons() {
  local addons_dir="${TOOLBOX_ROOT}/configs/devcontainer/src/addons"

  if [[ ! -d "$addons_dir" ]] || ! ls "$addons_dir"/*.json &>/dev/null; then
    info "No addons available."
    return 0
  fi

  echo "Available addons:"
  echo ""
  for f in "$addons_dir"/*.json; do
    local name desc
    name="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['name'])" "$f")"
    desc="$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['description'])" "$f")"
    printf "  %-20s %s\n" "$name" "$desc"
  done
}

devcontainer_apply_addons() {
  local template="$1" project_name="$2" output="$3"
  shift 3
  local addon_files=("$@")

  # Collect existing .mcp.json if present
  local existing_mcp=""
  if [[ -f ".mcp.json" ]]; then
    existing_mcp=".mcp.json"
  fi

  python3 - "$template" "$project_name" "$output" "$existing_mcp" "${addon_files[@]}" << 'PYTHON_SCRIPT'
import json
import re
import sys

def strip_jsonc_comments(text):
    """Remove single-line // comments from JSONC, preserving strings."""
    result = []
    i = 0
    in_string = False
    escape = False
    while i < len(text):
        c = text[i]
        if escape:
            result.append(c)
            escape = False
            i += 1
            continue
        if c == '\\' and in_string:
            result.append(c)
            escape = True
            i += 1
            continue
        if c == '"' and not in_string:
            in_string = True
            result.append(c)
            i += 1
            continue
        if c == '"' and in_string:
            in_string = False
            result.append(c)
            i += 1
            continue
        if c == '/' and not in_string and i + 1 < len(text) and text[i + 1] == '/':
            # Skip to end of line
            while i < len(text) and text[i] != '\n':
                i += 1
            continue
        result.append(c)
        i += 1
    return ''.join(result)

def deep_merge(base, override):
    """Merge override dict into base dict recursively."""
    for key, val in override.items():
        if key in base and isinstance(base[key], dict) and isinstance(val, dict):
            deep_merge(base[key], val)
        else:
            base[key] = val
    return base

template_path = sys.argv[1]
project_name = sys.argv[2]
output_path = sys.argv[3]
existing_mcp_path = sys.argv[4]  # empty string if none
addon_paths = sys.argv[5:]

# Parse template (JSONC)
with open(template_path) as f:
    raw = f.read()
cleaned = strip_jsonc_comments(raw)
cleaned = cleaned.replace('${projectName}', project_name)
config = json.loads(cleaned)

# Collect MCP servers from all addons
all_mcp_servers = {}

for addon_path in addon_paths:
    with open(addon_path) as f:
        addon = json.load(f)

    # Merge postCreateCommand
    if 'postCreateCommand' in addon:
        if 'postCreateCommand' not in config:
            config['postCreateCommand'] = {}
        elif isinstance(config['postCreateCommand'], str):
            config['postCreateCommand'] = {"default": config['postCreateCommand']}
        config['postCreateCommand'].update(addon['postCreateCommand'])

    # Merge features
    if 'features' in addon:
        if 'features' not in config:
            config['features'] = {}
        config['features'].update(addon['features'])

    # Merge containerEnv
    if 'containerEnv' in addon:
        if 'containerEnv' not in config:
            config['containerEnv'] = {}
        config['containerEnv'].update(addon['containerEnv'])

    # Collect mcpServers
    if 'mcpServers' in addon:
        all_mcp_servers.update(addon['mcpServers'])

# Write devcontainer.json
with open(output_path, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

# Write .mcp.json if any addon has mcpServers
if all_mcp_servers:
    mcp_config = {}
    if existing_mcp_path:
        with open(existing_mcp_path) as f:
            mcp_config = json.load(f)

    if 'mcpServers' not in mcp_config:
        mcp_config['mcpServers'] = {}
    mcp_config['mcpServers'].update(all_mcp_servers)

    with open('.mcp.json', 'w') as f:
        json.dump(mcp_config, f, indent=2)
        f.write('\n')
PYTHON_SCRIPT
}

detect_language() {
  if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" || -f "Pipfile" ]]; then
    echo "python"
  elif [[ -f "package.json" ]]; then
    echo "node"
  elif [[ -f "Cargo.toml" ]]; then
    echo "rust"
  fi
}

devcontainer_check() {
  echo "Checking container environment..."
  echo ""

  local has_error=0

  # Check directories and files
  local items=(
    "dir:${HOME}/.claude/:~/.claude/"
    "file:${HOME}/.claude.json:~/.claude.json"
    "dir:${HOME}/.ssh/:~/.ssh/"
    "dir:${HOME}/.config/gh/:~/.config/gh/"
  )

  echo "Mounts:"
  for item in "${items[@]}"; do
    local type="${item%%:*}"
    local rest="${item#*:}"
    local path="${rest%%:*}"
    local label="${rest#*:}"

    if [[ "$type" == "dir" && -d "$path" ]] || [[ "$type" == "file" && -f "$path" ]]; then
      printf "  ${GREEN} OK${NC}  %s\n" "$label"
    else
      printf "  ${RED}ERR${NC}  %s not found\n" "$label"
      has_error=1
    fi
  done

  echo ""
  echo "Tools:"

  # Check claude
  if command -v claude &>/dev/null; then
    local claude_ver
    claude_ver="$(claude --version 2>/dev/null || echo 'unknown')"
    printf "  ${GREEN} OK${NC}  claude %s\n" "$claude_ver"
  else
    printf "  ${RED}ERR${NC}  claude not found\n"
    has_error=1
  fi

  # Check gh
  if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
      printf "  ${GREEN} OK${NC}  gh authenticated\n"
    else
      printf "  ${YELLOW}WARN${NC} gh installed but not authenticated\n"
    fi
  else
    printf "  ${YELLOW}WARN${NC} gh not installed\n"
  fi

  return "$has_error"
}
