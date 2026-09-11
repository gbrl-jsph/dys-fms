# DYS FMS AI Context

## Identity

- **Project:** DYS Financial Management System (DYS FMS)
- **Course:** COMSCI 3100 Case Study
- **Client:** DYS Events Management
- **Business Owner / client representative:** Mrs. Divine Samonte
- **Purpose:** Centralize financial monitoring across DYS business sectors; record sales and expenses, calculate payroll, generate reports, manage sector context, and manage authorized accounts.

## Source of Truth

For behavior and scope, use this order:

1. Final System Design Documentation PDF.
2. Explicit user instructions after that PDF.
3. Current verified implementation and tests.
4. Current maintained documentation indexed by `memory/project-index.md`.
5. Historical concept paper, interview, blueprint, and academic artifacts.

Do not silently resolve a conflict that changes behavior. Report both facts and wait for approval.

## Official Terms

**Final-design actors:** Business Owner, Event Manager, Bookkeeper, and Employee/Event Staff. Current runtime roles may differ; do not align runtime behavior without approval.

**Business sectors:** DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories. The Business Owner defaults to DYS Events and is the only actor who can switch sector context.

## Current Architecture

- Flutter presentation: screens, shared widgets, theme, GoRouter.
- Provider state: feature providers and app providers.
- Repositories and DTOs: API abstraction and mapping.
- Dio network layer: `ApiClient`, interceptors, authentication handling.
- Laravel 12 backend: controllers, services, requests, middleware, mail, Sanctum.
- MySQL data layer: Eloquent models, migrations, seeders.

Reuse existing Providers, Repositories, DTOs, shared widgets, and `ApiClient`; do not create parallel implementations for an existing concern.

## Current Runtime RBAC (Implementation Snapshot)

| Actor | Current access |
|------|----------------|
| Business Owner | Cross-sector sales/expenses/reports, Owner analytics, payroll calculation and all payroll, user management, sector switching |
| Event Manager | Assigned-sector sales/expenses and reports; own payroll only; no analytics, payroll calculation, user management, or sector switching |
| Employee/Staff | Authentication and own payroll only; no sales, expenses, reports, user management, or sector switching |

Backend authorization is authoritative. Flutter routing mirrors it but does not replace it.

## Data Model

Core business entities are `User`, `BusinessSector`, `SalesTransaction`, `Expense`, and persistent `PayrollRecord`. Payroll is stored and atomically creates an associated payroll-generated `Expense`. Additional implementation entities are Sanctum personal-access tokens, password-reset tokens, and audit logs. Sales and expenses use soft deletes.

## Platforms and Authentication

- **Android:** Flutter native app; Sanctum bearer token held in Flutter Secure Storage.
- **Web/PWA:** Flutter Web served by Vercel; same-origin `/api/*` and `/sanctum/*` rewrites proxy to Render. Sanctum uses HttpOnly session cookies, CSRF/XSRF protection, and no browser bearer-token persistence.
- **iPhone/iPad:** Safari Web/PWA through Add to Home Screen, not a native iOS application.
- **Database:** Aiven MySQL with mandatory CA-backed TLS verification via Render Secret File. Never commit the CA, credentials, APP_KEY, SMTP secrets, tokens, or cookies.

## Implemented Modules

Authentication, Dashboard, Sales, Expenses, Payroll, Reports with real compact API-driven charts, Business Sector Switching, User Management, Settings/Profile/Password Management, optional transaction `recorded_at`, search/filtering, transaction maintenance, soft deletes, temporary-password mail flow, and audit logging.

The Dashboard Sales Overview chart was removed. Do not restore it. `AppChartPlaceholder` may remain as a utility, but reports use real `fl_chart` renderers.

## Required Workflow

1. Read this file, `PROJECT.md`, and the relevant documents in `memory/project-index.md`.
2. Inspect relevant source before editing.
3. Check Git status; preserve unrelated user changes.
4. Make only the requested change. Do not add scope, roles, sectors, endpoints, tables, workflows, or dependencies without approval.
5. For behavior changes, run `flutter analyze`, Flutter tests, PHPUnit when its database environment is available, and relevant regression checks.
6. Never weaken tests to make them pass.
7. Report completed work, tests, limitations, conflicts, and assumptions. Stop after each major task and wait for approval.

## Historical and UML Rules

Academic UML is not automatically synchronized with product source. Before changing any UML source or generated artifact, separately reconcile its latest individually approved decision. The As-Is Activity Diagram intentionally represents manual notebook/receipt/Messenger workflows; it must not acquire app, API, dashboard, or database behavior.

Historical documents may retain older project names or requirements as evidence. Do not rewrite original interviews or concept papers. Use `memory/project-index.md` to determine whether a document is current, historical, or pending reconciliation.

## Current Verification

- `flutter analyze`: clean in the latest audit.
- `flutter test`: 268/268 passing in the latest audit.
- PHPUnit: currently blocked locally because `dys_fms_testing` credentials are unavailable; do not report it as passing without a successful run.
- Production Web session lifecycle and Android bearer lifecycle were previously verified; do not claim a new deployment is verified without live regression testing.

## Superseded Traps

- Payroll is persistent; it is not a transient calculator.
- Web does not persist bearer tokens and CSRF is `/sanctum/csrf-cookie`, not `/api/sanctum/csrf-cookie`.
- Sanctum web sessions require `guard => ['web']`.
- Placeholder-only charts and the old Dashboard Sales Overview chart are obsolete assumptions.
- Employee/Staff manual participation in the As-Is workflow does not grant proposed-system expense-entry access.
