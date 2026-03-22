#!/usr/bin/env bash
#
# common-setup.bash — Shared test fixtures for bats tests
#

# Project root (two levels up from test_helper/)
TOOLBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLI="${TOOLBOX_ROOT}/bin/claude-toolbox"

setup_common() {
  # Create isolated temp directory for each test
  TEST_TEMP="$(mktemp -d)"
  export HOME="${TEST_TEMP}/home"
  mkdir -p "$HOME/.claude"

  # Override toolbox root for commands that need it
  export TOOLBOX_ROOT
}

teardown_common() {
  # Clean up temp directory
  if [[ -d "${TEST_TEMP:-}" ]]; then
    rm -rf "$TEST_TEMP"
  fi
}

# Helper: create a mock agent file with frontmatter
create_mock_agent() {
  local dir="$1" name="$2" desc="${3:-Test agent}"
  cat > "${dir}/${name}.md" << EOF
---
name: ${name}
description: ${desc}
tools: Read, Grep, Glob
model: sonnet
---

System prompt for ${name}.
EOF
}

# Helper: create a mock command file
create_mock_command() {
  local dir="$1" name="$2" desc="${3:-Test command}"
  mkdir -p "$dir"
  cat > "${dir}/${name}.md" << EOF
# ${name}
${desc}

## Instructions
1. Do the thing.
EOF
}

# Helper: create a minimal _index.md for agents
create_mock_agents_index() {
  local dir="$1"
  cat > "${dir}/_index.md" << 'EOF'
# Agents Index

## Available Agents

| Agent | Description |
|-------|-------------|
EOF
}

# Helper: create a minimal _index.md for commands
create_mock_commands_index() {
  local dir="$1"
  cat > "${dir}/_index.md" << 'EOF'
# Commands Index

## Quick Reference

| Command | Category | Description |
|---------|----------|-------------|
EOF
}
