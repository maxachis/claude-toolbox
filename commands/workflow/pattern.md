# Pattern

Search, browse, and apply reusable code structure recipes from the toolbox.

## Arguments

- `$ARGUMENTS` — Optional: pattern name to view/apply, or a tag to filter by

## Instructions

1. If no arguments provided, list all available patterns:
   - Run `claude-toolbox list patterns` to show patterns with descriptions
   - Ask the user which pattern they'd like to view or apply

2. If a pattern name is given:
   - Run `claude-toolbox list patterns` and check if the name matches a pattern
   - If found, read the pattern file from the toolbox's `patterns/` directory
   - Display a summary of the pattern (description, tags, key sections)
   - Ask the user if they want to apply it to the project

3. If a tag is given (no exact pattern name match):
   - Run `claude-toolbox list patterns --tag <tag>` to filter patterns
   - Show matching patterns and let the user choose

4. To apply a pattern:
   - Run `claude-toolbox apply pattern <name>` to copy it to `.claude/patterns/`
   - Confirm the file was created successfully

5. If the user wants to see all tags:
   - Parse pattern files and collect unique tags
   - Display them as a list

## Output format

When listing patterns:
```
Available patterns:
  <name>    <description>    [tags]
```

When showing a pattern:
```
## <Pattern Name>
<description>
Tags: <tag1>, <tag2>

<key sections from the pattern>

Apply this pattern? (claude-toolbox apply pattern <name>)
```
