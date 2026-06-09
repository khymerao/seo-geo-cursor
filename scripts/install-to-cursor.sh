#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=template/scripts/lib/common.sh
source "$ROOT/scripts/lib/common.sh"

NAME="$(plugin_name "$ROOT")"
DISPLAY="$(plugin_display_name "$ROOT")"
TARGET="$(local_install_path "$ROOT")"
LOCAL_DIR="$(local_plugins_dir)"

echo "Installing Cursor plugin: $DISPLAY ($NAME)"
echo "Source: $ROOT"
echo "Target: $TARGET"

"$ROOT/scripts/validate.sh"

mkdir -p "$LOCAL_DIR"
rm -rf "$TARGET"

# shellcheck disable=SC2046
rsync -a $(rsync_excludes) "$ROOT/" "$TARGET/"

if has_mcp_component "$ROOT"; then
  "$TARGET/scripts/setup.sh"
fi

echo ""
echo "Installed to: $TARGET"
echo ""
echo "Important:"
echo "  - Cursor ignores symlinked local plugins (security)."
echo "  - This installer copies real files into $LOCAL_DIR/$NAME."
echo "  - /add-plugin works only for Marketplace plugins, not local ones."
echo ""
echo "Next steps:"
echo "  1. Developer: Reload Window"
echo "  2. Settings → Plugins → verify '$DISPLAY'"
if has_mcp_component "$ROOT"; then
  echo "  3. Settings → Tools & MCP → enable '$NAME'"
fi
echo "  4. Output → Cursor Plugins → loadUserLocalPlugins (... 1 plugins loaded)"
