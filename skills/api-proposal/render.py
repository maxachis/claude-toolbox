#!/usr/bin/env python3
"""Render an API-design proposal (JSON) into the standard review page (HTML).

The agent writes only the proposal JSON. This script owns everything that must
not depend on the agent's diligence: which fields were added, removed or
changed, and which of those changes break existing callers.

Usage: render.py <proposal.json> -o <out.html>   (stdlib only)
"""

import argparse
import html
import json
import sys
from pathlib import Path

TEMPLATE_PATH = Path(__file__).with_name("template.html")
TEMPLATE_SLOT = "__PROPOSAL_JSON__"
DIAGRAM_SLOT = "__DIAGRAM_SECTION__"

CHANGE_NEW = "new"
CHANGE_CHANGED = "changed"
CHANGE_REMOVED = "removed"
CHANGE_KINDS = (CHANGE_NEW, CHANGE_CHANGED, CHANGE_REMOVED)

FIELD_ADDED = "added"
FIELD_REMOVED = "removed"
FIELD_CHANGED = "changed"
FIELD_SAME = "same"

# The parts of a field that form the contract. `notes` is prose: a change to it
# shows as "changed" but never counts as breaking.
CONTRACT_KEYS = ("type", "required")
COMPARED_KEYS = CONTRACT_KEYS + ("notes",)

SIDES_BY_CHANGE = {
    CHANGE_NEW: ("after",),
    CHANGE_CHANGED: ("before", "after"),
    CHANGE_REMOVED: ("before",),
}


def _field_key(f):
    return (f.get("in", ""), f["name"])


def diff_fields(*, before, after):
    """Compare two field lists by (location, name), keeping `after`'s order."""
    before_by_key = {_field_key(f): f for f in before}
    after_keys = {_field_key(f) for f in after}
    rows = []
    for f in after:
        old = before_by_key.get(_field_key(f))
        if old is None:
            status = FIELD_ADDED
        elif any(old.get(k) != f.get(k) for k in COMPARED_KEYS):
            status = FIELD_CHANGED
        else:
            status = FIELD_SAME
        rows.append({"name": f["name"], "in": f.get("in", ""), "status": status,
                     "before": old, "after": f})
    for f in before:
        if _field_key(f) not in after_keys:
            rows.append({"name": f["name"], "in": f.get("in", ""), "status": FIELD_REMOVED,
                         "before": f, "after": None})
    return rows


def diff_tables(*, before, after):
    def key(t):
        return (t["table"], t["access"])

    old, new = {key(t) for t in before}, {key(t) for t in after}
    rows = [{**t, "status": FIELD_SAME if key(t) in old else FIELD_ADDED} for t in after]
    rows += [{**t, "status": FIELD_REMOVED} for t in before if key(t) not in new]
    return rows


def _contract_changed(row):
    return any(row["before"].get(k) != row["after"].get(k) for k in CONTRACT_KEYS)


def _input_breaks(row):
    label = f"input `{row['name']}` ({row['in']})"
    if row["status"] == FIELD_REMOVED:
        return f"{label} removed: callers still sending it are refused"
    if row["status"] == FIELD_ADDED and row["after"].get("required"):
        return f"{label} added as required: existing callers don't send it"
    if row["status"] == FIELD_CHANGED and _contract_changed(row):
        return f"{label} changed type or became required"
    return None


def _output_breaks(row):
    label = f"output `{row['name']}`"
    if row["status"] == FIELD_REMOVED:
        return f"{label} removed: readers relying on it break"
    if row["status"] == FIELD_CHANGED and _contract_changed(row):
        return f"{label} changed type or nullability"
    return None


def _section_fields(side, section):
    return side.get(section, {}).get("fields", [])


def breaking_changes(endpoint):
    """Every reason this endpoint change can break an existing caller."""
    reasons = []
    if endpoint["change"] == CHANGE_REMOVED:
        reasons.append("endpoint removed")
    elif endpoint["change"] == CHANGE_CHANGED:
        before, after = endpoint["before"], endpoint["after"]
        for section, judge in (("input", _input_breaks), ("output", _output_breaks)):
            rows = diff_fields(before=_section_fields(before, section),
                               after=_section_fields(after, section))
            reasons += [r for r in map(judge, rows) if r]
        old_perm = before.get("auth", {}).get("permission")
        new_perm = after.get("auth", {}).get("permission")
        if old_perm != new_perm:
            reasons.append(f"permission changed from `{old_perm}` to `{new_perm}`: "
                           "check every current caller still qualifies")
    return reasons + list(endpoint.get("breaking_notes", []))


def validate(proposal):
    errors = [f"missing top-level `{k}`" for k in ("title", "summary", "endpoints")
              if k not in proposal]
    for i, ep in enumerate(proposal.get("endpoints", [])):
        where = f"endpoints[{i}] {ep.get('method', '?')} {ep.get('path', '?')}"
        change = ep.get("change")
        if change not in CHANGE_KINDS:
            errors.append(f"{where}: change `{change}` is not one of {CHANGE_KINDS}")
            continue
        errors += [f"{where}: a `{change}` endpoint needs `{side}`"
                   for side in SIDES_BY_CHANGE[change] if side not in ep]
    return errors


def build_view(proposal):
    """The proposal plus everything computed from it, ready for the page."""
    endpoints = []
    for ep in proposal["endpoints"]:
        view = dict(ep)
        view["breaking"] = breaking_changes(ep)
        if ep["change"] == CHANGE_CHANGED:
            b, a = ep["before"], ep["after"]
            view["diff"] = {
                "input": diff_fields(before=_section_fields(b, "input"),
                                     after=_section_fields(a, "input")),
                "output": diff_fields(before=_section_fields(b, "output"),
                                      after=_section_fields(a, "output")),
                "tables": diff_tables(before=b.get("tables", []), after=a.get("tables", [])),
            }
        endpoints.append(view)
    return {**proposal, "endpoints": endpoints}


def _diagram_section(proposal):
    source = proposal.get("diagram")
    if not source:
        return ""
    caption = html.escape(proposal.get("diagram_caption", "How the endpoints touch the data"))
    return (f'<section class="diagram"><h2>{caption}</h2>'
            f'<pre class="mermaid">{html.escape(source, quote=False)}</pre></section>')


def render(*, proposal, template):
    payload = json.dumps(build_view(proposal), indent=1, ensure_ascii=False)
    # `<\/` is the same string to JSON but can never end the <script> it sits in.
    return (template
            .replace(DIAGRAM_SLOT, _diagram_section(proposal))
            .replace(TEMPLATE_SLOT, payload.replace("</", "<\\/")))


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("proposal", type=Path)
    parser.add_argument("-o", "--out", type=Path, required=True)
    args = parser.parse_args()
    proposal = json.loads(args.proposal.read_text())
    errors = validate(proposal)
    if errors:
        sys.exit("proposal is invalid:\n  " + "\n  ".join(errors))
    args.out.write_text(render(proposal=proposal, template=TEMPLATE_PATH.read_text()))
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()
