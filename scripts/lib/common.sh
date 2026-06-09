#!/usr/bin/env bash
# Shared helpers for cursor-plugin template scripts.
# Source from scripts: source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

set -euo pipefail

plugin_root() {
  cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd
}

read_plugin_json_field() {
  local field="$1"
  local root="${2:-$(plugin_root)}"
  python3 - "$root" "$field" <<'PY'
import json, sys
root, field = sys.argv[1], sys.argv[2]
with open(f"{root}/.cursor-plugin/plugin.json", encoding="utf-8") as f:
    data = json.load(f)
value = data.get(field, "")
if value is None:
    value = ""
print(value)
PY
}

plugin_name() {
  read_plugin_json_field name "$@"
}

plugin_display_name() {
  read_plugin_json_field displayName "$@"
}

local_plugins_dir() {
  printf '%s\n' "${CURSOR_LOCAL_PLUGINS_DIR:-$HOME/.cursor/plugins/local}"
}

local_install_path() {
  local root="${1:-$(plugin_root)}"
  local name
  name="$(plugin_name "$root")"
  printf '%s/%s\n' "$(local_plugins_dir)" "$name"
}

find_python() {
  local min_major="${1:-3}"
  local min_minor="${2:-11}"
  local candidate version major minor

  for candidate in python3.13 python3.12 python3.11 python3; do
    if command -v "$candidate" >/dev/null 2>&1; then
      version="$("$candidate" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
      major="${version%%.*}"
      minor="${version#*.}"
      if [[ "$major" -gt "$min_major" || ( "$major" -eq "$min_major" && "$minor" -ge "$min_minor" ) ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    fi
  done
  return 1
}

has_mcp_component() {
  local root="${1:-$(plugin_root)}"
  [[ -f "$root/mcp/server.py" ]]
}

rsync_excludes() {
  printf '%s\n' \
    --exclude 'mcp/.venv' \
    --exclude '.git' \
    --exclude '__pycache__' \
    --exclude '*.pyc' \
    --exclude '.DS_Store'
}
