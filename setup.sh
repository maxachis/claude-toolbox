#!/usr/bin/env bash
#
# setup.sh — Link claude-toolbox into ~/.claude/
#
# Usage:
#   ./setup.sh                    # Validate agents, then link
#   ./setup.sh --unlink           # Remove links and restore backups
#   ./setup.sh --skip-validation  # Link without validating agents
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# Directories to link: toolbox_subdir -> ~/.claude/target_name
LINK_DIRS=("commands" "skills" "agents")

# Settings file to merge into ~/.claude/settings.json
SETTINGS_SRC="${SCRIPT_DIR}/configs/settings/global.json"
SETTINGS_DEST="${CLAUDE_DIR}/settings.json"

# Global CLAUDE.md to link into ~/.claude/CLAUDE.md
CLAUDE_MD_SRC="${SCRIPT_DIR}/configs/CLAUDE.md"
CLAUDE_MD_DEST="${CLAUDE_DIR}/CLAUDE.md"

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

find_python() {
  # Try each candidate; verify it actually runs (Windows Store stubs exist but fail)
  for cmd in python3 python py; do
    if "$cmd" --version &>/dev/null; then
      echo "$cmd"
      return 0
    fi
  done
  return 1
}

merge_settings() {
  local src="$1" dest="$2"

  if [[ ! -f "$src" ]]; then
    warn "Settings source not found — skipping merge"
    return
  fi

  local py
  py="$(find_python)" || {
    warn "Python not found — skipping settings merge"
    return
  }

  # Back up existing settings before merge
  if [[ -f "$dest" ]]; then
    cp "$dest" "${dest}.backup.$(date +%Y%m%d%H%M%S)"
  fi

  "$py" - "$src" "$dest" << 'PYEOF'
import json, sys, os

def deep_merge(base, overlay):
    """Merge overlay into base. Arrays are unioned, objects merged recursively."""
    result = dict(base)
    for key, value in overlay.items():
        if key in result:
            if isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = deep_merge(result[key], value)
            elif isinstance(result[key], list) and isinstance(value, list):
                # Union: add items from overlay not already in base
                seen = set(json.dumps(item, sort_keys=True) for item in result[key])
                for item in value:
                    serialized = json.dumps(item, sort_keys=True)
                    if serialized not in seen:
                        result[key].append(item)
                        seen.add(serialized)
            else:
                result[key] = value
        else:
            result[key] = value
    return result

src_path, dest_path = sys.argv[1], sys.argv[2]

with open(src_path) as f:
    overlay = json.load(f)

if os.path.isfile(dest_path):
    with open(dest_path) as f:
        base = json.load(f)
else:
    base = {}

merged = deep_merge(base, overlay)

with open(dest_path, "w") as f:
    json.dump(merged, f, indent=2)
    f.write("\n")
PYEOF

  if [[ $? -eq 0 ]]; then
    info "settings.json merged"
  else
    error "Settings merge failed"
  fi
}

do_link() {
  # Validate agents before linking (unless --skip-validation)
  if [[ "${SKIP_VALIDATION:-}" != "1" ]]; then
    if [[ -x "${SCRIPT_DIR}/validate.sh" ]]; then
      if ! "${SCRIPT_DIR}/validate.sh"; then
        error "Agent validation failed — fix errors above before linking"
        error "Or run with --skip-validation to bypass"
        exit 1
      fi
      echo ""
    else
      warn "validate.sh not found — skipping agent validation"
    fi
  fi

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

  # Link global CLAUDE.md
  if [[ -f "$CLAUDE_MD_SRC" ]]; then
    if is_link "$CLAUDE_MD_DEST" && [[ "$(readlink -f "$CLAUDE_MD_DEST" 2>/dev/null || true)" == "$(readlink -f "$CLAUDE_MD_SRC" 2>/dev/null || true)" ]]; then
      info "CLAUDE.md already linked"
    else
      if [[ -f "$CLAUDE_MD_DEST" ]] && ! is_link "$CLAUDE_MD_DEST"; then
        local backup="${CLAUDE_MD_DEST}.backup.$(date +%Y%m%d%H%M%S)"
        warn "CLAUDE.md exists — backing up to ${backup##*/}"
        mv "$CLAUDE_MD_DEST" "$backup"
      elif is_link "$CLAUDE_MD_DEST"; then
        warn "CLAUDE.md is a stale link — removing"
        remove_link "$CLAUDE_MD_DEST"
      fi
      create_link "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
      info "CLAUDE.md linked"
    fi
  else
    warn "configs/CLAUDE.md not found — skipping"
  fi

  # Merge global settings
  merge_settings "$SETTINGS_SRC" "$SETTINGS_DEST"

  # On WSL, set up symlinks from WSL home to Windows home for devcontainer mounts
  local wsl_setup="${SCRIPT_DIR}/configs/devcontainer/wsl-setup.sh"
  if [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null; then
    echo ""
    if [[ -x "$wsl_setup" ]]; then
      info "WSL detected — running devcontainer WSL setup..."
      "$wsl_setup"
    else
      warn "WSL detected but wsl-setup.sh not found — skipping"
      warn "Devcontainer mounts may not resolve correctly. See configs/devcontainer/README.md"
    fi
  fi

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

  # Unlink CLAUDE.md
  if is_link "$CLAUDE_MD_DEST"; then
    remove_link "$CLAUDE_MD_DEST"
    info "CLAUDE.md unlinked"

    local latest_backup
    latest_backup="$(ls -dt "${CLAUDE_MD_DEST}.backup."* 2>/dev/null | head -1 || true)"
    if [[ -n "$latest_backup" ]]; then
      mv "$latest_backup" "$CLAUDE_MD_DEST"
      info "CLAUDE.md restored from backup"
    fi
  else
    warn "CLAUDE.md is not a link — skipping"
  fi

  echo ""
  info "Done! Links removed."
}

case "${1:-}" in
  --unlink)
    do_unlink
    ;;
  --skip-validation)
    SKIP_VALIDATION=1 do_link
    ;;
  --help|-h)
    echo "Usage: $0 [--unlink | --skip-validation]"
    echo ""
    echo "  (no args)            Validate agents, then link toolbox into ~/.claude/"
    echo "  --skip-validation    Link without validating agents"
    echo "  --unlink             Remove links and restore backups"
    ;;
  *)
    do_link
    ;;
esac
