# Prompts Folder Convention

Projects can keep a `prompts/` directory at the repo root to store reusable prompt files that Claude is expected to execute on demand (e.g., scaffolding tasks, recurring audits, structured refactors).

## Layout

```
prompts/
├── CLAUDE.md          # instructions for handling prompt files
├── archives/          # timestamped copies of executed prompts
└── <prompt-name>.md   # individual prompt files
```

## Guidelines

- Each prompt file is a self-contained markdown document describing a task for Claude to carry out.
- Name files by intent (`refactor-auth.md`, `audit-deps.md`), not by date — the archive handles history.
- Keep the root of `prompts/` limited to prompts that are still pending or actively reused.

## Archive on successful execution

After Claude successfully executes a prompt file from this directory:

1. Move the executed file into `prompts/archives/`.
2. Prepend a UTC timestamp in `YYYY-MM-DDTHHMMSSZ` format to the filename (e.g., `2026-04-18T143022Z_refactor-auth.md`).
3. Create `prompts/archives/` if it does not exist yet.

Only archive after the task has completed successfully. If execution fails or is aborted, leave the prompt file in place so it can be retried.

## Why

- Preserves a dated record of what was run and when, without polluting the active prompt list.
- Makes it obvious which prompts are still pending versus already applied.
- Avoids re-running prompts that have already done their job.
