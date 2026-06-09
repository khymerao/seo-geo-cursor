#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=template/scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

ERR=0

fail() {
  echo "ERROR: $*" >&2
  ERR=1
}

warn() {
  echo "WARN: $*" >&2
}

ok() {
  echo "OK: $*"
}

MANIFEST="$ROOT/.cursor-plugin/plugin.json"
if [[ ! -f "$MANIFEST" ]]; then
  fail "Missing $MANIFEST"
else
  ok "Found plugin manifest"
fi

if [[ -L "$ROOT" ]]; then
  fail "Plugin root is a symlink — Cursor will not load it from ~/.cursor/plugins/local/"
fi

NAME="$(plugin_name "$ROOT" 2>/dev/null || true)"
if [[ -z "$NAME" ]]; then
  fail "Could not read 'name' from plugin.json"
elif [[ ! "$NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  warn "Plugin name '$NAME' should be lowercase kebab-case (a-z, 0-9, hyphens)"
else
  ok "Plugin name: $NAME"
fi

for dir in skills rules; do
  if [[ -d "$ROOT/$dir" ]] && [[ -n "$(ls -A "$ROOT/$dir" 2>/dev/null)" ]]; then
    ok "Component present: $dir/"
  fi
done

if [[ -f "$ROOT/hooks/hooks.json" ]]; then
  if python3 -m json.tool "$ROOT/hooks/hooks.json" >/dev/null 2>&1; then
    ok "Valid hooks/hooks.json"
  else
    fail "Invalid JSON in hooks/hooks.json"
  fi
fi

if has_mcp_component "$ROOT"; then
  ok "MCP server: mcp/server.py"
  if [[ ! -f "$ROOT/mcp/requirements.txt" ]]; then
    fail "Missing mcp/requirements.txt"
  fi
  if [[ -f "$ROOT/.mcp.json" ]]; then
    if python3 -m json.tool "$ROOT/.mcp.json" >/dev/null 2>&1; then
      ok "Valid .mcp.json"
    else
      fail "Invalid .mcp.json"
    fi
  else
    warn ".mcp.json not generated yet — run scripts/setup.sh"
  fi
fi

for script in setup.sh install-to-cursor.sh validate.sh; do
  path="$ROOT/scripts/$script"
  if [[ -f "$path" && ! -x "$path" ]]; then
    warn "Script not executable: scripts/$script (run: chmod +x scripts/*.sh)"
  fi
done

while IFS= read -r -d '' f; do
  if grep -q '{{PLUGIN_' "$f" 2>/dev/null; then
    fail "Unsubstituted template placeholders in ${f#"$ROOT"/}"
  fi
done < <(find "$ROOT" -type f \
  ! -path '*/scripts/validate.sh' \
  ! -path '*/.git/*' \
  ! -path '*/mcp/.venv/*' \
  -print0 2>/dev/null)

if [[ "$ERR" -ne 0 ]]; then
  echo ""
  echo "Validation failed." >&2
  exit 1
fi

echo ""
echo "Validation passed."
