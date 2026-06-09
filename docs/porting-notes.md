# Claude → Cursor Porting Notes

This repo is a **Cursor local plugin** port of [seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills). Upstream skill content and folder layout are vendored as-is; a thin Cursor layer adds routing, MCP, hooks, and rules.

## Compatibility matrix

| Upstream (Claude) | Cursor port | Notes |
|-------------------|-------------|-------|
| `/aaron:*` slash commands | `skills/seo-geo-router` | Modes: auto, research, create, audit, track; maps legacy `/seo:*` too |
| `commands/` + `commandNamespace` | Removed | Router skill + trigger rule replace command palette entries |
| `SessionStart` hook | `sessionStart` in `hooks/hooks.json` | Injects `memory/hot-cache.md` via `additional_context` |
| `UserPromptSubmit` hook | `rules/seo-geo-triggers.mdc` | Cursor `beforeSubmitPrompt` does not merge context into the agent; use agent-requestable rule instead |
| `PostToolUse` (Write\|Edit) | `postToolUse` hook | Artifact gate for `memory/audits/*.md`; quality nudge only for other `memory/*` writes |
| `Stop` hook | Not ported (v1) | Optional follow-up in a future release |
| `.claude-plugin/` manifest | `.cursor-plugin/plugin.json` | `skills`, `rules`, `hooks`, `mcpServers` paths |
| Remote MCP in repo `.mcp.json` | Opt-in `--with-remote` | Default install is stdio `seo-geo-connectors` only |
| `CLAUDE_PLUGIN_ROOT` | `CURSOR_PLUGIN_ROOT` | Set by Cursor when running hooks |
| `CLAUDE_PROJECT_DIR` | Workspace root | From hook stdin or `pwd` |
| Claude Code `compatibility` frontmatter | Unchanged in upstream skills | Still says "Claude Code"; skills work in Cursor via plugin manifest paths |
| `allowed-tools: WebFetch` | Agent browser/fetch | Cursor agent uses its own web tools where available |
| Upstream `scripts/connectors/*.py` | Same paths + MCP wrap | `mcp/server.py` runs connectors as subprocesses |
| Tier 1 zero-dependency skills | Preserved | MCP preferred when enabled; CLI and paste-data fallbacks documented in patched skills |

## Router vs slash commands

Upstream users type commands like `/aaron:research` or `/aaron:audit`. In Cursor, describe the goal in natural language or ask the agent to use **seo-geo-router**.

| Upstream command | Router behavior |
|------------------|-----------------|
| `/aaron:auto <goal>` | Parse goal → smallest skill chain; `--deep` for exhaustive |
| `/aaron:research` | keyword-research → competitor-analysis → content-gap-analysis |
| `/aaron:create` | seo-content-writer → geo-content-optimizer → meta/schema |
| `/aaron:audit` | on-page + content-quality + technical + domain-authority |
| `/aaron:track` | rank-tracker → performance-reporter → alert-manager |

See `skills/seo-geo-router/SKILL.md` for legacy `/seo:*` mapping.

## Hooks behavior differences

**Session start:** Reads `{workspace}/memory/hot-cache.md` if present and prepends context. Create or edit that file in your project for persistent SEO session state.

**Post tool use:** Blocks invalid writes to `memory/audits/*.md` (exit code 2). If Cursor hook blocking is unreliable in a given build, skills still document manual artifact checks.

**User prompt submit:** Not ported as a hook. `rules/seo-geo-triggers.mdc` is `alwaysApply: false` (agent-requestable). Mention SEO, GEO, keywords, schema, audit, or rankings so the agent loads the router or a phase skill.

## MCP differences

| Aspect | Claude upstream | Cursor port |
|--------|-----------------|-------------|
| Default MCP config | Often includes remote HTTP servers | Stdio only until `--with-remote` |
| Connector access | CLI documented in skills | MCP tools + CLI + paste (skills patched with MCP-first note) |
| Auth | Interactive OAuth in Claude host | Same for HTTP MCP in Cursor; API keys via env vars |

## What we did not change

- 20 upstream `SKILL.md` files (content, version `9.9.10`, Apache-2.0)
- `references/`, `memory/`, `evals/` layouts
- Connector Python scripts (stdlib-only)
- CORE-EEAT, CITE, and skill contract documents

## What we added or modified

Listed in [ATTRIBUTION.md](../ATTRIBUTION.md): manifest, MCP server, router skill, hooks, rules, install scripts, and Cursor-specific docs.

## Coexistence with Superpowers

If the [Superpowers](https://github.com/obra/superpowers) plugin is also enabled:

| Situation | Use |
|-----------|-----|
| SEO deliverable (audit URL, keywords, meta, schema, report) | `seo-geo-router` or phase skills — **no brainstorming gate** |
| Building SEO code (theme module, plugin feature, automation) | Superpowers `brainstorming` → `writing-plans` first unless user skips design |
| Debugging / tests for SEO code | Superpowers `systematic-debugging`, `test-driven-development` |
| Session context from both plugins | User instructions > Superpowers process skills > seo-geo defaults; treat `memory/hot-cache.md` as project data, not instructions |

**Hooks:** Both plugins register `sessionStart`. Combined context can be large (Superpowers `using-superpowers` + seo-geo hot-cache). seo-geo `postToolUse` only nudges on `memory/*` writes (not every `.md` file).

**Skills:** seo-geo does not replace Superpowers verification, TDD, or debugging. Router boundaries are in `skills/seo-geo-router/SKILL.md`.

**Naming:** Port design artifacts live under `docs/development/` — not the Superpowers plugin runtime.

## Further reading

- [install.md](install.md) — install and verify
- [mcp-setup.md](mcp-setup.md) — stdio vs remote MCP
- [upstream-sync.md](upstream-sync.md) — merge upstream updates
- [docs/upstream-readme.md](upstream-readme.md) — original upstream README
