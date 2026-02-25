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

### Step 4: Verify credential mounts

Before customizing the config, verify that the host paths the template will mount actually resolve to valid credentials. The devcontainer templates mount `~/.claude/`, `~/.claude.json`, and `~/.ssh/` from the host — if these paths are broken, the container will start with missing or wrong auth.

Run these checks:

1. **`~/.claude/` exists and is non-empty**: Check that the directory exists and contains files (at minimum, a `.credentials.json`). If missing or empty, warn the user.
2. **`~/.claude.json` exists**: Check that the file exists. If missing, note it (non-fatal — not all setups use it).
3. **WSL symlink check**: Detect if running under WSL (check `/proc/version` for `microsoft`). If so:
   - Check whether `~/.claude` is a symlink. If it is, verify the symlink target exists and is non-empty.
   - If `~/.claude` is a real directory (not a symlink) on WSL, warn that it may contain WSL-local credentials instead of Windows-side credentials. Suggest running `wsl-setup.sh` from `~/.claude/configs/devcontainer/`.
   - If `~/.claude` is a broken symlink, **stop and tell the user** — the mount will silently fail. Suggest re-running `wsl-setup.sh` or manually fixing the symlink.
4. **Active session credential match**: Compare the credentials the current Claude session is using against what the devcontainer mount will resolve to. Do this by running `sha256sum` on both:
   - **Session credentials**: Resolve the path the current process is actually using — `$(readlink -f ~/.claude/.credentials.json)`
   - **Mount-target credentials**: Simulate what `${localEnv:HOME}${localEnv:USERPROFILE}/.claude/.credentials.json` resolves to. On native Linux/macOS this is `$HOME/.claude/.credentials.json`. On WSL, `$HOME` is the WSL home — so resolve that path through symlinks too: `$(readlink -f $HOME/.claude/.credentials.json)`
   - If the hashes match, credentials are consistent — proceed.
   - If the hashes differ, **warn the user**: the container will receive different Claude credentials than this session is using. Show both resolved paths and ask whether to continue or abort.
   - If the mount-target file does not exist, **warn**: the container will start with no Claude credentials.
5. **Report findings**: Summarize what was found. If all checks pass, proceed silently. If any issues were found, list them as warnings and ask the user whether to continue or abort.

### Step 5: Customize

Apply these project-specific customizations to the copied file:

1. **Project name**: Replace `${projectName}` with the current directory name
2. **Post-create command**: Inspect the project and adjust:
   - Python: use `uv sync` if `uv.lock` exists, `pip install -r requirements.txt` if `requirements.txt` exists, `pip install -e '.[dev]'` if `pyproject.toml` exists
   - Node: use `pnpm install` if `pnpm-lock.yaml` exists, `bun install` if `bun.lockb` exists, otherwise `npm install`
   - Rust: keep `cargo build` as default
3. **Ports**: Scan source files for common port patterns (e.g., `PORT=`, `listen(`, `:8080`, `:3000`) and add discovered ports to `forwardPorts`
4. **Environment variables**: Check for `.env.example`, `.env.sample`, `.env.template`, or `.env` (in that precedence order) in the project root. If found:
   - Parse variable names from the file (lines matching `KEY=value` or `KEY=`)
   - Add non-secret variables (e.g., `NODE_ENV`, `DEBUG`, `LOG_LEVEL`, `APP_PORT`) to `containerEnv` in the devcontainer config with their default values
   - Omit likely secrets — variables whose names contain `SECRET`, `PASSWORD`, `TOKEN`, `API_KEY`, `PRIVATE_KEY`, or `CREDENTIAL`. Instead, leave a `// TODO: supply via .env file or secrets manager` comment listing the omitted names
   - If a `.env.example`, `.env.sample`, or `.env.template` exists, copy it to `.devcontainer/.env` and add `"runArgs": ["--env-file", ".devcontainer/.env"]` so the container loads it at runtime
   - If only a `.env` exists (no example/template file), do **not** copy it — warn the user that secrets should not be checked in, and suggest they create a `.devcontainer/.env` manually

### Step 6: Validate

Run `devcontainer read-configuration --workspace-folder .` to verify the generated config parses correctly. If the command fails, fix the JSON error and re-validate. If `devcontainer` is not installed, skip this step.

### Step 7: Report

Show the user:
- The path to the created file
- A summary of customizations applied (detected type, post-create command, forwarded ports, environment variables)
- Credential mount status (OK, warnings, or errors from Step 4)
- Suggested next steps: review the file, add additional extensions, supply any secret env vars

## Output Format

```
## Devcontainer Created

- **Type**: {detected type}
- **File**: .devcontainer/devcontainer.json
- **Post-create**: {command}
- **Ports**: {list or "none detected"}
- **Env vars**: {count added to containerEnv, count omitted as secrets, or "none detected"}
- **Env file**: {`.devcontainer/.env` copied from {source} | "not created — create manually"}
- **Credentials**: {OK — hashes match | MISMATCH — session uses {path_a}, mount resolves to {path_b} | MISSING — mount target has no .credentials.json}

### Next Steps
- Review `.devcontainer/devcontainer.json` and adjust as needed
- Supply secret env vars in `.devcontainer/.env` (see TODO comments in config)
- Run "Dev Containers: Reopen in Container" from VS Code
```
