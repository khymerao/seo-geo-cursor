#!/usr/bin/env python3
"""Minimal MCP server template for Cursor local plugins."""

from __future__ import annotations

from mcp.server.fastmcp import FastMCP

# Server name should match plugin.json "name" / mcpServers key
mcp = FastMCP("seo-geo-cursor")


@mcp.tool()
def seo_geo_cursor_ping(message: str = "hello") -> str:
    """Health-check tool — replace with your plugin's MCP tools."""
    return f"pong: {message}"


if __name__ == "__main__":
    mcp.run()
