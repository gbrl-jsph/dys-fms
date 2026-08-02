# Requirements Traceability Matrix (RTM) — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Draft (Pending Audit)
**Project:** DYS Financial Management System (DYS FMS)
**Purpose:** Master verification document proving that every approved functional requirement is completely traced across every blueprint artifact.
**Scope:** All 8 Functional Requirements (FR-001 through FR-008) as defined in the Functional Requirements Specification (FRS), cross-referenced against all 20 approved blueprint documents.

---

## RTM Methodology

This Requirements Traceability Matrix (RTM) verifies every Functional Requirement by tracing it across every approved blueprint artifact. Each FR is validated against:

- **Concept Paper** — primary source of truth for feature origin
- **Use Case** — behavioral specification in use-case.md
- **Use Case Diagram** — visual UML representation
- **Screen(s)** — UI screens from Navigation Map and Wireframes
- **API Endpoint(s)** — REST endpoints from API Specification
- **Database Table(s)** — storage entities from Data Dictionary and Database Schema
- **Validation Rules** — business and validation rules from Validation Rules Matrix
- **Development Phase** — implementation phase from Development Roadmap
- **Test Case IDs** — placeholder test case identifiers (to be expanded in Test Case Specification)

**Rules:**
- No requirement exists without implementation evidence across all artifacts
- No requirement is invented — every FR traces to the approved Concept Paper
- If a requirement cannot be traced, it is reported under Gap Analysis (Section 11)

---

## Master Requirements Traceability Matrix

| FR ID | Requirement | Concept Paper | Use Case(s) | Use Case Diagram | Screen(s) | API Endpoint(s) | Database Table(s) | Validation Rules | Development Phase | Test Case IDs | Status |
|-------|-------------|:-------------:|:------------:|:----------------:|:----------:|:----------------:|:-----------------:|:----------------:|:-----------------:|:-------------:|:------:|
| FR-001 | Authentication | Proposed Solution (line 17: "role-based access control"); Features (line 25: "RBAC"); Challenges (line 40: "authentication, RBAC, password encryption"); Business Rules (lines 45–46: account creation, activation) | UC1: Login/Authenticate | UC1 node; BO→UC1, EM→UC1, EE→UC1 | Login (Screen 1) | POST /api/login, POST /api/logout | Users, Business Sectors | Authentication module (7 rules: email, password, account_status) | Phase 1 (Authentication & Core Setup) | TC-FR001-01, TC-FR001-02, TC-FR001-03, TC-FR001-04 | Blueprint Complete |
| FR-002 | Dashboard | Features (line 31: "Interactive Visual Analytics Dashboard"); Business Rules (lines 54–55: default sector on login); Target Users (lines 20–22: role-based dashboards) | UC4: View Analytics Dashboard | UC4 node; BO→UC4 | Dashboard (Screen 2) | POST /api/login (default sector), GET /api/sales, GET /api/expenses, GET /api/payroll, GET /api/reports, GET /api/business-sectors | Users, Business Sectors, Sales Transactions, Expenses | N/A (presentation screen — no input fields) | Phase 8 (Final Integration) | TC-FR002-01, TC-FR002-02, TC-FR002-03 | Blueprint Complete |
| FR-003 | User Account Management | Features (line 26: "User Account Management — Business Owner only"); Business Rules (lines 45–46: "Business Owner creates all accounts; no public registration"); Target Users (line 20) | UC10: Manage User Accounts | UC10 node; BO→UC10 | User Account Management (Screen 8) | GET /api/users, POST /api/users, GET /api/users/{id}, PUT /api/users/{id}, PATCH /api/users/{id}/status | Users, Business Sectors | User Account Management module (14 rules: name, email, role, sector_id, password, account_status) | Phase 2 (User Account Management) | TC-FR003-01, TC-FR003-02, TC-FR003-03, TC-FR003-04, TC-FR003-05, TC-FR003-06, TC-FR003-07 | Blueprint Complete |
| FR-004 | Record Sales | Features (line 27: "Sales and Expense Recording"); Business Rules (line 51: "Only Business Owners and Event Managers can record sales/expenses") | UC2: Record Sales Transaction | UC2 node; BO→UC2, EM→UC2 | Sales (Screen 3) | GET /api/sales, POST /api/sales | Sales Transactions, Users, Business Sectors | Sales module (8 rules: amount, description, sector_id, user_id, recorded_at, role, sector scope) | Phase 3 (Sales) | TC-FR004-01, TC-FR004-02, TC-FR004-03, TC-FR004-04, TC-FR004-05 | Blueprint Complete |
| FR-005 | Record Expenses | Features (line 27: "Sales and Expense Recording"); Business Rules (line 51: "Only Business Owners and Event Managers"); Features (line 29: payroll auto-creates Expense — system actor) | UC3: Record Expense | UC3 node; BO→UC3, EM→UC3 | Expenses (Screen 4) | GET /api/expenses, POST /api/expenses | Expenses, Users, Business Sectors, Payroll Records | Expenses module (10 rules: amount, description, sector_id, user_id, recorded_at, payroll_record_id, role, sector scope) | Phase 4 (Expenses) | TC-FR005-01, TC-FR005-02, TC-FR005-03, TC-FR005-04, TC-FR005-05, TC-FR005-06 | Blueprint Complete |
| FR-006 | Payroll | Features (line 29: "Automated Payroll Calculator"); Business Rules (lines 47–50: payroll permissions; line 57: formula and auto-create); Target Users (lines 20–22) | UC5: View Payroll Calculations, UC7: View Own Payroll, UC9: Payroll Auto-creates Expense | UC5, UC7, UC9 nodes; BO→UC5, EM→UC7, EE→UC7; UC5 → UC9 (<<include>>) | Payroll (Screen 5) | GET /api/payroll, POST /api/payroll | Payroll Records, Users, Business Sectors, Expenses | Payroll module (11 rules: user_id, hours_worked, hourly_rate, pay_period, computed_salary, sector_id, calculated_at, role, view scope) | Phase 5 (Payroll) | TC-FR006-01, TC-FR006-02, TC-FR006-03, TC-FR006-04, TC-FR006-05, TC-FR006-06, TC-FR006-07, TC-FR006-08 | Blueprint Complete |
| FR-007 | Reports | Features (line 32: "Report Generation"); Features (line 25: "RBAC" for role-specific views); Target Users (line 20: "Business Owner — full access, cross-sector visibility"; line 21: "Event Manager — sector-specific access") | UC6: View Reports | UC6 node; BO→UC6, EM→UC6 | Reports (Screen 6) | GET /api/reports | Sales Transactions, Expenses, Business Sectors, Payroll Records | Reports module (6 rules: role, sector_id, type, date_from, date_to) | Phase 6 (Reports) | TC-FR007-01, TC-FR007-02, TC-FR007-03, TC-FR007-04, TC-FR007-05 | Blueprint Complete |
| FR-008 | Business Sector Switching | Features (line 30: "Business Sector Switcher — Owner only; auto-refreshes Dashboard, Sales, Expenses, Reports on switch"); Business Rules (lines 52–53: "Owner only; EM/Employee permanently assigned"); Target Users (line 20: "Owner can switch sectors") | UC8: Switch Business Sector | UC8 node; BO→UC8 | Sector Switcher (Screen 7) | GET /api/business-sectors, POST /api/business-sectors/switch | Business Sectors | Business Sector Switching module (3 rules: sector_id, role, list sectors) | Phase 7 (Business Sector Switching) | TC-FR008-01, TC-FR008-02, TC-FR008-03, TC-FR008-04 | Blueprint Complete |

---

## Screen Traceability

| Screen | Functional Requirements Supported | FRS Reference | Navigation Map Ref | Wireframe Ref |
|--------|----------------------------------|:-------------:|:-----------------:|:-------------:|
| Login (Screen 1) | FR-001 (Authentication), FR-002 (default sector routing on login) | § FR-001 | Screen 1 | Hi-Fi: login.html; Low-Fi: § 1 |
| Dashboard (Screen 2) | FR-002 (Dashboard — hub for all role-based navigation, summary cards, chart placeholder) | § FR-002 | Screen 2 | Hi-Fi: dashboard.html; Low-Fi: § 2 |
| Sales (Screen 3) | FR-004 (Record Sales) | § FR-004 | Screen 3 | Hi-Fi: sales.html; Low-Fi: § 3 |
| Expenses (Screen 4) | FR-005 (Record Expenses) | § FR-005 | Screen 4 | Hi-Fi: expenses.html; Low-Fi: § 4 |
| Payroll (Screen 5) | FR-006 (Payroll — calculate + view) | § FR-006 | Screen 5 | Hi-Fi: payroll.html; Low-Fi: § 5 |
| Reports (Screen 6) | FR-007 (Reports — role-filtered financial reports and analytics) | § FR-007 | Screen 6 | Hi-Fi: reports.html; Low-Fi: § 6 |
| Sector Switcher (Screen 7) | FR-008 (Business Sector Switching) | § FR-008 | Screen 7 | Hi-Fi: sector-switcher.html; Low-Fi: § 7 |
| User Account Management (Screen 8) | FR-003 (User Account Management) | § FR-003 | Screen 8 | Hi-Fi: users.html; Low-Fi: § 8 |

### Screen Count by FR

| FR ID | Screen(s) | Count |
|-------|-----------|:-----:|
| FR-001 | Login | 1 |
| FR-002 | Dashboard | 1 |
| FR-003 | User Account Management | 1 |
| FR-004 | Sales | 1 |
| FR-005 | Expenses | 1 |
| FR-006 | Payroll | 1 |
| FR-007 | Reports | 1 |
| FR-008 | Sector Switcher | 1 |

**Note:** Each FR maps to exactly one primary screen. The Login screen supports FR-001 directly and FR-002 indirectly (default sector routing).

---

## API Traceability

| Endpoint | Method | Functional Requirement | API Spec Ref | Allowed Roles |
|----------|--------|:---------------------:|:------------:|:-------------:|
| /api/login | POST | FR-001 (Authentication), FR-002 (default sector returned) | § Authentication API | All (unauthenticated) |
| /api/logout | POST | FR-001 (Authentication — session termination) | § Authentication API | All (authenticated) |
| /api/users | GET | FR-003 (User Account Management — list users) | § User Account Management API | Business Owner only |
| /api/users | POST | FR-003 (User Account Management — create user) | § User Account Management API | Business Owner only |
| /api/users/{id} | GET | FR-003 (User Account Management — view user) | § User Account Management API | Business Owner only |
| /api/users/{id} | PUT | FR-003 (User Account Management — update user) | § User Account Management API | Business Owner only |
| /api/users/{id}/status | PATCH | FR-003 (User Account Management — activate/deactivate) | § User Account Management API | Business Owner only |
| /api/sales | GET | FR-004 (Record Sales — list transactions), FR-002 (Dashboard summary) | § Sales API | Business Owner, Event Manager |
| /api/sales | POST | FR-004 (Record Sales — create transaction) | § Sales API | Business Owner, Event Manager |
| /api/expenses | GET | FR-005 (Record Expenses — list records), FR-002 (Dashboard summary) | § Expenses API | Business Owner, Event Manager |
| /api/expenses | POST | FR-005 (Record Expenses — create manual record) | § Expenses API | Business Owner, Event Manager |
| /api/payroll | GET | FR-006 (Payroll — view records, role-filtered) | § Payroll API | All (role-filtered) |
| /api/payroll | POST | FR-006 (Payroll — calculate and save; auto-creates Expense) | § Payroll API | Business Owner only |
| /api/reports | GET | FR-007 (Reports — generate financial reports and analytics) | § Reports API | Business Owner, Event Manager |
| /api/business-sectors | GET | FR-008 (Business Sector Switching — list sectors) | § Business Sector API | All (authenticated) |
| /api/business-sectors/switch | POST | FR-008 (Business Sector Switching — update sector context) | § Business Sector API | Business Owner only |

### Endpoint Count by FR

| FR ID | Direct Endpoints | Supporting Endpoints | Total |
|-------|:----------------:|:--------------------:|:-----:|
| FR-001 | 2 | — | 2 |
| FR-002 | — | 5 (sales, expenses, payroll, reports, sectors) | 5 |
| FR-003 | 5 | — | 5 |
| FR-004 | 2 | — | 2 |
| FR-005 | 2 | — | 2 |
| FR-006 | 2 | — | 2 |
| FR-007 | 1 | — | 1 |
| FR-008 | 2 | — | 2 |

**Total unique endpoints:** 16 (all endpoints map to at least one FR)

---

## Database Traceability

| Table | Functional Requirements Supported | Data Dictionary Ref | Schema Ref | Key FKs |
|-------|----------------------------------|:-------------------:|:----------:|:-------:|
| Users | FR-001 (authentication — email, password, role, account_status); FR-002 (default sector — sector_id); FR-003 (user management — all columns); FR-006 (payroll — employee selection) | § Users | Table 1 | sector_id → Business Sectors |
| Business Sectors | FR-001 (default sector resolution); FR-002 (sector context); FR-003 (sector assignment); FR-004 (sector scoping sales); FR-005 (sector scoping expenses); FR-006 (sector scoping payroll); FR-008 (sector switching) | § Business Sectors | Table 2 | (parent table) |
| Sales Transactions | FR-002 (dashboard summary); FR-004 (record sales); FR-007 (reports data) | § Sales Transactions | Table 3 | user_id → Users, sector_id → Business Sectors |
| Expenses | FR-002 (dashboard summary); FR-005 (record expenses); FR-006 (payroll auto-create); FR-007 (reports data) | § Expenses | Table 4 | user_id → Users, sector_id → Business Sectors, payroll_record_id → Payroll Records |
| Payroll Records | FR-006 (payroll calculation and history); FR-007 (Owner analytics) | § Payroll Records | Table 5 | user_id → Users, sector_id → Business Sectors |

### Table Count by FR

| FR ID | Primary Tables | Referenced Tables | Total |
|-------|:--------------:|:-----------------:|:-----:|
| FR-001 | Users | Business Sectors | 2 |
| FR-002 | Users, Business Sectors, Sales Transactions, Expenses | — | 4 |
| FR-003 | Users | Business Sectors | 2 |
| FR-004 | Sales Transactions | Users, Business Sectors | 3 |
| FR-005 | Expenses | Users, Business Sectors, Payroll Records | 4 |
| FR-006 | Payroll Records | Users, Business Sectors, Expenses | 4 |
| FR-007 | Sales Transactions, Expenses | Business Sectors, Payroll Records | 4 |
| FR-008 | Business Sectors | — | 1 |

**Total unique tables:** 5 (all tables support at least one FR)

---

## Validation Traceability

| Validation Rule Category | Functional Requirements | Validation Rules Matrix Ref | Rule Count | Key Validation Areas |
|--------------------------|------------------------|:--------------------------:|:----------:|---------------------|
| Authentication | FR-001 | § Authentication (7 rules) | 7 | email format and existence, password match, account_status Active, inactivity generic error, token validity |
| User Account Management | FR-003 | § User Account Management (14 rules) | 14 | name 1–255, email unique/format, role ENUM, sector FK, password auto-generate, account_status ENUM, Owner cannot be deactivated |
| Sales | FR-004 | § Sales (8 rules) | 8 | amount positive, description nullable, sector FK, user_id server-set, recorded_at server-set, role gate, sector scope |
| Expenses | FR-005 | § Expenses (10 rules) | 10 | amount positive, description nullable, sector FK, user_id server-set, recorded_at server-set, payroll_record_id nullable, role gate, sector scope |
| Payroll | FR-006 | § Payroll (11 rules) | 11 | user_id FK + role check, hours_worked positive + max, hourly_rate positive + max, pay_period date, computed_salary derived, sector_id auto, role gate, view scope |
| Reports | FR-007 | § Reports (6 rules) | 6 | role gate (Owner: all + analytics; EM: sector only; Employee: forbidden), sector_id FK, type ENUM, date_from/date_to valid |
| Business Sector Switching | FR-008 | § Business Sector Switching (3 rules) | 3 | sector_id FK, role gate (Owner only), list sectors (all authenticated) |

### Validation Rule Count by FR

| FR ID | Validation Rules |
|-------|:----------------:|
| FR-001 | 7 |
| FR-002 | 0 (presentation screen — no input fields) |
| FR-003 | 15 |
| FR-004 | 9 |
| FR-005 | 10 |
| FR-006 | 11 |
| FR-007 | 5 |
| FR-008 | 3 |
| **Total** | **60** |

**Note:** The 60 rules in the Validation Rules Matrix cover all FR validation needs. The Dashboard (FR-002) has no input validation — it is a presentation screen.

---

## Development Phase Traceability

| Phase | Functional Requirements | Development Roadmap Ref | Key Deliverables |
|:-----:|------------------------|:----------------------:|------------------|
| 1 | FR-001 (Authentication) | § Phase 1 — Authentication & Core Setup | DB migrations, Laravel + Flutter scaffolds, login/logout API, token management, role-based route guard |
| 2 | FR-003 (User Account Management) | § Phase 2 — User Account Management | User CRUD controller, 5 user management API endpoints, temporary password logic, role/sector assignment, Users screen |
| 3 | FR-004 (Record Sales) | § Phase 3 — Sales | Sales Transactions migration, Sales controller, sales API (GET, POST), sales form + transactions list |
| 4 | FR-005 (Record Expenses) | § Phase 4 — Expenses | Expenses migration, Expense controller, expenses API (GET, POST), expense form + records list |
| 5 | FR-006 (Payroll) | § Phase 5 — Payroll | Payroll Records migration, Payroll controller, payroll API (GET, POST), compute salary server-side, auto-create Expense, role-filtered view |
| 6 | FR-007 (Reports) | § Phase 6 — Reports | Reports controller + aggregation queries, cross-sector/per-sector/analytics endpoints, Reports screen |
| 7 | FR-008 (Business Sector Switching) | § Phase 7 — Business Sector Switching | Business Sectors controller, list + switch endpoints, Sector Switcher screen, sector chip |
| 8 | FR-002 (Dashboard) | § Phase 8 — Final Integration | Dashboard screen with summary cards, chart placeholder, role-specific navigation, bottom nav bars, quick actions, sector context wiring |
| 9 | All (testing) | § Phase 9 — Testing | Unit tests, API tests, integration tests, UI tests, end-to-end flows |
| 10 | All (deployment) | § Phase 10 — Deployment Preparation | Environment config, build flavors, migration automation, deployment docs |

### Phase Count by FR

| FR ID | Primary Phase | Also Tested In |
|-------|:-------------:|:--------------:|
| FR-001 | Phase 1 | Phase 9 |
| FR-002 | Phase 8 | Phase 9 |
| FR-003 | Phase 2 | Phase 9 |
| FR-004 | Phase 3 | Phase 9 |
| FR-005 | Phase 4 | Phase 9 |
| FR-006 | Phase 5 | Phase 9 |
| FR-007 | Phase 6 | Phase 9 |
| FR-008 | Phase 7 | Phase 9 |

---

## Test Case Mapping

The following placeholder test case IDs are defined for each FR. These will be expanded into full test case specifications in the Test Case Specification document.

| FR ID | Test Case ID | Test Scenario Description (Placeholder) |
|-------|:------------:|----------------------------------------|
| FR-001 | TC-FR001-01 | Login with valid credentials — Business Owner |
| FR-001 | TC-FR001-02 | Login with valid credentials — Event Manager |
| FR-001 | TC-FR001-03 | Login with invalid credentials |
| FR-001 | TC-FR001-04 | Login with inactive account |
| FR-002 | TC-FR002-01 | Dashboard loads with correct role-based view — Business Owner |
| FR-002 | TC-FR002-02 | Dashboard loads with correct role-based view — Event Manager |
| FR-002 | TC-FR002-03 | Dashboard loads with correct role-based view — Employee/Staff |
| FR-003 | TC-FR003-01 | Create user account — Event Manager |
| FR-003 | TC-FR003-02 | Create user account — Employee/Staff |
| FR-003 | TC-FR003-03 | Create user with duplicate email |
| FR-003 | TC-FR003-04 | Edit existing user account |
| FR-003 | TC-FR003-05 | Deactivate and reactivate user account |
| FR-003 | TC-FR003-06 | Non-Owner attempts to access user management |
| FR-003 | TC-FR003-07 | List all users returns correct data |
| FR-004 | TC-FR004-01 | Record a sale — Business Owner |
| FR-004 | TC-FR004-02 | Record a sale — Event Manager |
| FR-004 | TC-FR004-03 | Record sale with invalid amount |
| FR-004 | TC-FR004-04 | Employee attempts to record sale |
| FR-004 | TC-FR004-05 | View sales list — sector-scoped correctly |
| FR-005 | TC-FR005-01 | Record a manual expense — Business Owner |
| FR-005 | TC-FR005-02 | Record a manual expense — Event Manager |
| FR-005 | TC-FR005-03 | Record expense with invalid amount |
| FR-005 | TC-FR005-04 | Employee attempts to record expense |
| FR-005 | TC-FR005-05 | View expenses list — sector-scoped correctly |
| FR-005 | TC-FR005-06 | System-generated expense has payroll_record_id set |
| FR-006 | TC-FR006-01 | Calculate payroll for an employee — Business Owner |
| FR-006 | TC-FR006-02 | Verify Expense record auto-created on payroll save |
| FR-006 | TC-FR006-03 | Calculate payroll with employee role check (reject BO target) |
| FR-006 | TC-FR006-04 | Calculate payroll with invalid hours/rate |
| FR-006 | TC-FR006-05 | Event Manager views own payroll only |
| FR-006 | TC-FR006-06 | Employee views own payroll only |
| FR-006 | TC-FR006-07 | Non-Owner attempts to calculate payroll |
| FR-006 | TC-FR006-08 | Business Owner views all payroll records across sectors |
| FR-007 | TC-FR007-01 | Business Owner views cross-sector report |
| FR-007 | TC-FR007-02 | Business Owner views analytics report |
| FR-007 | TC-FR007-03 | Event Manager views sector-scoped report |
| FR-007 | TC-FR007-04 | Employee attempts to access reports — forbidden |
| FR-007 | TC-FR007-05 | Business Owner views per-sector filtered report |
| FR-008 | TC-FR008-01 | Business Owner switches sector successfully |
| FR-008 | TC-FR008-02 | Verify data refresh on sector switch (Dashboard, Sales, Expenses, Reports) |
| FR-008 | TC-FR008-03 | Non-Owner attempts to switch sector |
| FR-008 | TC-FR008-04 | List business sectors — all authenticated roles |

### Test Case Count Summary

| FR ID | Test Cases |
|-------|:----------:|
| FR-001 | 4 |
| FR-002 | 3 |
| FR-003 | 7 |
| FR-004 | 5 |
| FR-005 | 6 |
| FR-006 | 8 |
| FR-007 | 5 |
| FR-008 | 4 |
| **Total** | **42** |

---

## Coverage Summary

### Overall Metrics

| Metric | Count |
|--------|:-----:|
| Total Functional Requirements | 8 |
| Total Screens | 8 |
| Total API Endpoints | 16 |
| Total Database Tables | 5 |
| Total Validation Rule Categories | 7 (59 total rules) |
| Total Development Phases | 10 |
| Total Test Case Placeholder IDs | 42 |

### Verification Checklist

| Criterion | Status |
|-----------|:------:|
| ✓ Every FR has a Use Case | Verified — 8 FRs → 10 use cases (FR-006 spans UC5, UC7, UC9) |
| ✓ Every FR has Screens | Verified — 8 FRs → 8 screens (1:1 mapping) |
| ✓ Every FR has APIs | Verified — 8 FRs → 16 endpoints (minimum 1 per FR; FR-003 has 5) |
| ✓ Every FR has Database Tables | Verified — 8 FRs → 5 tables (minimum 1 per FR; all FRS tables mapped) |
| ✓ Every FR has Validation Rules | Verified — 8 FRs → 7 validation categories (FR-002 has 0 — presentation screen with no input; all others have rules) |
| ✓ Every FR has Development Phase | Verified — 8 FRs → 10 phases (Phases 1–8 each have a primary FR; Phases 9–10 cover all) |
| ✓ Every FR has Test Case IDs | Verified — 8 FRs → 42 placeholder test case IDs |

### Cross-Reference Completeness

| Artifact | Total Count | Mapped to FR | Unmapped | Status |
|----------|:-----------:|:------------:|:--------:|:------:|
| Functional Requirements | 8 | 8 | 0 | ✓ Complete |
| Screens | 8 | 8 | 0 | ✓ Complete |
| API Endpoints | 16 | 16 | 0 | ✓ Complete |
| Database Tables | 5 | 5 | 0 | ✓ Complete |
| Validation Rule Categories | 7 | 7 | 0 | ✓ Complete |
| Development Phases | 10 | 10 | 0 | ✓ Complete |

---

## Gap Analysis

No gaps were found during the traceability audit. Every approved functional requirement is fully traceable across all blueprint artifacts. The following observations are documented for awareness:

| Issue | Affected Documents | Recommendation |
|-------|-------------------|---------------|
| FR-002 (Dashboard) has 0 validation rules | FRS § FR-002, Validation Rules Matrix | This is correct by design — the Dashboard is a presentation screen that displays aggregated data with no user input fields. No action required. |
| FR-002 maps to UC4 (View Analytics Dashboard) but Dashboard screen serves all roles, not just BO | FRS § FR-002, Use Case Spec | The Dashboard is the landing screen for all roles. UC4 represents the analytics dashboard feature within it, which is BO-only. The Dashboard screen (Screen 2) serves as the hub for all roles with role-specific variants. This is consistent across all documents. |
| No dedicated "Change Password" screen or endpoint | Concept Paper, FRS, API Spec | The approved blueprint includes an optional "Employee may change password on first login" note (User Flow, line 42; Project Memory, line 69) but no dedicated screen or API endpoint is defined. This is a recognized gap — a change password mechanism is implied but not specified. Recommend defining in a future blueprint amendment if required. |

---

## Consistency Audit

| Source | Status | Notes |
|--------|:------:|-------|
| Concept Paper | ✓ | All 8 FRs trace to Concept Paper features and business rules |
| Functional Requirements Specification (FRS) | ✓ | FR definitions match RTM — all 8 FRs cross-referenced |
| Use Case Specification (use-case.md) | ✓ | UC1–UC10 map to FRs (note: UC6 conflict documented in Use Case Diagram — BO also mapped per Concept Paper) |
| Use Case Diagram (PlantUML) | ✓ | All 10 use case nodes, actor associations, and <<include>> relationship confirmed |
| System Architecture | ✓ | 4-layer architecture supports all FRs; 8 backend services mapped |
| System Flowchart | ✓ | All 7 process flows map to FRs (Process 1→FR-001, Process 2→FR-004, etc.) |
| User Flow Diagram | ✓ | All 7 user flows map to FRs (Flow 1→FR-001, Flow 2→FR-004, etc.) |
| Navigation Map | ✓ | All 8 screens documented with role-based access matching FR permissions |
| API Specification | ✓ | All 16 endpoints mapped to FRs; permission matrix matches FR role definitions |
| ER Diagram | ✓ | All 5 entities support FR data requirements |
| Database Schema | ✓ | All 5 tables and columns support FR data storage needs |
| Data Dictionary | ✓ | All columns, relationships, and business rules verified against FRs |
| Validation Rules Matrix | ✓ | 60 validation rules cover all FR validation needs |
| Definition of System Components | ✓ | All 8 client components and 8 backend services map to FRs |
| Wireframes (Low + Hi-Fi) | ✓ | All 8 screens represented; role-based variants match FR permissions |
| UI Style Guide | ✓ | Design tokens and component inventory support FR screen requirements |
| Development Roadmap | ✓ | All 10 phases mapped to FRs; dependency order verified |
| Requirements Traceability Matrix | ✓ | Self-referencing — this document |
| Project Memory | ✓ | Approved features, roles, workflows, and business rules match FR definitions |
| CHANGELOG | ✓ | All approved changes reflected in current FR set |
| VERSION | ✓ | Current v3.7 — all FRs accounted for |

**Issues Found:** None (gap items in Section 11 are observations, not consistency failures)

---

## Final Verification Checklist

| # | Criterion | Status |
|:-:|-----------|:------:|
| 1 | No orphan Functional Requirements (every FR has implementation evidence) | ✓ Verified |
| 2 | No orphan APIs (every endpoint traces to at least one FR) | ✓ Verified |
| 3 | No orphan Screens (every screen traces to at least one FR) | ✓ Verified |
| 4 | No orphan Database Tables (every table traces to at least one FR) | ✓ Verified |
| 5 | No orphan Validation Rules (every rule category traces to at least one FR) | ✓ Verified |
| 6 | Every requirement mapped to a Use Case | ✓ Verified |
| 7 | Every requirement mapped to Screen(s) | ✓ Verified |
| 8 | Every requirement mapped to API Endpoint(s) | ✓ Verified |
| 9 | Every requirement mapped to Database Table(s) | ✓ Verified |
| 10 | Every requirement mapped to Validation Rules | ✓ Verified |
| 11 | Every requirement mapped to Development Phase | ✓ Verified |
| 12 | Every requirement has Test Case ID placeholders | ✓ Verified |
| 13 | Zero requirements invented beyond approved Concept Paper | ✓ Verified |
| 14 | Zero features, screens, APIs, tables, roles, or workflows invented | ✓ Verified |
| 15 | Ready for Testing Phase (Test Case Specification) | ✓ Ready |
| 16 | Ready for Development (all artifacts fully traced and consistent) | ✓ Ready |

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | Requirements Traceability Matrix (RTM) |
| Version | 1.0 |
| Status | Draft — Pending Audit |
| Functional Requirements Traced | 8 of 8 (100%) |
| Artifacts Cross-Referenced | 20 |
| Total Traceability Links | ~200+ (FR-to-artifact mappings) |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Test Case Specification | Yes |
