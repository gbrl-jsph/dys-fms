# Changelog — AI Knowledge Base

## 2026-08-27 — Post-v1.0.0 Verification: Expenses Hardening, Black + Gold Theme, Settings + Dark Mode

> **Release baseline:** `v1.0.0` remains the current release (`flutter_app/pubspec.yaml` `1.0.0+1`, `flutter_app/lib/core/constants/app_info.dart` `1.0.0`). No new release number is issued. Items below are verified changes after that baseline, pending the next release. Knowledge-base `VERSION.md` stays at `v3.7` (`2026-07-29`) — this is a post-baseline implementation-verification entry, not a blueprint version bump.

### Expenses Backend — Phase 4 Hardening (Verified)

- Backend Phase 4 (`GET /api/expenses`, `POST /api/expenses`) verified against implemented code: `backend/app/Http/Controllers/Api/ExpensesController.php:18`, `backend/app/Services/ExpenseService.php:22`, `backend/app/Http/Requests/Expenses/IndexExpenseRequest.php:18`, `backend/app/Http/Requests/Expenses/StoreExpenseRequest.php:20`, `backend/app/Http/Middleware/EnsureExpenseAccess.php:10`, `backend/routes/api.php:31`, `backend/app/Models/Expense.php:8`, `backend/database/migrations/2026_07_30_000005_create_expenses_table.php:5`, `backend/database/migrations/2026_08_02_000000_expand_expenses_amount_precision.php`.
- RBAC re-verified: Business Owner + Event Manager allowed; Employee/Staff `403` via `EnsureExpenseAccess`. Owner required `sector_id` filter; Event Manager sector always overridden to `user.sector_id` in both controller and service.
- Server-controlled fields re-verified: `user_id` and `recorded_at` are never taken from the client (`ExpenseService.recordExpense` creates without `user_id`/`recorded_at` overrides); `payroll_record_id` stays `null` for manual entries (nullable FK, only payroll service writes it).
- Immutability re-verified: only `GET,HEAD` and `POST` routes exist for `api/expenses`; no `PUT`/`PATCH`/`DELETE`.
- Tests hardened with 3 additional cases in `backend/tests/Feature/Expenses/ExpenseManagementTest.php:475`: `test_client_supplied_user_id_and_recorded_at_are_ignored`, `test_client_cannot_assign_payroll_record_id_on_manual_expense`, `test_only_get_and_post_expense_routes_exist`. Full suite now `94 tests / 504 assertions` — `Expenses: 15 tests / 87 assertions` (verified via `PATH="/home/deck/.local/bin:$PATH" php backend/vendor/bin/phpunit --configuration backend/phpunit.xml --testdox`).

### Black + Gold UI Theme (Verified)

- Client-requested branding: primary gold `#D4AF37` (`AppColors.lightPalette.primary` / `darkPalette.primary` in `flutter_app/lib/core/constants/app_colors.dart:26,59`), hover `#C2A22B`.
- Light theme: white/warm-gray surfaces (`#FFFFFF`/`#F7F7F4`/`#F0EFE8`), near-black text `#1C1B16`; Dark theme: near-black/charcoal surfaces (`#1A1A1A`/`#121212`/`#242420`), off-white text `#F2F2EC`. Verified in `app_colors.dart` both palettes.
- Material 3 surface roles explicitly overridden (no seed-derived leakage) in `flutter_app/lib/core/theme/app_theme.dart:44` (`surfaceContainer*`, `surfaceDim/Bright`, `inverseSurface`, `surfaceTint: transparent`). Dialogs, menus, date pickers, snackbars, tooltips, bottom sheets, progress indicators all bound to palette tokens (`dialogTheme`, `popupMenuTheme`, `menuTheme`, `datePickerTheme`, `snackBarTheme`, `tooltipTheme`, `bottomSheetTheme`).
- Gold applied to primary actions, selected states, navigation indicator (`navigationBarTheme.indicatorColor: palette.primary`, `AppTheme:253`), CTA shadows (`AppShadows.shadowCta` now gold `0x47D4AF37` light / `0x59D4AF37` dark in `app_shadows.dart:66`).
- Semantic colors and sector signature colors unchanged (success/danger/warning + 4 sector pairs preserved).
- Existing `ThemeController` / `ThemeModeStore` architecture reused (`flutter_app/lib/core/theme/theme_controller.dart:12`, `theme_mode_store.dart:7`). `Light / Dark / System Default` remain supported; `AppColors.brightness` synced from `App.resolve` (`lib/app.dart:92`) and `ThemeModeStore` persists `theme_mode` in `flutter_secure_storage`.
- Status-bar handling brightness-aware: `AppTheme.appBarTheme.systemOverlayStyle` (`app_theme.dart:285`) + `App.builder` `AnnotatedRegion<SystemUiOverlayStyle>` (`app.dart:105`).
- Shadows dark-mode aware via brightness getters (`AppShadows.shadow1/shadow2/shadowCta` in `app_shadows.dart:82`).
- Flutter verification: `flutter analyze — No issues found`, `flutter test — 253 passed` (verified via `/home/deck/flutter/bin/flutter analyze` and `flutter test`).

### Settings Screen + Dark Mode (Verified)

- Settings screen exists: `flutter_app/lib/features/settings/presentation/screens/settings_screen.dart:22` — Appearance section (Light / Dark / System Default radio tiles via `_AppearanceTile`) + About section (`AppInfo.appName` `DYS Financial Management System`, `AppInfo.appVersion` `1.0.0` from `lib/core/constants/app_info.dart:8` mirroring `pubspec.yaml: version: 1.0.0+1`).
- Appearance persists: `ThemeModeStore` (`secure_storage` key `theme_mode`, AES-GCM) + `ThemeController.setMode`/`initialize`; preference survives restart and logout/login (covered by `test/integration/app_integration_test.dart: theme preference survives logout and login` and `test/features/settings/settings_screen_test.dart:105` — Dark persists, System Default follows platform).
- Dashboard avatar menu now points to Settings: `dashboard_screen.dart:166` (`_AvatarMenu` shows `Settings` + `Logout`; `onSelected` routes `context.go('/settings')`); duplicate Light/Dark/System toggles removed from that menu.
- Routing: `app_router.dart:138` adds `GoRoute(path: '/settings', builder: SettingsScreen)` — authenticated-only (redirect to `/login` when unauthenticated, verified by router tests `unauthenticated user visiting /settings is redirected to /login`).
- Logout does NOT delete theme: `SecureStorage.clearAuth()` (`secure_storage.dart:50` deletes only `auth_token` + `user_data`) + `AuthRepository.logout()` (`auth_repository.dart:48`) calls `clearAuth` instead of `deleteAll`; tested via `auth_repository_test.dart:120` (`clearAuthCalled`) and integration test.
- No notification settings added — correctly excluded as not in approved scope.
- Tests added: `test/core/theme/app_theme_test.dart` (light/dark/structure) + `test/features/settings/settings_screen_test.dart` (6 cases) + router int tests for `/settings`. Updated: `sectors` model nil handling (`business_sector.dart:30` `previousSector` now `BusinessSector?`), corresponding provider/repository test adjustments (`!`).

### Ancillary Fixes Included in This Working Tree (Verified, No Behavior Change Beyond Fix)

- `flutter_app/android/app/src/main/AndroidManifest.xml:5` — add `<uses-permission android:name="android.permission.INTERNET"/>` (release builds need it; debug/profile already inherit) + `android:usesCleartextTraffic="true"` for local backend URL.
- `flutter_app/lib/features/sectors/data/models/business_sector.dart:30` — `SectorSwitchResult.previousSector` is now nullable (`BusinessSector?`) with `fromJson` null guard, matching the first-switch `null` previous.

## 2026-08-25

### AS-IS Process Clarification: Employee / Manager Expense Recording
New authoritative clarification received regarding the CURRENT BUSINESS PROCESS (AS-IS):
- Employees / Event Staff ARE allowed to manually record expense details in the current manual process (e.g., purchasing supplies and recording expense details via notes, receipts, Messenger).
- Manager / Head can perform the same expense-recording activity when assigned, AND additionally:
  1. Supervises Employees / Event Staff
  2. Reviews financial reports within their assigned business-sector range

**Critical distinction preserved:** This clarification applies to the AS-IS manual process only. It does NOT alter the proposed-system RBAC. The proposed system's "Record Expenses" use case remains restricted to Business Owner and Event Manager.

Files updated: `project-memory.md`, `CHANGELOG.md`, `client-interview.md`

## 2026-07-29

### Requirements Traceability Matrix (RTM) Created
- Created `memory/blueprint/requirements-traceability-matrix.md` — v1.0, Draft — master verification document tracing all 8 FRs across 20 artifacts
- 8 FRs mapped to: 10 use cases, 8 screens, 16 API endpoints, 5 database tables, 7 validation rule categories (59 rules), 10 development phases
- 42 placeholder test case IDs generated for future Test Case Specification
- 200+ traceability links verified across all blueprint documents
- Coverage summary confirms 100% FR traceability — zero orphan artifacts
- Gap analysis documents 3 observations (Dashboard has no validation rules; Dashboard serves all roles vs UC4 being BO-only; no dedicated Change Password screen/endpoint defined)
- Consistency audit passed against all 20 approved source documents
- VERSION.md bumped to v3.7

### Use Case Diagram Rebuilt (Strict UML Notation)
- Replaced Mermaid diagram with PlantUML strict UML 2.x notation at `memory/diagrams/use-case-diagram.puml`
- Rendered PNG (31.9 KB) and SVG (16.0 KB) via PlantUML server
- Updated `memory/blueprint/use-case-diagram.md` to v2.0 with PlantUML source, UML notation guide, and expanded documentation
- Documented conflict: use-case.md:20 lists UC6 as Event Manager only, contradicting Concept Paper, FRS FR-007, and Validation Rules Matrix (resolved per your confirmation — BO + EM both mapped to UC6)

## 2026-07-28

### New Approved Scope Change: User Account Management (Official Project Decision)
Business Owner is responsible for creating all Event Manager and Employee accounts. There is no public registration, no self-registration, and no admin role. Workflow: Business Owner → Create User Account → Assign Role → Assign Business Sector → Generate Temporary Password → Provide Credentials to Employee → Employee Logs In → Employee Changes Password on First Login (optional).

New feature added: **User Account Management** (Business Owner only) — create Event Manager/Employee accounts, assign business sector, assign role, generate temporary credentials, activate/deactivate accounts (instead of deleting).

Explicitly excluded, per instruction: public registration, Register/Sign Up screens, admin/super-admin roles, password reset by email, invitation links, self-registration.

Database: added `account_status` ENUM column to the existing Users table (Active/Inactive). No new tables introduced.

### Files Updated (User Account Management)
- `memory/concept-paper.md` — Features, Business Rules
- `memory/project-memory.md` — Approved Features, Approved User Roles, Approved Workflows, Business Rules, Things AI Must NEVER Invent, Finalized Diagrams (bumped to v1.1)
- `memory/system-components.md` — Client Tier Components, Backend Services, User Flow, User Roles
- `memory/AI_INSTRUCTIONS.md` — Approved Features, Approved User Roles, Workflows, Things AI Must Never Do; version bumped 3.0 → 3.1
- `memory/project-index.md` — summaries for system-flowchart.md, user-flow.md, use-case-diagram.md, wireframes.md
- `memory/blueprint/system-architecture.md` — Client Tier Screens, Backend Services
- `memory/blueprint/system-flowchart.md` — added Process 7 (User Account Management Flow)
- `memory/blueprint/user-flow.md` — added Flow 7 (Manage User Accounts), Business Rules
- `memory/blueprint/use-case.md` — added Use Case 10 (Manage User Accounts), Relationships
- `memory/blueprint/use-case-diagram.md` — added UC10 node + Business Owner association, Actor Permissions Mapping row
- `memory/blueprint/wireframes.md` — added Manage Users screen description
- `memory/blueprint/er-diagram.md` — User entity: added account status attribute and account-creation note
- `memory/blueprint/database-schema.md` — Users table: added `account_status` column; Notes
- `memory/blueprint/consistency-review.md` — added User Account Management section, updated Final Result
- `memory/diagrams/system-architecture.md` — added Manage Users screen node, User Account Management service node, Screens/Services tables, RBAC block
- `memory/diagrams/system-flowchart.md` — added Process 7 subgraph (role-gated: Business Owner only), Process Summary, Business Rules Enforced, Decision Points
- `memory/diagrams/user-flow.md` — added Manage Users nodes/edges to Business Owner subgraph, Flow Summary, Screen Navigation Matrix, Business Rules Enforced
- `memory/diagrams/wireframes.md` — added Manage Users nav button to Owner dashboard, new Manage Users mockup section, Screen Descriptions, Navigation Mapping, Role Access Matrix, Business Rules Enforced

Note: `memory/blueprint/system-flowchart.md`'s new Process 7 subgraph is physically positioned in the Mermaid source between Process 4 and Process 5 (cosmetic only — the diagram renders correctly and the process is correctly labeled "7"; file section is simply out of strict numeric order).

### High-Fidelity Wireframes Updated (User Account Management)
- Created `5 - Wireframes/wireframes-hifi/users.html` — Screen 8: Manage Users (user list table, Add/Edit form, Generate Temporary Password, Save/Deactivate, bottom nav)
- Updated `dashboard.html` — added Manage Users to quick actions, bottom nav, notes
- Updated `index.html` — screen count 7→8, added screen 8 link
- Updated `login.html` — notes mention no self-registration
- Updated `sales.html`, `expenses.html`, `payroll.html`, `reports.html`, `sector-switcher.html` — nav bars updated

### New Approved Client Clarification: Payroll Permissions (Highest Priority Source of Truth)
Supersedes any previous ambiguity regarding payroll permissions.
- Business Owner: can calculate payroll for every employee; can view payroll for every employee
- Event Manager: cannot calculate payroll; can view only their own payroll; cannot view other employees' payroll
- Employee/Event Staff: cannot calculate payroll; can view only their own payroll; cannot view other employees' payroll
- Canonical rule: Only the Business Owner can calculate payroll. Event Managers and Employees are restricted to viewing only their own payroll. No role except the Business Owner may view another employee's payroll.
- Resolves the prior Event Manager "sector-scoped payroll" model and removes Employees' separate "View Reports" capability (folded into "View Own Payroll only")

### Files Updated
- `memory/concept-paper.md` — Business Rules
- `memory/project-memory.md` — Approved User Roles, Approved Workflows, Business Rules
- `memory/system-components.md` — User Flow, User Roles
- `memory/AI_INSTRUCTIONS.md` — Approved User Roles, Workflows
- `memory/blueprint/user-flow.md` — Generate Reports, Payroll Processing, Business Rules
- `memory/blueprint/use-case.md` — Use Cases, Relationships
- `memory/blueprint/use-case-diagram.md` — Mermaid actor associations, Actor Permissions Mapping table
- `memory/blueprint/wireframes.md` — Payroll, Reports
- `memory/blueprint/consistency-review.md` — added Payroll & Reports Permissions section, updated Final Result
- `memory/diagrams/user-flow.md` — Mermaid nodes/edges, Flow Summary, Screen Navigation Matrix, Business Rules Enforced (not in original request list; included per AI_INSTRUCTIONS.md "never update only one document if the change affects multiple project artifacts" — this file contained the exact superseded "View Payroll (Sector-scoped)" wording)
- `memory/diagrams/system-flowchart.md` — Payroll Processing flow role gate, Process Summary, Business Rules Enforced, Decision Points (not in original request list; same rationale)
- `memory/diagrams/system-architecture.md` — Screens table, RBAC block (not in original request list; same rationale)
- `memory/diagrams/wireframes.md` — Employee dashboard mockup, Payroll mockups (added Event Manager view), Reports mockup (removed Employee version), Screen Descriptions, Role Access Matrix, Business Rules Enforced (not in original request list; same rationale)
- `memory/project-index.md` — reviewed, no change needed (summaries are generic and do not enumerate role-specific payroll permissions)

## 2026-07-27

### Earlier
- Removed Activity Diagrams
- Updated Wireframes
- Revised Concept Paper
- Regenerated AI knowledge base
- Updated Business Sector Switching: Owner only can switch; Event Managers and Employees permanently assigned
- Updated Payroll: formula Hours × Rate, stored in database
- Updated Reports: monitor income, monitor expenses, view summaries, view reports, track sector performance
- Removed curation artifacts: immutability rule, rewritten challenges/constraints
- Added Payroll Records table to ER Diagram and Database Schema
- Added sector_id to Users table for permanent sector assignment
- Regenerated concept-paper.md, project-memory.md, project-index.md with latest clarifications

### Latest Client Clarifications Applied
- Updated AI_INSTRUCTIONS.md to v3.0 with new governance rules
- Changed default sector from "Finance" to "DYS Event Management" for Business Owner
- Added default sector rule: Event Managers/Employees default to their assigned business sector
- Updated Payroll requirement: stored permanently, viewable historically, auto-creates Expense record
- Added Payroll Record entity to ER Diagram with Expense auto-creation relationship
- Added Payroll Records table to Database Schema with Expense FK linkage
- Added Payroll auto-creates Expense to all workflow documents (flowchart, user-flow, use-case)
- Updated System Architecture: added Payroll Record to data entities
- Updated System Components: added Payroll Record as data entity
- Updated Wireframes: fixed default sector from Finance to DYS Event Management / assigned sector
- Updated Consistency Review with default sector rules and new data entity verification
- Performed full consistency audit across 11 curated documents — no contradictions found

### Diagrams Finalized
- Created System Architecture diagram (`diagrams/system-architecture.md`) — v1.0 frozen
- Created System Flowchart diagram (`diagrams/system-flowchart.md`) — v1.0 frozen
- Created User Flow diagram (`diagrams/user-flow.md`) — v1.0 frozen
- Created Wireframes (`diagrams/wireframes.md`) — v1.0 frozen
- Updated High-Fidelity Wireframes (`5 - Wireframes/wireframes-hifi/`) to match approved low-fi blueprint
- Project-wide rename: "DYS Event Management System" / "DYS Sales Tracker Management System" → "DYS Financial Management System (DYS FMS)"
- Updated VERSION.md to v3.1, project-memory.md with diagram tracking

### Use Case Diagram Finalized
- Created Use Case Diagram (`blueprint/use-case-diagram.md`) — v1.0 frozen
- 3 actors (Business Owner, Event Manager, Employee/Event Staff), 9 use cases, `<<include>>` relationship from View Payroll Calculations to Payroll Auto-creates Expense
- Mermaid `graph TB` layout with actor permissions table and consistency check
- Updated VERSION.md to v3.3, project-memory.md pending deliverables
