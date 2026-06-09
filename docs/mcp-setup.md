# MCP Setup

This plugin exposes SEO/GEO data tools through MCP. **Tier 1 (default)** uses a local stdio server wrapping upstream `scripts/connectors/*.py`. **Tier 2/3 (optional)** adds 14 remote HTTP MCP servers for paid SEO platforms and SaaS integrations.

Every skill works without MCP — paste data or run connector CLIs manually. MCP automates retrieval when enabled.

## Default: stdio `seo-geo-connectors`

`./scripts/setup.sh` (or `install-to-cursor.sh`, which calls setup) generates `.mcp.json` with one server:

```json
{
  "mcpServers": {
    "seo-geo-connectors": {
      "type": "stdio",
      "command": "/path/to/mcp/.venv/bin/python",
      "args": ["/path/to/mcp/server.py"]
    }
  }
}
```

Paths are absolute to your install directory.

### Enable in Cursor

1. Install the plugin ([install guide](install.md))
2. **Settings → Tools & MCP**
3. Turn on **`seo-geo-connectors`**
4. **Developer: Reload Window** if tools do not appear

### Available tools

| MCP tool | Connector script | Typical use |
|----------|------------------|-------------|
| `crawl_site` | `crawl.py` | Site crawl → page records |
| `onpage_audit` | `onpage.py` | Title, meta, headings, canonical, JSON-LD |
| `check_robots` | `robots.py` | robots.txt + AI-bot rules |
| `fetch_sitemap` | `sitemap.py` | Sitemap / sitemap-index / llms.txt |
| `link_graph` | `linkgraph.py` | Orphans, depth, internal PageRank |
| `page_speed` | `psi.py` | Lighthouse + Core Web Vitals |
| `schema_lint` | `schema_lint.py` | Structured data extract + validate |
| `wikidata_entity` | `kg.py` | Entity → Wikidata QID + claims |
| `wayback_history` | `wayback.py` | Archive.org change history |
| `domain_authority` | `openpagerank.py` | Domain authority signal |
| `keyword_suggest` | `suggest.py` | Google Autocomplete ideas |
| `rss_monitor` | `rss_monitor.py` | Brand / mention RSS feeds |

Skills prefer these MCP tools when the server is enabled; otherwise they fall back to `python3 scripts/connectors/<script>.py` or ask you to paste data.

### Verify

```bash
./scripts/setup.sh
python3 scripts/smoke-test-mcp.py
```

## Optional: remote HTTP MCP (`--with-remote`)

Paid SEO platforms and SaaS tools ship as **opt-in** remote HTTP MCP endpoints. They are **not** included in the default `.mcp.json` to keep install zero-config.

Regenerate config with all 14 remote servers:

```bash
./scripts/generate-mcp-config.sh --with-remote
```

Re-run from the installed copy if you use `install-to-cursor.sh`:

```bash
~/.cursor/plugins/local/seo-geo-cursor/scripts/generate-mcp-config.sh --with-remote
```

Then reload Cursor and enable the servers you need in **Tools & MCP**.

### Merging with existing MCP config

`--with-remote` uses generic server keys (`ahrefs`, `semrush`, `notion`, etc.) that may **collide** with servers you already defined in Cursor user settings or another plugin.

| Approach | When to use |
|----------|-------------|
| **Plugin-only `.mcp.json`** (default) | Let the plugin manifest supply MCP; do not copy remote entries into global config |
| **Manual merge** | Rename conflicting keys before merge (e.g. `seo-geo-ahrefs`) and update skill docs if you reference them |
| **Stdio-only** | Keep `./scripts/generate-mcp-config.sh` without `--with-remote` if you already use Ahrefs/Semrush MCP elsewhere |

The plugin never overwrites your user-level MCP settings — it only writes `.mcp.json` inside the plugin directory.

### 14 HTTP MCP servers

| Server key | Vendor | Endpoint | Primary auth |
|------------|--------|----------|--------------|
| `ahrefs` | Ahrefs | `https://api.ahrefs.com/mcp/mcp` | API key (`AHREFS_API_KEY`) |
| `semrush` | Semrush | `https://mcp.semrush.com/v1/mcp` | OAuth or `Authorization: Apikey KEY` |
| `se-ranking` | SE Ranking | `https://api.seranking.com/mcp` | OAuth or `X-Api-Key` |
| `sistrix` | SISTRIX | `https://api.sistrix.com/mcp` | OAuth / Bearer / `X-API-Key` |
| `similarweb` | SimilarWeb | `https://mcp.similarweb.com` | OAuth or API key |
| `cloudflare` | Cloudflare | `https://mcp.cloudflare.com/mcp` | OAuth (interactive) |
| `vercel` | Vercel | `https://mcp.vercel.com` | OAuth (interactive) |
| `hubspot` | HubSpot | `https://mcp.hubspot.com/anthropic` | OAuth (interactive) |
| `amplitude` | Amplitude | `https://mcp.amplitude.com/mcp` | API key (`AMPLITUDE_API_KEY`) |
| `notion` | Notion | `https://mcp.notion.com/mcp` | OAuth (interactive) |
| `webflow` | Webflow | `https://mcp.webflow.com/sse` | OAuth (interactive) |
| `sanity` | Sanity | `https://mcp.sanity.io` | OAuth (interactive) |
| `contentful` | Contentful | `https://mcp.contentful.com/mcp` | OAuth (interactive) |
| `slack` | Slack | `https://mcp.slack.com/mcp` | OAuth (interactive) |

Stdio `seo-geo-connectors` remains in the same `.mcp.json` when using `--with-remote`.

### OAuth vs API keys

**OAuth (interactive):** Semrush, SE Ranking, SISTRIX, SimilarWeb, Cloudflare, Vercel, HubSpot, Notion, Webflow, Sanity, Contentful, Slack — Cursor prompts on first use; no env var required in most cases.

**API keys (env vars):**

| Variable | Server | Used by skills (examples) |
|----------|--------|---------------------------|
| `AHREFS_API_KEY` | Ahrefs MCP | keyword-research, competitor-analysis, serp-analysis, content-gap-analysis, backlink-analyzer, rank-tracker, internal-linking-optimizer |
| `AMPLITUDE_API_KEY` | Amplitude MCP | performance-reporter, alert-manager |

Set in your shell profile or Cursor environment before starting MCP:

```bash
export AHREFS_API_KEY="your-key"
export AMPLITUDE_API_KEY="your-key"
```

**Free Google data (not in default `.mcp.json`):** Google Analytics and Search Console have separate community/official stdio MCP servers that need your own Google OAuth or service account. See [CONNECTORS.md](../CONNECTORS.md) for links.

### Connector script keys (stdio helpers)

Some stdio tools accept keys at call time (not MCP env vars):

| Helper | Key | Notes |
|--------|-----|-------|
| `psi.py` | Google PSI API key | Optional but recommended for automation |
| `openpagerank.py` | `API-OPR` header | Free tier at openpagerank.com |

## Progressive tiers

| Tier | Setup | Experience |
|------|-------|------------|
| **1** | None | Paste data or run `scripts/connectors/*.py` manually |
| **2** | Enable `seo-geo-connectors` | Agent calls MCP tools for crawls, audits, CWV, entities |
| **3** | `--with-remote` + vendor auth | Automated Ahrefs, Semrush, HubSpot, etc. |

## Switch back to stdio-only

```bash
./scripts/generate-mcp-config.sh
```

Reload Cursor. Remote servers are removed from `.mcp.json`; only `seo-geo-connectors` remains.

## More detail

- [CONNECTORS.md](../CONNECTORS.md) — placeholder categories, free public APIs, caveats
- [install.md](install.md) — full plugin install and troubleshooting
