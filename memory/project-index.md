# DYS FMS Documentation Index and Authority Map

Read [`../AI.md`](../AI.md) and [`../PROJECT.md`](../PROJECT.md) before using detailed documents. This index prevents historical project material from being mistaken for the current implementation baseline.

## Authority Order

1. Final System Design Documentation PDF.
2. Explicit user instructions after that PDF.
3. Verified source, tests, and deployment configuration.
4. Current maintained references listed below.
5. Frozen/historical academic and design evidence.

## Active Current References

| Document | Use |
|----------|-----|
| [`../AI.md`](../AI.md) | Coding-agent rules, architecture, RBAC, startup procedure |
| [`FINAL_DESIGN_AUTHORITY.md`](FINAL_DESIGN_AUTHORITY.md) | Final design authority and implementation-alignment boundary |
| [`../PROJECT.md`](../PROJECT.md) | Current product, implementation, platform, testing, and deployment baseline |
| [`../backend/DEPLOYMENT.md`](../backend/DEPLOYMENT.md) | Render, Vercel, Aiven TLS, Android, and Web/PWA deployment instructions |
| [`AI_INSTRUCTIONS.md`](AI_INSTRUCTIONS.md) | Supplementary documentation governance |
| [`project-memory.md`](project-memory.md) | Curated requirements and business-rule detail; defer to root baseline for post-baseline decisions |
| [`system-components.md`](system-components.md) | Detailed component architecture; verify against source before behavior changes |
| [`development/user-manual.md`](development/user-manual.md) | User-facing draft; verify feature wording against current source |

## Frozen or Historical Design References

These documents preserve approved design history. They must not override current implementation or explicit approvals without reconciliation.

| Group | Documents | Notes |
|-------|-----------|-------|
| Original requirements evidence | `concept-paper.md`, `client-interview.md` | Preserve source history; do not rewrite interview responses |
| Blueprint design | `blueprint/functional-requirements-specification.md`, `validation-rules.md`, `use-case*.md`, `navigation-map.md`, `wireframes.md`, `ui-style-guide.md`, `system-architecture.md`, `system-flowchart.md`, `user-flow.md` | Several predate Web/PWA, session auth, settings, mutable transactions, and later UI changes |
| Data design | `blueprint/er-diagram.md`, `database-schema.md`, `data-dictionary.md`, `database-relationship-diagram.md` | Conceptual model preserves persistent payroll; current physical source includes soft deletes, audit logs, password-reset tokens, and Sanctum tables |
| Testing/traceability | `blueprint/requirements-traceability-matrix.md`, `blueprint/test-case-specification.md`, `blueprint/test-execution-report.md`, `development/requirements-traceability-matrix.md`, `development/test-case-specification.md` | Historical counts/endpoints may be stale; use actual test runs and routes |
| Plans/audits | `development/development-roadmap.md`, `development/development-execution-plan.md`, `development/phase-1-implementation-plan.md`, `development/final-consistency-audit.md`, `development/risk-assessment.md` | Historical planning/audit evidence; implementation has progressed beyond them |
| Older deployment/testing guides | `development/deployment-installation-guide.md`, `development/deployment-testing-guide.md` | Consult `../backend/DEPLOYMENT.md` first; reconcile provider-specific guidance before use |

## Academic UML and Case Study Material

| Location | Status |
|----------|--------|
| `../Case Study 4 - UML Modeling/` | Individually approved academic sources/artifacts. Do not edit without a dedicated UML reconciliation task. The As-Is Activity Diagram is manual-only and intentionally differs from proposed-system RBAC. |
| `../1 - System Architecture/`, `../3 - User Flow Diagram/`, `../4 - Use Case Diagram/`, `../0 - Project Documentation/` | Academic/working artifacts. Some alternate variants conflict with current RBAC; preserve and classify until separately reconciled. |
| `diagrams/` | Curated Mermaid/PlantUML descriptions. Verify against current source before treating as physical implementation documentation. |

## Generated and Non-Authoritative Material

- `extracted/`: raw MarkItDown conversions and hash state; regenerate, do not hand-edit.
- `scripts/`: extraction/cross-link tooling.
- `VERSION.md` and `CHANGELOG.md`: historical release records; check Git and app metadata for current version state.

## Current Implementation Deltas to Remember

- Payroll is persistent and atomically creates an Expense.
- Sales and expenses support approved maintenance/filtering and soft deletion.
- Reports render compact `fl_chart` charts; the Dashboard legacy Sales Overview chart was removed.
- Transactions accept optional `recorded_at`, persist UTC, and display local time.
- Android uses bearer tokens; Web/PWA uses Sanctum session cookies/XSRF through Vercel same-origin rewrites.
- Current production architecture is Vercel Web/PWA + Render API + Aiven MySQL TLS.
- Official roles are Business Owner, Event Manager, Employee/Staff only.
