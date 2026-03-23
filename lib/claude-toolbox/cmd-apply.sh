#!/usr/bin/env bash
#
# cmd-apply.sh — Pull knowledge from the toolbox into a project
#

cmd_apply() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << 'EOF'
Usage: claude-toolbox apply <type> <name> [--force|-f]
       claude-toolbox apply --list [type]

Apply toolbox content to the current project.

Types:
  rule <name>           Copy a project-type template → ./CLAUDE.md
  convention <name>     Copy a convention snippet → .claude/rules/<name>.md
  bundle <name>         Copy bundle CLAUDE.md + commands into project
  pattern <name>        Copy a pattern recipe → .claude/patterns/<name>.md

Options:
  --list [type]    List available rules/conventions/bundles
  -f, --force      Skip overwrite confirmations
EOF
    return 0
  fi

  # Handle --list anywhere in args
  if [[ "${1:-}" == "--list" ]]; then
    shift
    apply_list "${1:-}"
    return $?
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
    error "Missing type. Usage: claude-toolbox apply <rule|convention|bundle|pattern> <name>"
    return 1
  fi

  if [[ -z "$name" ]]; then
    error "Missing name. Usage: claude-toolbox apply $type <name>"
    return 1
  fi

  case "$type" in
    rule)       apply_rule "$name" "$force" ;;
    convention) apply_convention "$name" "$force" ;;
    bundle)     apply_bundle "$name" "$force" ;;
    pattern)    apply_pattern "$name" "$force" ;;
    *)
      error "Unknown type: $type. Use 'rule', 'convention', 'bundle', or 'pattern'."
      return 1
      ;;
  esac
}

apply_list() {
  local filter="${1:-}"

  if [[ -z "$filter" || "$filter" == "rules" ]]; then
    local rules_dir="${TOOLBOX_ROOT}/rules/project-types"
    if [[ -d "$rules_dir" ]]; then
      echo "Rules (project types):"
      for f in "$rules_dir"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name="$(basename "$f" .md)"
        printf "  %s\n" "$name"
      done
      echo ""
    fi
  fi

  if [[ -z "$filter" || "$filter" == "conventions" ]]; then
    local conv_dir="${TOOLBOX_ROOT}/rules/conventions"
    if [[ -d "$conv_dir" ]]; then
      echo "Conventions:"
      for f in "$conv_dir"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name="$(basename "$f" .md)"
        printf "  %s\n" "$name"
      done
      echo ""
    fi
  fi

  if [[ -z "$filter" || "$filter" == "bundles" ]]; then
    local bundles_dir="${TOOLBOX_ROOT}/bundles"
    if [[ -d "$bundles_dir" ]]; then
      echo "Bundles:"
      for d in "$bundles_dir"/*/; do
        [[ -d "$d" ]] || continue
        local name
        name="$(basename "$d")"
        printf "  %s\n" "$name"
      done
      echo ""
    fi
  fi

  if [[ -z "$filter" || "$filter" == "patterns" ]]; then
    local patterns_dir="${TOOLBOX_ROOT}/patterns"
    if [[ -d "$patterns_dir" ]]; then
      echo "Patterns:"
      for f in "$patterns_dir"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name="$(basename "$f" .md)"
        [[ "$name" == "_index" || "$name" == "README" ]] && continue
        printf "  %s\n" "$name"
      done
      echo ""
    fi
  fi
}

apply_rule() {
  local name="$1"
  local force="$2"
  local source="${TOOLBOX_ROOT}/rules/project-types/${name}.md"
  local target="./CLAUDE.md"

  if [[ ! -f "$source" ]]; then
    error "Rule '${name}' not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error "CLAUDE.md already exists. Use --force to overwrite."
    return 1
  fi

  cp "$source" "$target"
  info "Applied rule '${name}' → ./CLAUDE.md"
}

apply_convention() {
  local name="$1"
  local force="$2"
  local source="${TOOLBOX_ROOT}/rules/conventions/${name}.md"
  local target=".claude/rules/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Convention '${name}' not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error ".claude/rules/${name}.md already exists. Use --force to overwrite."
    return 1
  fi

  mkdir -p ".claude/rules"
  cp "$source" "$target"
  info "Applied convention '${name}' → .claude/rules/${name}.md"
}

apply_bundle() {
  local name="$1"
  local force="$2"
  local bundle_dir="${TOOLBOX_ROOT}/bundles/${name}"

  if [[ ! -d "$bundle_dir" ]]; then
    error "Bundle '${name}' not found at ${bundle_dir}"
    return 1
  fi

  # Copy CLAUDE.md if present
  if [[ -f "${bundle_dir}/CLAUDE.md" ]]; then
    if [[ -f "./CLAUDE.md" && "$force" -ne 1 ]]; then
      error "CLAUDE.md already exists. Use --force to overwrite."
      return 1
    fi
    cp "${bundle_dir}/CLAUDE.md" "./CLAUDE.md"
    info "Applied ${name}/CLAUDE.md → ./CLAUDE.md"
  fi

  # Copy commands if present
  if [[ -d "${bundle_dir}/commands" ]]; then
    mkdir -p ".claude/commands"
    local count=0
    for f in "${bundle_dir}/commands/"*.md; do
      [[ -f "$f" ]] || continue
      local cmd_name
      cmd_name="$(basename "$f")"
      if [[ -f ".claude/commands/${cmd_name}" && "$force" -ne 1 ]]; then
        warn "Skipping .claude/commands/${cmd_name} (already exists)"
        continue
      fi
      cp "$f" ".claude/commands/${cmd_name}"
      count=$((count + 1))
    done
    info "Applied ${count} commands → .claude/commands/"
  fi
}

apply_pattern() {
  local name="$1"
  local force="$2"
  local source="${TOOLBOX_ROOT}/patterns/${name}.md"
  local target=".claude/patterns/${name}.md"

  if [[ ! -f "$source" ]]; then
    error "Pattern '${name}' not found at ${source}"
    return 1
  fi

  if [[ -f "$target" && "$force" -ne 1 ]]; then
    error ".claude/patterns/${name}.md already exists. Use --force to overwrite."
    return 1
  fi

  mkdir -p ".claude/patterns"
  cp "$source" "$target"
  info "Applied pattern '${name}' → .claude/patterns/${name}.md"
}
