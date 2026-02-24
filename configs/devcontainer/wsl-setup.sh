#!/usr/bin/env bash
#
# wsl-setup.sh — Create symlinks from WSL home to Windows home for devcontainer mounts
#
# The devcontainer templates use ${localEnv:HOME}${localEnv:USERPROFILE} for
# mount sources. On WSL, this resolves to the WSL home (~), but credentials
# typically live under the Windows home (/mnt/c/Users/you). This script
# creates symlinks so the mounts resolve correctly.
#
# Usage:
#   ./wsl-setup.sh            # Auto-detect Windows home
#   ./wsl-setup.sh /mnt/c/Users/you   # Specify Windows home explicitly

set -euo pipefail

# Colors (if terminal supports them)
if [ -t 1 ]; then
  GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; NC=''
fi

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*" >&2; }

# --- Check WSL ---
if [[ ! -f /proc/version ]] || ! grep -qi microsoft /proc/version; then
  error "This script is intended for WSL only."
  exit 1
fi

# --- Determine Windows home ---
if [[ $# -ge 1 ]]; then
  WIN_HOME="$1"
else
  # Use cmd.exe to get the Windows USERPROFILE, then convert to WSL path
  WIN_USERPROFILE="$(cmd.exe /C "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')" || true
  if [[ -n "$WIN_USERPROFILE" ]]; then
    WIN_HOME="$(wslpath "$WIN_USERPROFILE")"
  else
    error "Could not detect Windows home. Pass it explicitly:"
    error "  $0 /mnt/c/Users/YourName"
    exit 1
  fi
fi

if [[ ! -d "$WIN_HOME" ]]; then
  error "Windows home not found: $WIN_HOME"
  exit 1
fi

info "WSL home:     $HOME"
info "Windows home: $WIN_HOME"
echo ""

# --- Files to symlink ---
TARGETS=(.ssh .claude .claude.json)
CREATED=0
SKIPPED=0

for target in "${TARGETS[@]}"; do
  src="${WIN_HOME}/${target}"
  dest="${HOME}/${target}"

  # Check if source exists on the Windows side
  if [[ ! -e "$src" ]]; then
    warn "Skipping ${target} — not found at ${src}"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Already a correct symlink
  if [[ -L "$dest" ]]; then
    existing="$(readlink "$dest")"
    if [[ "$existing" == "$src" ]]; then
      info "${target} — symlink already correct"
      SKIPPED=$((SKIPPED + 1))
      continue
    else
      warn "${target} — symlink exists but points to ${existing} (expected ${src})"
      warn "  Remove it manually and re-run if you want to update it"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
  fi

  # Real file/directory exists — don't clobber
  if [[ -e "$dest" ]]; then
    warn "${target} — real file/directory exists at ${dest}, skipping"
    warn "  Back it up and remove it if you want the symlink instead"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Create symlink
  ln -s "$src" "$dest"
  info "${target} — symlink created: ${dest} -> ${src}"
  CREATED=$((CREATED + 1))
done

echo ""
info "Done: ${CREATED} created, ${SKIPPED} skipped"
