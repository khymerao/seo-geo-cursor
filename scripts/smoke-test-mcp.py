#!/usr/bin/env python3
"""Smoke test for MCP server — run after setup.sh."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVER_PATH = ROOT / "mcp" / "server.py"
MCP_DIR = str(ROOT / "mcp")


def load_server():
    if MCP_DIR not in sys.path:
        sys.path.insert(0, MCP_DIR)
    spec = importlib.util.spec_from_file_location("plugin_mcp_server", SERVER_PATH)
    if spec is None or spec.loader is None:
        raise SystemExit(f"Cannot load {SERVER_PATH}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    if not hasattr(module, "mcp"):
        raise SystemExit("server.py must define `mcp = FastMCP(...)`")
    return module


def test_module_loads():
    load_server()
    print("OK: MCP server module loads")


def test_runner_import():
    if MCP_DIR not in sys.path:
        sys.path.insert(0, MCP_DIR)
    import runner  # noqa: F401
    print("OK: runner module imports")


def test_ping():
    module = load_server()
    result = module.seo_geo_connectors_ping("smoke")
    assert "pong" in result, f"unexpected ping response: {result!r}"
    print("OK: seo_geo_connectors_ping")


def test_onpage_audit_live():
    if MCP_DIR not in sys.path:
        sys.path.insert(0, MCP_DIR)
    import runner

    result = runner.run_script("onpage.py", ["https://example.com"], timeout=90)
    assert result.get("ok"), f"onpage.py failed: {result.get('error', result)}"
    data = result["data"]
    assert isinstance(data, dict), "onpage.py should return JSON object"
    assert "title" in data or "fetch" in data, f"missing expected keys: {list(data.keys())[:8]}"
    print("OK: onpage_audit live (example.com)")


def test_onpage_audit_tool_registered():
    module = load_server()
    assert hasattr(module, "onpage_audit"), "server must expose onpage_audit tool"
    raw = module.onpage_audit("https://example.com")
    payload = json.loads(raw)
    assert payload.get("ok"), f"onpage_audit MCP tool failed: {payload}"
    print("OK: onpage_audit MCP tool")


def main() -> None:
    test_module_loads()
    test_runner_import()
    test_ping()
    test_onpage_audit_live()
    test_onpage_audit_tool_registered()
    print("smoke test passed")


if __name__ == "__main__":
    main()
