# Final Design Authority

## Status

Active project-context rule. Updated 2026-09-11.

## Source Priority

1. Final System Design Documentation PDF supplied with this task.
2. Explicit user instructions issued after that PDF.
3. Current implemented source code.
4. Current maintained project Markdown.
5. Older approved documents.
6. Historical memory, UML, and superseded drafts.

The final PDF is authoritative for design, requirements, RBAC, UML, user flow,
architecture, database design, UI/UX, QA, and project documentation. Source
code records current implementation, not final design authority.

## Current Context-Only Phase

Do not implement runtime alignment yet. Do not change Laravel policies, role
storage, Flutter routing, API contracts, or database schema until the user
approves the next alignment phase.

The PDF defines four design actors: Business Owner, Event Manager, Bookkeeper,
and Employee/Event Staff. Older three-actor context is superseded for design
and documentation purposes. Runtime differences remain implementation gaps for
the next approved phase.

## Agent Procedure

1. Start with `memory/README.md` and `memory/project-index.md`.
2. Use `graphify query` for relationship questions when `graphify-out/graph.json` exists.
3. Load only documents relevant to the task.
4. Inspect source before editing implementation.
5. Update context after approved changes and run `graphify update .`.

## Historical Material

Preserve unique academic artifacts. Mark conflicting historical material as
superseded or pending reconciliation. Do not delete it merely because it
conflicts with the final PDF.
