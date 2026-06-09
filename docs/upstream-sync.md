# Upstream Sync

Pull updates from [aaron-he-zhu/seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) into this Cursor port. Upstream content is vendored by rsync (not a git submodule).

Current pin: see [ATTRIBUTION.md](../ATTRIBUTION.md).

## When to sync

- New upstream release (check upstream `SKILL.md` `version` fields or tags)
- Bug fixes in connector scripts or skill references
- New eval cases or memory templates you want in the port

After sync, re-apply Cursor-specific patches (MCP refs in skills) and re-test before committing.

## Sync procedure

### 1. Clone upstream (shallow)

```bash
cd /path/to/seo-geo-cursor
git clone --depth 1 https://github.com/aaron-he-zhu/seo-geo-claude-skills.git /tmp/seo-geo-upstream
```

Use a fresh temp path each time to avoid stale trees.

### 2. Rsync vendored directories

```bash
rsync -a /tmp/seo-geo-upstream/research/ ./research/
rsync -a /tmp/seo-geo-upstream/build/ ./build/
rsync -a /tmp/seo-geo-upstream/optimize/ ./optimize/
rsync -a /tmp/seo-geo-upstream/monitor/ ./monitor/
rsync -a /tmp/seo-geo-upstream/cross-cutting/ ./cross-cutting/
rsync -a /tmp/seo-geo-upstream/scripts/connectors/ ./scripts/connectors/
rsync -a /tmp/seo-geo-upstream/references/ ./references/
rsync -a /tmp/seo-geo-upstream/memory/ ./memory/
rsync -a /tmp/seo-geo-upstream/evals/ ./evals/
```

### 3. Copy root files that track upstream

```bash
cp /tmp/seo-geo-upstream/CONNECTORS.md ./CONNECTORS.md
cp /tmp/seo-geo-upstream/LICENSE ./LICENSE
cp /tmp/seo-geo-upstream/README.md ./docs/upstream-readme.md
cp /tmp/seo-geo-upstream/PRIVACY.md ./PRIVACY.md
cp /tmp/seo-geo-upstream/SECURITY.md ./SECURITY.md
```

**Do not overwrite** Cursor-only files:

- `.cursor-plugin/plugin.json`
- `skills/seo-geo-router/`
- `mcp/`, `hooks/`, `rules/`
- `scripts/setup.sh`, `install-to-cursor.sh`, `generate-mcp-config.sh`, `patch-skill-mcp-refs.sh`, `validate.sh`
- `docs/install.md`, `docs/mcp-setup.md`, `docs/porting-notes.md`, `docs/upstream-sync.md`

### 4. Re-merge CONNECTORS.md Cursor section

Upstream `CONNECTORS.md` may not include the Cursor MCP tools table. After `cp`, restore or re-add the **Cursor MCP tools (seo-geo-connectors)** section at the top if rsync overwrote your edits. Compare with git diff before committing.

### 5. Bump ATTRIBUTION.md

Record the new upstream version and commit hash:

```bash
cd /tmp/seo-geo-upstream
git rev-parse HEAD
# Read version from a SKILL.md frontmatter or upstream tag
```

Edit `ATTRIBUTION.md`:

```markdown
## Upstream Version

Imported: **vX.Y.Z** (commit `abcdef...` from /tmp/seo-geo-upstream)
```

### 6. Re-run skill MCP patch

Upstream skills reference CLI helpers only. Re-apply the Cursor MCP-first banner:

```bash
chmod +x scripts/patch-skill-mcp-refs.sh
./scripts/patch-skill-mcp-refs.sh
```

The script inserts **Cursor MCP (preferred)** before `**Zero-dependency local helper**` or `**Zero-dependency local helpers**` in any skill that uses `scripts/connectors/` and does not already mention `seo-geo-connectors`.

### 7. Verify

```bash
./scripts/validate.sh
python3 scripts/smoke-test-mcp.py
python3 scripts/connectors/onpage.py https://example.com | python3 -m json.tool | head -20
```

Confirm 20 upstream skills still exist:

```bash
find research build optimize monitor cross-cutting -name 'SKILL.md' | wc -l
# Expected: 20
```

### 8. Re-install locally (optional)

```bash
./scripts/install-to-cursor.sh
```

Reload Cursor (**Developer: Reload Window**).

### 9. Commit

```bash
git add research build optimize monitor cross-cutting scripts/connectors \
  references memory evals CONNECTORS.md LICENSE PRIVACY.md SECURITY.md \
  docs/upstream-readme.md ATTRIBUTION.md
git add -u optimize/  # if patch script modified skills
git commit -m "chore: sync upstream seo-geo-claude-skills vX.Y.Z"
```

## Conflict handling

| Area | Strategy |
|------|----------|
| Skill content | Prefer upstream; re-run `patch-skill-mcp-refs.sh` |
| CONNECTORS.md | Merge: keep upstream body + Cursor MCP section |
| `mcp/server.py` tool list | If upstream adds connectors, add matching MCP tools in `mcp/server.py` |
| Router / hooks / rules | Keep port versions unless upstream changes hook contracts |

## Version checklist

- [ ] ATTRIBUTION.md version + commit hash updated
- [ ] 20 `SKILL.md` files present
- [ ] `patch-skill-mcp-refs.sh` run (including plural "helpers" skills)
- [ ] `validate.sh` and `smoke-test-mcp.py` pass
- [ ] CONNECTORS.md Cursor section intact
- [ ] Local install tested after major connector changes

## Related docs

- [porting-notes.md](porting-notes.md) — what differs from Claude upstream
- [ATTRIBUTION.md](../ATTRIBUTION.md) — license and modification list
