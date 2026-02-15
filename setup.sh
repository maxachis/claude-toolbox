#!/usr/bin/env bash
#
# setup.sh — Link claude-toolbox into ~/.claude/
#
# Usage:
#   ./setup.sh           # Link commands and skills
#   ./setup.sh --unlink  # Remove links and restore backups
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# Directories to link: toolbox_subdir -> ~/.claude/target_name
LINK_DIRS=("commands" "skills")

# Colors (if terminal supports them)
if [ -t 1 ]; then
  GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; NC=''
fi

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; }

is_link() {
  # Works for symlinks, junctions, and Git Bash's ln -s
  [[ -L "$1" ]] || [[ -h "$1" ]]
}

create_link() {
  local src="$1" dest="$2"

  if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* || "$OSTYPE" == win* ]]; then
    # Windows: use junctions via PowerShell (no admin required, handles spaces)
    local win_src win_dest
    win_src="$(cygpath -w "$src")"
    win_dest="$(cygpath -w "$dest")"
    powershell -NoProfile -Command \
      "New-Item -ItemType Junction -Path '${win_dest}' -Target '${win_src}'" > /dev/null
  else
    # macOS / Linux: standard symlink
    ln -s "$src" "$dest"
  fi
}

remove_link() {
  local dest="$1"

  if [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* || "$OSTYPE" == win* ]]; then
    # Windows junctions: remove the link without deleting target contents
    local win_dest
    win_dest="$(cygpath -w "$dest")"
    powershell -NoProfile -Command \
      "(Get-Item '${win_dest}').Delete()" > /dev/null
  else
    rm "$dest"
  fi
}

do_link() {
  mkdir -p "$CLAUDE_DIR"

  for dir in "${LINK_DIRS[@]}"; do
    local src="${SCRIPT_DIR}/${dir}"
    local dest="${CLAUDE_DIR}/${dir}"

    if [[ ! -d "$src" ]]; then
      warn "Skipping ${dir}/ — not found in toolbox"
      continue
    fi

    # Already linked to the right place
    if is_link "$dest" && [[ "$(readlink -f "$dest" 2>/dev/null || true)" == "$(readlink -f "$src" 2>/dev/null || true)" ]]; then
      info "${dir}/ already linked"
      continue
    fi

    # Back up existing directory
    if [[ -d "$dest" ]] && ! is_link "$dest"; then
      local backup="${dest}.backup.$(date +%Y%m%d%H%M%S)"
      warn "${dir}/ exists — backing up to ${backup##*/}"
      mv "$dest" "$backup"
    elif is_link "$dest"; then
      warn "${dir}/ is a stale link — removing"
      remove_link "$dest"
    fi

    create_link "$src" "$dest"
    info "${dir}/ linked"
  done

  echo ""
  info "Done! Your toolbox is linked to ${CLAUDE_DIR}"
}

do_unlink() {
  for dir in "${LINK_DIRS[@]}"; do
    local dest="${CLAUDE_DIR}/${dir}"

    if is_link "$dest"; then
      remove_link "$dest"
      info "${dir}/ unlinked"

      # Restore most recent backup if one exists
      local latest_backup
      latest_backup="$(ls -dt "${dest}.backup."* 2>/dev/null | head -1 || true)"
      if [[ -n "$latest_backup" ]]; then
        mv "$latest_backup" "$dest"
        info "${dir}/ restored from backup"
      fi
    else
      warn "${dir}/ is not a link — skipping"
    fi
  done

  echo ""
  info "Done! Links removed."
}

case "${1:-}" in
  --unlink)
    do_unlink
    ;;
  --help|-h)
    echo "Usage: $0 [--unlink]"
    echo ""
    echo "  (no args)   Link toolbox dirs into ~/.claude/"
    echo "  --unlink    Remove links and restore backups"
    ;;
  *)
    do_link
    ;;
esac
