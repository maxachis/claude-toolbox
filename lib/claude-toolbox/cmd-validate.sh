#!/usr/bin/env bash
#
# cmd-validate.sh — Validate delegation to validate.sh
#

cmd_validate() {
  # Handle --help
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox validate [directory]

Validate agent frontmatter in the agents/ directory.
Optionally pass a custom directory path.
EOF
    return 0
  fi

  local validate_sh="${TOOLBOX_VALIDATE_SH:-${TOOLBOX_ROOT}/validate.sh}"

  if [[ ! -x "$validate_sh" ]]; then
    error "validate.sh not found at ${validate_sh}"
    return 1
  fi

  "$validate_sh" "$@"
}
