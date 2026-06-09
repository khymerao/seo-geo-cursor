#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=template/scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

if ! has_mcp_component "$ROOT"; then
  echo "No MCP server in this plugin (mcp/server.py missing). Skipping setup." >&2
  exit 0
fi

VENV="$ROOT/mcp/.venv"
PYTHON=""
if ! PYTHON="$(find_python 3 11)"; then
  echo "Python >= 3.11 is required for the MCP server." >&2
  exit 1
fi

echo "Using $PYTHON ($("$PYTHON" --version))"

"$PYTHON" -m venv "$VENV"
"$VENV/bin/pip" install -U pip wheel
"$VENV/bin/pip" install -r "$ROOT/mcp/requirements.txt"

if [[ -f "$ROOT/mcp/post-setup.sh" ]]; then
  echo "Running mcp/post-setup.sh..."
  bash "$ROOT/mcp/post-setup.sh"
fi

"$ROOT/scripts/generate-mcp-config.sh"

echo "Setup complete."
echo "Python: $VENV/bin/python"
echo "Run MCP: $ROOT/scripts/run-mcp-server.sh"
