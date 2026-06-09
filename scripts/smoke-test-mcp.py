#!/usr/bin/env python3
"""Smoke test for MCP server — run after setup.sh."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVER_PATH = ROOT / "mcp" / "server.py"


def load_server():
    mcp_dir = str(ROOT / "mcp")
    if mcp_dir not in sys.path:
        sys.path.insert(0, mcp_dir)
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
    sys.path.insert(0, str(ROOT / "mcp"))
    import runner  # noqa: F401
    print("OK: runner module imports")


def test_onpage_audit_callable():
    module = load_server()
    assert hasattr(module, "onpage_audit"), "server must expose onpage_audit tool"
    print("OK: onpage_audit tool registered")


def main() -> None:
    test_module_loads()
    test_runner_import()
    test_onpage_audit_callable()
    print("smoke test passed")


if __name__ == "__main__":
    main()
