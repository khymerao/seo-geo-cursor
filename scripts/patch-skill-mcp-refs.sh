#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for skill in "$ROOT"/research/*/SKILL.md "$ROOT"/build/*/SKILL.md "$ROOT"/optimize/*/SKILL.md "$ROOT"/monitor/*/SKILL.md "$ROOT"/cross-cutting/*/SKILL.md; do
  [[ -f "$skill" ]] || continue
  if grep -q 'scripts/connectors/' "$skill" && ! grep -q 'seo-geo-connectors' "$skill"; then
    python3 - "$skill" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
text = p.read_text(encoding="utf-8")
needle = "**Zero-dependency local helper**"
insert = "**Cursor MCP (preferred):** Use `seo-geo-connectors` MCP tools when enabled; CLI fallback below.\n\n"
if needle in text and insert not in text:
    text = text.replace(needle, insert + needle, 1)
    p.write_text(text, encoding="utf-8")
    print("patched", p)
PY
  fi
done
