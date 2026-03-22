#!/usr/bin/env bash
#
# cmd-status.sh — Health checks and link status
#

cmd_status() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox status

Show link health, settings status, credentials, and component counts.
Exit code 0 if all healthy, 1 if any errors.
EOF
    return 0
  fi

  local claude_dir="${HOME}/.claude"
  local link_dirs=("commands" "skills" "agents" "configs")
  local has_error=0

  echo "Links:"
  for dir in "${link_dirs[@]}"; do
    local dest="${claude_dir}/${dir}"
    local expected="${TOOLBOX_ROOT}/${dir}"

    if [[ ! -e "$dest" && ! -L "$dest" ]]; then
      printf "  ${RED}ERR${NC}  %-12s not linked\n" "${dir}/"
      has_error=1
    elif is_link "$dest"; then
      local target
      target="$(readlink -f "$dest" 2>/dev/null || true)"
      local expected_resolved
      expected_resolved="$(readlink -f "$expected" 2>/dev/null || true)"
      if [[ "$target" == "$expected_resolved" ]]; then
        printf "  ${GREEN} OK${NC}  %-12s → %s\n" "${dir}/" "$target"
      else
        printf "  ${RED}ERR${NC}  %-12s stale link → %s\n" "${dir}/" "$target"
        has_error=1
      fi
    else
      printf "  ${RED}ERR${NC}  %-12s exists but is not a symlink\n" "${dir}/"
      has_error=1
    fi
  done

  # CLAUDE.md check
  local claude_md="${claude_dir}/CLAUDE.md"
  local claude_md_src="${TOOLBOX_ROOT}/configs/CLAUDE.md"
  if is_link "$claude_md" 2>/dev/null; then
    local target
    target="$(readlink -f "$claude_md" 2>/dev/null || true)"
    local expected_resolved
    expected_resolved="$(readlink -f "$claude_md_src" 2>/dev/null || true)"
    if [[ "$target" == "$expected_resolved" ]]; then
      printf "  ${GREEN} OK${NC}  %-12s → %s\n" "CLAUDE.md" "$target"
    else
      printf "  ${RED}ERR${NC}  %-12s stale link\n" "CLAUDE.md"
      has_error=1
    fi
  elif [[ -f "$claude_md" ]]; then
    printf "  ${YELLOW}WARN${NC} %-12s exists but is not a symlink\n" "CLAUDE.md"
  else
    printf "  ${RED}ERR${NC}  %-12s not linked\n" "CLAUDE.md"
    has_error=1
  fi

  echo ""
  echo "Settings:"
  if [[ -f "${claude_dir}/settings.json" ]]; then
    printf "  ${GREEN} OK${NC}  settings.json exists\n"
  else
    printf "  ${RED}ERR${NC}  settings.json not found\n"
    has_error=1
  fi

  echo ""
  echo "Credentials:"
  local cred_items=(
    ".credentials.json:${claude_dir}/.credentials.json"
    ".claude.json:${HOME}/.claude.json"
    ".ssh/:${HOME}/.ssh"
  )
  for item in "${cred_items[@]}"; do
    local label="${item%%:*}"
    local path="${item#*:}"
    if [[ -e "$path" ]]; then
      printf "  ${GREEN} OK${NC}  %s\n" "$label"
    else
      printf "  ${YELLOW}WARN${NC} %s not found\n" "$label"
    fi
  done

  echo ""
  echo "Components:"
  # Count agents (exclude _index.md and README.md)
  local agent_count=0
  if [[ -d "${TOOLBOX_ROOT}/agents" ]]; then
    agent_count=$(find "${TOOLBOX_ROOT}/agents" -maxdepth 1 -name '*.md' ! -name '_index.md' ! -name 'README.md' | wc -l)
  fi

  # Count commands (walk category subdirs)
  local command_count=0
  local category_count=0
  if [[ -d "${TOOLBOX_ROOT}/commands" ]]; then
    for cat_dir in "${TOOLBOX_ROOT}/commands"/*/; do
      [[ -d "$cat_dir" ]] || continue
      category_count=$((category_count + 1))
      local cat_commands
      cat_commands=$(find "$cat_dir" -maxdepth 1 -name '*.md' ! -name 'README.md' ! -name '_index.md' | wc -l)
      command_count=$((command_count + cat_commands))
    done
  fi

  # Count plugins
  local plugin_count=0
  if [[ -d "${TOOLBOX_ROOT}/plugins" ]]; then
    plugin_count=$(find "${TOOLBOX_ROOT}/plugins" -name 'plugin.json' | wc -l)
  fi

  printf "  %d agents, %d commands (%d categories), %d plugins\n" \
    "$agent_count" "$command_count" "$category_count" "$plugin_count"

  return "$has_error"
}
