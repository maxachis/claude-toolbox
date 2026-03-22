#!/usr/bin/env bats

load test_helper/common-setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "--help prints usage" {
  run "$CLI" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"claude-toolbox"* ]]
}

@test "-h prints usage" {
  run "$CLI" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version prints version" {
  run "$CLI" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "no arguments prints usage" {
  run "$CLI"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "unknown command exits 1" {
  run "$CLI" nonexistent
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command"* ]]
}

@test "help command prints usage" {
  run "$CLI" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "help lists all available commands" {
  run "$CLI" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"install"* ]]
  [[ "$output" == *"uninstall"* ]]
  [[ "$output" == *"status"* ]]
  [[ "$output" == *"validate"* ]]
  [[ "$output" == *"list"* ]]
  [[ "$output" == *"add"* ]]
  [[ "$output" == *"remove"* ]]
  [[ "$output" == *"devcontainer"* ]]
}
