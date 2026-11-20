"""Spec for the API-proposal renderer.

The renderer, not the agent writing the proposal, decides what changed and what
breaks. An agent narrating its own diff can miss a removed field; a comparison
of the before/after field lists cannot. These tests pin that comparison.

Run: python3 -m unittest discover -s ~/.claude/skills/api-proposal
"""

import json
import unittest

import render


def field(name, *, type_="string", required=True, location="body", notes=""):
    return {"name": name, "in": location, "type": type_, "required": required, "notes": notes}


def changed_endpoint(*, input_before=(), input_after=(), output_before=(), output_after=(),
                     auth_before="content:write", auth_after="content:write"):
    def side(inputs, outputs, permission):
        return {
            "purpose": "Does a thing.",
            "tables": [{"table": "bylines", "access": "write"}],
            "input": {"fields": list(inputs)},
            "output": {"status": 200, "fields": list(outputs)},
            "auth": {"permission": permission, "who": "Editors"},
        }

    return {
        "change": "changed",
        "method": "PATCH",
        "path": "/bylines/:byline_id",
        "before": side(input_before, output_before, auth_before),
        "after": side(input_after, output_after, auth_after),
    }


def statuses(diff):
    return {row["name"]: row["status"] for row in diff}


class FieldDiffTest(unittest.TestCase):
    def test_a_field_only_in_after_is_added_and_only_in_before_is_removed(self):
        diff = render.diff_fields(before=[field("a"), field("b")], after=[field("b"), field("c")])
        self.assertEqual(statuses(diff), {"a": "removed", "b": "same", "c": "added"})

    def test_a_type_or_required_change_marks_the_field_changed(self):
        diff = render.diff_fields(
            before=[field("a", type_="string"), field("b", required=False)],
            after=[field("a", type_="uuid"), field("b", required=True)],
        )
        self.assertEqual(statuses(diff), {"a": "changed", "b": "changed"})

    def test_the_same_name_in_path_and_body_is_two_fields(self):
        # `id` in the URL and `id` in a body are different contracts.
        diff = render.diff_fields(
            before=[field("id", location="path")],
            after=[field("id", location="path"), field("id", location="body")],
        )
        self.assertEqual([row["status"] for row in diff], ["same", "added"])


class BreakingChangeTest(unittest.TestCase):
    def test_removing_an_output_field_breaks_readers(self):
        ep = changed_endpoint(output_before=[field("bio")], output_after=[])
        self.assertTrue(any("bio" in reason for reason in render.breaking_changes(ep)))

    def test_adding_an_optional_input_or_any_output_field_does_not_break(self):
        ep = changed_endpoint(
            input_after=[field("bio", required=False)],
            output_after=[field("bio")],
        )
        self.assertEqual(render.breaking_changes(ep), [])

    def test_a_new_required_input_breaks_existing_callers(self):
        ep = changed_endpoint(input_after=[field("kind", required=True)])
        self.assertEqual(len(render.breaking_changes(ep)), 1)

    def test_removing_an_input_field_breaks_callers_still_sending_it(self):
        # Tissue refuses unknown request fields, so a dropped input is a 400 for
        # every client that still sends it, not a silent no-op.
        ep = changed_endpoint(input_before=[field("legacy", required=False)])
        self.assertEqual(len(render.breaking_changes(ep)), 1)

    def test_a_permission_change_is_flagged(self):
        ep = changed_endpoint(auth_after="admin")
        self.assertTrue(any("permission" in reason for reason in render.breaking_changes(ep)))

    def test_a_removed_endpoint_always_breaks(self):
        ep = {"change": "removed", "method": "GET", "path": "/x", "before": {}}
        self.assertEqual(len(render.breaking_changes(ep)), 1)

    def test_author_supplied_breaking_notes_are_kept(self):
        # Semantic breaks (same shape, different meaning) are invisible to a
        # schema comparison, so the author can add them by hand.
        ep = changed_endpoint()
        ep["breaking_notes"] = ["`slug` now freezes after first publish"]
        self.assertEqual(render.breaking_changes(ep), ["`slug` now freezes after first publish"])


class ValidationTest(unittest.TestCase):
    def test_a_changed_endpoint_needs_both_sides(self):
        ep = changed_endpoint()
        del ep["before"]
        errors = render.validate({"title": "t", "summary": "s", "endpoints": [ep]})
        self.assertTrue(any("before" in e for e in errors))

    def test_an_unknown_change_kind_is_refused(self):
        errors = render.validate({"title": "t", "summary": "s",
                                  "endpoints": [{"change": "tweaked", "method": "GET", "path": "/"}]})
        self.assertTrue(any("tweaked" in e for e in errors))


class RenderTest(unittest.TestCase):
    def test_proposal_text_cannot_close_the_embedding_script_tag(self):
        proposal = {"title": "</script><b>x", "summary": "s", "endpoints": []}
        html = render.render(proposal=proposal, template="<script>__PROPOSAL_JSON__</script>")
        self.assertEqual(html.count("</script>"), 1)
        embedded = html[len("<script>"):-len("</script>")]
        self.assertEqual(json.loads(embedded)["title"], "</script><b>x")

    def test_a_diagram_is_placed_statically_and_escaped(self):
        # The viewer renders mermaid blocks present at load; one injected later
        # by page script would stay raw text.
        proposal = {"title": "t", "summary": "s", "endpoints": [],
                    "diagram": "graph LR\n  A-->B<x>"}
        html = render.render(proposal=proposal, template="__DIAGRAM_SECTION__")
        self.assertIn('<pre class="mermaid">', html)
        self.assertIn("A--&gt;B&lt;x&gt;", html)

    def test_no_diagram_leaves_no_section(self):
        html = render.render(proposal={"title": "t", "summary": "s", "endpoints": []},
                             template="[__DIAGRAM_SECTION__]")
        self.assertEqual(html, "[]")


if __name__ == "__main__":
    unittest.main()
