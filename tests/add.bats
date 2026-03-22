#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{commands/api,agents,bin,lib/claude-toolbox}

  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create initial index files
  create_mock_agents_index "$TOOLBOX_ROOT/agents"
  create_mock_commands_index "$TOOLBOX_ROOT/commands"

  # Add an existing agent row for alphabetical insertion test
  echo '| `existing-agent` | An existing agent |' >> "$TOOLBOX_ROOT/agents/_index.md"
}

teardown() {
  teardown_common
}

@test "add --help shows usage" {
  run "$LOCAL_CLI" add --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"add"* ]]
}

@test "add agent creates agent file with frontmatter" {
  run "$LOCAL_CLI" add agent my-agent
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/agents/my-agent.md" ]

  # Check frontmatter content
  run cat "$TOOLBOX_ROOT/agents/my-agent.md"
  [[ "$output" == *"name: my-agent"* ]]
  [[ "$output" == *"description:"* ]]
  [[ "$output" == *"---"* ]]
}

@test "add agent updates _index.md" {
  run "$LOCAL_CLI" add agent my-agent
  [ "$status" -eq 0 ]

  run cat "$TOOLBOX_ROOT/agents/_index.md"
  [[ "$output" == *"my-agent"* ]]
}

@test "add agent inserts alphabetically" {
  run "$LOCAL_CLI" add agent alpha-agent
  [ "$status" -eq 0 ]

  # alpha-agent should appear before existing-agent
  run cat "$TOOLBOX_ROOT/agents/_index.md"
  [[ "$output" == *"alpha-agent"* ]]

  # Check ordering: alpha before existing
  local alpha_line existing_line
  alpha_line=$(grep -n "alpha-agent" "$TOOLBOX_ROOT/agents/_index.md" | head -1 | cut -d: -f1)
  existing_line=$(grep -n "existing-agent" "$TOOLBOX_ROOT/agents/_index.md" | head -1 | cut -d: -f1)
  [ "$alpha_line" -lt "$existing_line" ]
}

@test "add agent rejects duplicate" {
  "$LOCAL_CLI" add agent new-agent
  run "$LOCAL_CLI" add agent new-agent
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
}

@test "add agent rejects invalid name" {
  run "$LOCAL_CLI" add agent "Invalid_Name"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid name"* ]]
}

@test "add agent rejects name starting with digit" {
  run "$LOCAL_CLI" add agent "1bad-name"
  [ "$status" -eq 1 ]
}

@test "add command creates command file" {
  run "$LOCAL_CLI" add command api/new-endpoint
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/commands/api/new-endpoint.md" ]

  run cat "$TOOLBOX_ROOT/commands/api/new-endpoint.md"
  [[ "$output" == *"# new-endpoint"* ]]
  [[ "$output" == *"## Instructions"* ]]
}

@test "add command updates _index.md" {
  run "$LOCAL_CLI" add command api/new-endpoint
  [ "$status" -eq 0 ]

  run cat "$TOOLBOX_ROOT/commands/_index.md"
  [[ "$output" == *"new-endpoint"* ]]
  [[ "$output" == *"api"* ]]
}

@test "add command creates new category if needed" {
  run "$LOCAL_CLI" add command devops/deploy
  [ "$status" -eq 0 ]
  [ -d "$TOOLBOX_ROOT/commands/devops" ]
  [ -f "$TOOLBOX_ROOT/commands/devops/deploy.md" ]
  [ -f "$TOOLBOX_ROOT/commands/devops/README.md" ]
}

@test "add with missing name shows error" {
  run "$LOCAL_CLI" add agent
  [ "$status" -eq 1 ]
}

@test "add with missing type shows error" {
  run "$LOCAL_CLI" add
  [ "$status" -eq 1 ]
}
