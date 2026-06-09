---
name: seo-geo-router
description: |
  SEO/GEO workflow router for Cursor. Use when the user describes any SEO or GEO goal
  without naming a specific skill — keyword research, content writing, technical audit,
  schema markup, rank tracking, AI visibility, CORE-EEAT, CITE. Replaces upstream /aaron:* commands.
triggers:
  - "SEO workflow"
  - "GEO workflow"
  - "audit my site"
  - "research keywords"
  - "write SEO content"
  - "track rankings"
---

# SEO/GEO Router

Orchestrates the 20 phase skills at the smallest safe depth.

## Modes

| Mode | Trigger phrases | Skill chain |
|------|-----------------|-------------|
| **auto** | any SEO/GEO goal | infer → smallest chain below |
| **research** | keywords, SERP, competitors, gaps | keyword-research → competitor-analysis → content-gap-analysis |
| **create** | write, brief, meta, schema, refresh | seo-content-writer → geo-content-optimizer → meta-tags-optimizer / schema-markup-generator |
| **audit** | audit, on-page, technical, quality, authority | on-page-seo-auditor + content-quality-auditor + technical-seo-checker + domain-authority-auditor |
| **track** | rankings, alerts, report, remember | rank-tracker → performance-reporter → alert-manager |

## Algorithm

1. Parse goal → assign mode (research / create / audit / track / auto).
2. If `--deep` or "exhaustive/stress-test": output phase plan first; run preflight → research → audit → create → track.
3. Apply risk gates from `references/aaron-product-api-contract.md`.
4. Use MCP tool `seo-geo-connectors` when available; else `python3 scripts/connectors/<script>.py`; else ask user to paste data (Tier 1).
5. Return execution summary: steps, evidence, blockers, artifacts, next action.

## Legacy command mapping

| Old `/seo:*` | New route |
|--------------|-----------|
| audit-page | audit mode → on-page + quality |
| audit-domain | audit mode + domain-authority-auditor |
| check-technical | audit mode → technical-seo-checker |
| generate-schema | create mode → schema-markup-generator |
| keyword-research | research mode → keyword-research |
| optimize-meta | create mode → meta-tags-optimizer |
| report | track mode → performance-reporter |
| setup-alert | track mode → alert-manager |
| write-content | create mode → seo-content-writer |

## Boundaries

- memory-management, entity-optimizer: invoke directly when user asks about memory or canonical entities.
- Non-SEO work: stop with pack-boundary note.
- Never commit/publish/CMS-post without explicit user confirmation.
