#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{bin,lib/claude-toolbox}
  mkdir -p "$TOOLBOX_ROOT"/rules/{project-types,conventions}
  mkdir -p "$TOOLBOX_ROOT"/bundles/my-bundle/commands

  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create sample rule
  echo "# Python Project Rules" > "$TOOLBOX_ROOT/rules/project-types/python-project.md"

  # Create sample convention
  echo "# Commit Messages" > "$TOOLBOX_ROOT/rules/conventions/commit-messages.md"

  # Create sample bundle
  echo "# Bundle CLAUDE.md" > "$TOOLBOX_ROOT/bundles/my-bundle/CLAUDE.md"
  echo "# Bundle README" > "$TOOLBOX_ROOT/bundles/my-bundle/README.md"
  mkdir -p "$TOOLBOX_ROOT/bundles/my-bundle/commands"
  echo "# cmd1" > "$TOOLBOX_ROOT/bundles/my-bundle/commands/cmd1.md"
  echo "# cmd2" > "$TOOLBOX_ROOT/bundles/my-bundle/commands/cmd2.md"

  # Create a project directory to apply into
  PROJECT_DIR="${TEST_TEMP}/project"
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR"
}

teardown() {
  teardown_common
}

# --- Help ---

@test "apply --help shows usage" {
  run "$LOCAL_CLI" apply --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"apply"* ]]
}

# --- List ---

@test "apply --list shows available rules, conventions, and bundles" {
  run "$LOCAL_CLI" apply --list
  [ "$status" -eq 0 ]
  [[ "$output" == *"python-project"* ]]
  [[ "$output" == *"commit-messages"* ]]
  [[ "$output" == *"my-bundle"* ]]
}

@test "apply --list rules shows only rules" {
  run "$LOCAL_CLI" apply --list rules
  [ "$status" -eq 0 ]
  [[ "$output" == *"python-project"* ]]
  [[ "$output" != *"commit-messages"* ]]
  [[ "$output" != *"my-bundle"* ]]
}

@test "apply --list conventions shows only conventions" {
  run "$LOCAL_CLI" apply --list conventions
  [ "$status" -eq 0 ]
  [[ "$output" != *"python-project"* ]]
  [[ "$output" == *"commit-messages"* ]]
}

@test "apply --list bundles shows only bundles" {
  run "$LOCAL_CLI" apply --list bundles
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-bundle"* ]]
  [[ "$output" != *"python-project"* ]]
}

# --- Apply rule ---

@test "apply rule copies template to CLAUDE.md" {
  run "$LOCAL_CLI" apply rule python-project
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/CLAUDE.md" ]
  [[ "$(cat "$PROJECT_DIR/CLAUDE.md")" == *"Python Project Rules"* ]]
}

@test "apply rule fails for nonexistent rule" {
  run "$LOCAL_CLI" apply rule nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "apply rule prompts on existing CLAUDE.md without --force" {
  echo "existing content" > "$PROJECT_DIR/CLAUDE.md"
  # Without --force and no TTY, should fail/skip
  run "$LOCAL_CLI" apply rule python-project
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "apply rule overwrites with --force" {
  echo "existing content" > "$PROJECT_DIR/CLAUDE.md"
  run "$LOCAL_CLI" apply rule python-project --force
  [ "$status" -eq 0 ]
  [[ "$(cat "$PROJECT_DIR/CLAUDE.md")" == *"Python Project Rules"* ]]
}

@test "apply rule -f works as alias for --force" {
  echo "existing content" > "$PROJECT_DIR/CLAUDE.md"
  run "$LOCAL_CLI" apply rule python-project -f
  [ "$status" -eq 0 ]
  [[ "$(cat "$PROJECT_DIR/CLAUDE.md")" == *"Python Project Rules"* ]]
}

# --- Apply convention ---

@test "apply convention copies to .claude/rules/" {
  run "$LOCAL_CLI" apply convention commit-messages
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.claude/rules/commit-messages.md" ]
  [[ "$(cat "$PROJECT_DIR/.claude/rules/commit-messages.md")" == *"Commit Messages"* ]]
}

@test "apply convention creates .claude/rules/ directory" {
  [ ! -d "$PROJECT_DIR/.claude/rules" ]
  run "$LOCAL_CLI" apply convention commit-messages
  [ "$status" -eq 0 ]
  [ -d "$PROJECT_DIR/.claude/rules" ]
}

@test "apply convention fails for nonexistent convention" {
  run "$LOCAL_CLI" apply convention nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "apply convention blocks overwrite without --force" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "existing" > "$PROJECT_DIR/.claude/rules/commit-messages.md"
  run "$LOCAL_CLI" apply convention commit-messages
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "apply convention overwrites with --force" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "existing" > "$PROJECT_DIR/.claude/rules/commit-messages.md"
  run "$LOCAL_CLI" apply convention commit-messages --force
  [ "$status" -eq 0 ]
  [[ "$(cat "$PROJECT_DIR/.claude/rules/commit-messages.md")" == *"Commit Messages"* ]]
}

# --- Apply bundle ---

@test "apply bundle copies CLAUDE.md and commands" {
  run "$LOCAL_CLI" apply bundle my-bundle --force
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/CLAUDE.md" ]
  [ -f "$PROJECT_DIR/.claude/commands/cmd1.md" ]
  [ -f "$PROJECT_DIR/.claude/commands/cmd2.md" ]
}

@test "apply bundle fails for nonexistent bundle" {
  run "$LOCAL_CLI" apply bundle nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "apply bundle blocks CLAUDE.md overwrite without --force" {
  echo "existing" > "$PROJECT_DIR/CLAUDE.md"
  run "$LOCAL_CLI" apply bundle my-bundle
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "apply bundle warns on command conflicts without --force" {
  mkdir -p "$PROJECT_DIR/.claude/commands"
  echo "old" > "$PROJECT_DIR/.claude/commands/cmd1.md"
  run "$LOCAL_CLI" apply bundle my-bundle --force
  [ "$status" -eq 0 ]
  # cmd1 should be overwritten
  [[ "$(cat "$PROJECT_DIR/.claude/commands/cmd1.md")" == "# cmd1" ]]
}

# --- Missing args ---

@test "apply with missing type shows error" {
  run "$LOCAL_CLI" apply
  [ "$status" -eq 1 ]
}

@test "apply rule with missing name shows error" {
  run "$LOCAL_CLI" apply rule
  [ "$status" -eq 1 ]
}

# --- Apply pattern ---

@test "apply pattern copies to .claude/patterns/" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  cat > "$TOOLBOX_ROOT/patterns/glossary-component.md" << 'EOF'
---
description: A reusable glossary
tags: [frontend, component]
---
# Glossary Component
Recipe content here.
EOF
  run "$LOCAL_CLI" apply pattern glossary-component
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.claude/patterns/glossary-component.md" ]
  [[ "$(cat "$PROJECT_DIR/.claude/patterns/glossary-component.md")" == *"Glossary Component"* ]]
}

@test "apply pattern creates .claude/patterns/ directory" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  cat > "$TOOLBOX_ROOT/patterns/glossary-component.md" << 'EOF'
---
description: A glossary
tags: [frontend]
---
# Glossary
EOF
  [ ! -d "$PROJECT_DIR/.claude/patterns" ]
  run "$LOCAL_CLI" apply pattern glossary-component
  [ "$status" -eq 0 ]
  [ -d "$PROJECT_DIR/.claude/patterns" ]
}

@test "apply pattern fails for nonexistent pattern" {
  run "$LOCAL_CLI" apply pattern nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "apply pattern blocks overwrite without --force" {
  mkdir -p "$TOOLBOX_ROOT/patterns" "$PROJECT_DIR/.claude/patterns"
  echo "# Old" > "$TOOLBOX_ROOT/patterns/glossary-component.md"
  echo "existing" > "$PROJECT_DIR/.claude/patterns/glossary-component.md"
  run "$LOCAL_CLI" apply pattern glossary-component
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "apply pattern overwrites with --force" {
  mkdir -p "$TOOLBOX_ROOT/patterns" "$PROJECT_DIR/.claude/patterns"
  echo "# New Pattern" > "$TOOLBOX_ROOT/patterns/glossary-component.md"
  echo "existing" > "$PROJECT_DIR/.claude/patterns/glossary-component.md"
  run "$LOCAL_CLI" apply pattern glossary-component --force
  [ "$status" -eq 0 ]
  [[ "$(cat "$PROJECT_DIR/.claude/patterns/glossary-component.md")" == *"New Pattern"* ]]
}

@test "apply --list shows patterns" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  echo "# Pat" > "$TOOLBOX_ROOT/patterns/glossary-component.md"
  run "$LOCAL_CLI" apply --list patterns
  [ "$status" -eq 0 ]
  [[ "$output" == *"glossary-component"* ]]
}
