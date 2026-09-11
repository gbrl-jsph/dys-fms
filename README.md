# DYS Financial Management System (DYS FMS)

DYS FMS is a mobile-first financial management system for **DYS Events Management** and its four business sectors: DYS Events, B&DYS, Flavors by DYS, and SnapDYS Memories. The client and Business Owner representative is **Mrs. Divine Samonte**.

It centralizes sales, expenses, payroll, reports, sector context, and authorized user accounts to replace fragmented notebook, receipt, and Messenger-based financial recording.

## Start Here

1. Read [AI.md](AI.md) for the operational rules and fresh-agent startup procedure.
2. Read [PROJECT.md](PROJECT.md) for the current verified implementation and deployment baseline.
3. Use [memory/project-index.md](memory/project-index.md) to locate detailed, historical, and academic documents.

## Repository Map

| Path | Purpose |
|------|---------|
| `backend/` | Laravel 12 REST API, Sanctum, migrations, seeders, PHPUnit tests, Docker deployment files |
| `flutter_app/` | Flutter Android and Web/PWA client, Provider state, GoRouter, Dio, flutter_test suites |
| `memory/` | Detailed requirements, academic documentation, deployment/testing guides, and source classifications |
| `Case Study 4 - UML Modeling/` | Academic UML sources and generated artifacts; preserve unless explicitly requested |
| `.ai/development/` | Compact AI memory pointer for tools that discover `.ai` context |

## Current Status

- Flutter: `flutter analyze` clean; `flutter test` currently 268/268 passing.
- Backend PHPUnit requires the local `dys_fms_testing` MySQL credentials; it is currently blocked in this workspace.
- Web/PWA: Vercel same-origin proxy to the Render API; browser sessions use Sanctum cookies and CSRF.
- Android: Sanctum bearer tokens stored with Flutter Secure Storage.

See [PROJECT.md](PROJECT.md) before changing behavior, RBAC, API contracts, deployment, or documentation.
