#!/usr/bin/env bash
#
# cmd-add.sh — Scaffold new agents and commands
#

cmd_add() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox add <type> <name>

Scaffold a new component and update catalog files.

Types:
  agent <name>            Create an agent (e.g., my-agent)
  command <category/name> Create a command (e.g., api/new-endpoint)

Names must be lowercase letters, digits, and hyphens, starting with a letter.
EOF
    return 0
  fi

  local type="${1:-}"
  local name="${2:-}"

  if [[ -z "$type" ]]; then
    error "Missing type. Usage: claude-toolbox add <agent|command> <name>"
    return 1
  fi

  if [[ -z "$name" ]]; then
    error "Missing name. Usage: claude-toolbox add $type <name>"
    return 1
  fi

  case "$type" in
    agent)   add_agent "$name" ;;
    command) add_command "$name" ;;
    *)
      error "Unknown type: $type. Use 'agent' or 'command'."
      return 1
      ;;
  esac
}

validate_name() {
  local name="$1"
  if ! [[ "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
    error "Invalid name '$name' — must be lowercase letters, digits, and hyphens, starting with a letter"
    return 1
  fi
}

add_agent() {
  local name="$1"
  local agents_dir="${TOOLBOX_ROOT}/agents"
  local file="${agents_dir}/${name}.md"
  local index="${agents_dir}/_index.md"

  validate_name "$name" || return 1

  if [[ -f "$file" ]]; then
    error "Agent '${name}' already exists at ${file}"
    return 1
  fi

  # Write agent template
  cat > "$file" << EOF
---
name: ${name}
description: TODO — describe when Claude should use this agent
tools: Read, Grep, Glob
model: sonnet
---

System prompt for ${name}.

## When Invoked
1. First step
2. Second step
EOF

  info "Created ${file}"

  # Update _index.md if it exists
  if [[ -f "$index" ]]; then
    local row="| \`${name}\` | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
    info "Updated agents/_index.md"
  fi
}

add_command() {
  local input="$1"

  # Parse category/name
  if [[ "$input" != */* ]]; then
    error "Command name must include category: <category/name> (e.g., api/new-endpoint)"
    return 1
  fi

  local category="${input%%/*}"
  local name="${input#*/}"

  validate_name "$name" || return 1

  local cat_dir="${TOOLBOX_ROOT}/commands/${category}"
  local file="${cat_dir}/${name}.md"
  local index="${TOOLBOX_ROOT}/commands/_index.md"
  local cat_readme="${cat_dir}/README.md"

  if [[ -f "$file" ]]; then
    error "Command '${name}' already exists at ${file}"
    return 1
  fi

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

  # Write command template
  cat > "$file" << EOF
# ${name}
TODO — brief description.

## Arguments
- \$ARGUMENTS — describe expected arguments

## Instructions
1. First step
2. Second step

## Output format
Describe the expected output.
EOF

  info "Created ${file}"

  # Update commands/_index.md
  if [[ -f "$index" ]]; then
    local row="| \`/${name}\` | [${category}](${category}/) | TODO — add description |"
    insert_table_row "$index" "$row" "$name"
    info "Updated commands/_index.md"
  fi

  # Update category README.md
  if [[ -f "$cat_readme" ]]; then
    local cat_row="| \`${name}\` | TODO — add description |"
    insert_table_row "$cat_readme" "$cat_row" "$name"
    info "Updated ${category}/README.md"
  fi
}

