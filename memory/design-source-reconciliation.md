# Design and Source Reconciliation

## Status

Current as of 2026-09-11. This record reconciles the submitted system design
document with verified source, tests, deployment configuration, and the current
repository baseline. It does not change product behavior.

## Authority

Use this order when facts conflict:

1. Latest explicit approval.
2. Verified source, tests, and deployment configuration.
3. [`../AI.md`](../AI.md) and [`../PROJECT.md`](../PROJECT.md).
4. This reconciliation record and active references in
   [`project-index.md`](project-index.md).
5. Historical, academic, blueprint, and generated artifacts.

## Reviewed Design Reference

- [`../DYS_FMS_System_Design_Sections_II_III.pdf`](../DYS_FMS_System_Design_Sections_II_III.pdf)
  — System Architecture & Environment and System Logic & Behavior.

## Confirmed Alignment

| Design claim | Verified current implementation |
|---|---|
| Flutter client, Laravel REST API, and MySQL database | Flutter/Dart client and Laravel 12 API communicate through JSON/HTTPS; Eloquent persists MySQL data. |
| Six client-to-data layers | Flutter presentation, Provider state, repository/DTO mapping, Dio `ApiClient`, Laravel controllers/services/requests/middleware, and Eloquent/MySQL are present. |
| Provider, GoRouter, Dio, Flutter Secure Storage, Laravel Sanctum | All are active dependencies and implementation components. Secure Storage applies to Android bearer tokens only. |
| Backend RBAC, validation, payroll calculation, reports | Laravel middleware, Form Requests, services, and tests enforce these behaviors. |
| Active sector scopes finance data | Owner may choose sector context; Event Manager is server-scoped to assigned sector. |
| Payroll persists and creates an Expense | `PayrollRecord` persists. Payroll creation atomically creates a linked payroll-generated Expense. |

## Current Deployment Baseline

- Android uses Sanctum bearer tokens stored in Flutter Secure Storage.
- Web/PWA uses credentialed Sanctum session cookies and XSRF protection. Browser bearer tokens are not persisted.
- Vercel serves Flutter Web/PWA and proxies `/api/*` and `/sanctum/*` to the Render API.
- Render runs the Dockerized Laravel API. Aiven MySQL uses CA-backed TLS certificate verification.
- See [`../backend/DEPLOYMENT.md`](../backend/DEPLOYMENT.md) for operational deployment steps.

## Behavior Conflicts: Reported, Not Implemented

| Design claim | Verified current behavior | Resolution |
|---|---|---|
| Four roles include Bookkeeper | Only Business Owner, Event Manager, and Employee/Staff exist in user schema, middleware, routes, UI guards, and tests. | Do not add Bookkeeper without explicit approval and full RBAC/API/UI/test design. |
| Event Manager views analytics | Event Manager may access assigned-sector reports, but analytics is Business Owner-only. | Preserve current authorization. |
| Employee/Staff records expenses and views analytics | Employee/Staff has authentication and own-payroll access only. Expense and report routes are denied. | Preserve current authorization. |
| Every actor views dashboard | Dashboard visibility and available navigation are role-gated. Employee/Staff does not gain reports or transaction access. | Preserve current client and backend guards. |

The manual As-Is process may show employees recording expense details through
notebooks, receipts, or Messenger. That historical process does not grant
Employee/Staff proposed-system expense-entry permission.

## Documentation Handling

- Treat four-role UML, user-flow, and academic working artifacts as pending
  reconciliation, not implementation authority.
- Preserve original concept papers, interviews, and approved UML artifacts.
- Do not regenerate documentation with `memory/scripts/extract-docs.py` until
  its obsolete templates are reconciled. It can overwrite curated documents
  with stale claims.
- Do not hand-edit `memory/extracted/`; it contains generated raw conversions.
- Review and reconcile an individual UML source before changing its PlantUML,
  generated SVG/PNG, or companion documentation.

## Evidence

- Roles and access: `backend/database/migrations/2026_07_30_000002_create_users_table.php`, `backend/app/Http/Middleware/Ensure*Access.php`, and feature tests.
- Client route guards: `flutter_app/lib/routing/app_router.dart` and `flutter_app/test/routing/app_router_test.dart`.
- Authentication: `backend/app/Services/AuthService.php`, `flutter_app/lib/data/api/api_client.dart`, and `flutter_app/lib/features/auth/data/repositories/auth_repository.dart`.
- Deployment: `flutter_app/vercel.json`, `.github/workflows/deploy-web.yml`, `backend/Dockerfile`, and `backend/config/database.php`.
