# Development Execution Plan — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Approved for Development
**Project:** DYS Financial Management System (DYS FMS)
**Source:** `memory/development/development-roadmap.md` (v1.1, Approved)
**Blueprint Reference:** All `memory/blueprint/` documents

---

## 1. Executive Summary

### Current Project State

The DYS FMS blueprint phase is **complete and frozen**. All planning artifacts have been audited for consistency across 20+ documents. The Requirements Traceability Matrix confirms 100% FR coverage with zero orphan artifacts.

### Blueprint Completion

| Artifact | Status |
|----------|--------|
| Concept Paper | Approved |
| Client Interview | Approved |
| FRS (FR-001 through FR-008) | Draft — Pending Audit |
| System Architecture | Frozen |
| System Flowchart | Frozen |
| User Flow | Frozen |
| Navigation Map | Draft — Pending Audit |
| Use Case Specification | Frozen |
| Use Case Diagram (PlantUML) | Frozen |
| Low-Fi Wireframes | Frozen |
| Hi-Fi Wireframes (8 screens) | Frozen |
| UI Style Guide | Draft — Pending Audit |
| ER Diagram | Frozen |
| Database Schema | Frozen |
| Data Dictionary | Draft — Pending Audit |
| API Specification (16 endpoints) | Draft — Pending Audit |
| Validation Rules Matrix (60 rules) | Approved |
| System Components | Frozen |
| RTM | Draft |
| Test Case Specification (42 cases) | Draft |
| Test Execution Report (Pre-Execution) | Draft |
| Development Roadmap (10 phases) | Approved |
| CHANGELOG | Current |
| VERSION | Current v3.7 |

### Development Readiness

**The project is ready to begin coding.**

All blueprint documents are internally consistent. Every API endpoint, database table, screen, validation rule, and business rule is defined and traceable to an approved functional requirement. No ambiguities remain that would block development.

---

## 2. Development Order

The implementation follows the 10-phase sequence from the approved Development Roadmap. Each phase produces working, testable deliverables before the next phase begins.

| Order | Phase | Module | Backend | Flutter | Database |
|:-----:|:-----:|--------|:-------:|:-------:|:--------:|
| 1 | Phase 1 | Project Scaffold + Auth | Laravel project, Sanctum, Login/Logout endpoints | Flutter project, HTTP client, routing shell, Login screen | Migrations (all 5 tables), seeds (4 sectors, 1 BO) |
| 2 | Phase 2 | User Account Management | Users CRUD controller, 5 endpoints, Owner-only gate | Users screen (list, add/edit form, generate password, activate/deactivate) | — (table exists from Phase 1) |
| 3 | Phase 3 | Sales | Sales controller, 2 endpoints, sector scoping | Sales screen (amount/description form, recent list) | — |
| 4 | Phase 4 | Expenses | Expenses controller, 2 endpoints, sector scoping, nullable payroll_record_id support | Expenses screen (amount/description form, recent list) | — |
| 5 | Phase 5 | Payroll | Payroll controller, 2 endpoints, computed_salary calculation, auto-create Expense in transaction | Payroll screen (Owner: employee selector + calculate; EM/EE: history only) | — |
| 6 | Phase 6 | Reports | Reports controller, 1 endpoint with aggregation queries, analytics chart data | Reports screen (type selector, date range, summary table, chart placeholders) | — |
| 7 | Phase 7 | Business Sector Switching | Sectors controller, 2 endpoints (list + switch), Owner-only gate for switch | Sector Switcher screen (4 sector cards, active indicator), sector chip on Dashboard | — |
| 8 | Phase 8 | Dashboard + Final Integration | All endpoints consumed by UI | Dashboard (3 role variants, summary cards, chart placeholder, quick actions, bottom nav, sector chip) | — |
| 9 | Phase 9 | Testing | Backend unit/API/integration tests | Flutter widget/E2E tests | FK/integrity tests |
| 10 | Phase 10 | Deployment Prep | Env config, CORS, error logging | Build flavors, release artifacts | Migration automation |

**Note on parallel work:** Phases 3 and 4 (Sales and Expenses) have identical dependencies (Auth + Sectors) and no dependency on each other. They can be developed in parallel if resources allow.

---

## 3. Module Dependencies

```
Phase 1 (Foundation)
├── Phase 2 (User Management) ───── depends on: Auth, Sectors
├── Phase 3 (Sales) ─────────────── depends on: Auth, Sectors
├── Phase 4 (Expenses) ──────────── depends on: Auth, Sectors
│   └── Phase 5 (Payroll) ───────── depends on: Auth, Sectors, User Mgmt, Expenses table
│       └── Phase 6 (Reports) ───── depends on: Sales, Expenses, Payroll
├── Phase 7 (Sector Switching) ──── depends on: Auth, Sectors
│   └── Phase 8 (Dashboard) ─────── depends on: ALL prior phases
│       └── Phase 9 (Testing) ───── depends on: ALL prior phases
│           └── Phase 10 (Deploy) ─ depends on: Testing
```

### Dependency Matrix

| Module | Depends On | Blocks |
|--------|------------|--------|
| Database Setup | — | Everything |
| Backend Scaffold | Database | Auth, User Mgmt, Sales, Expenses, Payroll, Reports, Sectors |
| Frontend Scaffold | — | Auth, all screens |
| Authentication | Database, Backend, Frontend | User Mgmt, Sales, Expenses, Payroll, Reports, Sectors, Dashboard |
| Business Sectors (seed) | Database | User Mgmt, Sales, Expenses, Payroll, Sector Switching |
| User Management | Auth, Sectors | Payroll |
| Sales | Auth, Sectors | Reports, Dashboard |
| Expenses | Auth, Sectors | Payroll, Reports, Dashboard |
| Payroll | Auth, Sectors, User Mgmt, Expenses | Reports, Dashboard |
| Reports | Sales, Expenses, Payroll | Dashboard |
| Sector Switching | Auth, Sectors | Dashboard |
| Dashboard | All modules | Testing |
| Testing | All modules | Deployment |

---

## 4. Backend Milestones

### Phase 1 — Authentication & Core Setup

**Controllers:** AuthController
**Models:** User, BusinessSector, SalesTransaction, Expense, PayrollRecord
**Migrations:** `create_users_table`, `create_business_sectors_table`, `create_sales_transactions_table`, `create_expenses_table`, `create_payroll_records_table`
**Policies:** None in Phase 1 (role gating added per module)
**Services:** AuthService (login logic, token issuance, default sector resolution)
**Routes:**
- `POST /api/login` (public)
- `POST /api/logout` (authenticated)
**Middleware:** `auth:sanctum` on all non-login routes
**Validation:** Login request validation (email required, email format, password required)
**Seeds:**
- `BusinessSectorSeeder` — 4 sectors: DYS Events (id=1), B&DYS (id=2), Flavors by DYS (id=3), SnapDYS Memories (id=4)
- `UserSeeder` — 1 Business Owner (owner@dys.com, sector_id=null, role=Business Owner, account_status=Active)

**Test coverage:** TC-FR001-01, TC-FR001-02, TC-FR001-03, TC-FR001-04

### Phase 2 — User Account Management

**Controllers:** UserController
**Services:** UserManagementService (create, update, status, temp password generation)
**Policies:** UserPolicy (Owner-only gate via middleware or gate)
**Routes:**
- `GET /api/users`
- `POST /api/users`
- `GET /api/users/{id}`
- `PUT /api/users/{id}`
- `PATCH /api/users/{id}/status`
**Validation:** Create user request (name, email, role, sector_id), Update user request, Status update request
**Key logic:** Temporary password generation (min 8 chars, mixed case, numbers, special), BCrypt hashing, account_status defaults to Active, Owner's own account cannot be deactivated, Business Owner role cannot be created via this endpoint

**Test coverage:** TC-FR003-01 through TC-FR003-07

### Phase 3 — Sales

**Controllers:** SalesController
**Services:** SalesService (create transaction, sector-scoped listing)
**Policies:** SalesPolicy (Owner/EM only, EM sector scoping)
**Routes:**
- `GET /api/sales`
- `POST /api/sales`
**Validation:** Amount required + positive, description optional, sector_id conditional (required for Owner, overridden for EM)
**Key logic:** user_id set server-side, recorded_at set server-side, EM sector overridden to assigned sector, no PUT/PATCH/DELETE

**Test coverage:** TC-FR004-01 through TC-FR004-05

### Phase 4 — Expenses

**Controllers:** ExpenseController
**Services:** ExpenseService (create expense, sector-scoped listing)
**Policies:** ExpensePolicy (Owner/EM only, EM sector scoping)
**Routes:**
- `GET /api/expenses`
- `POST /api/expenses`
**Validation:** Amount required + positive, description optional, sector_id conditional
**Key logic:** payroll_record_id = null for manual entries, user_id set server-side, recorded_at set server-side, EM sector overridden, no PUT/PATCH/DELETE

**Test coverage:** TC-FR005-01 through TC-FR005-06

### Phase 5 — Payroll

**Controllers:** PayrollController
**Services:** PayrollService (calculate payroll, auto-create expense in same DB transaction)
**Policies:** PayrollPolicy (Owner-only for POST; role-filtered for GET)
**Routes:**
- `GET /api/payroll`
- `POST /api/payroll`
**Validation:** user_id (exists, role ≠ Business Owner), hours_worked (positive, max 99999999.99), hourly_rate (positive, max 99999999.99), pay_period (valid date, YYYY-MM-DD)
**Key logic:** computed_salary = hours_worked × hourly_rate (server-calculated), sector_id = employee's assigned sector, auto-create Expense: amount = computed_salary, description = "Payroll — {name} — {pay_period}", user_id = authenticated BO, payroll_record_id = FK to new PayrollRecord. All in one database transaction.
**GET filtering:** BO sees all; EM/EE see own only

**Test coverage:** TC-FR006-01 through TC-FR006-08

### Phase 6 — Reports

**Controllers:** ReportController
**Services:** ReportService (aggregation queries: total sales, total expenses, net balance, chart data)
**Policies:** ReportPolicy (Owner: all + analytics; EM: assigned sector only; EE: forbidden)
**Routes:**
- `GET /api/reports`
**Validation:** type (in: summary, sales, expenses, analytics), sector_id (exists if provided, overridden for EM), date_from/date_to (valid dates if provided)
**Key logic:** Aggregation queries over Sales Transactions + Expenses, cross-sector aggregation for Owner (when no sector_id), per-sector filtering, analytics chart data endpoints (may return empty arrays), EM restricted to assigned sector, Employee returns 403

**Test coverage:** TC-FR007-01 through TC-FR007-05

### Phase 7 — Business Sector Switching

**Controllers:** BusinessSectorController
**Services:** BusinessSectorService (list sectors, validate switch)
**Policies:** SectorSwitchPolicy (Owner-only for POST; GET available to all)
**Routes:**
- `GET /api/business-sectors`
- `POST /api/business-sectors/switch`
**Validation:** sector_id required for POST, must reference existing Business Sectors.id
**Key logic:** GET returns all 4 sectors; POST validates role (Owner only), returns previous/current sector for client sync; sector switch is stateless (sector context maintained client-side)

**Test coverage:** TC-FR008-01 through TC-FR008-04

### Phase 8 — Dashboard

No new backend endpoints. All existing endpoints consumed by the Flutter Dashboard.

**Test coverage:** TC-FR002-01, TC-FR002-02, TC-FR002-03

### Phase 9 — Testing

Backend test types:
- **Unit tests:** Services (AuthService, PayrollService computed_salary, UserManagementService temp password), validation rules
- **API tests:** All 16 endpoints — success, validation error (422), auth failure (401), role authorization (403)
- **Integration tests:** Database FK constraints, auto-create Expense on Payroll (same transaction), sector scoping queries

### Phase 10 — Deployment

- Environment config (`.env`): DB credentials, APP_URL, Sanctum config
- CORS configuration for Flutter client
- Server-side error logging (Laravel log)
- Migration automation (php artisan migrate --seed)

---

## 5. Flutter Milestones

### Phase 1 — Authentication & Core Setup

**Screens:** Login (Screen 1)
**Navigation:** Unauthenticated route (Login only), post-auth route guard (role-based redirect)
**State management:** Auth state (token, user, role, default sector), token storage (flutter_secure_storage)
**API integration:** HTTP client (Dio or http package), Bearer token header injection
**Key widgets:** Email field, password field, Login button, error message display
**Packages:** `flutter_secure_storage` (token), `provider` or `riverpod` (state), `dio` (HTTP)

**Test coverage:** TC-FR001-01 through TC-FR001-04 (login flows)

### Phase 2 — User Account Management

**Screens:** User Account Management (Screen 8)
**Navigation:** Bottom nav Users tab (Owner only), Manage Users quick action
**Key widgets:** User list table, Add/Edit form (Name, Email, Role dropdown, Sector dropdown), Generate Temporary Password button, Save Account button, Deactivate/Activate button (red outline for Deactivate), inline validation errors
**State:** User list state, form state, temp password display

**Test coverage:** TC-FR003-01 through TC-FR003-07

### Phase 3 — Sales

**Screens:** Sales (Screen 3)
**Navigation:** Bottom nav Sales tab (Owner/EM), Record Sale quick action
**Key widgets:** Amount field (numeric keyboard), Description field, Save Sale Record button, recent transactions list (ordered by recorded_at desc, paginated), sector display (Owner: dropdown; EM: read-only)
**State:** Sales list state, form state, pagination

**Test coverage:** TC-FR004-01 through TC-FR004-05

### Phase 4 — Expenses

**Screens:** Expenses (Screen 4)
**Navigation:** Bottom nav Expenses tab (Owner/EM), Record Expense quick action
**Key widgets:** Amount field, Description field, Save Expense Record button, recent expenses list, sector display (Owner: dropdown; EM: read-only)
**State:** Expenses list state, form state, pagination

**Test coverage:** TC-FR005-01 through TC-FR005-06

### Phase 5 — Payroll

**Screens:** Payroll (Screen 5)
**Navigation:** Bottom nav Payroll tab (all roles), View Payroll quick action
**Key widgets (Owner variant):** Employee selector dropdown (Event Manager + Employee users), Hours Worked field, Hourly Rate field, Computed Salary display (read-only), Calculate & Save button, payroll history table (all employees)
**Key widgets (EM/EE variant):** Payroll history table (own records only, no calculation controls)
**State:** Payroll list state, calculation form state, role-based UI conditional rendering

**Test coverage:** TC-FR006-01 through TC-FR006-08

### Phase 6 — Reports

**Screens:** Reports (Screen 6)
**Navigation:** Bottom nav Reports tab (Owner/EM), View Reports quick action
**Key widgets (Owner):** Report type selector (summary, sales, expenses, analytics), date range picker, financial summary table, sales trend chart placeholder, expense breakdown chart placeholder, sector comparison chart placeholder
**Key widgets (EM):** Report type selector (summary, sales, expenses — no analytics), sector summary chart, sector-scoped financial table
**Key widgets (Employee):** Reports tab routes to own payroll view (same as Payroll screen)
**State:** Report data state, type selection, date range

**Test coverage:** TC-FR007-01 through TC-FR007-05

### Phase 7 — Business Sector Switching

**Screens:** Sector Switcher (Screen 7)
**Navigation:** Accessible via sector chip on Dashboard (Owner only), NOT in bottom nav
**Key widgets:** 4 sector cards with name/description, active sector indicator (filled radio dot/badge), tap to select and return
**State:** Sector context state (current sector ID, sector name)

**Test coverage:** TC-FR008-01 through TC-FR008-04

### Phase 8 — Dashboard & Final Integration

**Screens:** Dashboard (Screen 2) — 3 role variants
**Navigation:** Central hub for all screens
**Role variants:**

| Element | Business Owner | Event Manager | Employee |
|---------|:--------------:|:-------------:|:--------:|
| Summary cards (Total Sales, Total Exp., Net Balance) | ✓ (sector-scoped) | ✓ (sector-scoped) | — |
| Chart placeholder | ✓ | ✓ | — |
| Record Sale quick action | ✓ | ✓ | — |
| Record Expense quick action | ✓ | ✓ | — |
| View Reports quick action | ✓ | ✓ | — |
| View Payroll quick action | ✓ | ✓ | ✓ |
| Manage Users quick action | ✓ | — | — |
| Switch Sector quick action (sector chip) | ✓ (clickable) | — (read-only) | — (no chip) |
| Bottom nav tabs | Dashboard, Sales, Expenses, Payroll, Users, Reports | Dashboard, Sales, Expenses, Payroll, Reports | Dashboard, Payroll, Reports |

**Key logic:**
- Default sector on login: Owner = DYS Events (id=1); EM/Employee = assigned sector from Users.sector_id
- Sector switch triggers data refresh across Dashboard, Sales, Expenses, Reports
- Logout from avatar menu (clears token + sector state)
- All financial amounts displayed with peso sign (₱)

**Test coverage:** TC-FR002-01, TC-FR002-02, TC-FR002-03

### Phase 9 — Testing (Flutter)

- **Widget tests:** Screen rendering, navigation flows, role-based visibility, form validation, empty states
- **E2E tests:** Full user flows: login → record sale → view on dashboard, login → calculate payroll → verify expense created

### Phase 10 — Deployment (Flutter)

- Build flavors: dev, staging, production
- API base URL configuration per environment
- Release build artifacts (APK, App Bundle)

---

## 6. Database Milestones

### Migration Order

All 5 migrations run in Phase 1. The order matters for FK constraints:

1. `create_business_sectors_table` (no FK dependencies)
2. `create_users_table` (FK to business_sectors.id — nullable)
3. `create_sales_transactions_table` (FKs to users.id, business_sectors.id)
4. `create_expenses_table` (FKs to users.id, business_sectors.id, payroll_records.id — nullable)
5. `create_payroll_records_table` (FKs to users.id, business_sectors.id)

**Note:** Migration 5 must run before migration 4 due to Expenses → Payroll Records FK. If using a single migration file per table, the order is: BusinessSectors → Users → SalesTransactions → PayrollRecords → Expenses.

### Foreign Keys

| Migration | FK Column | References | On Delete | On Update |
|-----------|-----------|------------|-----------|-----------|
| Users | sector_id | business_sectors.id | SET NULL | CASCADE |
| Sales Transactions | user_id | users.id | RESTRICT | CASCADE |
| Sales Transactions | sector_id | business_sectors.id | RESTRICT | CASCADE |
| Expenses | user_id | users.id | RESTRICT | CASCADE |
| Expenses | sector_id | business_sectors.id | RESTRICT | CASCADE |
| Expenses | payroll_record_id | payroll_records.id | RESTRICT | CASCADE |
| Payroll Records | user_id | users.id | RESTRICT | CASCADE |
| Payroll Records | sector_id | business_sectors.id | RESTRICT | CASCADE |

### Seeders (Phase 1)

1. `BusinessSectorSeeder` — inserts 4 rows:
   - (1, "DYS Events", "Event coordination and styling main branch")
   - (2, "B&DYS", "Souvenirs")
   - (3, "Flavors by DYS", "Grazing tables and celebration drinks")
   - (4, "SnapDYS Memories", "Video guestbook")

2. `UserSeeder` — inserts 1 Business Owner:
   - (name: "Juan Dela Cruz", email: "owner@dys.com", role: "Business Owner", sector_id: null, account_status: "Active", password: BCrypt hashed)

### Development Seeders (Phase 9, for testing)

Per Test Case Specification:
- Event Manager: maria@dys.com, role=Event Manager, sector_id=2, Active
- Employee: ana@dys.com, role=Employee/Staff, sector_id=1, Active
- Inactive user: inactive@dys.com, role=Employee/Staff, sector_id=1, Inactive

### Indexes

| Table | Index | Type |
|-------|-------|------|
| Users | id | PRIMARY |
| Users | email | UNIQUE |
| Users | sector_id | INDEX (FK) |
| Business Sectors | id | PRIMARY |
| Business Sectors | name | UNIQUE |
| Sales Transactions | id | PRIMARY |
| Sales Transactions | user_id | INDEX (FK) |
| Sales Transactions | sector_id | INDEX (FK) |
| Sales Transactions | recorded_at | INDEX (for ordering) |
| Expenses | id | PRIMARY |
| Expenses | user_id | INDEX (FK) |
| Expenses | sector_id | INDEX (FK) |
| Expenses | payroll_record_id | INDEX (FK) |
| Expenses | recorded_at | INDEX (for ordering) |
| Payroll Records | id | PRIMARY |
| Payroll Records | user_id | INDEX (FK) |
| Payroll Records | sector_id | INDEX (FK) |
| Payroll Records | pay_period | INDEX (for filtering) |
| Payroll Records | calculated_at | INDEX (for ordering) |

---

## 7. Integration Milestones

### Frontend ↔ Backend

| Phase | Integration Point | Mechanism | Verification |
|:-----:|-------------------|-----------|--------------|
| 1 | Login/Logout | JSON POST, token returned in response | TC-FR001-01–04 |
| 1 | Sector list on login | default_sector in login response | TC-FR001-01, TC-FR001-02 |
| 2 | User CRUD | JSON GET/POST/PUT/PATCH with Bearer token | TC-FR003-01–07 |
| 3 | Sales CRUD | JSON GET/POST with Bearer token + sector_id param | TC-FR004-01–05 |
| 4 | Expenses CRUD | JSON GET/POST with Bearer token + sector_id param | TC-FR005-01–06 |
| 5 | Payroll calc + view | JSON POST (calc) + GET (history) | TC-FR006-01–08 |
| 6 | Reports | JSON GET with type/sector/date params | TC-FR007-01–05 |
| 7 | Sector switch | JSON POST with sector_id | TC-FR008-01–04 |
| 8 | Dashboard aggregation | Multiple GET calls on load | TC-FR002-01–03 |

**Common integration patterns:**
- Bearer token in `Authorization` header on all authenticated requests
- Sector context sent via `?sector_id=` query param or `X-Sector-ID` header
- All POST/PUT requests use JSON body with `Content-Type: application/json`
- Error responses follow standard envelope: `{ "message": "...", "errors": {...} }`

### API ↔ Database

| Constraint | Layer | Verification |
|------------|:-----:|:-------------|
| FK integrity | Database | Migration foreign key definitions |
| Unique email | Database + Backend | UNIQUE index + Laravel validation |
| ENUM values (role, account_status) | Database + Backend | ENUM column + request validation |
| Positive amounts | Backend | Request validation before write |
| Sector existence | Backend | exists:business_sectors,id validation |
| computed_salary derivation | Backend | Server-calculated in service layer |
| Auto-create Expense | Backend | DB transaction in PayrollService |

### Authentication Flow (Cross-Cutting)

```
Login (POST /api/login)
  → Validate credentials
  → Check account_status = Active
  → Determine role + default sector
  → Issue Sanctum token
  → Return { user, token, default_sector }
  → Flutter stores token (secure storage), sets sector context
  → Flutter redirects to Dashboard (role variant)

All subsequent requests:
  → Flutter loads token from secure storage
  → Attaches to Authorization: Bearer <token>
  → Laravel auth:sanctum middleware validates
  → Controller checks role authorization
  → Service executes business logic

Logout (POST /api/logout)
  → Revoke current token
  → Flutter clears token + sector state
  → Redirect to Login
```

### Payroll Workflow (Integration-Critical)

```
Flutter POST /api/payroll { user_id, hours_worked, hourly_rate, pay_period }
  → Backend validates: user exists, role ≠ BO, hours > 0, rate > 0
  → Backend computes: computed_salary = hours_worked × hourly_rate
  → DB transaction BEGIN:
      → INSERT into payroll_records (user_id, sector_id, hours_worked, hourly_rate, computed_salary, pay_period, calculated_at)
      → INSERT into expenses (user_id=BO, sector_id=employee.sector_id, amount=computed_salary, description="Payroll — {name} — {pay_period}", recorded_at=calculated_at, payroll_record_id=new_payroll.id)
  → DB transaction COMMIT
  → Return { PayrollRecord with nested Expense }
  → Flutter updates Payroll screen and Dashboard
```

### Reports Workflow (Integration-Critical)

```
Flutter GET /api/reports?type=summary&sector_id=1
  → Backend validates: role (Owner/EM), type (valid enum)
  → If EM: sector_id overridden to assigned sector
  → Aggregate queries:
      - SUM(sales.amount) WHERE sector_id = X
      - SUM(expenses.amount) WHERE sector_id = X
      - net_balance = total_sales - total_expenses
  → If Owner and no sector_id: cross-sector aggregation
  → Return { sector / sectors[], summary, period }
  → Flutter renders summary cards / charts
```

### Sector Switching Workflow

```
Flutter POST /api/business-sectors/switch { sector_id: 2 }
  → Backend validates: Owner role, sector exists
  → Returns { previous_sector, current_sector }
  → Flutter updates sector context state
  → Flutter re-fetches Dashboard, Sales, Expenses, Reports with new sector_id
```

---

## 8. Testing Milestones

Every phase milestone maps to specific test cases from `memory/blueprint/test-case-specification.md` (42 total).

### Phase 1 — Auth Tests (4 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR001-01 | BO login — success, default sector = DYS Events | Critical |
| TC-FR001-02 | EM login — success, default sector = assigned | Critical |
| TC-FR001-03 | Invalid credentials — generic error 401 | Critical |
| TC-FR001-04 | Inactive account — generic error 401, no status disclosure | High |

### Phase 2 — User Management Tests (7 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR003-01 | Create EM account — 201, temp password works | Critical |
| TC-FR003-02 | Create EE account — 201, view-only Dashboard | Critical |
| TC-FR003-03 | Duplicate email — 422 | High |
| TC-FR003-04 | Update user — name, email, sector change | High |
| TC-FR003-05 | Deactivate/reactivate — login blocked/restored | Critical |
| TC-FR003-06 | Non-Owner (EM/EE) forbidden — 403 all endpoints | Critical |
| TC-FR003-07 | List users — all returned, required fields present | High |

### Phase 3 — Sales Tests (5 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR004-01 | BO records sale — 201, persisted | Critical |
| TC-FR004-02 | EM records sale — sector overridden | Critical |
| TC-FR004-03 | Invalid amount — 422 | High |
| TC-FR004-04 | Employee forbidden — 403 | Critical |
| TC-FR004-05 | Sector scoping — BO filters, EM restricted | High |

### Phase 4 — Expenses Tests (6 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR005-01 | BO records expense — 201, payroll_record_id=null | Critical |
| TC-FR005-02 | EM records expense — sector overridden | Critical |
| TC-FR005-03 | Invalid amount — 422 | High |
| TC-FR005-04 | Employee forbidden — 403 | Critical |
| TC-FR005-05 | Sector scoping + manual vs system-generated | High |
| TC-FR005-06 | Payroll-generated expense linkage verified | Critical |

### Phase 5 — Payroll Tests (8 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR006-01 | Calculate payroll — 201, computed_salary correct, expense created | Critical |
| TC-FR006-02 | Expense auto-creation — FK linkage, amount match | Critical |
| TC-FR006-03 | Cannot calculate payroll for BO — 422 | High |
| TC-FR006-04 | Invalid hours/rate — 422 | High |
| TC-FR006-05 | EM views own payroll only | Critical |
| TC-FR006-06 | EE views own payroll only | Critical |
| TC-FR006-07 | Non-Owner calculate forbidden — 403 | Critical |
| TC-FR006-08 | BO views all payroll — cross-sector, filters work | Critical |

### Phase 6 — Reports Tests (5 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR007-01 | BO cross-sector summary report | High |
| TC-FR007-02 | BO analytics — charts + summary | High |
| TC-FR007-03 | EM sector-scoped reports — analytics forbidden | High |
| TC-FR007-04 | Employee reports forbidden — 403 | Critical |
| TC-FR007-05 | Report type/date/sector filtering — invalid type = 422 | High |

### Phase 7 — Sector Switching Tests (4 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR008-01 | BO switches sector — 200, context updated | High |
| TC-FR008-02 | Data refresh after switch — all screens update | High |
| TC-FR008-03 | Non-Owner switch forbidden — 403 | Critical |
| TC-FR008-04 | All roles list sectors — 200, 4 sectors returned | Medium |

### Phase 8 — Dashboard Tests (3 cases)

| TC ID | Description | Priority |
|-------|-------------|:--------:|
| TC-FR002-01 | BO Dashboard — 6 quick actions, 6-tab bottom nav, clickable sector chip | Critical |
| TC-FR002-02 | EM Dashboard — 4 quick actions, 5-tab bottom nav, read-only sector chip | Critical |
| TC-FR002-03 | Employee Dashboard — 1 quick action, 3-tab bottom nav | Critical |

### Phase 9 — Full Test Execution

Execute all 42 test cases. Acceptance criteria per Test Case Specification:

| # | Criterion |
|:-:|-----------|
| 1 | All 8 FRs tested (42 test cases executed) |
| 2 | All 25 Critical-priority test cases pass |
| 3 | All 15 High-priority test cases pass |
| 4 | Zero Critical defects remain open |
| 5 | Auth works for all 3 roles |
| 6 | Invalid/inactive credentials rejected with generic error |
| 7 | RBAC enforced at API (403) and UI (hidden controls) |
| 8 | BO can create, edit, deactivate, reactivate accounts |
| 9 | BO and EM can record sales and expenses |
| 10 | computed_salary = hours_worked × hourly_rate |
| 11 | Payroll auto-creates linked Expense |
| 12 | Role-filtered payroll (BO=all, EM=own, EE=own) |
| 13 | BO cross-sector + analytics reports |
| 14 | BO sector switching with data refresh |
| 15 | Validation rejects invalid data with correct error messages |
| 16 | No unsupported features/endpoints/screens present |

---

## 9. Risks

Only risks already documented in the approved blueprint are listed. No new risks are introduced.

### Documented Risks (from Concept Paper — Software Engineering Challenges)

| # | Risk | Source | Mitigation |
|:-:|------|--------|:-----------|
| R1 | **Password encryption and authentication security** | Concept Paper — Security | Sanctum token-based auth, BCrypt hashing, no plaintext passwords. Tested via TC-FR001-01–04. |
| R2 | **User adoption for users accustomed to manual processes** | Concept Paper — User Adoption | Mobile-first Flutter UI with role-specific simplified workflows. Wireframes reviewed with client. |
| R3 | **Data migration from manual formats** | Concept Paper — Data Migration | API endpoints support manual data entry. No bulk import defined in scope. Business Owner enters records directly. |

### Documented Constraints (from Concept Paper — Constraints)

| # | Constraint | Source | Impact |
|:-:|------------|--------|:--------|
| C1 | **Six-month project completion** | Concept Paper — Time Constraint | 10-phase plan must be scheduled within this window. No schedule dates in this document. |
| C2 | **Free/open-source tools only** | Concept Paper — Budget Constraint | Laravel 12, Flutter, MySQL, Sanctum. No paid services or licenses. |
| C3 | **Student developers with evolving skills** | Concept Paper — Technical Experience | Phase dependency graph ensures building-block approach. Each phase produces working deliverables before advancing. |

### Architectural Risks (Implied by Blueprint)

| # | Risk | Source | Mitigation |
|:-:|------|--------|:-----------|
| R4 | **No DELETE endpoints for transactional data** | API Specification — Business Rules | Sales, Expenses, and Payroll Records are immutable by design. Corrections require new entries. BR-17, BR-18, BR-19. |
| R5 | **Sector context managed client-side** | API Specification — Sector Context | Client must correctly send sector_id on all scoped requests. If lost, data may display incorrectly. Mitigated by role-based query filtering (EM/EE always scoped server-side). |
| R6 | **Temporary password visible only once** | API Specification — POST /users | BR-42: returned only in creation response. Business Owner must record and deliver manually. No retrieval endpoint. |

---

## 10. Readiness Checklist

| # | Criterion | Status | Notes |
|:-:|-----------|:------:|-------|
| 1 | All 8 Functional Requirements defined and approved | ✓ | FR-001 through FR-008 per FRS |
| 2 | All 16 API endpoints specified with request/response schemas | ✓ | API Specification — 16 endpoints |
| 3 | All 5 database tables designed with columns, types, FK constraints | ✓ | Database Schema + ERD |
| 4 | All 4 Business Sectors defined and seeded | ✓ | DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories |
| 5 | All 8 screens designed with Hi-Fi wireframes | ✓ | wireframes-hifi/ (8 HTML files) |
| 6 | All 3 user roles defined with explicit permissions | ✓ | BO, EM, EE per Project Memory |
| 7 | Validation rules documented for every input field | ✓ | Validation Rules Matrix (60 rules, 50 error messages) |
| 8 | Business rules documented and audited | ✓ | 44 business rules in Validation Rules Matrix |
| 9 | Navigation map complete with role-based routing | ✓ | Navigation Map — 8 screens, role-specific bottom nav |
| 10 | Module dependency graph validated | ✓ | Phase dependency graph matches FRS data flow |
| 11 | 42 test cases defined covering all 8 FRs | ✓ | Test Case Specification — all IDs present |
| 12 | Build order respects all dependencies | ✓ | 10-phase sequence with critical path identified |
| 13 | No invented features, endpoints, roles, or tables | ✓ | RTM confirms 100% traceability, zero orphans |
| 14 | Consistency audit passed against all source documents | ✓ | Roadmap audit: 20 artifacts verified |
| 15 | Authentication flow fully specified | ✓ | Sanctum + role-based + default sector |
| 16 | Payroll auto-create Expense workflow specified | ✓ | DB transaction in PayrollService |
| 17 | Sector context management specified | ✓ | Client-side with server-side overrides |
| 18 | Technology stack confirmed | ✓ | Flutter + Laravel 12 + MySQL + Sanctum |

**Result: All 18 criteria are met. The project is ready to begin coding.**

### Recommended Start Sequence

1. Set up Laravel 12 project with Sanctum
2. Create all 5 database migrations + seeders
3. Set up Flutter project with HTTP client, secure storage, routing shell
4. Build AuthController + Login screen
5. Verify login/logout end-to-end (TC-FR001-01 through TC-FR001-04)
6. Proceed to Phase 2 (User Account Management)

---

## Appendix A: Blueprint-to-Phase Mapping

| FR | Module | Phase | Test Cases |
|:--:|--------|:-----:|:-----------|
| FR-001 | Authentication | 1 | TC-FR001-01–04 (4) |
| FR-002 | Dashboard | 8 | TC-FR002-01–03 (3) |
| FR-003 | User Account Management | 2 | TC-FR003-01–07 (7) |
| FR-004 | Sales | 3 | TC-FR004-01–05 (5) |
| FR-005 | Expenses | 4 | TC-FR005-01–06 (6) |
| FR-006 | Payroll | 5 | TC-FR006-01–08 (8) |
| FR-007 | Reports | 6 | TC-FR007-01–05 (5) |
| FR-008 | Business Sector Switching | 7 | TC-FR008-01–04 (4) |

## Appendix B: API Endpoint-to-Phase Mapping

| Method | Route | Phase | FR |
|--------|-------|:-----:|:--:|
| POST | /api/login | 1 | FR-001 |
| POST | /api/logout | 1 | FR-001 |
| GET | /api/users | 2 | FR-003 |
| POST | /api/users | 2 | FR-003 |
| GET | /api/users/{id} | 2 | FR-003 |
| PUT | /api/users/{id} | 2 | FR-003 |
| PATCH | /api/users/{id}/status | 2 | FR-003 |
| GET | /api/sales | 3 | FR-004 |
| POST | /api/sales | 3 | FR-004 |
| GET | /api/expenses | 4 | FR-005 |
| POST | /api/expenses | 4 | FR-005 |
| GET | /api/payroll | 5 | FR-006 |
| POST | /api/payroll | 5 | FR-006 |
| GET | /api/reports | 6 | FR-007 |
| GET | /api/business-sectors | 7 | FR-008 |
| POST | /api/business-sectors/switch | 7 | FR-008 |

## Appendix C: Roadmap Audit Notes

The following minor observations were identified during audit of `memory/development/development-roadmap.md` against the approved blueprint. These do not block development:

| # | Observation | Location | Note |
|:-:|-------------|----------|------|
| 1 | Build Order row 5 says "Business Sectors API + Sector data — Phase 1" but Phase 1 only seeds sector data. The Business Sectors controller and API endpoints are correctly placed in Phase 7. | Build Order Summary vs Phase 1 & 7 details | No effect on build order. Follow Phase 1 (seed only) and Phase 7 (controller + endpoints). |
| 2 | Phase 1 lists "Database migrations for all 5 tables" but Phases 4 and 5 list "Expenses migration" and "Payroll Records migration" as deliverables. | Phase 1, 4, 5 deliverables | All 5 tables are migrated in Phase 1. The Phase 4/5 references are redundant. Actual work in those phases is controller/service creation. |

No other inconsistencies were found.
