#!/usr/bin/env bash
#
# cmd-audit.sh — Audit a codebase against the antipatterns/ catalog (mechanical tier)
#
# Runs each antipattern entry's `detect.grep` over its `detect.globs` with zero
# LLM cost. This is the cheap, deterministic, CI-friendly pass. Subtle entries
# that rely on `detect.heuristic` need the antipattern-auditor agent instead.
#
# Exit codes: 0 = clean, 1 = setup/usage error, 2 = candidate violations found.
#

cmd_audit() {
  if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    cat << 'EOF'
Usage: claude-toolbox audit [path] [--catalog <dir>] [--severity <low|medium|high>]

Audit a codebase against the antipatterns/ catalog (mechanical grep tier only).

Arguments:
  path                  Directory to audit (default: current directory)

Options:
  --catalog <dir>       Antipattern catalog directory. Default resolution order:
                          1. <path>/.claude/antipatterns/
                          2. the toolbox's antipatterns/
  --severity <level>    Only report entries at or above this severity
                        (low < medium < high; default: low)

Notes:
  Reports MECHANICAL CANDIDATES — grep matches, not confirmed findings. The
  judgment tier (false-positive suppression, heuristic-only antipatterns) needs
  the antipattern-auditor agent. Scope is first-party code; common vendored and
  build directories are skipped automatically.

Exit codes: 0 = clean, 1 = setup/usage error, 2 = candidate violations found.
EOF
    return 0
  fi

  local target="."
  local catalog=""
  local severity="low"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --catalog)  shift; catalog="${1:-}" ;;
      --severity) shift; severity="${1:-}" ;;
      -*) error "Unknown option: $1"; return 1 ;;
      *) target="$1" ;;
    esac
    shift
  done

  if [[ ! -d "$target" ]]; then
    error "Audit path not found: ${target}"
    return 1
  fi

  case "$severity" in
    low|medium|high) ;;
    *) error "Invalid --severity '${severity}'. Use low, medium, or high."; return 1 ;;
  esac

  # Resolve the catalog directory.
  if [[ -z "$catalog" ]]; then
    if [[ -d "${target}/.claude/antipatterns" ]]; then
      catalog="${target}/.claude/antipatterns"
    else
      catalog="${TOOLBOX_ROOT}/antipatterns"
    fi
  fi

  if [[ ! -d "$catalog" ]]; then
    error "Antipattern catalog not found at ${catalog}"
    return 1
  fi

  local python
  python="$(find_python)" || {
    error "Python not found. Required for the audit parser."
    return 1
  }

  local tmpscript
  tmpscript="$(mktemp)"
  trap 'rm -f "$tmpscript"' RETURN

  cat > "$tmpscript" << 'PYEOF'
import sys, os, re, itertools

catalog_dir, target, min_severity = sys.argv[1], sys.argv[2], sys.argv[3]

SKIP_FILES = {"_index.md", "README.md"}
SKIP_DIRS = {
    ".git", "node_modules", "vendor", "dist", "build", "out",
    ".venv", "venv", "__pycache__", ".next", ".cache", "target",
    "coverage", ".mypy_cache", ".pytest_cache",
}
SEVERITY_RANK = {"low": 0, "medium": 1, "high": 2}
min_rank = SEVERITY_RANK[min_severity]

GREEN = YELLOW = RED = BOLD = NC = ""
if os.isatty(1):
    GREEN, YELLOW, RED, BOLD, NC = (
        "\033[0;32m", "\033[0;33m", "\033[0;31m", "\033[1m", "\033[0m"
    )


def parse_frontmatter(path):
    """Extract id, severity, detect.grep, detect.globs from a catalog entry.

    Deliberately small: handles the flat top-level keys plus the one nested
    `detect:` block this catalog uses. Not a general YAML parser.
    """
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    m = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    if not m:
        return None
    body = m.group(1)

    entry = {"id": None, "severity": None, "grep": None, "globs": []}
    in_detect = False
    for line in body.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        indent = len(line) - len(line.lstrip())
        stripped = line.strip()

        if indent == 0:
            in_detect = stripped.rstrip() == "detect:"
            key, _, val = stripped.partition(":")
            val = val.strip()
            if key == "id":
                entry["id"] = val
            elif key == "severity":
                entry["severity"] = val
            continue

        if in_detect:
            key, _, val = stripped.partition(":")
            val = val.strip()
            if key == "grep":
                entry["grep"] = _unquote(val)
            elif key == "globs":
                entry["globs"] = _parse_inline_list(val)
    return entry


def _unquote(val):
    if len(val) >= 2 and val[0] == val[-1] and val[0] in "'\"":
        return val[1:-1]
    return val


def _parse_inline_list(val):
    val = val.strip()
    if val.startswith("[") and val.endswith("]"):
        val = val[1:-1]
    # Split on top-level commas only: commas inside brace groups (e.g. the
    # `{ts,js}` in a glob) or quotes are part of a single element.
    items, buf, depth, quote = [], [], 0, None
    for ch in val:
        if quote:
            if ch == quote:
                quote = None
            buf.append(ch)
        elif ch in "'\"":
            quote = ch
            buf.append(ch)
        elif ch in "{[(":
            depth += 1
            buf.append(ch)
        elif ch in "}])":
            depth -= 1
            buf.append(ch)
        elif ch == "," and depth == 0:
            items.append("".join(buf))
            buf = []
        else:
            buf.append(ch)
    items.append("".join(buf))
    return [_unquote(p.strip()) for p in items if p.strip()]


def expand_braces(pattern):
    """`a.{ts,js}` -> ['a.ts', 'a.js']. Handles multiple groups."""
    m = re.search(r"\{([^{}]*)\}", pattern)
    if not m:
        return [pattern]
    pre, post = pattern[: m.start()], pattern[m.end():]
    out = []
    for opt in m.group(1).split(","):
        out.extend(expand_braces(pre + opt + post))
    return out


def glob_to_regex(glob):
    """Translate a glob (with **, *, ?) to a full-match regex over a path."""
    out, i = [], 0
    while i < len(glob):
        c = glob[i]
        if glob[i:i + 3] == "**/":
            out.append("(?:.*/)?")
            i += 3
        elif glob[i:i + 2] == "**":
            out.append(".*")
            i += 2
        elif c == "*":
            out.append("[^/]*")
            i += 1
        elif c == "?":
            out.append("[^/]")
            i += 1
        else:
            out.append(re.escape(c))
            i += 1
    return re.compile("^" + "".join(out) + "$")


def matchers_for(globs):
    regexes = []
    for g in globs:
        for expanded in expand_braces(g):
            regexes.append(glob_to_regex(expanded))
    return regexes


def iter_files(root):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, root).replace(os.sep, "/")
            yield full, rel


# --- Load catalog entries ---
entries = []
for fname in sorted(os.listdir(catalog_dir)):
    if not fname.endswith(".md") or fname in SKIP_FILES:
        continue
    entry = parse_frontmatter(os.path.join(catalog_dir, fname))
    if not entry or not entry["id"]:
        continue
    if not entry["grep"]:
        # No mechanical signal — heuristic-only, belongs to the agent tier.
        continue
    sev = entry["severity"] or "low"
    if SEVERITY_RANK.get(sev, 0) < min_rank:
        continue
    try:
        entry["_re"] = re.compile(entry["grep"])
    except re.error as exc:
        print("%s[!]%s skipping '%s': bad grep regex (%s)" % (YELLOW, NC, entry["id"], exc))
        continue
    entry["_matchers"] = matchers_for(entry["globs"]) if entry["globs"] else None
    entries.append(entry)

if not entries:
    print("No auditable antipattern entries (with a detect.grep) in %s" % catalog_dir)
    sys.exit(0)

# --- Scan ---
# findings[severity] = list of (id, rel, lineno, text)
findings = []
files = list(iter_files(target))
for entry in entries:
    matchers = entry["_matchers"]
    rx = entry["_re"]
    for full, rel in files:
        if matchers is not None and not any(m.match(rel) for m in matchers):
            continue
        try:
            with open(full, encoding="utf-8", errors="replace") as fh:
                for lineno, line in enumerate(fh, 1):
                    if rx.search(line):
                        findings.append(
                            (entry["severity"] or "low", entry["id"], rel, lineno, line.rstrip("\n").strip())
                        )
        except (OSError, UnicodeDecodeError):
            continue

if not findings:
    print("%s[+]%s No antipattern candidates found in %s" % (GREEN, NC, target))
    sys.exit(0)

# --- Report, grouped by severity (high -> low) ---
order = {"high": 0, "medium": 1, "low": 2}
findings.sort(key=lambda f: (order.get(f[0], 3), f[1], f[2], f[3]))

sev_color = {"high": RED, "medium": YELLOW, "low": GREEN}
by_sev = {}
for sev, _id, rel, lineno, text in findings:
    by_sev[sev] = by_sev.get(sev, 0) + 1
    color = sev_color.get(sev, "")
    print("%s[%s]%s %s%s%s — %s:%d" % (color, sev, NC, BOLD, _id, NC, rel, lineno))
    print("    %s" % text)

ids = sorted({f[1] for f in findings})
summary = ", ".join("%s=%d" % (s, by_sev[s]) for s in ("high", "medium", "low") if s in by_sev)
print("")
print("%s%d candidate(s)%s across %d antipattern(s) [%s]" % (BOLD, len(findings), NC, len(ids), summary))
print("These are MECHANICAL matches — review for false positives, then run the")
print("antipattern-auditor agent for the judgment tier (suppression + heuristics).")
sys.exit(2)
PYEOF

  "$python" "$tmpscript" "$catalog" "$target" "$severity"
}
