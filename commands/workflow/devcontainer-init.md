# Devcontainer Init

Scaffold a `.devcontainer/devcontainer.json` for the current project by detecting the project type and copying the appropriate template.

## Arguments

- `$ARGUMENTS` - (Optional) Project type override: `python`, `node`, or `rust`. Auto-detected if omitted.

## Instructions

### Step 1: Check for existing config

Check if `.devcontainer/devcontainer.json` already exists in the project root. If it does, warn the user and ask whether to overwrite or abort.

### Step 2: Detect project type

If `$ARGUMENTS` specifies a type, use it. Otherwise detect from project files:

- `pyproject.toml` or `requirements.txt` → **python**
- `package.json` → **node**
- `Cargo.toml` → **rust**

If multiple indicators are found, prefer the one matching `$ARGUMENTS`, or ask the user. If no type can be determined, ask the user to specify one.

### Step 3: Copy template

Read the matching template from `~/.claude/configs/devcontainer/{type}.jsonc`. Create `.devcontainer/` in the project root and write the template as `.devcontainer/devcontainer.json`.

### Step 4: Customize

Apply these project-specific customizations to the copied file:

1. **Project name**: Replace `${projectName}` with the current directory name
2. **Post-create command**: Inspect the project and adjust:
   - Python: use `uv sync` if `uv.lock` exists, `pip install -r requirements.txt` if `requirements.txt` exists, `pip install -e '.[dev]'` if `pyproject.toml` exists
   - Node: use `pnpm install` if `pnpm-lock.yaml` exists, `bun install` if `bun.lockb` exists, otherwise `npm install`
   - Rust: keep `cargo build` as default
3. **Ports**: Scan source files for common port patterns (e.g., `PORT=`, `listen(`, `:8080`, `:3000`) and add discovered ports to `forwardPorts`

### Step 5: Validate

Run `devcontainer read-configuration --workspace-folder .` to verify the generated config parses correctly. If the command fails, fix the JSON error and re-validate. If `devcontainer` is not installed, skip this step.

### Step 6: Report

Show the user:
- The path to the created file
- A summary of customizations applied (detected type, post-create command, forwarded ports)
- Suggested next steps: review the file, add additional extensions, configure environment variables

## Output Format

```
## Devcontainer Created

- **Type**: {detected type}
- **File**: .devcontainer/devcontainer.json
- **Post-create**: {command}
- **Ports**: {list or "none detected"}

### Next Steps
- Review `.devcontainer/devcontainer.json` and adjust as needed
- Add environment variables via `containerEnv` or a `.env` file
- Run "Dev Containers: Reopen in Container" from VS Code
```
