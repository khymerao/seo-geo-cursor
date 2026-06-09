#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$ROOT/mcp/.venv"
PYTHON="$VENV/bin/python"
SERVER="$ROOT/mcp/server.py"

if [[ ! -x "$PYTHON" ]]; then
  echo "MCP venv missing. Run: $ROOT/scripts/setup.sh" >&2
  exit 1
fi

exec "$PYTHON" "$SERVER"
