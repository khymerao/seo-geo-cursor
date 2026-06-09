# Install Guide

Install the **SEO & GEO Skills** Cursor local plugin from a git clone. The installer copies real files into `~/.cursor/plugins/local/` (symlinks are not supported).

## Prerequisites

- **Cursor** desktop app (recent build with local plugins and MCP support)
- **Git**
- **Python ≥ 3.11** (for the stdio MCP connector server)
- **bash** and **rsync** (macOS/Linux; WSL on Windows)

## Quick install

```bash
git clone git@github.com:khymerao/seo-geo-cursor.git
cd seo-geo-cursor
chmod +x scripts/*.sh hooks/*
./scripts/setup.sh
./scripts/install-to-cursor.sh
```

HTTPS clone works the same:

```bash
git clone https://github.com/khymerao/seo-geo-cursor.git
```

### What each step does

| Step | Purpose |
|------|---------|
| `chmod +x scripts/*.sh hooks/*` | Makes setup, install, validate, and hook scripts executable |
| `./scripts/setup.sh` | Creates `mcp/.venv`, installs FastMCP deps, generates `.mcp.json` (stdio only) |
| `./scripts/install-to-cursor.sh` | Runs `validate.sh`, rsync-copies the plugin to `~/.cursor/plugins/local/seo-geo-cursor/`, re-runs setup in the install target |

## Reload Cursor

After install, reload the window so Cursor picks up the new local plugin:

1. **Command Palette** → **Developer: Reload Window**

Or restart Cursor.

## Verify installation

### 1. Validation (terminal)

From the repo (or installed copy):

```bash
./scripts/validate.sh
python3 scripts/smoke-test-mcp.py
```

Expected: `Validation passed.` and MCP smoke tests report `OK`.

### 2. Plugin load (Cursor UI)

1. **View → Output**
2. Select **Cursor Plugins** in the channel dropdown
3. Look for `loadUserLocalPlugins` with **1 plugins loaded** (or similar success line)

### 3. Plugin settings

**Settings → Plugins** → confirm **SEO & GEO Skills** appears and is enabled.

### 4. MCP server

**Settings → Tools & MCP** → enable **`seo-geo-connectors`** (stdio server).

If it is missing, run `./scripts/setup.sh` again from the installed directory:

```bash
~/.cursor/plugins/local/seo-geo-cursor/scripts/setup.sh
```

Then reload the window.

### 5. Smoke prompt (optional)

In Agent chat, try:

> Research keywords for B2B SaaS onboarding

The agent should load `seo-geo-router` or `keyword-research` (see [porting notes](porting-notes.md)).

## Development workflow

Edit files in your git clone, then re-install:

```bash
./scripts/install-to-cursor.sh
```

Reload Window after each install. Cursor does not hot-reload local plugin changes.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Plugin not listed in **Settings → Plugins** | Install not copied or window not reloaded | Run `./scripts/install-to-cursor.sh`, then **Developer: Reload Window** |
| Output shows 0 plugins loaded | Symlinked plugin path | Do not symlink into `~/.cursor/plugins/local/`; use `install-to-cursor.sh` (real copy) |
| `Plugin root is a symlink` from validate | Repo or target is a symlink | Clone to a normal directory; installer copies to a real path |
| `Script not executable` warning | Missing `chmod` | `chmod +x scripts/*.sh hooks/*` |
| `Python >= 3.11 is required` | Old Python default | Install Python 3.11+; ensure `python3 --version` ≥ 3.11 |
| `Missing venv. Run setup.sh` | MCP venv not built | `./scripts/setup.sh` |
| `.mcp.json not generated` | Setup skipped or failed | `./scripts/setup.sh`; check `mcp/.venv` exists |
| `seo-geo-connectors` missing in **Tools & MCP** | MCP disabled or stale install | Re-run install + setup; reload window; enable server in settings |
| MCP tools fail at runtime | Wrong cwd or broken venv | Run from plugin root; reinstall with `install-to-cursor.sh` |
| `/add-plugin` does nothing | Local plugins are not Marketplace plugins | Use git clone + `install-to-cursor.sh` only |
| Hooks not firing | Hooks channel errors | **Output → Hooks**; confirm `hooks/hooks.json` valid (`validate.sh`) |
| Skills not suggested | Rules are agent-requestable | Mention SEO/GEO terms or ask to use `seo-geo-router` |

## Uninstall

```bash
rm -rf ~/.cursor/plugins/local/seo-geo-cursor
```

Reload Cursor. Your git clone is unaffected.

## Next steps

- [MCP setup](mcp-setup.md) — stdio connectors vs optional remote HTTP servers
- [Porting notes](porting-notes.md) — differences from upstream Claude plugin
- [Upstream sync](upstream-sync.md) — pull new versions from seo-geo-claude-skills
