#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "validate delegates to validate.sh" {
  mock_validate="${TEST_TEMP}/mock-validate.sh"
  cat > "$mock_validate" << 'EOF'
#!/usr/bin/env bash
echo "VALIDATE_CALLED"
echo "ARGS=$*"
EOF
  chmod +x "$mock_validate"

  export TOOLBOX_VALIDATE_SH="$mock_validate"
  run "$CLI" validate
  [ "$status" -eq 0 ]
  [[ "$output" == *"VALIDATE_CALLED"* ]]
}

@test "validate passes directory argument" {
  mock_validate="${TEST_TEMP}/mock-validate.sh"
  cat > "$mock_validate" << 'EOF'
#!/usr/bin/env bash
echo "ARGS=$*"
EOF
  chmod +x "$mock_validate"

  export TOOLBOX_VALIDATE_SH="$mock_validate"
  run "$CLI" validate /some/path
  [ "$status" -eq 0 ]
  [[ "$output" == *"/some/path"* ]]
}

@test "validate --help shows validate usage" {
  run "$CLI" validate --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"validate"* ]]
}
