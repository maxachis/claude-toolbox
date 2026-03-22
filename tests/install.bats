#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "install delegates to setup.sh" {
  # Create a mock setup.sh that records it was called
  mock_setup="${TEST_TEMP}/mock-setup.sh"
  cat > "$mock_setup" << 'EOF'
#!/usr/bin/env bash
echo "SETUP_CALLED"
echo "ARGS=$*"
EOF
  chmod +x "$mock_setup"

  # Point the CLI at our mock
  export TOOLBOX_SETUP_SH="$mock_setup"
  run "$CLI" install
  [ "$status" -eq 0 ]
  [[ "$output" == *"SETUP_CALLED"* ]]
}

@test "install --skip-validation passes flag to setup.sh" {
  mock_setup="${TEST_TEMP}/mock-setup.sh"
  cat > "$mock_setup" << 'EOF'
#!/usr/bin/env bash
echo "ARGS=$*"
EOF
  chmod +x "$mock_setup"

  export TOOLBOX_SETUP_SH="$mock_setup"
  run "$CLI" install --skip-validation
  [ "$status" -eq 0 ]
  [[ "$output" == *"--skip-validation"* ]]
}

@test "uninstall delegates to setup.sh --unlink" {
  mock_setup="${TEST_TEMP}/mock-setup.sh"
  cat > "$mock_setup" << 'EOF'
#!/usr/bin/env bash
echo "ARGS=$*"
EOF
  chmod +x "$mock_setup"

  export TOOLBOX_SETUP_SH="$mock_setup"
  run "$CLI" uninstall
  [ "$status" -eq 0 ]
  [[ "$output" == *"--unlink"* ]]
}

@test "install --help shows install usage" {
  run "$CLI" install --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"install"* ]]
}
