#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{commands/api,agents,bin,lib/claude-toolbox}

  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create agents index with entries
  cat > "$TOOLBOX_ROOT/agents/_index.md" << 'EOF'
# Agents Index

## Available Agents

| Agent | Description |
|-------|-------------|
| `alpha-agent` | Alpha agent |
| `beta-agent` | Beta agent |
| `gamma-agent` | Gamma agent |
EOF

  # Create the agent files
  create_mock_agent "$TOOLBOX_ROOT/agents" "alpha-agent" "Alpha agent"
  create_mock_agent "$TOOLBOX_ROOT/agents" "beta-agent" "Beta agent"
  create_mock_agent "$TOOLBOX_ROOT/agents" "gamma-agent" "Gamma agent"

  # Create commands index with entries
  cat > "$TOOLBOX_ROOT/commands/_index.md" << 'EOF'
# Commands Index

## Quick Reference

| Command | Category | Description |
|---------|----------|-------------|
| `/api-design` | [api](api/) | Design APIs |
| `/api-test` | [api](api/) | Test APIs |
EOF

  # Create command files
  create_mock_command "$TOOLBOX_ROOT/commands/api" "api-design" "Design APIs"
  create_mock_command "$TOOLBOX_ROOT/commands/api" "api-test" "Test APIs"

  # Create category README
  cat > "$TOOLBOX_ROOT/commands/api/README.md" << 'EOF'
# API Commands

| Command | Description |
|---------|-------------|
| `api-design` | Design APIs |
| `api-test` | Test APIs |
EOF
}

teardown() {
  teardown_common
}

@test "remove --help shows usage" {
  run "$LOCAL_CLI" remove --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"remove"* ]]
}

@test "remove agent deletes file with --force" {
  run "$LOCAL_CLI" remove agent beta-agent --force
  [ "$status" -eq 0 ]
  [ ! -f "$TOOLBOX_ROOT/agents/beta-agent.md" ]
}

@test "remove agent updates _index.md" {
  run "$LOCAL_CLI" remove agent beta-agent --force
  [ "$status" -eq 0 ]

  run cat "$TOOLBOX_ROOT/agents/_index.md"
  [[ "$output" != *"beta-agent"* ]]
  # Other agents should still be there
  [[ "$output" == *"alpha-agent"* ]]
  [[ "$output" == *"gamma-agent"* ]]
}

@test "remove agent fails for nonexistent agent" {
  run "$LOCAL_CLI" remove agent nonexistent --force
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "remove command deletes file with --force" {
  run "$LOCAL_CLI" remove command api/api-design --force
  [ "$status" -eq 0 ]
  [ ! -f "$TOOLBOX_ROOT/commands/api/api-design.md" ]
}

@test "remove command updates _index.md" {
  run "$LOCAL_CLI" remove command api/api-design --force
  [ "$status" -eq 0 ]

  run cat "$TOOLBOX_ROOT/commands/_index.md"
  [[ "$output" != *"api-design"* ]]
  [[ "$output" == *"api-test"* ]]
}

@test "remove command updates category README" {
  run "$LOCAL_CLI" remove command api/api-design --force
  [ "$status" -eq 0 ]

  run cat "$TOOLBOX_ROOT/commands/api/README.md"
  [[ "$output" != *"api-design"* ]]
  [[ "$output" == *"api-test"* ]]
}

@test "remove with missing name shows error" {
  run "$LOCAL_CLI" remove agent
  [ "$status" -eq 1 ]
}

@test "remove with -f works as alias for --force" {
  run "$LOCAL_CLI" remove agent beta-agent -f
  [ "$status" -eq 0 ]
  [ ! -f "$TOOLBOX_ROOT/agents/beta-agent.md" ]
}
