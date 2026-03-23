#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  # Create a mock toolbox structure
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{commands/api,commands/git,agents,skills/languages,plugins/my-plugin,bin,lib/claude-toolbox}

  # Copy the real CLI and libs
  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Create mock agents
  create_mock_agent "$TOOLBOX_ROOT/agents" "security-reviewer" "Security audits and vulnerability analysis"
  create_mock_agent "$TOOLBOX_ROOT/agents" "test-generator" "Comprehensive test generation"

  # Create mock commands
  create_mock_command "$TOOLBOX_ROOT/commands/api" "api-design" "Design RESTful API endpoints"
  create_mock_command "$TOOLBOX_ROOT/commands/git" "commit" "Generate commit message"

  # Create mock plugin
  cat > "$TOOLBOX_ROOT/plugins/my-plugin/plugin.json" << 'EOF'
{
  "name": "my-plugin",
  "description": "A test plugin"
}
EOF

  # Create mock skills
  cat > "$TOOLBOX_ROOT/skills/languages/python.md" << 'EOF'
# Python
Python language conventions and best practices.
EOF
}

teardown() {
  teardown_common
}

@test "list --help shows usage" {
  run "$LOCAL_CLI" list --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"list"* ]]
}

@test "list agents shows agent names and descriptions" {
  run "$LOCAL_CLI" list agents
  [ "$status" -eq 0 ]
  [[ "$output" == *"security-reviewer"* ]]
  [[ "$output" == *"Security audits"* ]]
  [[ "$output" == *"test-generator"* ]]
}

@test "list commands shows commands grouped by category" {
  run "$LOCAL_CLI" list commands
  [ "$status" -eq 0 ]
  [[ "$output" == *"api"* ]]
  [[ "$output" == *"api-design"* ]]
  [[ "$output" == *"git"* ]]
  [[ "$output" == *"commit"* ]]
}

@test "list plugins shows plugin names and descriptions" {
  run "$LOCAL_CLI" list plugins
  [ "$status" -eq 0 ]
  [[ "$output" == *"my-plugin"* ]]
  [[ "$output" == *"A test plugin"* ]]
}

@test "list skills shows skill files" {
  run "$LOCAL_CLI" list skills
  [ "$status" -eq 0 ]
  [[ "$output" == *"python"* ]]
}

@test "list with no args shows all component types" {
  run "$LOCAL_CLI" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"Agents"* ]]
  [[ "$output" == *"Commands"* ]]
  [[ "$output" == *"Plugins"* ]]
  [[ "$output" == *"Skills"* ]]
}

@test "list with invalid type shows error" {
  run "$LOCAL_CLI" list nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown"* ]]
}

# --- Patterns ---

@test "list patterns shows pattern names and descriptions" {
  # Create mock patterns
  mkdir -p "$TOOLBOX_ROOT/patterns"
  cat > "$TOOLBOX_ROOT/patterns/glossary-component.md" << 'PATEOF'
---
description: A reusable glossary with alphabetical index
tags: [frontend, component, reference]
---
# Glossary Component
PATEOF
  cat > "$TOOLBOX_ROOT/patterns/search-index.md" << 'PATEOF'
---
description: Client-side search index generation
tags: [frontend, search]
---
# Search Index
PATEOF

  run "$LOCAL_CLI" list patterns
  [ "$status" -eq 0 ]
  [[ "$output" == *"Patterns:"* ]]
  [[ "$output" == *"glossary-component"* ]]
  [[ "$output" == *"A reusable glossary"* ]]
  [[ "$output" == *"search-index"* ]]
}

@test "list patterns --tag filters by tag" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  cat > "$TOOLBOX_ROOT/patterns/glossary-component.md" << 'PATEOF'
---
description: A reusable glossary with alphabetical index
tags: [frontend, component, reference]
---
# Glossary Component
PATEOF
  cat > "$TOOLBOX_ROOT/patterns/db-seed.md" << 'PATEOF'
---
description: Database seeding strategy
tags: [backend, database]
---
# DB Seed
PATEOF

  run "$LOCAL_CLI" list patterns --tag frontend
  [ "$status" -eq 0 ]
  [[ "$output" == *"glossary-component"* ]]
  [[ "$output" != *"db-seed"* ]]
}

@test "list patterns --tag with no matches shows none" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  cat > "$TOOLBOX_ROOT/patterns/glossary-component.md" << 'PATEOF'
---
description: A glossary
tags: [frontend]
---
# Glossary
PATEOF

  run "$LOCAL_CLI" list patterns --tag nonexistent
  [ "$status" -eq 0 ]
  [[ "$output" == *"(none)"* ]]
}

@test "list patterns with empty directory shows none" {
  mkdir -p "$TOOLBOX_ROOT/patterns"
  run "$LOCAL_CLI" list patterns
  [ "$status" -eq 0 ]
  [[ "$output" == *"(none)"* ]]
}
