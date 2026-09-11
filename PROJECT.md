# DYS Financial Management System (DYS FMS) — Current Project Baseline

## Identity and Scope

DYS FMS is the current name for the COMSCI 3100 Case Study application for DYS Events Management. Mrs. Divine Samonte is the client and Business Owner representative. Older titles such as DYS Sales Tracker Management System, DYS Sale Tracking System, and DYS Event Management System are historical unless an academic source intentionally preserves them.

The system centralizes financial monitoring across DYS Events, B&DYS, Flavors by DYS, and SnapDYS Memories. It does not expand into general event-management software.

## Technology and Repository Structure

| Area | Current implementation |
|------|------------------------|
| Backend | Laravel 12, PHP 8.2+ compatible baseline, MySQL, Eloquent ORM, Laravel Sanctum, PHPUnit |
| Client | Flutter/Dart, Material 3, Provider, GoRouter, Dio, Flutter Secure Storage, flutter_test |
| Deployment | Render Docker API, Aiven MySQL TLS, Vercel Flutter Web/PWA with same-origin rewrites |
| Source paths | `backend/`, `flutter_app/`, `memory/`, `Case Study 4 - UML Modeling/`, `.ai/development/` |

## Current Role Access (Implementation Snapshot)

| Actor | Access |
|------|--------|
| Business Owner | Cross-sector records and reports, Owner analytics, all payroll, payroll calculation, user management, sector switching |
| Event Manager | Assigned-sector sales and expenses, assigned-sector reports, own payroll |
| Employee/Staff | Authentication and own payroll only |

The Business Owner defaults to DYS Events. Event Manager and Employee/Staff accounts remain assigned to one sector. The backend enforces all permission rules.

## Current Functional State

| Module | Implemented behavior |
|--------|----------------------|
| Authentication | Login/logout, Android token restore, Web session restore, inactive-account rejection, profile/name changes, password changes, forgot/reset password |
| Dashboard | Financial summary for authorized roles, sector context, compact recent activity, role-gated navigation, display options, unified Add Transaction action; no legacy Sales Overview chart |
| Sales and Expenses | Create, list, details, update, soft delete, search/filter, optional UTC `recorded_at` persisted and displayed locally; payroll-generated expenses cannot be edited/deleted |
| Payroll | Business Owner calculates `hours × rate`; records persist; one associated Expense is created atomically; non-owners see only their own history |
| Reports | Summary, sales, expenses, and analytics data; Event Manager is sector-scoped and cannot use analytics; real compact API-driven charts use `fl_chart` |
| Sectors | All authenticated users list sectors; Business Owner switches active client context |
| Users | Business Owner creates/updates/deactivates approved accounts, assigns roles/sectors, generates temporary passwords, and uses failover mail delivery |
| Settings | Light/dark/system preference, persisted across logout, profile and password management |

## Data Model

`business_sectors`, `users`, `sales_transactions`, `expenses`, and persistent `payroll_records` are the core tables. `expenses.payroll_record_id` is nullable for manual expenses and links payroll-generated expenses. Current implementation also contains `personal_access_tokens`, `password_reset_tokens`, and `audit_logs`. Sales and expenses have soft deletes.

Do not reintroduce the obsolete claim that Payroll is not an entity.

## Authentication and Deployment

- Android uses Sanctum personal-access bearer tokens stored by Flutter Secure Storage.
- Web/PWA uses Sanctum SPA/session authentication with HttpOnly Secure cookies, SameSite=Lax, XSRF, and no browser bearer-token persistence.
- Vercel rewrites `/api/*` and `/sanctum/*` to the Render API. Web builds use `API_BASE_URL=/api`; the CSRF endpoint is `/sanctum/csrf-cookie`.
- Aiven MySQL requires CA-backed TLS verification. `MYSQL_ATTR_SSL_CA` is a Render Secret File path and must remain secret.
- Render runs the Dockerized API and exposes `/up` for health checks.

## Current Test and Release Status

- Application version: `1.0.0+1` in `flutter_app/pubspec.yaml`.
- Current Git HEAD and tags are volatile; use `git log --oneline -1` and `git tag --sort=-creatordate` rather than copying them into feature documents.
- Latest local audit: `flutter analyze` clean and `flutter test` 268/268 passing.
- PHPUnit is currently blocked in this workspace by unavailable `dys_fms_testing` MySQL credentials. It must be rerun in a configured environment.
- Production authentication was previously verified for both Web sessions and Android bearer tokens; a local green suite alone is not a production verification.

## Documentation Authority

- Final System Design Documentation PDF is design authority. This file records current implementation only.
- [AI.md](AI.md): operational instructions for coding agents.
- This file: concise current technical/product baseline.
- [memory/project-index.md](memory/project-index.md): classification and navigation for detailed documentation.
- [backend/DEPLOYMENT.md](backend/DEPLOYMENT.md): operational deployment guide.
- Academic UML and original research evidence remain separate; do not modify them without an explicit UML/documentation task.

## Remaining Work and Constraints

- Local backend test database access must be restored before backend changes can be fully verified.
- SMTP production delivery must be retested before being claimed as verified.
- Do not introduce scope, change RBAC, change endpoint contracts, or add database entities without approval.
- Preserve the black/gold Material 3 theme, persistent payroll behavior, dual Android/Web authentication design, and existing Provider/Repository/ApiClient/DTO architecture.
