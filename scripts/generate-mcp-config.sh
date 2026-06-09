#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=template/scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

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

SERVER_KEY="$(plugin_name "$ROOT")"

cat > "$OUT" <<EOF
{
  "mcpServers": {
    "$SERVER_KEY": {
      "type": "stdio",
      "command": "$PYTHON",
      "args": ["$SERVER"]
    }
  }
}
EOF

echo "Generated $OUT"
