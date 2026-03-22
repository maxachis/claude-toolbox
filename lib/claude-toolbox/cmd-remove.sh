#!/usr/bin/env bash
#
# cmd-remove.sh — Remove agents and commands
#

cmd_remove() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox remove <type> <name> [--force|-f]

Remove a component and update catalog files.

Types:
  agent <name>            Remove an agent
  command <category/name> Remove a command

Options:
  -f, --force    Skip confirmation prompt
EOF
    return 0
  fi

  local type="${1:-}"
  local name="${2:-}"
  shift 2 2>/dev/null || true

  # Parse remaining flags
  local force=0
  for arg in "$@"; do
    case "$arg" in
      -f|--force) force=1 ;;
    esac
  done

  if [[ -z "$type" ]]; then
    error "Missing type. Usage: claude-toolbox remove <agent|command> <name>"
    return 1
  fi

  if [[ -z "$name" ]]; then
    error "Missing name. Usage: claude-toolbox remove $type <name>"
    return 1
  fi

  case "$type" in
    agent)   remove_agent "$name" "$force" ;;
    command) remove_command "$name" "$force" ;;
    *)
      error "Unknown type: $type. Use 'agent' or 'command'."
      return 1
      ;;
  esac
}

remove_agent() {
  local name="$1"
  local force="$2"
  local file="${TOOLBOX_ROOT}/agents/${name}.md"
  local index="${TOOLBOX_ROOT}/agents/_index.md"

  if [[ ! -f "$file" ]]; then
    error "Agent '${name}' not found at ${file}"
    return 1
  fi

  if [[ "$force" -ne 1 ]]; then
    confirm "Remove agent '${name}'?" || return 0
  fi

  rm "$file"
  info "Removed ${file}"

  # Remove row from _index.md
  if [[ -f "$index" ]]; then
    remove_table_row "$index" "$name"
    info "Updated agents/_index.md"
  fi
}

remove_command() {
  local input="$1"
  local force="$2"

  if [[ "$input" != */* ]]; then
    error "Command name must include category: <category/name>"
    return 1
  fi

  local category="${input%%/*}"
  local name="${input#*/}"
  local file="${TOOLBOX_ROOT}/commands/${category}/${name}.md"
  local index="${TOOLBOX_ROOT}/commands/_index.md"
  local cat_readme="${TOOLBOX_ROOT}/commands/${category}/README.md"

  if [[ ! -f "$file" ]]; then
    error "Command '${name}' not found at ${file}"
    return 1
  fi

  if [[ "$force" -ne 1 ]]; then
    confirm "Remove command '${category}/${name}'?" || return 0
  fi

  rm "$file"
  info "Removed ${file}"

  # Remove from commands/_index.md
  if [[ -f "$index" ]]; then
    remove_table_row "$index" "$name"
    info "Updated commands/_index.md"
  fi

  # Remove from category README
  if [[ -f "$cat_readme" ]]; then
    remove_table_row "$cat_readme" "$name"
    info "Updated ${category}/README.md"
  fi
}

