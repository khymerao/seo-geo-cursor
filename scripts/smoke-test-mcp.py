#!/usr/bin/env python3
"""Smoke test for MCP server — run after setup.sh."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SERVER_PATH = ROOT / "mcp" / "server.py"


def main() -> None:
    spec = importlib.util.spec_from_file_location("plugin_mcp_server", SERVER_PATH)
    if spec is None or spec.loader is None:
        raise SystemExit(f"Cannot load {SERVER_PATH}")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    if not hasattr(module, "mcp"):
        raise SystemExit("server.py must define `mcp = FastMCP(...)`")

    print("smoke test passed: MCP server module loads")


if __name__ == "__main__":
    main()
