#!/usr/bin/env bash
#
# cmd-list.sh — List components with descriptions
#

cmd_list() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox list [type]

List components with descriptions.

Types:
  agents      Show agents with descriptions from frontmatter
  commands    Show commands grouped by category
  plugins     Show plugins with descriptions from plugin.json
  skills      Show skills organized by subdirectory
  patterns    Show patterns with descriptions from frontmatter

Options (patterns only):
  --tag <tag>   Filter patterns by tag

If no type is given, shows all.
EOF
    return 0
  fi

  local type="${1:-all}"
  shift 2>/dev/null || true

  case "$type" in
    agents)   list_agents ;;
    commands) list_commands ;;
    plugins)  list_plugins ;;
    skills)   list_skills ;;
    patterns) list_patterns "$@" ;;
    all)
      list_agents
      echo ""
      list_commands
      echo ""
      list_plugins
      echo ""
      list_skills
      echo ""
      list_patterns
      ;;
    *)
      error "Unknown component type: $type"
      echo "Valid types: agents, commands, plugins, skills, patterns"
      return 1
      ;;
  esac
}

list_agents() {
  local dir="${TOOLBOX_ROOT}/agents"
  echo "${BOLD}Agents:${NC}"

  if [[ ! -d "$dir" ]]; then
    echo "  (none)"
    return
  fi

  local found=0
  for file in "$dir"/*.md; do
    [[ -f "$file" ]] || continue
    local name
    name="$(basename "$file" .md)"
    [[ "$name" == "_index" || "$name" == "README" ]] && continue

    # Parse description from frontmatter
    local desc=""
    desc=$(awk '
      /^---$/ { if (++c == 2) exit }
      c == 1 && /^description:/ { sub(/^description:[[:space:]]*/, ""); print }
    ' "$file")

    printf "  %-24s %s\n" "$name" "$desc"
    found=1
  done

  if [[ $found -eq 0 ]]; then echo "  (none)"; fi
}

list_commands() {
  local dir="${TOOLBOX_ROOT}/commands"
  echo "${BOLD}Commands:${NC}"

  if [[ ! -d "$dir" ]]; then
    echo "  (none)"
    return
  fi

  local found=0
  for cat_dir in "$dir"/*/; do
    [[ -d "$cat_dir" ]] || continue
    local category
    category="$(basename "$cat_dir")"
    echo "  ${category}/"

    for file in "$cat_dir"/*.md; do
      [[ -f "$file" ]] || continue
      local name
      name="$(basename "$file" .md)"
      [[ "$name" == "README" || "$name" == "_index" ]] && continue

      # Extract description: first non-heading, non-empty line
      local desc=""
      desc=$(awk '
        NR == 1 && /^#/ { next }
        /^$/ { next }
        /^#/ { next }
        { print; exit }
      ' "$file")

      printf "    %-22s %s\n" "$name" "$desc"
      found=1
    done
  done

  if [[ $found -eq 0 ]]; then echo "  (none)"; fi
}

list_plugins() {
  local dir="${TOOLBOX_ROOT}/plugins"
  echo "${BOLD}Plugins:${NC}"

  if [[ ! -d "$dir" ]]; then
    echo "  (none)"
    return
  fi

  local found=0
  for manifest in "$dir"/*/plugin.json; do
    [[ -f "$manifest" ]] || continue

    # Parse name and description with awk (avoid Python dependency)
    local name desc
    name=$(awk -F'"' '/"name"/ { print $4 }' "$manifest")
    desc=$(awk -F'"' '/"description"/ { print $4 }' "$manifest")

    printf "  %-24s %s\n" "$name" "$desc"
    found=1
  done

  if [[ $found -eq 0 ]]; then echo "  (none)"; fi
}

list_skills() {
  local dir="${TOOLBOX_ROOT}/skills"
  echo "${BOLD}Skills:${NC}"

  if [[ ! -d "$dir" ]]; then
    echo "  (none)"
    return
  fi

  local found=0
  for sub_dir in "$dir"/*/; do
    [[ -d "$sub_dir" ]] || continue
    local category
    category="$(basename "$sub_dir")"
    echo "  ${category}/"

    for file in "$sub_dir"/*.md; do
      [[ -f "$file" ]] || continue
      local name
      name="$(basename "$file" .md)"
      [[ "$name" == "README" || "$name" == "_index" ]] && continue

      # Extract first heading as description
      local desc=""
      desc=$(awk '/^#/ { sub(/^#+[[:space:]]*/, ""); print; exit }' "$file")

      printf "    %-22s %s\n" "$name" "$desc"
      found=1
    done
  done

  if [[ $found -eq 0 ]]; then echo "  (none)"; fi
}

list_patterns() {
  local dir="${TOOLBOX_ROOT}/patterns"
  local tag_filter=""

  # Parse --tag flag
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --tag) shift; tag_filter="${1:-}" ;;
    esac
    shift
  done

  echo "${BOLD}Patterns:${NC}"

  if [[ ! -d "$dir" ]]; then
    echo "  (none)"
    return
  fi

  local found=0
  for file in "$dir"/*.md; do
    [[ -f "$file" ]] || continue
    local name
    name="$(basename "$file" .md)"
    [[ "$name" == "_index" || "$name" == "README" ]] && continue

    # Parse description and tags from frontmatter
    local desc="" tags=""
    desc=$(awk '
      /^---$/ { if (++c == 2) exit }
      c == 1 && /^description:/ { sub(/^description:[[:space:]]*/, ""); print }
    ' "$file")
    tags=$(awk '
      /^---$/ { if (++c == 2) exit }
      c == 1 && /^tags:/ { sub(/^tags:[[:space:]]*/, ""); gsub(/[\[\]]/, ""); print }
    ' "$file")

    # Apply tag filter if specified
    if [[ -n "$tag_filter" ]]; then
      local match=0
      IFS=',' read -ra tag_array <<< "$tags"
      for t in "${tag_array[@]}"; do
        t="$(echo "$t" | xargs)"  # trim whitespace
        if [[ "$t" == "$tag_filter" ]]; then
          match=1
          break
        fi
      done
      [[ $match -eq 0 ]] && continue
    fi

    printf "  %-24s %s\n" "$name" "$desc"
    found=1
  done

  if [[ $found -eq 0 ]]; then echo "  (none)"; fi
}
