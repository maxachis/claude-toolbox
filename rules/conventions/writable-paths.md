# Writable Paths for User Data

## Rule

**Never hardcode relative paths for user data (databases, config, caches, logs).** Resolve them against the OS-provided user directories at startup, and create the directory if it doesn't exist.

## Why It Matters

Relative paths like `./app.db` or `./config.json` work in development and break in production. The failure mode depends on how the binary is launched:

- **Windows `.exe` in Program Files**: write-protected, silent failure or permission errors
- **Double-clicked from a file manager**: working directory is unpredictable (often the user's home, sometimes root)
- **System-started services / launchers**: CWD might be `/` or `C:\Windows\System32`
- **Desktop app bundles (macOS `.app`)**: CWD is the bundle internal path, not writable

In development you always launch from the project directory, so you never see this. Users hit it immediately.

## Per-Language Solutions

### Go

```go
configDir, err := os.UserConfigDir()   // ~/.config | %AppData% | ~/Library/Application Support
cacheDir, err := os.UserCacheDir()     // ~/.cache  | %LocalAppData% | ~/Library/Caches

appDir := filepath.Join(configDir, "myapp")
if err := os.MkdirAll(appDir, 0o755); err != nil {
    return err
}
dbPath := filepath.Join(appDir, "data.db")
```

### Python

```python
from platformdirs import user_config_dir, user_cache_dir
from pathlib import Path

app_dir = Path(user_config_dir("myapp"))
app_dir.mkdir(parents=True, exist_ok=True)
db_path = app_dir / "data.db"
```

### Node.js

```js
import envPaths from 'env-paths';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';

const paths = envPaths('myapp');
await mkdir(paths.data, { recursive: true });
const dbPath = path.join(paths.data, 'data.db');
```

### Rust

```rust
use directories::ProjectDirs;

let proj = ProjectDirs::from("com", "example", "myapp").unwrap();
std::fs::create_dir_all(proj.data_dir())?;
let db_path = proj.data_dir().join("data.db");
```

## Which Directory To Use

| Kind of data | Go | Python | Node | Notes |
|---|---|---|---|---|
| Config, user databases | `UserConfigDir` | `user_config_dir` | `paths.config` / `paths.data` | Persists across reboots; backed up |
| Rebuildable caches | `UserCacheDir` | `user_cache_dir` | `paths.cache` | OS may auto-clean |
| Logs | — (use `UserCacheDir` subdir) | `user_log_dir` | `paths.log` | |
| Ephemeral scratch | `os.TempDir` | `tempfile` | `os.tmpdir` | Wiped on reboot |

For small apps with one kind of data, `UserConfigDir` (or equivalent) is the right default.

## Anti-Patterns

- `./app.db` — breaks the moment CWD changes
- `~/app.db` — clutters home directory; doesn't follow OS conventions
- Hardcoded `/var/lib/myapp` — not cross-platform, requires root on first run
- `os.path.dirname(__file__)` — breaks when packaged (PyInstaller, py2app, etc.)
- Reading from an env var without a fallback — fine as an override, not as the primary path
