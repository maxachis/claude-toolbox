#!/usr/bin/env bash
#
# cmd-install.sh — Install/uninstall delegation to setup.sh
#

cmd_install() {
  local action="$1"
  shift

  # Handle --help
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << EOF
Usage: claude-toolbox install [--skip-validation]
       claude-toolbox uninstall

install     Link toolbox components into ~/.claude/
            --skip-validation    Skip agent validation before linking

uninstall   Remove links and restore backups
EOF
    return 0
  fi

  local setup_sh="${TOOLBOX_SETUP_SH:-${TOOLBOX_ROOT}/setup.sh}"

  if [[ ! -x "$setup_sh" ]]; then
    error "setup.sh not found at ${setup_sh}"
    return 1
  fi

  case "$action" in
    install)
      "$setup_sh" "$@"
      ;;
    uninstall)
      "$setup_sh" --unlink "$@"
      ;;
  esac
}
