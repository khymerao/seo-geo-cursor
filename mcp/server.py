#!/usr/bin/env python3
"""MCP server exposing upstream SEO/GEO connector scripts."""

from __future__ import annotations

import json

from mcp.server.fastmcp import FastMCP

from runner import run_script

mcp = FastMCP("seo-geo-connectors")


def _json_result(result: dict) -> str:
    return json.dumps(result, ensure_ascii=False)


@mcp.tool()
def seo_geo_connectors_ping(message: str = "hello") -> str:
    """Health-check for the connector MCP server."""
    return f"pong: {message}"


@mcp.tool()
def crawl_site(url: str, max_pages: int = 20, max_depth: int = 3) -> str:
    """Polite same-host crawl. Returns JSON page records."""
    return _json_result(
        run_script("crawl.py", [url, "--max-pages", str(max_pages), "--max-depth", str(max_depth)])
    )


@mcp.tool()
def onpage_audit(url: str) -> str:
    """On-page audit: title, meta, headings, canonical, JSON-LD types."""
    return _json_result(run_script("onpage.py", [url]))


@mcp.tool()
def check_robots(url: str, check_ai_bots: bool = True) -> str:
    """Evaluate robots.txt; optionally check AI bot access."""
    args = [url]
    if check_ai_bots:
        args.append("--check-ai-bots")
    return _json_result(run_script("robots.py", args))


@mcp.tool()
def fetch_sitemap(url: str, limit: int = 500) -> str:
    """Fetch sitemap.xml or sitemap index URLs."""
    return _json_result(run_script("sitemap.py", [url, "--limit", str(limit)]))


@mcp.tool()
def link_graph(crawl_json: str) -> str:
    """Build internal link graph from crawl JSON (stdin file content as string)."""
    return _json_result(run_script("linkgraph.py", ["-"], stdin_data=crawl_json))


@mcp.tool()
def page_speed(url: str, api_key: str = "") -> str:
    """PageSpeed Insights lab + field metrics."""
    args = [url]
    if api_key:
        args.extend(["--key", api_key])
    return _json_result(run_script("psi.py", args, timeout=180))


@mcp.tool()
def schema_lint(url: str) -> str:
    """Extract and validate JSON-LD on a page."""
    return _json_result(run_script("schema_lint.py", [url]))


@mcp.tool()
def wikidata_entity(name: str, action: str = "reconcile") -> str:
    """Wikidata search/entity/reconcile for entity optimization."""
    return _json_result(run_script("kg.py", [action, name]))


@mcp.tool()
def wayback_history(url: str, match: str = "host") -> str:
    """Wayback Machine CDX capture history."""
    return _json_result(run_script("wayback.py", [url, "--match", match]))


@mcp.tool()
def domain_authority(domain: str, api_key: str) -> str:
    """Open PageRank domain authority signal (requires free API key)."""
    return _json_result(run_script("openpagerank.py", [domain, "--key", api_key]))


@mcp.tool()
def keyword_suggest(seed: str, expand: bool = False) -> str:
    """Google Autocomplete keyword ideas (unofficial endpoint)."""
    args = [seed]
    if expand:
        args.append("--expand")
    return _json_result(run_script("suggest.py", args))


@mcp.tool()
def rss_monitor(feed_url: str) -> str:
    """Parse RSS/Atom feed for brand/mention monitoring."""
    return _json_result(run_script("rss_monitor.py", [feed_url]))


if __name__ == "__main__":
    mcp.run()
