# SEO & GEO Skills (Cursor Plugin)

Cursor local plugin port of [aaron-he-zhu/seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) — 20 SEO/GEO skills, CORE-EEAT + CITE frameworks, connector MCP, and optional remote SEO tool integrations.

Built with [khymerao/cursor-plugin](https://github.com/khymerao/cursor-plugin) boilerplate.

**Design spec:** [docs/superpowers/specs/2026-06-09-seo-geo-cursor-design.md](docs/superpowers/specs/2026-06-09-seo-geo-cursor-design.md)

## Status

Ready for install — 20 upstream skills, stdio MCP connectors, router skill, hooks, and trigger rules are included.

## Quick Start

```bash
git clone git@github.com:khymerao/seo-geo-cursor.git
cd seo-geo-cursor
chmod +x scripts/*.sh hooks/*
./scripts/setup.sh
./scripts/install-to-cursor.sh
```

Reload Cursor (**Developer: Reload Window**), then check **Settings → Plugins** and **Tools & MCP**.

Full steps, verification, and troubleshooting: [docs/install.md](docs/install.md).

## Documentation

- [Install guide](docs/install.md)
- [MCP setup](docs/mcp-setup.md)
- [Claude → Cursor porting notes](docs/porting-notes.md)
- [Upstream sync](docs/upstream-sync.md)
- [Attribution](ATTRIBUTION.md)
- [Connectors & data tiers](CONNECTORS.md)

## License

Apache-2.0 (upstream) — see [ATTRIBUTION.md](ATTRIBUTION.md).
