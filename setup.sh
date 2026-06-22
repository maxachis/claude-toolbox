#!/usr/bin/env bash
#
# setup.sh — Link claude-toolbox into a Claude Code config dir
#
# Usage:
#   ./setup.sh                    # Validate agents, then link
#   ./setup.sh --unlink           # Remove links and restore backups
#   ./setup.sh --skip-validation  # Link without validating agents
#
# Which account(s) get synced:
#   - By default, the active account: $CLAUDE_CONFIG_DIR if set, else ~/.claude.
#   - Set TOOLBOX_ACCOUNTS to a colon-separated list of config dirs to sync
#     several accounts in one run, e.g.
#       TOOLBOX_ACCOUNTS="$HOME/.claude:$HOME/.claude-work" ./setup.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directories to link: toolbox_subdir -> <config dir>/target_name
LINK_DIRS=("commands" "skills" "agents" "configs")

# Account-independent sources. global.json is committed; global.local.json is a
# gitignored overlay for machine-specific / secret-bearing servers, merged on
# top. Sources are overridable via env for testing.
SETTINGS_SRC="${SCRIPT_DIR}/configs/settings/global.json"
MCP_SRC="${TOOLBOX_MCP_SRC:-${SCRIPT_DIR}/configs/mcp/global.json}"
MCP_LOCAL_SRC="${TOOLBOX_MCP_LOCAL_SRC:-${SCRIPT_DIR}/configs/mcp/global.local.json}"
CLAUDE_MD_SRC="${SCRIPT_DIR}/configs/CLAUDE.md"

# Per-account destination paths. set_account_paths recomputes these for each
# config dir being synced; the call below initializes them for the active
# account (and for tests that source this script to exercise its functions).
set_account_paths() {
  CLAUDE_DIR="$1"
  SETTINGS_DEST="${CLAUDE_DIR}/settings.json"
  CLAUDE_MD_DEST="${CLAUDE_DIR}/CLAUDE.md"
  # The big config file sits BESIDE the dir (~/.claude.json) for the default
  # account, but INSIDE the dir for any account selected via CLAUDE_CONFIG_DIR.
  if [[ "$CLAUDE_DIR" == "${HOME}/.claude" ]]; then
    MCP_DEST="${TOOLBOX_MCP_DEST:-${HOME}/.claude.json}"
  else
    MCP_DEST="${TOOLBOX_MCP_DEST:-${CLAUDE_DIR}/.claude.json}"
  fi
}

# Populate ACCOUNTS with the config dir(s) to sync. TOOLBOX_ACCOUNTS (a
# colon-separated list) wins; otherwise the single active account.
resolve_accounts() {
  if [[ -n "${TOOLBOX_ACCOUNTS:-}" ]]; then
    local IFS=':'
    read -ra ACCOUNTS <<< "$TOOLBOX_ACCOUNTS"
  else
    ACCOUNTS=("${CLAUDE_CONFIG_DIR:-${HOME}/.claude}")
  fi
}

set_account_paths "${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"

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

merge_json() {
  local src="$1" dest="$2" label="$3"

  if [[ ! -f "$src" ]]; then
    warn "${label} source not found — skipping merge"
    return
  fi

  local py
  py="$(find_python)" || {
    warn "Python not found — skipping ${label} merge"
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
    info "${label} merged"
  else
    error "${label} merge failed"
  fi
}

merge_mcp() {
  local src="$1" dest="$2"

  if [[ ! -f "$src" ]]; then
    warn "MCP config source not found — skipping merge"
    return
  fi

  local py
  py="$(find_python)" || {
    warn "Python not found — skipping MCP config merge"
    return
  }

  # Skip when no servers are defined, so we don't back up the (often large)
  # global ~/.claude.json just to merge an empty object into it.
  local has_servers
  has_servers="$("$py" -c 'import json,sys; print("1" if json.load(open(sys.argv[1])).get("mcpServers") else "0")' "$src" 2>/dev/null || echo 0)"
  if [[ "$has_servers" != "1" ]]; then
    info "MCP config has no servers — nothing to merge"
    return
  fi

  # Merge ONLY the mcpServers subtree, so source-only keys ($schema, _comment,
  # etc.) never pollute the global ~/.claude.json.
  local overlay
  overlay="$("$py" -c 'import json,sys,tempfile; servers=json.load(open(sys.argv[1])).get("mcpServers",{}); f=tempfile.NamedTemporaryFile("w",suffix=".json",delete=False); json.dump({"mcpServers":servers},f); f.close(); print(f.name)' "$src")"
  merge_json "$overlay" "$dest" "mcpServers"
  rm -f "$overlay"
}

# Warn when a toolbox-managed MCP server's stdio `command` is not on PATH, so a
# missing runtime (npx/uvx/etc.) surfaces at install time rather than as a
# silent "failed to connect" later. URL-only (remote) servers have no command
# and are skipped.
check_mcp_deps() {
  local py
  py="$(find_python)" || return

  # Emit "command<TAB>server1,server2" per distinct command across all sources.
  local rows
  rows="$("$py" - "$@" << 'PYEOF'
import json, sys
from collections import OrderedDict

cmd_servers = OrderedDict()
for path in sys.argv[1:]:
    try:
        with open(path) as f:
            servers = json.load(f).get("mcpServers", {})
    except (FileNotFoundError, ValueError):
        continue
    for name, cfg in servers.items():
        cmd = cfg.get("command")
        if cmd:
            cmd_servers.setdefault(cmd, []).append(name)

for cmd, names in cmd_servers.items():
    print(cmd + "\t" + ",".join(names))
PYEOF
)"

  while IFS=$'\t' read -r cmd servers; do
    [[ -z "$cmd" ]] && continue
    if ! command -v "$cmd" > /dev/null 2>&1; then
      warn "MCP runtime '${cmd}' not found on PATH — server(s) [${servers}] won't start until it's installed"
    fi
  done <<< "$rows"
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
  merge_json "$SETTINGS_SRC" "$SETTINGS_DEST" "settings.json"

  # Merge global MCP servers into ~/.claude.json, then layer the optional
  # gitignored local overlay (secret-bearing / machine-specific servers) on top.
  merge_mcp "$MCP_SRC" "$MCP_DEST"
  if [[ -f "$MCP_LOCAL_SRC" ]]; then
    merge_mcp "$MCP_LOCAL_SRC" "$MCP_DEST"
  fi
  check_mcp_deps "$MCP_SRC" "$MCP_LOCAL_SRC"

  # Link toolbox root into ~/.claude/toolbox (used by devcontainer mounts)
  local toolbox_link="${CLAUDE_DIR}/toolbox"
  if is_link "$toolbox_link" && [[ "$(readlink -f "$toolbox_link" 2>/dev/null || true)" == "$(readlink -f "$SCRIPT_DIR" 2>/dev/null || true)" ]]; then
    info "toolbox/ already linked"
  else
    if is_link "$toolbox_link"; then
      remove_link "$toolbox_link"
    elif [[ -d "$toolbox_link" ]]; then
      warn "toolbox/ exists and is not a symlink — skipping"
    fi
    if [[ ! -e "$toolbox_link" ]]; then
      create_link "$SCRIPT_DIR" "$toolbox_link"
      info "toolbox/ linked (for devcontainer CLI access)"
    fi
  fi

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

  # Symlink CLI into ~/.local/bin/
  local cli_src="${SCRIPT_DIR}/bin/claude-toolbox"
  local cli_dest="${HOME}/.local/bin/claude-toolbox"
  if [[ -x "$cli_src" ]]; then
    mkdir -p "${HOME}/.local/bin"
    if is_link "$cli_dest" && [[ "$(readlink -f "$cli_dest" 2>/dev/null || true)" == "$(readlink -f "$cli_src" 2>/dev/null || true)" ]]; then
      info "CLI already linked"
    else
      if is_link "$cli_dest"; then
        remove_link "$cli_dest"
      elif [[ -f "$cli_dest" ]]; then
        warn "CLI exists at ${cli_dest} — overwriting"
        rm "$cli_dest"
      fi
      create_link "$cli_src" "$cli_dest"
      info "CLI linked to ${cli_dest}"
    fi
    # Warn if ~/.local/bin is not on PATH
    if [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
      warn "~/.local/bin is not on your PATH — add it to your shell profile"
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

  # Unlink CLI
  local cli_dest="${HOME}/.local/bin/claude-toolbox"
  if is_link "$cli_dest"; then
    remove_link "$cli_dest"
    info "CLI unlinked"
  fi

  # Unlink toolbox root
  local toolbox_link="${CLAUDE_DIR}/toolbox"
  if is_link "$toolbox_link"; then
    remove_link "$toolbox_link"
    info "toolbox/ unlinked"
  fi

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

# Run an action (do_link / do_unlink) once per configured account, recomputing
# the per-account destination paths each time. With a single account this is a
# transparent pass-through; with several it prints a header before each.
run_for_accounts() {
  local action="$1"
  resolve_accounts

  local multi=0
  [[ ${#ACCOUNTS[@]} -gt 1 ]] && multi=1

  local account
  for account in "${ACCOUNTS[@]}"; do
    set_account_paths "$account"
    if [[ $multi -eq 1 ]]; then
      echo ""
      info "════ Account: ${account} ════"
    fi
    "$action"
  done
}

# Only dispatch when executed directly; when sourced (e.g. by tests), expose the
# functions above without running anything.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    --unlink)
      run_for_accounts do_unlink
      ;;
    --skip-validation)
      SKIP_VALIDATION=1 run_for_accounts do_link
      ;;
    --help|-h)
      echo "Usage: $0 [--unlink | --skip-validation]"
      echo ""
      echo "  (no args)            Validate agents, then link toolbox into the active config dir"
      echo "  --skip-validation    Link without validating agents"
      echo "  --unlink             Remove links and restore backups"
      echo ""
      echo "Account selection:"
      echo "  By default targets \$CLAUDE_CONFIG_DIR (or ~/.claude). Set TOOLBOX_ACCOUNTS"
      echo "  to a colon-separated list of config dirs to sync several at once, e.g.:"
      echo "    TOOLBOX_ACCOUNTS=\"\$HOME/.claude:\$HOME/.claude-work\" $0"
      ;;
    *)
      run_for_accounts do_link
      ;;
  esac
fi
