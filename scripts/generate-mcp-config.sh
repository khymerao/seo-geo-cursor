#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

WITH_REMOTE=0
for arg in "$@"; do
  case "$arg" in
    --with-remote) WITH_REMOTE=1 ;;
    -h|--help)
      echo "Usage: $0 [--with-remote]"
      exit 0
      ;;
  esac
done

if ! has_mcp_component "$ROOT"; then
  echo "No MCP component — nothing to generate." >&2
  exit 0
fi

PYTHON="$ROOT/mcp/.venv/bin/python"
SERVER="$ROOT/mcp/server.py"
OUT="$ROOT/.mcp.json"

if [[ ! -x "$PYTHON" ]]; then
  echo "Missing venv. Run: $ROOT/scripts/setup.sh" >&2
  exit 1
fi

python3 - "$OUT" "$PYTHON" "$SERVER" "$WITH_REMOTE" <<'PY'
import json, sys
out, python, server, with_remote = sys.argv[1:5]
with_remote = with_remote == "1"
servers = {
    "seo-geo-connectors": {
        "type": "stdio",
        "command": python,
        "args": [server],
    }
}
if with_remote:
    remote = {
        "ahrefs": {"type": "http", "url": "https://api.ahrefs.com/mcp/mcp"},
        "semrush": {"type": "http", "url": "https://mcp.semrush.com/v1/mcp"},
        "se-ranking": {"type": "http", "url": "https://api.seranking.com/mcp"},
        "sistrix": {"type": "http", "url": "https://api.sistrix.com/mcp"},
        "similarweb": {"type": "http", "url": "https://mcp.similarweb.com"},
        "cloudflare": {"type": "http", "url": "https://mcp.cloudflare.com/mcp"},
        "vercel": {"type": "http", "url": "https://mcp.vercel.com"},
        "hubspot": {"type": "http", "url": "https://mcp.hubspot.com/anthropic"},
        "amplitude": {"type": "http", "url": "https://mcp.amplitude.com/mcp"},
        "notion": {"type": "http", "url": "https://mcp.notion.com/mcp"},
        "webflow": {"type": "http", "url": "https://mcp.webflow.com/sse"},
        "sanity": {"type": "http", "url": "https://mcp.sanity.io"},
        "contentful": {"type": "http", "url": "https://mcp.contentful.com/mcp"},
        "slack": {"type": "http", "url": "https://mcp.slack.com/mcp"},
    }
    servers.update(remote)
with open(out, "w", encoding="utf-8") as f:
    json.dump({"mcpServers": servers}, f, indent=2)
    f.write("\n")
print(f"Generated {out}" + (" (with remote HTTP MCP)" if with_remote else " (stdio only)"))
PY
