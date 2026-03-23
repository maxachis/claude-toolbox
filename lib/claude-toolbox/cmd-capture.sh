#!/usr/bin/env bash
#
# cmd-capture.sh — Push patterns from a project back to the toolbox
#

cmd_capture() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << 'EOF'
Usage: claude-toolbox capture <type> <name> [--force|-f] [--from <path>]

Capture project patterns into the toolbox for reuse.

Types:
  rule <name>             Save ./CLAUDE.md as a project-type template
  convention <name>       Save .claude/rules/<name>.md as a reusable convention
  command <category/name> Copy .claude/commands/<cat>/<name>.md into toolbox
  skill <category/name>   Copy .claude/skills/<cat>/<name>.md into toolbox
  pattern <name>          Copy .claude/patterns/<name>.md into toolbox

Options:
  -f, --force        Skip overwrite confirmations
  --from <path>      Use explicit source path instead of default location
EOF
    return 0
  fi

  local type="${1:-}"
  local name="${2:-}"
  shift 2 2>/dev/null || true

  # Parse remaining flags
  local force=0
  local from_path=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f|--force) force=1 ;;
      --from) shift; from_path="${1:-}" ;;
    esac
    shift
  done

  if [[ -z "$type" ]]; then
    error "Missing type. Usage: claude-toolbox capture <rule|convention|command|skill|pattern> <name>"
    return 1
  fi

  if [[ -z "$name" ]]; then
    error "Missing name. Usage: claude-toolbox capture $type <name>"
    return 1
  fi

  case "$type" in
    rule)       capture_rule "$name" "$force" "$from_path" ;;
    convention) capture_convention "$name" "$force" "$from_path" ;;
    command)    capture_command "$name" "$force" "$from_path" ;;
    skill)      capture_skill "$name" "$force" "$from_path" ;;
    pattern)    capture_pattern "$name" "$force" "$from_path" ;;
    *)
      error "Unknown type: $type. Use 'rule', 'convention', 'command', 'skill', or 'pattern'."
      return 1
      ;;
  esac
}

capture_rule() {
  local name="$1"
  local force="$2"
  local from_path="$3"
  local source="${from_path:-./CLAUDE.md}"
  local target="${TOOLBOX_ROOT}/rules/project-types/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "No CLAUDE.md found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "Rule '${name}' already exists at ${target}. Use --force to overwrite."
    return 1
  fi

  mkdir -p "${TOOLBOX_ROOT}/rules/project-types"
  cp "$source" "$target"
  info "Captured rule '${name}' from ${source}"

  # Update rules/_index.md
  local index="${TOOLBOX_ROOT}/rules/_index.md"
  if [[ -f "$index" ]]; then
    local row="| \`${name}\` | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
  fi
}

capture_convention() {
  local name="$1"
  local force="$2"
  local from_path="$3"
  local source="${from_path:-.claude/rules/${name}.md}"
  local target="${TOOLBOX_ROOT}/rules/conventions/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Convention source not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "Convention '${name}' already exists at ${target}. Use --force to overwrite."
    return 1
  fi

  mkdir -p "${TOOLBOX_ROOT}/rules/conventions"
  cp "$source" "$target"
  info "Captured convention '${name}'"

  # Update rules/_index.md
  local index="${TOOLBOX_ROOT}/rules/_index.md"
  if [[ -f "$index" ]]; then
    local row="| \`${name}\` | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
  fi
}

capture_command() {
  local input="$1"
  local force="$2"
  local from_path="$3"

  if [[ "$input" != */* ]]; then
    error "Command name must include category: <category/name> (e.g., api/new-endpoint)"
    return 1
  fi

  local category="${input%%/*}"
  local name="${input#*/}"
  local source="${from_path:-.claude/commands/${category}/${name}.md}"
  local target="${TOOLBOX_ROOT}/commands/${category}/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Command source not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "Command '${category}/${name}' already exists at ${target}. Use --force to overwrite."
    return 1
  fi

  local cat_dir="${TOOLBOX_ROOT}/commands/${category}"
  local cat_readme="${cat_dir}/README.md"

  # Create category directory if new
  if [[ ! -d "$cat_dir" ]]; then
    mkdir -p "$cat_dir"
    cat > "$cat_readme" << EOF
# ${category^} Commands

Commands for ${category}.

## Commands

| Command | Description |
|---------|-------------|
EOF
    info "Created new category: ${category}/"
  fi

  cp "$source" "$target"
  info "Captured command '${category}/${name}'"

  # Update commands/_index.md
  local index="${TOOLBOX_ROOT}/commands/_index.md"
  if [[ -f "$index" ]]; then
    local row="| \`/${name}\` | [${category}](${category}/) | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
  fi

  # Update category README
  if [[ -f "$cat_readme" ]]; then
    local cat_row="| \`${name}\` | TODO — add description |"
    insert_table_row "$cat_readme" "$cat_row" "$name"
  fi
}

capture_skill() {
  local input="$1"
  local force="$2"
  local from_path="$3"

  if [[ "$input" != */* ]]; then
    error "Skill name must include category: <category/name> (e.g., languages/go)"
    return 1
  fi

  local category="${input%%/*}"
  local name="${input#*/}"
  local source="${from_path:-.claude/skills/${category}/${name}.md}"
  local target="${TOOLBOX_ROOT}/skills/${category}/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Skill source not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "Skill '${category}/${name}' already exists at ${target}. Use --force to overwrite."
    return 1
  fi

  mkdir -p "${TOOLBOX_ROOT}/skills/${category}"
  cp "$source" "$target"
  info "Captured skill '${category}/${name}'"

  # Update skills/_index.md
  local index="${TOOLBOX_ROOT}/skills/_index.md"
  if [[ -f "$index" ]]; then
    local row="| \`${name}\` | ${category} | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
  fi
}

capture_pattern() {
  local name="$1"
  local force="$2"
  local from_path="$3"
  local source="${from_path:-.claude/patterns/${name}.md}"
  local target="${TOOLBOX_ROOT}/patterns/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Pattern source not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "Pattern '${name}' already exists at ${target}. Use --force to overwrite."
    return 1
  fi

  mkdir -p "${TOOLBOX_ROOT}/patterns"
  cp "$source" "$target"
  info "Captured pattern '${name}'"

  # Update patterns/_index.md
  local index="${TOOLBOX_ROOT}/patterns/_index.md"
  if [[ -f "$index" ]]; then
    local row="| \`${name}\` | TODO | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
  fi
}
