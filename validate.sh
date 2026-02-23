#!/usr/bin/env bash
#
# validate.sh — Validate agent frontmatter in agents/ directory
#
# Usage:
#   ./validate.sh              # Validate all agents in agents/
#   ./validate.sh agents/      # Same (explicit path)
#   ./validate.sh path/to/dir  # Validate agents in a custom directory
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${1:-${SCRIPT_DIR}/agents}"

find_python() {
  for cmd in python3 python py; do
    if "$cmd" --version &>/dev/null; then
      echo "$cmd"
      return 0
    fi
  done
  return 1
}

PYTHON="$(find_python)" || {
  echo "Error: Python not found. Required for frontmatter validation."
  exit 1
}

echo "Validating agents in ${AGENTS_DIR}/"
echo ""

# Write Python validator to a temp file to avoid heredoc buffering issues
TMPSCRIPT="$(mktemp)"
trap 'rm -f "$TMPSCRIPT"' EXIT

cat > "$TMPSCRIPT" << 'PYEOF'
import sys, os, re

agents_dir = sys.argv[1]

REQUIRED_FIELDS = {"name", "description"}
KNOWN_FIELDS = {"name", "description", "tools", "model", "permissionMode"}
VALID_TOOLS = {
    "Read", "Write", "Edit", "Bash", "Glob", "Grep",
    "Task", "WebFetch", "WebSearch", "NotebookEdit",
}
VALID_MODELS = {"sonnet", "opus", "haiku", "inherit"}
VALID_PERMISSION_MODES = {"default", "acceptEdits", "dontAsk", "bypassPermissions", "plan"}
SKIP_FILES = {"_index.md", "README.md"}

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
NC = "\033[0m"

if not os.isatty(1):
    GREEN = YELLOW = RED = NC = ""


def pass_msg(msg):
    print(f"  {GREEN}PASS{NC} {msg}")


def fail_msg(msg):
    print(f"  {RED}FAIL{NC} {msg}")


def warn_msg(msg):
    print(f"  {YELLOW}WARN{NC} {msg}")


def parse_frontmatter(content):
    """Extract frontmatter fields from --- delimited block."""
    lines = content.split("\n")
    if not lines or lines[0].strip() != "---":
        return None

    fields = {}
    for i, line in enumerate(lines[1:], start=2):
        stripped = line.strip()
        if stripped == "---":
            return fields
        if ":" in stripped:
            key, _, value = stripped.partition(":")
            fields[key.strip()] = value.strip()

    # Never found closing ---
    return None


def validate_agent(filepath):
    """Validate a single agent file. Returns (errors, warnings)."""
    errors = []
    warnings = []
    filename = os.path.basename(filepath)
    expected_name = filename.removesuffix(".md")

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    fields = parse_frontmatter(content)
    if fields is None:
        errors.append("Missing or malformed frontmatter (must be delimited by ---)")
        return errors, warnings

    # Required fields
    for field in REQUIRED_FIELDS:
        if field not in fields:
            errors.append(f"Missing required field: {field}")

    # Name format
    name = fields.get("name", "")
    if name and not re.match(r"^[a-z][a-z0-9-]*$", name):
        errors.append(f"Invalid name format '{name}' — must be lowercase letters, digits, and hyphens")

    # Name matches filename
    if name and name != expected_name:
        errors.append(f"Name '{name}' does not match filename '{expected_name}'")

    # Tools validation
    tools_str = fields.get("tools", "")
    if tools_str:
        tools = [t.strip() for t in tools_str.split(",")]
        invalid_tools = [t for t in tools if t not in VALID_TOOLS]
        if invalid_tools:
            errors.append(f"Invalid tools: {', '.join(invalid_tools)} — valid: {', '.join(sorted(VALID_TOOLS))}")

    # Model validation
    model = fields.get("model", "")
    if model and model not in VALID_MODELS:
        errors.append(f"Invalid model '{model}' — valid: {', '.join(sorted(VALID_MODELS))}")

    # Permission mode validation
    perm = fields.get("permissionMode", "")
    if perm and perm not in VALID_PERMISSION_MODES:
        errors.append(f"Invalid permissionMode '{perm}' — valid: {', '.join(sorted(VALID_PERMISSION_MODES))}")

    # Unknown fields
    unknown = set(fields.keys()) - KNOWN_FIELDS
    if unknown:
        warnings.append(f"Unknown fields: {', '.join(sorted(unknown))}")

    return errors, warnings


# Collect agent files
md_files = sorted(
    f for f in os.listdir(agents_dir)
    if f.endswith(".md") and f not in SKIP_FILES
)

if not md_files:
    print("No agent files found.")
    sys.exit(0)

total_errors = 0
total_warnings = 0

for filename in md_files:
    filepath = os.path.join(agents_dir, filename)
    print(f"{filename}")
    errors, warnings = validate_agent(filepath)

    if errors:
        for e in errors:
            fail_msg(e)
        total_errors += len(errors)
    if warnings:
        for w in warnings:
            warn_msg(w)
        total_warnings += len(warnings)
    if not errors and not warnings:
        pass_msg("OK")

print("")
print(f"Validated {len(md_files)} agent(s): ", end="")
parts = []
if total_errors:
    parts.append(f"{RED}{total_errors} error(s){NC}")
if total_warnings:
    parts.append(f"{YELLOW}{total_warnings} warning(s){NC}")
if not total_errors and not total_warnings:
    parts.append(f"{GREEN}all passed{NC}")
print(", ".join(parts))

sys.exit(1 if total_errors else 0)
PYEOF

rc=0
"$PYTHON" "$TMPSCRIPT" "$AGENTS_DIR" || rc=$?
exit "$rc"
