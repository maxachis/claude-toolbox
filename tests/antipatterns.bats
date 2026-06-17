#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
  export TOOLBOX_ROOT="${TEST_TEMP}/toolbox"
  mkdir -p "$TOOLBOX_ROOT"/{bin,lib/claude-toolbox,antipatterns}

  cp "${CLI}" "$TOOLBOX_ROOT/bin/claude-toolbox"
  cp "${CLI%bin/claude-toolbox}lib/claude-toolbox/"*.sh "$TOOLBOX_ROOT/lib/claude-toolbox/"
  LOCAL_CLI="$TOOLBOX_ROOT/bin/claude-toolbox"

  # Catalog index
  cat > "$TOOLBOX_ROOT/antipatterns/_index.md" << 'EOF'
# Antipatterns Index

| ID | Category | Severity | Summary |
|----|----------|----------|---------|
EOF

  # One mechanical-tier entry
  cat > "$TOOLBOX_ROOT/antipatterns/nonstandard-query-param.md" << 'EOF'
---
id: nonstandard-query-param
category: api-conventions
severity: low
tags: [http, naming]
detect:
  grep: '[?&](p|pp)='
  globs: ['**/*.{ts,py}']
  heuristic: >
    Abbreviated query param name.
---
# Nonstandard query parameter names
**Correct form:** use `page` / `per_page`.
EOF

  PROJECT_DIR="${TEST_TEMP}/project"
  mkdir -p "$PROJECT_DIR"
  cd "$PROJECT_DIR"
}

teardown() {
  teardown_common
}

# --- audit ---

@test "audit --help shows usage and exit-code legend" {
  run "$LOCAL_CLI" audit --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"mechanical grep tier"* ]]
  [[ "$output" == *"2 = candidate violations"* ]]
}

@test "audit flags a matching antipattern and exits 2" {
  mkdir -p "$PROJECT_DIR/src"
  printf 'const u = `/api?p=${n}`;\n' > "$PROJECT_DIR/src/api.ts"
  run "$LOCAL_CLI" audit "$PROJECT_DIR"
  [ "$status" -eq 2 ]
  [[ "$output" == *"nonstandard-query-param"* ]]
  [[ "$output" == *"src/api.ts:1"* ]]
}

@test "audit does not flag the conventional form" {
  mkdir -p "$PROJECT_DIR/src"
  printf 'fetch("/users?page=2");\n' > "$PROJECT_DIR/src/api.ts"
  run "$LOCAL_CLI" audit "$PROJECT_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No antipattern candidates"* ]]
}

@test "audit honors detect.globs (ignores non-matching extensions)" {
  printf 'href="?p=1"\n' > "$PROJECT_DIR/page.html"
  run "$LOCAL_CLI" audit "$PROJECT_DIR"
  [ "$status" -eq 0 ]
}

@test "audit skips vendored directories" {
  mkdir -p "$PROJECT_DIR/node_modules/pkg"
  printf 'x="?p=1"\n' > "$PROJECT_DIR/node_modules/pkg/i.py"
  run "$LOCAL_CLI" audit "$PROJECT_DIR"
  [ "$status" -eq 0 ]
}

@test "audit --severity filters out lower-severity entries" {
  mkdir -p "$PROJECT_DIR/src"
  printf 'u="?p=1"\n' > "$PROJECT_DIR/src/a.py"
  run "$LOCAL_CLI" audit "$PROJECT_DIR" --severity high
  [ "$status" -eq 0 ]
  [[ "$output" == *"No auditable antipattern entries"* ]]
}

@test "audit prefers project-local .claude/antipatterns catalog" {
  mkdir -p "$PROJECT_DIR/.claude/antipatterns" "$PROJECT_DIR/src"
  cat > "$PROJECT_DIR/.claude/antipatterns/local.md" << 'EOF'
---
id: local-only
severity: high
detect:
  grep: 'FORBIDDEN'
  globs: ['**/*.py']
---
EOF
  printf 'x = FORBIDDEN\n' > "$PROJECT_DIR/src/a.py"
  run "$LOCAL_CLI" audit "$PROJECT_DIR"
  [ "$status" -eq 2 ]
  [[ "$output" == *"local-only"* ]]
}

@test "audit fails on nonexistent path" {
  run "$LOCAL_CLI" audit /no/such/dir
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

# --- apply antipattern ---

@test "apply antipattern copies entry into .claude/antipatterns/" {
  run "$LOCAL_CLI" apply antipattern nonstandard-query-param
  [ "$status" -eq 0 ]
  [ -f "$PROJECT_DIR/.claude/antipatterns/nonstandard-query-param.md" ]
}

@test "apply antipattern fails for unknown entry" {
  run "$LOCAL_CLI" apply antipattern nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}

@test "apply --list antipatterns lists the catalog" {
  run "$LOCAL_CLI" apply --list antipatterns
  [ "$status" -eq 0 ]
  [[ "$output" == *"nonstandard-query-param"* ]]
}

# --- capture antipattern ---

@test "capture antipattern copies project entry into toolbox and indexes it" {
  mkdir -p "$PROJECT_DIR/.claude/antipatterns"
  cat > "$PROJECT_DIR/.claude/antipatterns/reinvented-helper.md" << 'EOF'
---
id: reinvented-helper
severity: medium
detect:
  heuristic: >
    Reimplemented a stdlib helper.
---
# Reinvented helper
EOF
  run "$LOCAL_CLI" capture antipattern reinvented-helper
  [ "$status" -eq 0 ]
  [ -f "$TOOLBOX_ROOT/antipatterns/reinvented-helper.md" ]
  [[ "$(cat "$TOOLBOX_ROOT/antipatterns/_index.md")" == *"reinvented-helper"* ]]
}

@test "capture antipattern fails when source missing" {
  run "$LOCAL_CLI" capture antipattern ghost
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]
}
