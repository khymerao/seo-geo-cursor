# SEO & GEO Skills (Cursor Plugin)

Cursor local plugin port of [aaron-he-zhu/seo-geo-claude-skills](https://github.com/aaron-he-zhu/seo-geo-claude-skills) — 20 SEO/GEO skills, CORE-EEAT + CITE frameworks, connector MCP, and optional remote SEO tool integrations.

Built with [khymerao/cursor-plugin](https://github.com/khymerao/cursor-plugin) boilerplate.

**Design spec:** [docs/superpowers/specs/2026-06-09-seo-geo-cursor-design.md](docs/superpowers/specs/2026-06-09-seo-geo-cursor-design.md)

## Status

🚧 In development — scaffold + design spec committed; upstream import and MCP layer pending.

## Quick Start (when ready)

```bash
git clone git@github.com:khymerao/seo-geo-cursor.git
cd seo-geo-cursor
chmod +x scripts/*.sh hooks/*
./scripts/setup.sh
./scripts/install-to-cursor.sh
```

Reload Cursor (**Developer: Reload Window**), then check **Settings → Plugins** and **Tools & MCP**.

## Documentation

- [Install guide](docs/install.md) *(pending)*
- [MCP setup](docs/mcp-setup.md) *(pending)*
- [Claude → Cursor porting notes](docs/porting-notes.md) *(pending)*
- [Upstream sync](docs/upstream-sync.md) *(pending)*
- [Attribution](ATTRIBUTION.md)

## License

Apache-2.0 (upstream) — see [ATTRIBUTION.md](ATTRIBUTION.md).
