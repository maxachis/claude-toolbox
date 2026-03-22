#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  # Create a mock toolbox structure
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{commands/api,agents,skills,configs,plugins,bin,lib/claude-toolbox}

  # Copy the real CLI and libs
  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"

  # Make the CLI resolve TOOLBOX_ROOT from its own location
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create some mock components
  create_mock_agent "$TOOLBOX_ROOT/agents" "test-agent" "A test agent"
  create_mock_agent "$TOOLBOX_ROOT/agents" "another-agent" "Another agent"
  create_mock_command "$TOOLBOX_ROOT/commands/api" "api-design" "Design APIs"
  mkdir -p "$TOOLBOX_ROOT/plugins/test-plugin"
  echo '{"name": "test-plugin"}' > "$TOOLBOX_ROOT/plugins/test-plugin/plugin.json"
}

teardown() {
  teardown_common
}

@test "status --help shows usage" {
  run "$LOCAL_CLI" status --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"status"* ]]
}

@test "status shows OK for correct symlinks" {
  # Create proper symlinks
  ln -s "$TOOLBOX_ROOT/commands" "$HOME/.claude/commands"
  ln -s "$TOOLBOX_ROOT/agents" "$HOME/.claude/agents"
  ln -s "$TOOLBOX_ROOT/skills" "$HOME/.claude/skills"
  ln -s "$TOOLBOX_ROOT/configs" "$HOME/.claude/configs"
  echo "# CLAUDE.md" > "$TOOLBOX_ROOT/configs/CLAUDE.md"
  ln -s "$TOOLBOX_ROOT/configs/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  echo '{}' > "$HOME/.claude/settings.json"

  run "$LOCAL_CLI" status
  [ "$status" -eq 0 ]
  [[ "$output" == *"OK"* ]]
  [[ "$output" == *"commands"* ]]
}

@test "status shows ERR for missing links" {
  # No symlinks created — should show errors
  run "$LOCAL_CLI" status
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERR"* ]]
  [[ "$output" == *"not linked"* ]]
}

@test "status shows ERR for stale symlinks" {
  # Create symlink pointing to nonexistent target
  ln -s "/nonexistent/path" "$HOME/.claude/commands"

  run "$LOCAL_CLI" status
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERR"* ]]
}

@test "status shows component counts" {
  ln -s "$TOOLBOX_ROOT/commands" "$HOME/.claude/commands"
  ln -s "$TOOLBOX_ROOT/agents" "$HOME/.claude/agents"
  ln -s "$TOOLBOX_ROOT/skills" "$HOME/.claude/skills"
  ln -s "$TOOLBOX_ROOT/configs" "$HOME/.claude/configs"
  echo '{}' > "$HOME/.claude/settings.json"

  run "$LOCAL_CLI" status
  [[ "$output" == *"2 agents"* ]]
  [[ "$output" == *"1 commands"* ]]
}

@test "status checks settings.json" {
  ln -s "$TOOLBOX_ROOT/commands" "$HOME/.claude/commands"
  ln -s "$TOOLBOX_ROOT/agents" "$HOME/.claude/agents"
  ln -s "$TOOLBOX_ROOT/skills" "$HOME/.claude/skills"
  ln -s "$TOOLBOX_ROOT/configs" "$HOME/.claude/configs"
  echo '{}' > "$HOME/.claude/settings.json"

  run "$LOCAL_CLI" status
  [[ "$output" == *"settings.json"* ]]
}
