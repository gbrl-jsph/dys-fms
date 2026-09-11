# DYS FMS Documentation Library

This directory contains detailed project evidence, approved design material, historical academic artifacts, and implementation-supporting guides for DYS Financial Management System (DYS FMS).

## Start Here

For current operational context, read these documents first:

1. [`FINAL_DESIGN_AUTHORITY.md`](FINAL_DESIGN_AUTHORITY.md) — final design authority and current phase boundary.
2. [`project-index.md`](project-index.md) — task-specific documentation index and status classification.
3. [`../AI.md`](../AI.md) and [`../PROJECT.md`](../PROJECT.md) — implementation-state references only.

Use `graphify query "<question>"` when `../graphify-out/graph.json` exists.
Load only task-specific Markdown and source files. Do not preload this library.

## Important Distinction

`memory/` contains both current reference documents and historical evidence. Do not treat every file here as an active implementation specification. In particular:

- Original concept papers and interviews preserve submitted/client evidence.
- Frozen blueprint and roadmap documents may predate later approved implementation work.
- Academic UML artifacts have their own approval history and require separate reconciliation before edits.
- `extracted/` contains generated raw conversions; do not hand-edit it.

## Structure

| Path | Purpose |
|------|---------|
| `project-index.md` | Documentation map, authority, and current/historical classification |
| `project-memory.md` | Curated requirements/business-rule memory; consult with current root baseline |
| `AI_INSTRUCTIONS.md` | Supplementary governance for this documentation library |
| `blueprint/` | Requirements/design references, many frozen or historical |
| `development/` | Roadmap, test, deployment, audit, and user-facing documents |
| `diagrams/` | Curated diagram descriptions and sources |
| `extracted/` | Generated raw source conversions, non-authoritative |
| `scripts/` | Documentation extraction tooling |

## Refreshing Raw Extractions

```bash
python3 memory/scripts/extract-docs.py
python3 memory/scripts/extract-docs.py --write
```

The default command is a dry run. `--write` creates raw conversions only under
`memory/generated/extracted/`. It never replaces curated Markdown. Reconcile
curated documentation manually from the final design PDF.
