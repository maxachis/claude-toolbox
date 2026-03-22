#!/usr/bin/env bash
#
# common.sh — Shared functions for claude-toolbox CLI
#

# Colors (if terminal supports them)
if [ -t 1 ]; then
  GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
  BOLD='\033[1m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; BOLD=''; NC=''
fi

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; }

find_python() {
  for cmd in python3 python py; do
    if "$cmd" --version &>/dev/null; then
      echo "$cmd"
      return 0
    fi
  done
  return 1
}

is_link() {
  [[ -L "$1" ]] || [[ -h "$1" ]]
}

is_wsl() {
  [[ -f /proc/version ]] && grep -qi microsoft /proc/version 2>/dev/null
}

confirm() {
  local prompt="${1:-Continue?}"
  echo -n "$prompt [y/N] "
  read -r reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

# Insert a row into a markdown table in alphabetical order
# Usage: insert_table_row <file> <row> <sort_key>
insert_table_row() {
  local file="$1"
  local new_row="$2"
  local sort_key="$3"

  awk -v new_row="$new_row" -v sort_key="$sort_key" '
    BEGIN { inserted = 0; in_table = 0 }

    /^\|[-| ]+\|$/ {
      in_table = 1
      print
      next
    }

    in_table && /^\|/ {
      row_name = ""
      if (match($0, /`[^`]+`/)) {
        row_name = substr($0, RSTART+1, RLENGTH-2)
        gsub(/^\//, "", row_name)
      }

      if (!inserted && sort_key < row_name) {
        print new_row
        inserted = 1
      }
      print
      next
    }

    in_table && !/^\|/ {
      if (!inserted) {
        print new_row
        inserted = 1
      }
      in_table = 0
      print
      next
    }

    { print }

    END {
      if (!inserted) {
        print new_row
      }
    }
  ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# Remove a row from a markdown table by matching the name in backticks
# Usage: remove_table_row <file> <name>
remove_table_row() {
  local file="$1"
  local name="$2"

  awk -v name="$name" '
    /^\|/ && (index($0, "`" name "`") > 0 || index($0, "`/" name "`") > 0) {
      next
    }
    { print }
  ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}
