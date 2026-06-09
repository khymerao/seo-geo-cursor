# SEO & GEO Cursor Plugin — Design Spec

**Date:** 2026-06-09  
**Status:** Approved  
**Repository:** [khymerao/seo-geo-cursor](https://github.com/khymerao/seo-geo-cursor)  
**Upstream:** [aaron-he-zhu/seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) v9.9.10 (Apache-2.0)

## Summary

Port the upstream SEO/GEO Claude plugin into a **Cursor local plugin** using the [khymerao/cursor-plugin](https://github.com/khymerao/cursor-plugin) boilerplate. Preserve upstream skill content and folder layout (vendor as-is). Add a Cursor-specific layer: stdio MCP connector tools, router skill (replaces slash commands), ported hooks, trigger rules, and opt-in remote HTTP MCP.

## Goals

1. Make all 20 upstream skills usable in Cursor via local plugin install.
2. Expose bundled Python connectors as MCP tools (Tier 1, zero paid deps).
3. Support optional remote HTTP MCP (Ahrefs, Semrush, etc.) via `--with-remote`.
4. Replace `/aaron:*` commands with a router skill + trigger rule.
5. Port memory and artifact-gate hooks to Cursor hook events.
6. Document install, MCP setup, upstream sync, and Claude→Cursor differences.

## Non-Goals

- Publishing to Cursor Marketplace (local plugin only).
- Rewriting skill methodology or CORE-EEAT/CITE frameworks.
- Building proprietary SEO data APIs (use upstream connectors + optional remote MCP).
- Git submodule of upstream (direct vendor copy with sync docs instead).

## Decisions Log

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | **C** — full port + stdio MCP | User requires MCP; maximum feature parity |
| Remote MCP | **Opt-in** (`--with-remote`) | Avoid failed connections and Settings noise at install |
| Repo | `khymerao/seo-geo-cursor` | User choice |
| Folder layout | **Vendor as-is** | Preserve references, memory paths, minimal skill edits |
| Commands | **Router skill** | Cursor has no `commands` manifest key |
| License | **Apache-2.0** | Upstream license; ATTRIBUTION.md required |

## Architecture

```
seo-geo-cursor/
├── .cursor-plugin/plugin.json
├── mcp/
│   ├── server.py              # FastMCP: 12 connector tools
│   └── requirements.txt
├── hooks/
│   ├── hooks.json
│   ├── session-start          # hot-cache injection
│   └── post-tool-use          # artifact gate + quality nudge
├── rules/
│   └── seo-geo-triggers.mdc
├── skills/
│   └── seo-geo-router/        # replaces /aaron:* commands
├── research/ build/ optimize/ monitor/ cross-cutting/   # upstream skills
├── scripts/connectors/        # upstream Python stdlib CLIs
├── references/ memory/ evals/
├── docs/
│   ├── install.md
│   ├── mcp-setup.md
│   ├── porting-notes.md
│   └── upstream-sync.md
├── scripts/
│   ├── setup.sh
│   ├── generate-mcp-config.sh   # [--with-remote]
│   ├── install-to-cursor.sh
│   └── validate.sh
└── ATTRIBUTION.md
```

### Data Flow

```
User prompt
  → rules/seo-geo-triggers.mdc (keyword routing)
  → skills/seo-geo-router (intent → mode chain)
  → phase skill (research|build|optimize|monitor|cross-cutting)
  → MCP tool (seo-geo-connectors) OR CLI fallback
  → optional remote HTTP MCP (Tier 2/3, user-enabled)
  → deliverable + memory/hot-cache.md update
```

## Cursor Manifest

```json
{
  "name": "seo-geo-cursor",
  "displayName": "SEO & GEO Skills",
  "version": "1.0.0",
  "description": "20 SEO/GEO skills, connector MCP, CORE-EEAT + CITE for Cursor",
  "skills": [
    "./skills/seo-geo-router",
    "./research/keyword-research",
    "./research/competitor-analysis",
    "./research/serp-analysis",
    "./research/content-gap-analysis",
    "./build/seo-content-writer",
    "./build/geo-content-optimizer",
    "./build/meta-tags-optimizer",
    "./build/schema-markup-generator",
    "./optimize/on-page-seo-auditor",
    "./optimize/technical-seo-checker",
    "./optimize/internal-linking-optimizer",
    "./optimize/content-refresher",
    "./monitor/rank-tracker",
    "./monitor/backlink-analyzer",
    "./monitor/performance-reporter",
    "./monitor/alert-manager",
    "./cross-cutting/content-quality-auditor",
    "./cross-cutting/domain-authority-auditor",
    "./cross-cutting/entity-optimizer",
    "./cross-cutting/memory-management"
  ],
  "rules": "./rules/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**Removed from upstream:** `commands`, `commandNamespace`.  
**Added:** `seo-geo-router` skill, Cursor hooks/rules.

## MCP Layer

### Default (stdio only)

After `./scripts/setup.sh`, `generate-mcp-config.sh` writes:

```json
{
  "mcpServers": {
    "seo-geo-connectors": {
      "type": "stdio",
      "command": "<abs>/mcp/.venv/bin/python",
      "args": ["<abs>/mcp/server.py"]
    }
  }
}
```

### Opt-in remote (`--with-remote`)

Appends 14 HTTP MCP servers from upstream `.mcp.json`:

- **SEO data:** ahrefs, semrush, se-ranking, sistrix, similarweb
- **Infra/CMS/CRM:** cloudflare, vercel, hubspot, amplitude, notion, webflow, sanity, contentful, slack

Document OAuth/API key setup in `docs/mcp-setup.md`. Remote servers are never required for Tier 1 operation.

### FastMCP Tools

Each tool invokes `scripts/connectors/<script>.py` via subprocess, returns JSON stdout or structured error.

| Tool | Script | Notes |
|------|--------|-------|
| `crawl_site` | crawl.py | max_pages, max_depth |
| `onpage_audit` | onpage.py | |
| `check_robots` | robots.py | check_ai_bots flag |
| `fetch_sitemap` | sitemap.py | limit |
| `link_graph` | linkgraph.py | accepts crawl JSON |
| `page_speed` | psi.py | optional API key |
| `schema_lint` | schema_lint.py | |
| `wikidata_entity` | kg.py | search/entity/reconcile |
| `wayback_history` | wayback.py | |
| `domain_authority` | openpagerank.py | requires free key |
| `keyword_suggest` | suggest.py | unofficial endpoint |
| `rss_monitor` | rss_monitor.py | |

### Skill Integration Pattern

In each skill's Data Sources section, prefer:

1. `CallMcpTool seo-geo-connectors <tool>` when MCP enabled
2. `python3 scripts/connectors/<script>.py` as CLI fallback
3. User-pasted data (Tier 1 manual mode) when neither available

## Router Skill (Commands Replacement)

`skills/seo-geo-router/SKILL.md` ports logic from `commands/auto.md`, `research.md`, `create.md`, `audit.md`, `track.md`.

| Upstream command | Router behavior |
|------------------|-----------------|
| `/aaron:auto <goal>` | Parse goal → smallest skill chain; `--deep` for exhaustive |
| `/aaron:research` | keyword-research → competitor-analysis → content-gap-analysis |
| `/aaron:create` | seo-content-writer → geo-content-optimizer → meta/schema |
| `/aaron:audit` | on-page + content-quality + technical + domain-authority |
| `/aaron:track` | rank-tracker → performance-reporter → alert-manager |

Router applies risk gates from `references/aaron-product-api-contract.md`. Legacy `/seo:*` commands map to new routes (documented in router skill).

## Hooks Port

| Claude (upstream) | Cursor (this plugin) | Notes |
|-------------------|----------------------|-------|
| `SessionStart` | `sessionStart` | Read `{workspace}/memory/hot-cache.md`, inject `additional_context` |
| `UserPromptSubmit` | **rule** (not hook) | Cursor `beforeSubmitPrompt` does not merge context into agent |
| `PostToolUse` Write\|Edit | `postToolUse` | Artifact gate for `memory/audits/*.md`; quality nudge for content files |
| `Stop` | `stop` (optional) | Low priority v1 |

Environment variables:
- `CLAUDE_PLUGIN_ROOT` → `CURSOR_PLUGIN_ROOT`
- `CLAUDE_PROJECT_DIR` → workspace root from hook stdin or `pwd`

Hook output format follows Cursor hooks spec (`additional_context`, `continue`, exit 2 to block).

## Rules

`rules/seo-geo-triggers.mdc` — agent-requestable (`alwaysApply: false`):

- Trigger terms: SEO, GEO, keyword research, schema markup, audit, rank tracking, etc.
- Instruct agent to load `seo-geo-router` or specific phase skill.
- Tier 1 fallback: use MCP connectors or CLI when no remote MCP connected.
- Reference `CONNECTORS.md` for data source tiers.

## Documentation

| File | Purpose |
|------|---------|
| `README.md` | Quick start: clone → setup → install → reload |
| `docs/install.md` | Full install, validate, troubleshoot |
| `docs/mcp-setup.md` | stdio default; `--with-remote`; API keys |
| `docs/porting-notes.md` | Claude vs Cursor compatibility matrix |
| `docs/upstream-sync.md` | How to pull updates from upstream |
| `docs/upstream-readme.md` | Preserved upstream README |
| `ATTRIBUTION.md` | Apache-2.0 credit, list of modifications |
| `CONNECTORS.md` | Updated: MCP tools + CLI + remote MCP tiers |

## Implementation Commits (planned order)

1. `chore: initial plugin scaffold` (boilerplate)
2. `feat: import upstream seo-geo-claude-skills v9.9.10`
3. `feat: add Cursor manifest and router skill`
4. `feat: add stdio MCP connector tools`
5. `feat: port Claude hooks to Cursor hooks`
6. `feat: add trigger rules and MCP-first skill references`
7. `docs: add install, MCP setup, porting notes`
8. `test: add validate and MCP smoke test`

## Testing

| Check | Method |
|-------|--------|
| Manifest valid | `./scripts/validate.sh` |
| MCP health | `smoke-test-mcp.py` — ping + `onpage_audit` on example.com |
| Plugin load | Reload Window → Output → Cursor Plugins |
| MCP listed | Settings → Tools & MCP → seo-geo-connectors |
| Hooks | Output → Hooks; sessionStart injects hot-cache |
| Skill routing | Prompt: "Research keywords for SaaS" → keyword-research |
| Router | Prompt: "Audit https://example.com" → audit chain |
| Artifact gate | Write invalid `memory/audits/*.md` → postToolUse blocks |
| Remote MCP | `generate-mcp-config.sh --with-remote` → HTTP servers in `.mcp.json` |

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Cursor rejects skills array paths | Test on install; flatten to `skills/` if needed |
| `postToolUse` block unsupported | Document fallback; rule-based gate in skill |
| MCP tool timeout on large crawls | Default low max_pages; document limits |
| Upstream drift | `docs/upstream-sync.md` + version pin in ATTRIBUTION |
| Apache-2.0 compliance | Keep LICENSE, ATTRIBUTION, mark modified files |

## Open Items (post-v1)

- `stop` hook follow-up loops
- Automated upstream sync script
- CI: shellcheck + scaffold validate + MCP smoke test (GitHub Actions)
