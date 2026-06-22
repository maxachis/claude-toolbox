#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  SETUP_SH="${TOOLBOX_ROOT}/setup.sh"
}

teardown() {
  teardown_common
}

# merge_mcp merges toolbox servers into an existing global config without
# clobbering unrelated keys.
@test "merge_mcp merges servers into existing ~/.claude.json" {
  src="${TEST_TEMP}/global.json"
  dest="${TEST_TEMP}/claude.json"
  cat > "$src" << 'EOF'
{ "$schema": "https://claude.ai/schemas/mcp.json",
  "mcpServers": { "github": { "command": "gh", "args": ["copilot", "--mcp"] } } }
EOF
  cat > "$dest" << 'EOF'
{ "numStartups": 7, "mcpServers": { "existing": { "command": "foo" } } }
EOF

  run bash -c "source '$SETUP_SH'; merge_mcp '$src' '$dest'"
  [ "$status" -eq 0 ]

  # Toolbox server added, pre-existing server and unrelated key preserved.
  run python3 -c "import json; d=json.load(open('$dest')); print(sorted(d['mcpServers'])); print(d['numStartups'])"
  [[ "$output" == *"['existing', 'github']"* ]]
  [[ "$output" == *"7"* ]]

  # Source-only top-level keys ($schema) must NOT leak into the global config.
  run python3 -c "import json; print('\$schema' in json.load(open('$dest')))"
  [[ "$output" == *"False"* ]]
}

# merge_mcp creates the global config when it does not yet exist.
@test "merge_mcp creates ~/.claude.json when absent" {
  src="${TEST_TEMP}/global.json"
  dest="${TEST_TEMP}/claude.json"
  cat > "$src" << 'EOF'
{ "mcpServers": { "github": { "command": "gh" } } }
EOF

  run bash -c "source '$SETUP_SH'; merge_mcp '$src' '$dest'"
  [ "$status" -eq 0 ]
  [ -f "$dest" ]

  run python3 -c "import json; print('github' in json.load(open('$dest'))['mcpServers'])"
  [[ "$output" == *"True"* ]]
}

# An empty mcpServers object is a no-op: the (potentially huge) global config is
# left untouched and never backed up.
@test "merge_mcp skips when no servers defined" {
  src="${TEST_TEMP}/global.json"
  dest="${TEST_TEMP}/claude.json"
  echo '{ "mcpServers": {} }' > "$src"
  echo '{ "numStartups": 1 }' > "$dest"

  run bash -c "source '$SETUP_SH'; merge_mcp '$src' '$dest'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no servers"* ]]

  # No backup created.
  run bash -c "ls '${dest}.backup.'* 2>/dev/null | wc -l"
  [[ "$output" == *"0"* ]]
}

# Layering global.json then global.local.json: the local overlay adds its own
# servers and wins on conflicting keys (where secrets/API keys live).
@test "merge_mcp local overlay layers on top of global" {
  base="${TEST_TEMP}/global.json"
  local_src="${TEST_TEMP}/global.local.json"
  dest="${TEST_TEMP}/claude.json"
  cat > "$base" << 'EOF'
{ "mcpServers": { "chrome-devtools": { "command": "npx" },
                  "context7": { "command": "npx", "args": ["-y", "@upstash/context7-mcp"] } } }
EOF
  cat > "$local_src" << 'EOF'
{ "mcpServers": { "context7": { "command": "npx",
                  "args": ["-y", "@upstash/context7-mcp", "--api-key", "ctx7sk-secret"] } } }
EOF

  run bash -c "source '$SETUP_SH'; merge_mcp '$base' '$dest'; merge_mcp '$local_src' '$dest'"
  [ "$status" -eq 0 ]

  # Both servers present; context7's args come from the local overlay (the key).
  run python3 -c "import json; d=json.load(open('$dest'))['mcpServers']; print(sorted(d)); print('--api-key' in d['context7']['args'])"
  [[ "$output" == *"['chrome-devtools', 'context7']"* ]]
  [[ "$output" == *"True"* ]]
}

# A missing source is tolerated (warn + return), not a hard failure.
@test "merge_mcp tolerates a missing source file" {
  run bash -c "source '$SETUP_SH'; merge_mcp '${TEST_TEMP}/nope.json' '${TEST_TEMP}/claude.json'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"not found"* ]]
}
