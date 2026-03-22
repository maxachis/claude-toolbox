#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{bin,lib/claude-toolbox}
  mkdir -p "$TOOLBOX_ROOT"/rules/{project-types,conventions}
  mkdir -p "$TOOLBOX_ROOT"/{commands,skills,agents}

  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create index files
  create_mock_commands_index "$TOOLBOX_ROOT/commands"
  cat > "$TOOLBOX_ROOT/rules/_index.md" << 'EOF'
# Rules Index

## Project Types

| Rule | Description |
|------|-------------|

## Conventions

| Convention | Description |
|------------|-------------|
EOF

  cat > "$TOOLBOX_ROOT/skills/_index.md" << 'EOF'
# Skills Index

| Skill | Category | Description |
|-------|----------|-------------|
EOF

  # Create a project directory to capture from
  PROJECT_DIR="${TEST_TEMP}/project"
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR"
}

teardown() {
  teardown_common
}

# --- Help ---

@test "capture --help shows usage" {
  run "$LOCAL_CLI" capture --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"capture"* ]]
}

# --- Capture rule ---

@test "capture rule saves CLAUDE.md as project-type template" {
  echo "# My Project Rules" > "$PROJECT_DIR/CLAUDE.md"
  run "$LOCAL_CLI" capture rule my-project
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/rules/project-types/my-project.md" ]
  [[ "$(cat "$TOOLBOX_ROOT/rules/project-types/my-project.md")" == *"My Project Rules"* ]]
}

@test "capture rule fails when CLAUDE.md missing" {
  run "$LOCAL_CLI" capture rule my-project
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]] || [[ "$output" == *"No CLAUDE.md"* ]]
}

@test "capture rule blocks overwrite without --force" {
  echo "# My Project" > "$PROJECT_DIR/CLAUDE.md"
  echo "# Existing" > "$TOOLBOX_ROOT/rules/project-types/my-project.md"
  run "$LOCAL_CLI" capture rule my-project
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "capture rule overwrites with --force" {
  echo "# Updated Rules" > "$PROJECT_DIR/CLAUDE.md"
  echo "# Old" > "$TOOLBOX_ROOT/rules/project-types/my-project.md"
  run "$LOCAL_CLI" capture rule my-project --force
  [ "$status" -eq 0 ]
  [[ "$(cat "$TOOLBOX_ROOT/rules/project-types/my-project.md")" == *"Updated Rules"* ]]
}

@test "capture rule updates rules/_index.md" {
  echo "# My Project" > "$PROJECT_DIR/CLAUDE.md"
  run "$LOCAL_CLI" capture rule my-project
  [ "$status" -eq 0 ]
  run cat "$TOOLBOX_ROOT/rules/_index.md"
  [[ "$output" == *"my-project"* ]]
}

# --- Capture convention ---

@test "capture convention saves .claude/rules/ file as convention" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "# Code Style" > "$PROJECT_DIR/.claude/rules/code-style.md"
  run "$LOCAL_CLI" capture convention code-style
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/rules/conventions/code-style.md" ]
  [[ "$(cat "$TOOLBOX_ROOT/rules/conventions/code-style.md")" == *"Code Style"* ]]
}

@test "capture convention fails when source missing" {
  run "$LOCAL_CLI" capture convention nonexistent
  [ "$status" -eq 1 ]
}

@test "capture convention blocks overwrite without --force" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "# Style" > "$PROJECT_DIR/.claude/rules/code-style.md"
  echo "# Old" > "$TOOLBOX_ROOT/rules/conventions/code-style.md"
  run "$LOCAL_CLI" capture convention code-style
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "capture convention overwrites with --force" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "# New Style" > "$PROJECT_DIR/.claude/rules/code-style.md"
  echo "# Old" > "$TOOLBOX_ROOT/rules/conventions/code-style.md"
  run "$LOCAL_CLI" capture convention code-style --force
  [ "$status" -eq 0 ]
  [[ "$(cat "$TOOLBOX_ROOT/rules/conventions/code-style.md")" == *"New Style"* ]]
}

@test "capture convention updates rules/_index.md" {
  mkdir -p "$PROJECT_DIR/.claude/rules"
  echo "# Style" > "$PROJECT_DIR/.claude/rules/code-style.md"
  run "$LOCAL_CLI" capture convention code-style
  [ "$status" -eq 0 ]
  run cat "$TOOLBOX_ROOT/rules/_index.md"
  [[ "$output" == *"code-style"* ]]
}

# --- Capture command ---

@test "capture command copies .claude/commands/ file into toolbox" {
  mkdir -p "$PROJECT_DIR/.claude/commands/api"
  echo "# My Endpoint" > "$PROJECT_DIR/.claude/commands/api/my-endpoint.md"
  run "$LOCAL_CLI" capture command api/my-endpoint
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/commands/api/my-endpoint.md" ]
}

@test "capture command fails when source missing" {
  run "$LOCAL_CLI" capture command api/nonexistent
  [ "$status" -eq 1 ]
}

@test "capture command creates category dir if new" {
  mkdir -p "$PROJECT_DIR/.claude/commands/newcat"
  echo "# My Command" > "$PROJECT_DIR/.claude/commands/newcat/my-cmd.md"
  run "$LOCAL_CLI" capture command newcat/my-cmd
  [ "$status" -eq 0 ]
  [ -d "$TOOLBOX_ROOT/commands/newcat" ]
  [ -f "$TOOLBOX_ROOT/commands/newcat/README.md" ]
}

@test "capture command updates commands/_index.md" {
  mkdir -p "$PROJECT_DIR/.claude/commands/api"
  echo "# My Endpoint" > "$PROJECT_DIR/.claude/commands/api/my-endpoint.md"
  run "$LOCAL_CLI" capture command api/my-endpoint
  [ "$status" -eq 0 ]
  run cat "$TOOLBOX_ROOT/commands/_index.md"
  [[ "$output" == *"my-endpoint"* ]]
}

@test "capture command blocks overwrite without --force" {
  mkdir -p "$PROJECT_DIR/.claude/commands/api" "$TOOLBOX_ROOT/commands/api"
  echo "# New" > "$PROJECT_DIR/.claude/commands/api/my-endpoint.md"
  echo "# Old" > "$TOOLBOX_ROOT/commands/api/my-endpoint.md"
  run "$LOCAL_CLI" capture command api/my-endpoint
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "capture command requires category/name format" {
  run "$LOCAL_CLI" capture command nocategory
  [ "$status" -eq 1 ]
}

# --- Capture skill ---

@test "capture skill copies .claude/skills/ file into toolbox" {
  mkdir -p "$PROJECT_DIR/.claude/skills/languages"
  echo "# Go Conventions" > "$PROJECT_DIR/.claude/skills/languages/go.md"
  run "$LOCAL_CLI" capture skill languages/go
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/skills/languages/go.md" ]
}

@test "capture skill fails when source missing" {
  run "$LOCAL_CLI" capture skill languages/nonexistent
  [ "$status" -eq 1 ]
}

@test "capture skill updates skills/_index.md" {
  mkdir -p "$PROJECT_DIR/.claude/skills/languages"
  echo "# Go" > "$PROJECT_DIR/.claude/skills/languages/go.md"
  run "$LOCAL_CLI" capture skill languages/go
  [ "$status" -eq 0 ]
  run cat "$TOOLBOX_ROOT/skills/_index.md"
  [[ "$output" == *"go"* ]]
}

# --- Capture with --from ---

@test "capture rule --from uses explicit source path" {
  echo "# Custom Rules" > "$PROJECT_DIR/my-rules.md"
  run "$LOCAL_CLI" capture rule custom-project --from "$PROJECT_DIR/my-rules.md"
  [ "$status" -eq 0 ]
  [[ "$(cat "$TOOLBOX_ROOT/rules/project-types/custom-project.md")" == *"Custom Rules"* ]]
}

# --- Missing args ---

@test "capture with missing type shows error" {
  run "$LOCAL_CLI" capture
  [ "$status" -eq 1 ]
}

@test "capture with missing name shows error" {
  run "$LOCAL_CLI" capture rule
  [ "$status" -eq 1 ]
}
