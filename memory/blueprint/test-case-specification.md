# Test Case Specification — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Draft
**Project:** DYS Financial Management System (DYS FMS)

---

## 1. Document Information

### Purpose

This document defines all 42 test cases for the DYS Financial Management System. Each test case is derived exclusively from the approved blueprint documents and verifies one or more Functional Requirements (FR-001 through FR-008). No feature, API, screen, role, workflow, or validation rule is introduced beyond what is documented in the approved source of truth.

### Scope

| In Scope | Out of Scope |
|----------|--------------|
| Authentication and role-based access (FR-001) | Performance / load / stress testing |
| Role-based dashboard rendering (FR-002) | Security penetration testing |
| User account CRUD by Business Owner (FR-003) | Cross-browser or device compatibility |
| Sales transaction recording and viewing (FR-004) | Backup and recovery testing |
| Expense recording — manual and system-generated (FR-005) | Network failure / reconnection scenarios |
| Payroll calculation, viewing, and auto-expense creation (FR-006) | Push notifications, email, SMS |
| Financial report generation (FR-007) | Payment gateway integration |
| Business sector switching and listing (FR-008) | QR code scanning |
| Role-based access control enforcement (all FRs) | Forgot Password / password reset / self-registration |
| Input validation and error messaging (all FRs with input) | MFA, OTP, CAPTCHA, email verification |

### References

| Document | File | Version |
|----------|------|---------|
| Concept Paper | `memory/concept-paper.md` | Frozen |
| Functional Requirements Specification | `memory/blueprint/functional-requirements-specification.md` | Draft |
| Requirements Traceability Matrix | `memory/blueprint/requirements-traceability-matrix.md` | Draft |
| API Specification | `memory/blueprint/api-specification.md` | Draft |
| Validation Rules Matrix | `memory/blueprint/validation-rules.md` | Approved |
| Use Case Diagram | `memory/blueprint/use-case-diagram.md` | Draft |
| Use Case Specification | `memory/blueprint/use-case.md` | Draft |
| Navigation Map | `memory/blueprint/navigation-map.md` | Draft |
| Database Schema | `memory/blueprint/database-schema.md` | Draft |
| System Architecture | `memory/blueprint/system-architecture.md` | Draft |
| System Flowchart | `memory/blueprint/system-flowchart.md` | Draft |
| User Flow | `memory/blueprint/user-flow.md` | Draft |
| System Components | `memory/system-components.md` | Draft |
| UI Style Guide | `memory/blueprint/ui-style-guide.md` | Draft |
| Development Roadmap | `memory/blueprint/development-roadmap.md` | Draft |
| Project Memory | `memory/project-memory.md` | Draft |
| VERSION | `memory/VERSION.md` | Current v3.7 |

---

## 2. Test Strategy

### Functional Testing

Every test case validates that the system behaves according to the approved business rules and workflows defined in the FRS, Concept Paper, and Use Case Specification. Functional tests cover complete end-to-end scenarios: login → role-based navigation → data entry → persistence → retrieval → role-appropriate display.

### API Testing

All 16 approved API endpoints are tested for correct HTTP status codes, request validation, response payload structure, authorization enforcement, and error handling. API tests use direct HTTP requests against the backend and verify responses against the API Specification and Validation Rules Matrix.

### UI Testing

Role-based screen rendering and navigation are verified for all 8 approved screens. UI tests confirm that each role (Business Owner, Event Manager, Employee/Staff) sees the correct set of controls, navigation items, and data scoping per the Navigation Map and FRS.

### Validation Testing

Input validation is tested for every field that accepts user input. Test cases verify that invalid data (missing, out-of-range, wrong type, duplicate) is rejected with the correct HTTP status code (422) and the exact error message defined in the Validation Rules Matrix.

### Authorization / RBAC Testing

Role-based access control is verified for every restricted feature. Tests confirm that forbidden actions return HTTP 403 and that the UI correctly hides restricted controls from unauthorized roles. The RBAC model (Business Owner = full access, Event Manager = sector-scoped operational, Employee = view-only) is enforced at both API and UI layers.

### Integration Testing

Cross-component workflows are tested: login → dashboard → data entry → persistence → report generation → sector switching → data refresh. The payroll-to-expense automatic linkage (UC9) is verified as an integrated system action spanning Payroll Records and Expenses tables in a single database transaction.

---

## 3. Test Environment

| Layer | Technology | Notes |
|-------|------------|-------|
| Mobile Application | Flutter | Development build connected to local or staging API |
| Backend Framework | Laravel 12 | REST API with Sanctum authentication |
| Database | MySQL | Schema matching approved Database Schema |
| Authentication | Laravel Sanctum | Token-based bearer authentication |
| Test Device | Android Emulator / Physical Device | Flutter app running on API 30+ or iOS equivalent |
| API Base URL | `http://localhost/api` (dev) / `https://staging-api.dys-fms.example.com/api` (staging) | Configurable in Flutter environment |

### Pre-seeded Test Data

| Entity | Record | Details |
|--------|--------|---------|
| User | Business Owner | owner@dys.com, password hashed, role=Business Owner, sector_id=null, account_status=Active |
| User | Event Manager | maria@dys.com, password hashed, role=Event Manager, sector_id=2, account_status=Active |
| User | Employee/Staff | ana@dys.com, password hashed, role=Employee/Staff, sector_id=1, account_status=Active |
| User | Inactive Account | inactive@dys.com, password hashed, role=Employee/Staff, sector_id=1, account_status=Inactive |
| Sector | DYS Events | id=1, name="DYS Events", description="Event coordination and styling main branch" |
| Sector | B&DYS | id=2, name="B&DYS", description="Souvenirs" |
| Sector | Flavors by DYS | id=3, name="Flavors by DYS", description="Grazing tables and celebration drinks" |
| Sector | SnapDYS Memories | id=4, name="SnapDYS Memories", description="Video guestbook" |

At least 2 sales and 2 expense records should exist in each of at least 2 different sectors before testing FR-002, FR-004, FR-005, FR-006, and FR-007.

---

## 4. Test Case Template

Every test case in Section 5 follows this exact structure:

| Field | Description |
|-------|-------------|
| **Test Case ID** | Unique identifier matching the RTM (TC-FRxxx-xx) |
| **Functional Requirement** | The FR being verified (FR-001 through FR-008) |
| **Use Case** | Use case(s) from the approved Use Case Specification |
| **Module** | System module under test |
| **Priority** | Critical / High / Medium / Low |
| **Test Type** | Functional / API / UI / Validation |
| **Preconditions** | System state required before test execution |
| **Test Data** | Specific input values used during the test |
| **Test Steps** | Numbered sequence of actions to perform |
| **Expected Result** | What the system must do or display on success |
| **Pass Criteria** | Measurable conditions that determine test outcome |
| **Related API Endpoint(s)** | API endpoint(s) exercised by this test case |
| **Related Screen(s)** | Screen(s) from the Navigation Map involved |
| **Related Validation Rule(s)** | Specific validation rules and business rules enforced |

---

## 5. Test Cases

---

### FR-001 — Authentication (4 test cases)

---

#### TC-FR001-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR001-01 |
| **Functional Requirement** | FR-001 Authentication |
| **Use Case** | UC1 Login/Authenticate |
| **Module** | Authentication |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner account exists with email owner@dys.com; account_status = Active; sector 1 (DYS Events) exists in Business Sectors table; API server is running |
| **Test Data** | `{ "email": "owner@dys.com", "password": "SecurePass123" }` |
| **Test Steps** | 1. Send POST request to /api/login with the test data. 2. Verify HTTP status code is 200. 3. Verify response contains data.user with role = "Business Owner". 4. Verify response contains data.token (non-empty Sanctum token). 5. Verify response contains data.default_sector with id = 1, name = "DYS Events". 6. Use the returned token to access an authenticated endpoint (e.g., GET /api/business-sectors) to confirm the session is active. 7. Verify the Flutter app navigates from the Login screen to the Dashboard. |
| **Expected Result** | HTTP 200 OK; response body contains user object with role "Business Owner", a valid Sanctum token, and default_sector pointing to DYS Events (id=1); authenticated requests succeed with the token; UI transitions to Dashboard. |
| **Pass Criteria** | Status 200; data.user.role = "Business Owner"; data.user.account_status = "Active"; data.default_sector.id = 1; token authenticates subsequent requests; Dashboard loads with Business Owner variant (full navigation, sector chip interactive). |
| **Related API Endpoint(s)** | POST /api/login |
| **Related Screen(s)** | Login (login.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Auth rows 26-31 (email required, email format, email exists, password required, password match, account_status = Active); BR-34 (BO default sector = DYS Events); BR-41 (inactive accounts get generic error) |

---

#### TC-FR001-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR001-02 |
| **Functional Requirement** | FR-001 Authentication |
| **Use Case** | UC1 Login/Authenticate |
| **Module** | Authentication |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager account exists with email maria@dys.com; account_status = Active; sector 2 (B&DYS) exists in Business Sectors table |
| **Test Data** | `{ "email": "maria@dys.com", "password": "SecurePass456" }` |
| **Test Steps** | 1. Send POST request to /api/login with the test data. 2. Verify HTTP status code is 200. 3. Verify response contains data.user with role = "Event Manager". 4. Verify response contains a valid token. 5. Verify response contains data.default_sector with id = 2, name = "B&DYS". 6. Use the returned token to access an authenticated endpoint. 7. Verify the Flutter app navigates to the Dashboard. |
| **Expected Result** | HTTP 200 OK; user role is "Event Manager"; default_sector is the assigned sector (id=2); token is valid; Dashboard loads with Event Manager variant (5-item bottom nav, read-only sector chip). |
| **Pass Criteria** | Status 200; data.user.role = "Event Manager"; data.default_sector.id = 2; token is valid; Dashboard shows EM variant (no Users tab, no sector switcher). |
| **Related API Endpoint(s)** | POST /api/login |
| **Related Screen(s)** | Login (login.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Auth rows 26-31; BR-35 (EM default sector = assigned business sector) |

---

#### TC-FR001-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR001-03 |
| **Functional Requirement** | FR-001 Authentication |
| **Use Case** | UC1 Login/Authenticate |
| **Module** | Authentication |
| **Priority** | Critical |
| **Test Type** | Validation, API |
| **Preconditions** | Valid accounts exist in the Users table; the test credentials do not match any existing user |
| **Test Data** | `{ "email": "nonexistent@dys.com", "password": "WrongPass123" }` |
| **Test Steps** | 1. Send POST request to /api/login with an email that does not exist in the Users table. 2. Verify HTTP status code is 401. 3. Verify the error message is "Invalid username or password." 4. Verify no token is returned. 5. Repeat with a valid email but incorrect password: `{ "email": "owner@dys.com", "password": "WrongPass123" }`. 6. Verify the same 401 status and identical error message. |
| **Expected Result** | Both scenarios return HTTP 401 with `{"message": "Invalid username or password."}`; no token is issued; the UI remains on the Login screen with the error displayed; the error message does not distinguish between "email not found" and "wrong password". |
| **Pass Criteria** | Status 401; error message is exactly "Invalid username or password."; no token in response; identical message for both non-existent email and wrong password; UI stays on Login screen. |
| **Related API Endpoint(s)** | POST /api/login |
| **Related Screen(s)** | Login (login.html) |
| **Related Validation Rule(s)** | Auth rows 26-30 (email required, email format, email exists, password required, password match); BR-41 (inactive accounts receive same message as invalid credentials — consistent error) |

---

#### TC-FR001-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR001-04 |
| **Functional Requirement** | FR-001 Authentication |
| **Use Case** | UC1 Login/Authenticate |
| **Module** | Authentication |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Inactive user account exists with email inactive@dys.com; account_status = Inactive |
| **Test Data** | `{ "email": "inactive@dys.com", "password": "InactivePass123" }` |
| **Test Steps** | 1. Send POST request to /api/login with the inactive account credentials. 2. Verify HTTP status code is 401. 3. Verify the error message is "Invalid username or password." — identical to the invalid credentials message. 4. Verify no token is returned. 5. Verify the response does not reveal that the account is inactive. |
| **Expected Result** | HTTP 401 with `{"message": "Invalid username or password."}`; the message is identical to TC-FR001-03; no indication of account status is exposed; no token is issued. |
| **Pass Criteria** | Status 401; error message matches "Invalid username or password." exactly; response does not contain any indication of account_status; no token issued. |
| **Related API Endpoint(s)** | POST /api/login |
| **Related Screen(s)** | Login (login.html) |
| **Related Validation Rule(s)** | Auth row 31 (account_status must be Active); BR-41 (inactive accounts receive same message as invalid credentials); BR-43 (account_status = Inactive prevents login) |

---

### FR-002 — Dashboard (3 test cases)

---

#### TC-FR002-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR002-01 |
| **Functional Requirement** | FR-002 Dashboard |
| **Use Case** | UC4 View Analytics Dashboard (BO-only analytics subset within the Dashboard screen) |
| **Module** | Dashboard |
| **Priority** | Critical |
| **Test Type** | Functional, UI |
| **Preconditions** | Business Owner is authenticated; default sector is DYS Events (id=1); at least one sale and one expense record exist in sector 1 |
| **Test Data** | Authenticated session as Business Owner (owner@dys.com); no direct input (presentation screen) |
| **Test Steps** | 1. Log in as Business Owner. 2. Verify the Dashboard title is "Dashboard". 3. Verify the sector chip/selector displays "DYS Events" and is tappable (navigates to Sector Switcher). 4. Verify financial summary cards are visible: Total Sales, Total Expenses, Net Balance. 5. Verify chart/graph placeholder area is visible. 6. Verify quick action buttons: Record Sale, Record Expense, View Reports, View Payroll, Manage Users, Switch Sector. 7. Verify bottom navigation tabs: Dashboard, Sales, Expenses, Payroll, Users, Reports. 8. Tap the sector chip and confirm navigation to the Sector Switcher screen. |
| **Expected Result** | Dashboard displays the Business Owner variant with all 6 quick actions, a 6-tab bottom navigation bar, interactive sector chip, financial summary cards scoped to sector 1, and a chart placeholder. |
| **Pass Criteria** | All BO-specific UI elements are present; financial summary data matches aggregated sales/expenses in sector 1; sector chip navigates to Sector Switcher; no Employee-only restrictions are visible. |
| **Related API Endpoint(s)** | POST /api/login (establishes session), GET /api/sales (feeds summary), GET /api/expenses (feeds summary) |
| **Related Screen(s)** | Dashboard (dashboard.html), Sector Switcher (sector-switcher.html) |
| **Related Validation Rule(s)** | BR-34 (BO default sector = DYS Events); FR-002 Business Rules (FRS § FR-002): all BO-specific dashboard rules |

---

#### TC-FR002-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR002-02 |
| **Functional Requirement** | FR-002 Dashboard |
| **Use Case** | UC4 View Analytics Dashboard (indirect — Dashboard serves all roles) |
| **Module** | Dashboard |
| **Priority** | Critical |
| **Test Type** | Functional, UI |
| **Preconditions** | Event Manager is authenticated; assigned sector is B&DYS (id=2); at least one sale and one expense record exist in sector 2 |
| **Test Data** | Authenticated session as Event Manager (maria@dys.com) |
| **Test Steps** | 1. Log in as Event Manager. 2. Verify the Dashboard title is "Dashboard". 3. Verify the sector chip shows "B&DYS" and is read-only (NOT tappable). 4. Verify financial summary cards are visible and scoped to sector 2. 5. Verify quick actions: Record Sale, Record Expense, View Reports, View Payroll. 6. Verify quick actions NOT present: Manage Users, Switch Sector. 7. Verify bottom navigation: Dashboard, Sales, Expenses, Payroll, Reports (5 tabs, no Users tab). |
| **Expected Result** | Dashboard displays the Event Manager variant; sector chip is read-only; data scoped to assigned sector; 4 quick actions; 5-item bottom nav; Manage Users and Switch Sector are absent. |
| **Pass Criteria** | All EM-specific UI elements present; financial data scoped to assigned sector; sector chip does NOT navigate; Manage Users and Switch Sector are absent. |
| **Related API Endpoint(s)** | POST /api/login, GET /api/sales, GET /api/expenses |
| **Related Screen(s)** | Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | BR-35 (EM default sector = assigned); BR-37 (EM permanently assigned to one sector); BR-40 (only BO can manage users) |

---

#### TC-FR002-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR002-03 |
| **Functional Requirement** | FR-002 Dashboard |
| **Use Case** | UC4 View Analytics Dashboard (indirect) |
| **Module** | Dashboard |
| **Priority** | Critical |
| **Test Type** | Functional, UI |
| **Preconditions** | Employee is authenticated; assigned sector is DYS Events (id=1) |
| **Test Data** | Authenticated session as Employee (ana@dys.com) |
| **Test Steps** | 1. Log in as Employee. 2. Verify the Dashboard title is "Dashboard". 3. Verify only quick action present is: View Payroll. 4. Verify Record Sale, Record Expense, View Reports, Manage Users, Switch Sector are NOT present. 5. Verify bottom navigation: Dashboard, Payroll, Reports (3 tabs). 6. Verify Sales, Expenses, Users tabs are NOT present. |
| **Expected Result** | Dashboard displays the Employee variant (view-only); single quick action (View Payroll); 3-tab bottom nav; no data entry options. |
| **Pass Criteria** | Only Employee-appropriate elements visible; no Record Sale, Record Expense, Manage Users, or Switch Sector; bottom nav limited to Dashboard, Payroll, Reports. |
| **Related API Endpoint(s)** | POST /api/login, GET /api/payroll |
| **Related Screen(s)** | Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | BR-36 (EE default sector = assigned); BR-37 (EE permanently assigned to one sector); FR-002 Business Rules (FRS § FR-002): Employee-specific restrictions |

---

### FR-003 — User Account Management (7 test cases)

---

#### TC-FR003-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-01 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; sector 2 (B&DYS) exists in Business Sectors table |
| **Test Data** | `{ "name": "New Event Manager", "email": "new.em@dys.com", "role": "Event Manager", "sector_id": 2 }` |
| **Test Steps** | 1. Send POST /api/users as Business Owner. 2. Verify HTTP 201. 3. Verify response data contains id, name, email, role="Event Manager", sector_id=2, account_status="Active". 4. Verify temporary_password is returned (non-empty). 5. Log in as the new user with the temporary password. 6. Verify login response confirms role="Event Manager" and default_sector.id=2. |
| **Expected Result** | HTTP 201; user created with correct role and sector; temporary password allows first login; login confirms correct role and sector assignment. |
| **Pass Criteria** | Status 201; user record exists in Users table; temporary password works for first login; role and sector correctly assigned; account_status defaults to Active. |
| **Related API Endpoint(s)** | POST /api/users, POST /api/login |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt rows 38-43 (Create User: name, email, role, sector_id, password auto, account_status auto); BR-01 (only BO can create users); BR-02 (only BO can assign roles); BR-03 (only BO can assign sectors) |

---

#### TC-FR003-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-02 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; sector 1 (DYS Events) exists |
| **Test Data** | `{ "name": "New Employee", "email": "new.employee@dys.com", "role": "Employee/Staff", "sector_id": 1 }` |
| **Test Steps** | 1. Send POST /api/users as Business Owner. 2. Verify HTTP 201. 3. Verify role="Employee/Staff". 4. Verify temporary_password is returned. 5. Log in as the new user. 6. Verify the Dashboard loads with Employee variant (view-only, no data entry options). |
| **Expected Result** | HTTP 201; user created with Employee/Staff role; temporary password works; Dashboard shows Employee variant. |
| **Pass Criteria** | Status 201; role is "Employee/Staff"; login returns correct role; Dashboard is view-only. |
| **Related API Endpoint(s)** | POST /api/users, POST /api/login |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt rows 38-43; BR-01; BR-02; BR-03 |

---

#### TC-FR003-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-03 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Business Owner is authenticated; email maria@dys.com already exists in Users table |
| **Test Data** | `{ "name": "Duplicate User", "email": "maria@dys.com", "role": "Event Manager", "sector_id": 2 }` |
| **Test Steps** | 1. Send POST /api/users with an email that already exists. 2. Verify HTTP 422. 3. Verify error message: "The email has already been taken." in errors.email. 4. Verify no new user record was created in the Users table. |
| **Expected Result** | HTTP 422; validation error for duplicate email; no new user record created; existing user unchanged. |
| **Pass Criteria** | Status 422; error mentions duplicate email; no new record in database. |
| **Related API Endpoint(s)** | POST /api/users |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt row 39 (email: valid format, unique); BR-27 (email must be unique per user) |

---

#### TC-FR003-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-04 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | High |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; user with id=2 (Maria Santos, Event Manager, sector 2) exists |
| **Test Data** | `{ "name": "Maria Santos Updated", "email": "maria.updated@dys.com", "role": "Event Manager", "sector_id": 3 }` |
| **Test Steps** | 1. Send PUT /api/users/2 as Business Owner. 2. Verify HTTP 200. 3. Verify response reflects updated name, email, sector_id=3. 4. Attempt to log in with the old email — verify 401. 5. Log in with the new email — verify 200 and sector 3 in default_sector. |
| **Expected Result** | HTTP 200; user updated; old credentials invalidated; new credentials work; sector change takes effect. |
| **Pass Criteria** | Status 200; updated fields persisted; old email login fails; new email login succeeds; sector 3 is active. |
| **Related API Endpoint(s)** | PUT /api/users/{id}, POST /api/login |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt rows 44-48 (Edit User rules); BR-03 (only BO can change sectors) |

---

#### TC-FR003-05

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-05 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; active user with id=2 exists |
| **Test Data** | Deactivate: `{ "account_status": "Inactive" }`; Reactivate: `{ "account_status": "Active" }` |
| **Test Steps** | 1. Send PATCH /api/users/2/status with account_status="Inactive". 2. Verify HTTP 200 and account_status="Inactive". 3. Attempt to log in as the deactivated user — verify 401 with generic error. 4. Send PATCH /api/users/2/status with account_status="Active". 5. Verify HTTP 200 and account_status="Active". 6. Log in again — verify 200 and token issued. |
| **Expected Result** | Deactivation: status changes to Inactive, login returns 401 with generic message. Reactivation: status returns to Active, login succeeds. |
| **Pass Criteria** | Status 200 for both PATCH calls; deactivated user gets 401 with "Invalid username or password."; reactivated user can log in successfully. |
| **Related API Endpoint(s)** | PATCH /api/users/{id}/status, POST /api/login |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt rows 49-50 (Update Status); BR-04 (only BO can activate/deactivate); BR-26 (accounts deactivated, not deleted); BR-41 (inactive = generic error); BR-43 (Inactive prevents login) |

---

#### TC-FR003-06

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-06 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com); Employee is authenticated (ana@dys.com) |
| **Test Data** | Authenticated sessions for EM and EE roles |
| **Test Steps** | 1. As EM, send GET /api/users — verify 403. 2. As EM, send POST /api/users — verify 403. 3. As EM, send PUT /api/users/2 — verify 403. 4. As EM, send PATCH /api/users/2/status — verify 403. 5. Repeat steps 1–4 as Employee — verify 403 for each. 6. Verify EM Dashboard has no "Manage Users" or "Users" tab. 7. Verify Employee Dashboard has no "Manage Users" or "Users" tab. |
| **Expected Result** | All user management API calls return 403 Forbidden; UI hides all user management entry points for both EM and Employee. |
| **Pass Criteria** | Status 403 for all 5 endpoints for both EM and EE; "Manage Users" and "Users" tab absent from EM and EE navigation. |
| **Related API Endpoint(s)** | GET /api/users, POST /api/users, GET /api/users/{id}, PUT /api/users/{id}, PATCH /api/users/{id}/status |
| **Related Screen(s)** | Dashboard (dashboard.html), User Account Management (users.html) |
| **Related Validation Rule(s)** | BR-01 (only BO can create users); BR-02 (only BO can assign roles); BR-04 (only BO can activate/deactivate); BR-40 (only BO can manage user accounts) |

---

#### TC-FR003-07

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR003-07 |
| **Functional Requirement** | FR-003 User Account Management |
| **Use Case** | UC10 Manage User Accounts |
| **Module** | User Account Management |
| **Priority** | High |
| **Test Type** | API |
| **Preconditions** | Business Owner is authenticated; multiple users exist with different roles, sectors, and account statuses including at least one inactive user |
| **Test Data** | Authenticated session as Business Owner |
| **Test Steps** | 1. Send GET /api/users as Business Owner. 2. Verify HTTP 200. 3. Verify response is an array containing all user records. 4. Verify each user contains: id, name, email, role, sector_id, sector_name, account_status, created_at. 5. Verify the Business Owner's own account appears in the list. 6. Verify inactive users appear with account_status="Inactive". |
| **Expected Result** | HTTP 200; all users returned regardless of account_status; each user object includes all required fields; sector_name is denormalized; BO account included; inactive users visible. |
| **Pass Criteria** | Status 200; all users returned; required fields present; sector_name matches corresponding sector; inactive users included. |
| **Related API Endpoint(s)** | GET /api/users |
| **Related Screen(s)** | User Account Management (users.html) |
| **Related Validation Rule(s)** | User Mgmt rows 51-52 (View User, List Users); BR-26 (accounts deactivated, not deleted — inactive users still listed) |

---

### FR-004 — Record Sales (5 test cases)

---

#### TC-FR004-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR004-01 |
| **Functional Requirement** | FR-004 Record Sales |
| **Use Case** | UC2 Record Sales Transaction |
| **Module** | Sales |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; current sector context is DYS Events (sector_id=1) |
| **Test Data** | `{ "amount": 15000.00, "description": "Full event coordination package", "sector_id": 1 }` |
| **Test Steps** | 1. Send POST /api/sales as Business Owner. 2. Verify HTTP 201. 3. Verify response data contains id, amount=15000.00, description, recorded_by, sector, recorded_at. 4. Verify recorded_by.id matches the authenticated Business Owner. 5. Verify sector.id = 1. 6. Send GET /api/sales and verify the new record appears. 7. Verify the Dashboard summary cards update to reflect the new sale. |
| **Expected Result** | HTTP 201; sale record persisted; amount and description match input; user_id is set to authenticated Business Owner (not client-supplied); sector_id is 1; recorded_at is a valid timestamp; record retrievable via GET. |
| **Pass Criteria** | Status 201; all fields match input; user_id = authenticated BO; sector_id = 1; GET returns the record; Dashboard updates. |
| **Related API Endpoint(s)** | POST /api/sales, GET /api/sales |
| **Related Screen(s)** | Sales (sales.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Sales rows 58-62 (Record Sale: amount required/positive, description optional, sector_id, user_id auto, recorded_at auto); BR-12 (only BO/EM can record sales); BR-17 (sales immutable after creation) |

---

#### TC-FR004-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR004-02 |
| **Functional Requirement** | FR-004 Record Sales |
| **Use Case** | UC2 Record Sales Transaction |
| **Module** | Sales |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com); assigned sector is B&DYS (sector_id=2) |
| **Test Data** | `{ "amount": 8500.00, "description": "Souvenir package" }` (no sector_id — server overrides to assigned sector) |
| **Test Steps** | 1. Send POST /api/sales as Event Manager (no sector_id in request). 2. Verify HTTP 201. 3. Verify sector.id = 2 in response (overridden to assigned sector). 4. Repeat with sector_id=1 in request body — verify sector.id is still 2 (overridden). 5. Verify recorded_by.id matches the Event Manager. 6. Send GET /api/sales and verify the record appears under sector 2. |
| **Expected Result** | HTTP 201; sector_id is always overridden to the Event Manager's assigned sector (2) regardless of request input; user_id = authenticated EM. |
| **Pass Criteria** | Status 201; sector.id = 2 in both cases; client-supplied sector_id ignored/overridden; user_id = EM. |
| **Related API Endpoint(s)** | POST /api/sales, GET /api/sales |
| **Related Screen(s)** | Sales (sales.html) |
| **Related Validation Rule(s)** | Sales rows 58-64; BR-12 (only BO/EM can record sales); row 64 (EM cannot record outside assigned sector) |

---

#### TC-FR004-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR004-03 |
| **Functional Requirement** | FR-004 Record Sales |
| **Use Case** | UC2 Record Sales Transaction |
| **Module** | Sales |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Business Owner is authenticated |
| **Test Data** | `{ "amount": 0, "description": "Zero", "sector_id": 1 }` / `{ "amount": -100, "description": "Negative", "sector_id": 1 }` / `{ "description": "Missing amount", "sector_id": 1 }` |
| **Test Steps** | 1. POST with amount=0 — verify 422 and "Amount must be a positive number." 2. POST with amount=-100 — verify 422 and "Amount must be a positive number." 3. POST without amount field — verify 422 and "Amount is required." 4. Verify no Sales Transaction records were created from any attempt. |
| **Expected Result** | HTTP 422 for all invalid inputs; error messages match approved Validation Rules Matrix; no records persist. |
| **Pass Criteria** | Status 422; error messages match E16/E17; zero new records in database. |
| **Related API Endpoint(s)** | POST /api/sales |
| **Related Screen(s)** | Sales (sales.html) |
| **Related Validation Rule(s)** | Sales row 58 (amount: required, positive); E16 ("Amount is required."); E17 ("Amount must be a positive number.") |

---

#### TC-FR004-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR004-04 |
| **Functional Requirement** | FR-004 Record Sales |
| **Use Case** | UC2 Record Sales Transaction |
| **Module** | Sales |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Employee is authenticated (ana@dys.com) |
| **Test Data** | `{ "amount": 5000.00, "description": "Employee attempt" }` |
| **Test Steps** | 1. As Employee, send POST /api/sales — verify 403. 2. As Employee, send GET /api/sales — verify 403. 3. Verify Employee Dashboard has no Sales in bottom navigation or quick actions. |
| **Expected Result** | POST and GET both return 403; Sales screen is inaccessible; no Sales tab or Record Sale quick action for Employee. |
| **Pass Criteria** | Status 403 for both POST and GET; UI hides all sales entry points for Employee. |
| **Related API Endpoint(s)** | POST /api/sales, GET /api/sales |
| **Related Screen(s)** | Sales (sales.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Sales rows 63, 66 (role-based access); BR-12 (only BO/EM can record sales) |

---

#### TC-FR004-05

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR004-05 |
| **Functional Requirement** | FR-004 Record Sales |
| **Use Case** | UC2 Record Sales Transaction |
| **Module** | Sales |
| **Priority** | High |
| **Test Type** | API |
| **Preconditions** | Sales records exist in at least 2 different sectors; Business Owner and Event Manager are authenticated |
| **Test Data** | Authenticated sessions for both roles |
| **Test Steps** | 1. As BO, GET /api/sales?sector_id=1 — verify only sector 1 records. 2. As BO, GET /api/sales?sector_id=2 — verify only sector 2 records. 3. As EM (assigned sector 2), GET /api/sales — verify only sector 2 records. 4. As EM, GET /api/sales?sector_id=1 — verify sector 1 parameter is overridden; sector 2 records returned. 5. Verify pagination metadata (per_page, page, total, last_page). |
| **Expected Result** | BO sees sector-filtered results; EM always sees assigned sector regardless of sector_id parameter; results ordered by recorded_at descending; pagination meta present. |
| **Pass Criteria** | BO can view any sector via filter; EM always scoped to assigned sector; EM sector_id parameter overridden; pagination works. |
| **Related API Endpoint(s)** | GET /api/sales |
| **Related Screen(s)** | Sales (sales.html) |
| **Related Validation Rule(s)** | Sales rows 65-66 (View Sales); row 64 (EM sector scope) |

---

### FR-005 — Record Expenses (6 test cases)

---

#### TC-FR005-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-01 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; current sector context is DYS Events (sector_id=1) |
| **Test Data** | `{ "amount": 5000.00, "description": "Catering supplies", "sector_id": 1 }` |
| **Test Steps** | 1. Send POST /api/expenses as Business Owner. 2. Verify HTTP 201. 3. Verify response contains id, amount, description, recorded_by, sector, recorded_at. 4. Verify payroll_record_id is null (manual entry). 5. Verify recorded_by.id matches authenticated BO. 6. Verify sector.id = 1. 7. Send GET /api/expenses and verify the record appears. |
| **Expected Result** | HTTP 201; expense record persisted; payroll_record_id is null; user_id = BO; sector_id = 1; record retrievable via GET. |
| **Pass Criteria** | Status 201; all fields match input; payroll_record_id = null; user_id = authenticated BO; sector_id = 1. |
| **Related API Endpoint(s)** | POST /api/expenses, GET /api/expenses |
| **Related Screen(s)** | Expenses (expenses.html) |
| **Related Validation Rule(s)** | Expenses rows 72-76 (Record Expense: amount, description, sector_id, user_id auto, recorded_at auto); BR-13 (only BO/EM can record expenses); BR-18 (expenses immutable) |

---

#### TC-FR005-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-02 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com); assigned sector is B&DYS (sector_id=2) |
| **Test Data** | `{ "amount": 3200.00, "description": "Office supplies" }` |
| **Test Steps** | 1. Send POST /api/expenses as Event Manager. 2. Verify HTTP 201. 3. Verify sector.id = 2 in response (overridden to assigned sector). 4. Verify payroll_record_id is null. 5. Repeat with sector_id=1 in body — verify sector is still 2. |
| **Expected Result** | HTTP 201; sector_id overridden to EM's assigned sector; payroll_record_id is null; user_id = authenticated EM. |
| **Pass Criteria** | Status 201; sector.id = 2; client-supplied sector_id overridden; payroll_record_id = null. |
| **Related API Endpoint(s)** | POST /api/expenses, GET /api/expenses |
| **Related Screen(s)** | Expenses (expenses.html) |
| **Related Validation Rule(s)** | Expenses rows 72-79; BR-13 (only BO/EM can record expenses); row 79 (EM sector scope) |

---

#### TC-FR005-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-03 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Business Owner is authenticated |
| **Test Data** | `{ "amount": 0, "description": "Zero", "sector_id": 1 }` / `{ "amount": -500, "description": "Negative", "sector_id": 1 }` / `{ "description": "Missing amount", "sector_id": 1 }` |
| **Test Steps** | 1. POST with amount=0 — verify 422 and "Amount must be a positive number." 2. POST with amount=-500 — verify 422 and "Amount must be a positive number." 3. POST without amount — verify 422 and "Amount is required." 4. Verify no expense records created. |
| **Expected Result** | HTTP 422 for all invalid inputs; correct error messages; no records created. |
| **Pass Criteria** | Status 422; error messages match E16/E17; zero new records. |
| **Related API Endpoint(s)** | POST /api/expenses |
| **Related Screen(s)** | Expenses (expenses.html) |
| **Related Validation Rule(s)** | Expenses row 72 (amount: required, positive); E16, E17 |

---

#### TC-FR005-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-04 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Employee is authenticated (ana@dys.com) |
| **Test Data** | `{ "amount": 1000.00, "description": "Employee attempt" }` |
| **Test Steps** | 1. As Employee, POST /api/expenses — verify 403. 2. As Employee, GET /api/expenses — verify 403. 3. Verify Expenses is not available in Employee navigation. |
| **Expected Result** | 403 for both POST and GET; Expenses screen inaccessible to Employee. |
| **Pass Criteria** | Status 403; UI hides expense entry points for Employee. |
| **Related API Endpoint(s)** | POST /api/expenses, GET /api/expenses |
| **Related Screen(s)** | Expenses (expenses.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Expenses rows 78, 81 (role-based access); BR-13 (only BO/EM can record expenses) |

---

#### TC-FR005-05

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-05 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | High |
| **Test Type** | API |
| **Preconditions** | Expense records exist in at least 2 sectors; some with payroll_record_id set, some null; BO and EM authenticated |
| **Test Data** | Authenticated sessions for both roles |
| **Test Steps** | 1. As BO, GET /api/expenses?sector_id=1 — verify sector 1 records. 2. As BO, GET /api/expenses?sector_id=2 — verify sector 2 records. 3. As EM (sector 2), GET /api/expenses — verify only sector 2 records. 4. Verify both manual (payroll_record_id=null) and system-generated (payroll_record_id=integer) records appear. 5. Verify results ordered by recorded_at descending. |
| **Expected Result** | BO filters by sector correctly; EM sees only assigned sector; both types of expenses returned; payroll_record_id distinguishes type. |
| **Pass Criteria** | BO gets sector-filtered results; EM scoped to assigned sector; payroll_record_id null for manual, integer for system-generated. |
| **Related API Endpoint(s)** | GET /api/expenses |
| **Related Screen(s)** | Expenses (expenses.html) |
| **Related Validation Rule(s)** | Expenses rows 80-81 (View Expenses) |

---

#### TC-FR005-06

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR005-06 |
| **Functional Requirement** | FR-005 Record Expenses |
| **Use Case** | UC3 Record Expense |
| **Module** | Expenses |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; a Payroll Record exists (from a successful POST /api/payroll); the corresponding Expense was auto-created |
| **Test Data** | Payroll Record ID from a known payroll calculation |
| **Test Steps** | 1. Identify a Payroll Record with a known ID. 2. Find the Expense record where payroll_record_id matches that Payroll Record ID. 3. Verify expense.amount = payroll.computed_salary. 4. Verify expense.description follows "Payroll — {employee_name} — {pay_period}". 5. Verify expense.user_id = authenticated Business Owner. 6. Verify expense.sector_id = payroll.sector_id. 7. Verify expense.recorded_at matches payroll.calculated_at. |
| **Expected Result** | System-generated expense exists with payroll_record_id FK set; amount matches computed_salary; description follows template; timestamps aligned. |
| **Pass Criteria** | Expense record exists with payroll_record_id set; amount matches salary; description matches template; all FK relationships correct. |
| **Related API Endpoint(s)** | GET /api/expenses, GET /api/payroll |
| **Related Screen(s)** | Expenses (expenses.html), Payroll (payroll.html) |
| **Related Validation Rule(s)** | Expenses row 77 (payroll_record_id); BR-20 (payroll auto-creates expense in same transaction); BR-21 (payroll-generated expenses cannot be deleted) |

---

### FR-006 — Payroll (8 test cases)

---

#### TC-FR006-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-01 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC5 View Payroll Calculations |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; employee user (ana@dys.com, id=3, sector_id=1) exists with role Employee/Staff |
| **Test Data** | `{ "user_id": 3, "hours_worked": 160.00, "hourly_rate": 125.00, "pay_period": "2026-07-15" }` |
| **Test Steps** | 1. Send POST /api/payroll as Business Owner. 2. Verify HTTP 201. 3. Verify response contains id, employee, sector, hours_worked=160.00, hourly_rate=125.00, computed_salary=20000.00, pay_period, calculated_at. 4. Verify computed_salary = 160.00 × 125.00 = 20000.00 (server-calculated). 5. Verify response contains nested expense object with id, amount=20000.00, description. 6. Verify the linked Expense record exists in GET /api/expenses. |
| **Expected Result** | HTTP 201; Payroll Record created with correct computed_salary; Expense auto-created and linked; both records persisted. |
| **Pass Criteria** | Status 201; computed_salary = hours × rate (server-calculated); expense nested in response; expense exists in database; user_id = selected employee; sector_id = employee's assigned sector. |
| **Related API Endpoint(s)** | POST /api/payroll, GET /api/expenses |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll rows 87-94 (Calculate Payroll: user_id, hours_worked, hourly_rate, pay_period, computed_salary auto, sector_id auto, calculated_at auto, role); BR-05 (only BO can calculate payroll); BR-22 (computed_salary = hours × rate, server-side); BR-23 (hourly rate recorded at calculation time) |

---

#### TC-FR006-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-02 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC9 Payroll Auto-creates Expense |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner has just calculated payroll for an employee (per TC-FR006-01); the Payroll Record ID is known |
| **Test Data** | Payroll Record ID from a successful calculation |
| **Test Steps** | 1. Send GET /api/payroll to retrieve the Payroll Record. 2. Note the expense.id from the payroll record's nested expense object. 3. Send GET /api/expenses and find the record with that expense.id. 4. Verify the expense's payroll_record_id matches the Payroll Record ID. 5. Verify expense.amount = payroll.computed_salary. 6. Verify expense.description follows "Payroll — {employee_name} — {pay_period}". |
| **Expected Result** | Payroll Record includes nested expense; Expense record exists with matching payroll_record_id FK; amounts match; description follows template. |
| **Pass Criteria** | expense.payroll_record_id = payroll.id; expense.amount = payroll.computed_salary; description matches approved template. |
| **Related API Endpoint(s)** | GET /api/payroll, GET /api/expenses |
| **Related Screen(s)** | Payroll (payroll.html), Expenses (expenses.html) |
| **Related Validation Rule(s)** | Expenses row 77; BR-20 (payroll auto-creates expense in same transaction); BR-24 (payroll records stored permanently) |

---

#### TC-FR006-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-03 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC5 View Payroll Calculations |
| **Module** | Payroll |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Business Owner is authenticated; Business Owner user exists (id=1, role="Business Owner") |
| **Test Data** | `{ "user_id": 1, "hours_worked": 160.00, "hourly_rate": 125.00, "pay_period": "2026-07-15" }` |
| **Test Steps** | 1. Send POST /api/payroll with user_id pointing to the Business Owner. 2. Verify HTTP 422. 3. Verify error message: "Payroll cannot be calculated for the Business Owner." 4. Verify no Payroll Record was created. 5. Verify no Expense was auto-created. |
| **Expected Result** | HTTP 422 with specific error message; no records created. |
| **Pass Criteria** | Status 422; error = "Payroll cannot be calculated for the Business Owner." (E34); zero new records. |
| **Related API Endpoint(s)** | POST /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll row 87 (user_id must reference role ≠ Business Owner); E34 ("Payroll cannot be calculated for the Business Owner.") |

---

#### TC-FR006-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-04 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC5 View Payroll Calculations |
| **Module** | Payroll |
| **Priority** | High |
| **Test Type** | Validation, API |
| **Preconditions** | Business Owner is authenticated; employee user with id=3 exists |
| **Test Data** | `{ "user_id":3, "hours_worked":0, "hourly_rate":125, "pay_period":"2026-07-15" }` / `{ "user_id":3, "hours_worked":160, "hourly_rate":-50, "pay_period":"2026-07-15" }` / `{ "user_id":3, "hourly_rate":125, "pay_period":"2026-07-15" }` / `{ "user_id":3, "hours_worked":100000000, "hourly_rate":125, "pay_period":"2026-07-15" }` |
| **Test Steps** | 1. POST with hours_worked=0 — verify 422 and "Hours worked must be a positive number." 2. POST with hourly_rate=-50 — verify 422 and "Hourly rate must be a positive number." 3. POST without hours_worked — verify 422 and "Hours worked is required." 4. POST with hours_worked exceeding max — verify 422 and "Value must not exceed 99999999.99." 5. Verify no Payroll Records created. |
| **Expected Result** | HTTP 422 for all invalid inputs; error messages match approved list; no records created. |
| **Pass Criteria** | Status 422; error messages match E25-E28, E50; zero payroll records. |
| **Related API Endpoint(s)** | POST /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll rows 88-89 (hours_worked, hourly_rate validation); E25-E28, E50 |

---

#### TC-FR006-05

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-05 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC7 View Own Payroll |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com, id=2); payroll records exist for multiple employees including the Event Manager |
| **Test Data** | Authenticated session as Event Manager |
| **Test Steps** | 1. Send GET /api/payroll as Event Manager. 2. Verify HTTP 200. 3. Verify all returned records have employee.id = 2 (EM's own user_id). 4. Verify no records for other employees appear. 5. Verify UI shows history-only view (no employee selector, no Calculate & Save button). |
| **Expected Result** | Only EM's own payroll records returned; no other employees' records visible; UI is view-only. |
| **Pass Criteria** | Status 200; all records filtered to EM's user_id; other employees excluded; UI has no calculation interface. |
| **Related API Endpoint(s)** | GET /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll rows 95-97 (role-based filtering); BR-09 (EM views only own payroll); BR-08 (EM cannot calculate) |

---

#### TC-FR006-06

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-06 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC7 View Own Payroll |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Employee is authenticated (ana@dys.com, id=3); payroll records exist for multiple employees including the Employee |
| **Test Data** | Authenticated session as Employee |
| **Test Steps** | 1. Send GET /api/payroll as Employee. 2. Verify HTTP 200. 3. Verify all returned records have employee.id = 3 (EE's own user_id). 4. Verify no records for other employees appear. 5. Verify UI shows history-only view. |
| **Expected Result** | Only EE's own payroll records returned; no other employees' records visible; UI is view-only. |
| **Pass Criteria** | Status 200; all records filtered to EE's user_id; other employees excluded; UI has no calculation interface. |
| **Related API Endpoint(s)** | GET /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll rows 95-97; BR-11 (EE views only own payroll); BR-10 (EE cannot calculate) |

---

#### TC-FR006-07

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-07 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC5 View Payroll Calculations |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com); Employee is authenticated (ana@dys.com) |
| **Test Data** | `{ "user_id": 3, "hours_worked": 160.00, "hourly_rate": 125.00, "pay_period": "2026-07-15" }` |
| **Test Steps** | 1. As EM, POST /api/payroll — verify 403. 2. As EE, POST /api/payroll — verify 403. 3. Verify EM Payroll screen has no Calculate & Save button. 4. Verify Employee Payroll screen has no Calculate & Save button. |
| **Expected Result** | Both non-Owner roles receive 403; UI hides payroll calculation interface. |
| **Pass Criteria** | Status 403 for both EM and EE; no payroll records created; calculation UI hidden. |
| **Related API Endpoint(s)** | POST /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll row 94 (role: only BO can calculate); BR-05 (only BO can calculate payroll); BR-08 (EM cannot); BR-10 (EE cannot) |

---

#### TC-FR006-08

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR006-08 |
| **Functional Requirement** | FR-006 Payroll |
| **Use Case** | UC5 View Payroll Calculations |
| **Module** | Payroll |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; payroll records exist for employees in at least 2 different sectors |
| **Test Data** | Authenticated session as Business Owner |
| **Test Steps** | 1. Send GET /api/payroll as Business Owner (no filters). 2. Verify HTTP 200. 3. Verify records for employees from all sectors are returned. 4. Verify each record includes nested expense object. 5. Send GET /api/payroll?sector_id=1 — verify sector-filtered results. 6. Send GET /api/payroll?user_id=3 — verify single-employee results. |
| **Expected Result** | BO sees all payroll records across all sectors; each record includes employee, sector, hours, rate, computed_salary, pay_period, calculated_at, and expense linkage; sector_id and user_id filters work. |
| **Pass Criteria** | Status 200; all payroll records visible; cross-sector visibility confirmed; filter parameters work; results ordered by calculated_at descending; expense linkage present. |
| **Related API Endpoint(s)** | GET /api/payroll |
| **Related Screen(s)** | Payroll (payroll.html) |
| **Related Validation Rule(s)** | Payroll rows 95-97; BR-07 (BO can view payroll for all employees) |

---

### FR-007 — Reports (5 test cases)

---

#### TC-FR007-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR007-01 |
| **Functional Requirement** | FR-007 Reports |
| **Use Case** | UC6 View Reports |
| **Module** | Reports |
| **Priority** | High |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; sales and expense records exist in at least 2 different sectors |
| **Test Data** | Authenticated session as Business Owner; no sector_id parameter (triggers cross-sector aggregation) |
| **Test Steps** | 1. Send GET /api/reports as Business Owner (no parameters). 2. Verify HTTP 200. 3. Verify data.cross_sector = true. 4. Verify data.sectors is an array with per-sector totals. 5. Verify data.grand_total contains total_sales, total_expenses, net_balance. 6. Verify net_balance = total_sales - total_expenses. 7. Verify default report type is "summary" when type is not specified. |
| **Expected Result** | HTTP 200; cross-sector report returned with all sectors; grand_total aggregated correctly; net_balance calculation correct. |
| **Pass Criteria** | Status 200; cross_sector = true; sectors array populated; grand_total arithmetic correct; default type = "summary". |
| **Related API Endpoint(s)** | GET /api/reports |
| **Related Screen(s)** | Reports (reports.html) |
| **Related Validation Rule(s)** | Reports rows 103-107; BR-16 (BO can access all sectors and analytics) |

---

#### TC-FR007-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR007-02 |
| **Functional Requirement** | FR-007 Reports |
| **Use Case** | UC6 View Reports |
| **Module** | Reports |
| **Priority** | High |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; sales and expense data exists |
| **Test Data** | `?type=analytics` |
| **Test Steps** | 1. As BO, GET /api/reports?type=analytics — verify HTTP 200. 2. Verify data.charts contains sales_trend, expense_breakdown, sector_comparison (may be empty arrays — valid no-data state). 3. Verify data.summary contains total_sales, total_expenses, net_balance. 4. As EM, GET /api/reports?type=analytics — verify 403. |
| **Expected Result** | BO sees analytics with chart placeholders and summary data; EM receives 403 for analytics type. |
| **Pass Criteria** | Status 200 for BO; chart arrays present (may be empty); summary data correct; EM gets 403. |
| **Related API Endpoint(s)** | GET /api/reports |
| **Related Screen(s)** | Reports (reports.html) |
| **Related Validation Rule(s)** | Reports rows 103, 105 (role and type validation); BR-16 (BO analytics access) |

---

#### TC-FR007-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR007-03 |
| **Functional Requirement** | FR-007 Reports |
| **Use Case** | UC6 View Reports |
| **Module** | Reports |
| **Priority** | High |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com, assigned sector 2); sales and expense records exist in sector 2 and at least one other sector |
| **Test Data** | Authenticated session as Event Manager |
| **Test Steps** | 1. GET /api/reports as EM (no sector_id) — verify data scoped to sector 2. 2. GET /api/reports?sector_id=1 as EM — verify sector 1 parameter overridden; sector 2 data returned. 3. GET /api/reports?type=analytics as EM — verify 403. 4. Verify no cross-sector data accessible. |
| **Expected Result** | EM sees only assigned sector data; sector_id parameter overridden; analytics type forbidden; cross-sector data inaccessible. |
| **Pass Criteria** | Status 200 for sector-scoped reports; sector_id filter overridden to assigned sector; analytics returns 403; no cross-sector data. |
| **Related API Endpoint(s)** | GET /api/reports |
| **Related Screen(s)** | Reports (reports.html) |
| **Related Validation Rule(s)** | Reports rows 103-104; BR-15 (EM reports assigned sector only) |

---

#### TC-FR007-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR007-04 |
| **Functional Requirement** | FR-007 Reports |
| **Use Case** | UC6 View Reports |
| **Module** | Reports |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Employee is authenticated (ana@dys.com) |
| **Test Data** | Authenticated session as Employee |
| **Test Steps** | 1. GET /api/reports as Employee — verify 403. 2. Verify Employee bottom nav "Reports" tab displays own payroll data (same as Payroll screen). 3. Verify no "View Reports" quick action on Employee Dashboard. |
| **Expected Result** | GET /api/reports returns 403; Employee "Reports" navigation routes to own payroll view; no dedicated Reports screen for Employee. |
| **Pass Criteria** | Status 403 for GET /api/reports; UI "Reports" shows own payroll; no separate Reports screen. |
| **Related API Endpoint(s)** | GET /api/reports |
| **Related Screen(s)** | Reports (reports.html), Payroll (payroll.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Reports row 103 (Employee forbidden); BR-14 (Employee cannot access Reports screen) |

---

#### TC-FR007-05

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR007-05 |
| **Functional Requirement** | FR-007 Reports |
| **Use Case** | UC6 View Reports |
| **Module** | Reports |
| **Priority** | High |
| **Test Type** | API |
| **Preconditions** | Business Owner is authenticated; sales and expense records exist in multiple sectors |
| **Test Data** | `?sector_id=1&type=sales`, `?sector_id=2&type=expenses`, `?sector_id=1&date_from=2026-01-01&date_to=2026-07-28`, `?type=sales` |
| **Test Steps** | 1. GET /api/reports?sector_id=1&type=sales — verify sales report for sector 1. 2. GET /api/reports?sector_id=2&type=expenses — verify expense report for sector 2. 3. GET /api/reports?sector_id=1 with date range — verify date filter works. 4. GET /api/reports?type=sales without sector_id — verify cross-sector sales report. 5. GET /api/reports?type=invalid — verify 422. |
| **Expected Result** | All valid combinations return 200 with correct filtering; sector, type, and date_range filters work; invalid type returns 422. |
| **Pass Criteria** | Status 200 for valid combinations; sector filter, type filter, date range all work; invalid type returns 422. |
| **Related API Endpoint(s)** | GET /api/reports |
| **Related Screen(s)** | Reports (reports.html) |
| **Related Validation Rule(s)** | Reports rows 103-107; BR-16 |

---

### FR-008 — Business Sector Switching (4 test cases)

---

#### TC-FR008-01

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR008-01 |
| **Functional Requirement** | FR-008 Business Sector Switching |
| **Use Case** | UC8 Switch Business Sector |
| **Module** | Sector Switcher |
| **Priority** | High |
| **Test Type** | Functional, API |
| **Preconditions** | Business Owner is authenticated; current sector context is DYS Events (sector_id=1); all 4 sectors exist |
| **Test Data** | `{ "sector_id": 2 }` |
| **Test Steps** | 1. Send POST /api/business-sectors/switch with sector_id=2. 2. Verify HTTP 200. 3. Verify response contains data.previous_sector.id=1 and data.current_sector.id=2. 4. Verify subsequent GET /api/sales requests return data for sector 2. 5. Verify Dashboard sector chip updates to "B&DYS". 6. Verify no confirmation dialog appears (per spec BR-39). |
| **Expected Result** | HTTP 200; switch acknowledged with previous/current sector; data context updated; no confirmation dialog. |
| **Pass Criteria** | Status 200; previous_sector.id=1; current_sector.id=2; subsequent data queries scoped to sector 2; no confirmation dialog. |
| **Related API Endpoint(s)** | POST /api/business-sectors/switch, GET /api/sales (to verify context) |
| **Related Screen(s)** | Sector Switcher (sector-switcher.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Sector rows 113-114 (Switch Sector: sector_id FK, role); BR-06 (only BO can switch); BR-38 (auto-refresh on switch); BR-39 (no confirmation dialog) |

---

#### TC-FR008-02

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR008-02 |
| **Functional Requirement** | FR-008 Business Sector Switching |
| **Use Case** | UC8 Switch Business Sector |
| **Module** | Sector Switcher |
| **Priority** | High |
| **Test Type** | Functional, UI |
| **Preconditions** | Business Owner is authenticated; sales and expense records exist in at least 2 sectors; current sector is DYS Events (id=1) |
| **Test Data** | Switch from sector 1 to sector 2, then back to sector 1 |
| **Test Steps** | 1. Record Dashboard summary for sector 1. 2. Switch to sector 2. 3. Verify Dashboard summary changes to sector 2 data. 4. Navigate to Sales — verify sales are for sector 2. 5. Navigate to Expenses — verify expenses for sector 2. 6. Navigate to Reports — verify reports for sector 2. 7. Switch back to sector 1 — verify all data reverts to sector 1. |
| **Expected Result** | All data screens refresh with new sector context after each switch; data reverts correctly when switching back; no re-login required. |
| **Pass Criteria** | Dashboard, Sales, Expenses, and Reports all reflect the current sector; switching back restores original data. |
| **Related API Endpoint(s)** | POST /api/business-sectors/switch, GET /api/sales, GET /api/expenses, GET /api/reports |
| **Related Screen(s)** | Sector Switcher (sector-switcher.html), Dashboard (dashboard.html), Sales (sales.html), Expenses (expenses.html), Reports (reports.html) |
| **Related Validation Rule(s)** | BR-38 (switching sectors auto-refreshes Dashboard, Sales, Expenses, Reports) |

---

#### TC-FR008-03

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR008-03 |
| **Functional Requirement** | FR-008 Business Sector Switching |
| **Use Case** | UC8 Switch Business Sector |
| **Module** | Sector Switcher |
| **Priority** | Critical |
| **Test Type** | Functional, API |
| **Preconditions** | Event Manager is authenticated (maria@dys.com); Employee is authenticated (ana@dys.com) |
| **Test Data** | `{ "sector_id": 2 }` |
| **Test Steps** | 1. As EM, POST /api/business-sectors/switch — verify 403. 2. As EE, POST /api/business-sectors/switch — verify 403. 3. Verify EM Dashboard sector chip is read-only (no tap navigation). 4. Verify Employee Dashboard has no sector chip. |
| **Expected Result** | Both non-Owner roles receive 403; UI shows sector chip as read-only for EM; no sector chip for EE. |
| **Pass Criteria** | Status 403 for both EM and EE; EM sector chip read-only; EE has no sector chip. |
| **Related API Endpoint(s)** | POST /api/business-sectors/switch |
| **Related Screen(s)** | Sector Switcher (sector-switcher.html), Dashboard (dashboard.html) |
| **Related Validation Rule(s)** | Sector row 114 (role: only BO can switch); BR-06 (only BO can switch); BR-37 (EM/EE permanently assigned) |

---

#### TC-FR008-04

| Field | Value |
|-------|-------|
| **Test Case ID** | TC-FR008-04 |
| **Functional Requirement** | FR-008 Business Sector Switching |
| **Use Case** | UC8 Switch Business Sector |
| **Module** | Sector Switcher |
| **Priority** | Medium |
| **Test Type** | API |
| **Preconditions** | All roles are authenticated (BO, EM, EE); an unauthenticated request is also prepared |
| **Test Data** | Authenticated sessions for each role; no authentication for negative test |
| **Test Steps** | 1. As BO, GET /api/business-sectors — verify 200 and 4 sectors. 2. As EM, GET /api/business-sectors — verify 200 and same 4 sectors. 3. As EE, GET /api/business-sectors — verify 200 and same 4 sectors. 4. Unauthenticated GET /api/business-sectors — verify 401. |
| **Expected Result** | All authenticated roles see all 4 sectors; unauthenticated request returns 401. |
| **Pass Criteria** | Status 200 for all authenticated roles; exactly 4 sectors returned (DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories); each has id, name, description; status 401 for unauthenticated. |
| **Related API Endpoint(s)** | GET /api/business-sectors |
| **Related Screen(s)** | Sector Switcher (sector-switcher.html) |
| **Related Validation Rule(s)** | Sector row 115 (List Sectors available to all authenticated roles) |

---

## 6. Test Coverage Matrix

| FR | Requirement | Test Cases | Count | Priority Distribution |
|:--:|-------------|:----------:|:-----:|:---------------------|
| FR-001 | Authentication | TC-FR001-01 ~ TC-FR001-04 | 4 | 3 Critical, 1 High |
| FR-002 | Dashboard | TC-FR002-01 ~ TC-FR002-03 | 3 | 3 Critical |
| FR-003 | User Account Management | TC-FR003-01 ~ TC-FR003-07 | 7 | 4 Critical, 2 High, 1 Medium |
| FR-004 | Record Sales | TC-FR004-01 ~ TC-FR004-05 | 5 | 3 Critical, 2 High |
| FR-005 | Record Expenses | TC-FR005-01 ~ TC-FR005-06 | 6 | 4 Critical, 2 High |
| FR-006 | Payroll | TC-FR006-01 ~ TC-FR006-08 | 8 | 6 Critical, 2 High |
| FR-007 | Reports | TC-FR007-01 ~ TC-FR007-05 | 5 | 1 Critical, 4 High |
| FR-008 | Business Sector Switching | TC-FR008-01 ~ TC-FR008-04 | 4 | 1 Critical, 2 High, 1 Medium |
| | **Total** | **42** | **42** | **25 Critical, 15 High, 2 Medium** |

### Test Type Coverage

| Type | Count | FRs Covered |
|------|:-----:|:------------|
| Functional | 42 | All 8 FRs |
| API | 30 | All 8 FRs |
| UI | 12 | FR-002, FR-003, FR-004, FR-005, FR-006, FR-008 |
| Validation | 8 | FR-001, FR-003, FR-004, FR-005, FR-006, FR-007 |

### Role Coverage

| Role | Direct Test Cases |
|------|:-----------------:|
| Business Owner | TC-FR001-01, TC-FR002-01, TC-FR003-01-05, TC-FR003-07, TC-FR004-01, TC-FR005-01, TC-FR006-01-04, TC-FR006-08, TC-FR007-01, TC-FR007-02, TC-FR007-05, TC-FR008-01, TC-FR008-02, TC-FR008-04 |
| Event Manager | TC-FR001-02, TC-FR002-02, TC-FR004-02, TC-FR005-02, TC-FR006-05, TC-FR007-03, TC-FR008-03, TC-FR008-04 |
| Employee/Staff | TC-FR001-01 (EE can log in), TC-FR002-03, TC-FR004-04, TC-FR005-04, TC-FR006-06, TC-FR006-07, TC-FR007-04, TC-FR008-03, TC-FR008-04 |
| System (auto-generated expense) | TC-FR005-06, TC-FR006-02 |

---

## 7. Traceability Summary

| Artifact | Total | Traced | Coverage |
|----------|:-----:|:------:|:--------:|
| Functional Requirements (FR-001 ~ FR-008) | 8 | 8 | 100% |
| Use Cases (UC1 ~ UC10) | 10 | 10 | 100% |
| API Endpoints (16 total) | 16 | 16 | 100% |
| Screens (8 total) | 8 | 8 | 100% |
| Database Tables (5 total) | 5 | 5 | 100% |
| Validation Rule Categories (7) | 7 | 7 | 100% |
| Business Rules (BR-01 ~ BR-44) | 44 | 44 | 100% (enforced via tests) |

### Endpoint-to-Test-Case Mapping

| Endpoint | Test Cases |
|----------|:-----------|
| POST /api/login | TC-FR001-01, TC-FR001-02, TC-FR001-03, TC-FR001-04 |
| POST /api/logout | Covered by session lifecycle in all authenticated tests |
| GET /api/users | TC-FR003-06, TC-FR003-07 |
| POST /api/users | TC-FR003-01, TC-FR003-02, TC-FR003-03, TC-FR003-06 |
| GET /api/users/{id} | TC-FR003-06 |
| PUT /api/users/{id} | TC-FR003-04, TC-FR003-06 |
| PATCH /api/users/{id}/status | TC-FR003-05, TC-FR003-06 |
| GET /api/sales | TC-FR004-01, TC-FR004-02, TC-FR004-04, TC-FR004-05 |
| POST /api/sales | TC-FR004-01, TC-FR004-02, TC-FR004-03, TC-FR004-04 |
| GET /api/expenses | TC-FR005-01, TC-FR005-02, TC-FR005-04, TC-FR005-05, TC-FR005-06 |
| POST /api/expenses | TC-FR005-01, TC-FR005-02, TC-FR005-03, TC-FR005-04 |
| GET /api/payroll | TC-FR006-02, TC-FR006-05, TC-FR006-06, TC-FR006-08 |
| POST /api/payroll | TC-FR006-01, TC-FR006-03, TC-FR006-04, TC-FR006-07 |
| GET /api/reports | TC-FR007-01, TC-FR007-02, TC-FR007-03, TC-FR007-04, TC-FR007-05 |
| GET /api/business-sectors | TC-FR008-04 |
| POST /api/business-sectors/switch | TC-FR008-01, TC-FR008-03 |

---

## 8. Acceptance Criteria

The DYS FMS is accepted for release when the following conditions are met:

| # | Criterion | Verification |
|:-:|-----------|:-------------|
| 1 | All 8 Functional Requirements have been tested | 42 test cases executed with documented results |
| 2 | All Critical-priority test cases pass (25 of 42) | Test execution report |
| 3 | All High-priority test cases pass (15 of 42) | Test execution report |
| 4 | Zero Critical defects remain open | Defect tracking log |
| 5 | Authentication works for all three roles (BO, EM, EE) | TC-FR001-01, TC-FR001-02 |
| 6 | Invalid credentials and inactive accounts are rejected with generic error | TC-FR001-03, TC-FR001-04 |
| 7 | Role-based access control is enforced at both API (403) and UI (hidden controls) levels | TC-FR003-06, TC-FR004-04, TC-FR005-04, TC-FR006-07, TC-FR007-04, TC-FR008-03 |
| 8 | Business Owner can create, edit, deactivate, and reactivate user accounts | TC-FR003-01, TC-FR003-02, TC-FR003-04, TC-FR003-05 |
| 9 | Business Owner and Event Manager can record sales and expenses | TC-FR004-01, TC-FR004-02, TC-FR005-01, TC-FR005-02 |
| 10 | Payroll calculation produces correct computed_salary = hours_worked × hourly_rate | TC-FR006-01 |
| 11 | Payroll calculation automatically creates a linked Expense record | TC-FR006-02 |
| 12 | Each role sees only their authorized payroll data (BO = all, EM = own, EE = own) | TC-FR006-05, TC-FR006-06, TC-FR006-08 |
| 13 | Business Owner can view cross-sector and analytics reports | TC-FR007-01, TC-FR007-02 |
| 14 | Business Owner can switch sectors and all data refreshes correctly | TC-FR008-01, TC-FR008-02 |
| 15 | Input validation rejects invalid data with correct error messages matching the Validation Rules Matrix | TC-FR001-03, TC-FR004-03, TC-FR005-03, TC-FR006-03, TC-FR006-04 |
| 16 | No unsupported features, endpoints, screens, or workflows are present | Test coverage audit + code review |

---

## 9. Consistency Audit

| Source | Status | Notes |
|--------|:------:|-------|
| Concept Paper | ✓ | All test scope derived exclusively from approved features and business rules |
| Functional Requirements Specification | ✓ | Every test case maps to FR-001 through FR-008; test flows match FRS main/alternative flows |
| Requirements Traceability Matrix | ✓ | All 42 RTM placeholder IDs expanded into complete test case specifications |
| API Specification | ✓ | All 16 endpoints tested; request/response schemas and error codes match API Spec |
| Validation Rules Matrix | ✓ | All error messages, validation rules, and business rules referenced in test cases |
| Use Case Diagram | ✓ | UC1–UC10 exercised through corresponding test scenarios |
| Use Case Specification | ✓ | Actor-to-use-case mappings match test role assignments |
| Navigation Map | ✓ | All 8 screens referenced; role-based access matches screen access matrix |
| Database Schema | ✓ | Test data aligns with table structures, column types, and FK constraints |
| System Architecture | ✓ | Test environment uses approved 4-layer architecture |
| System Flowchart | ✓ | Process flows verified through functional test scenarios |
| User Flow | ✓ | Navigation paths tested in UI-type test cases |
| System Components | ✓ | All 8 client components and 8 backend services covered |
| UI Style Guide | ✓ | UI verification criteria aligned with approved component behaviors |
| Project Memory | ✓ | No features beyond approved scope introduced |
| VERSION | ✓ | Current v3.7 — all artifacts synchronized |

### Verification Checklist

| # | Criterion | Status |
|:-:|-----------|:------:|
| 1 | All 42 RTM test case IDs exist in this document | ✓ Verified |
| 2 | No orphan test cases (every TC maps to an FR) | ✓ Verified |
| 3 | No orphan FRs (every FR has at least 3 test cases) | ✓ Verified |
| 4 | No invented API endpoints tested | ✓ Verified — only 16 approved endpoints |
| 5 | No invented validation rules referenced | ✓ Verified — all rules from approved matrix |
| 6 | No invented screens referenced | ✓ Verified — only 8 approved screens |
| 7 | No invented workflows tested | ✓ Verified — all flows from FRS and approved documents |
| 8 | All error messages match approved Validation Rules Matrix | ✓ Verified |
| 9 | All role permissions match approved RBAC model (BO, EM, EE) | ✓ Verified |
| 10 | All test data matches approved Database Schema field types | ✓ Verified |

**Issues Found:** None

---

## 10. Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-29 | Project Team | Initial Test Case Specification — all 42 test cases expanded from RTM placeholders; document structure, strategy, environment, coverage matrix, traceability, acceptance criteria, consistency audit, and version history complete |

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | Test Case Specification |
| Version | 1.0 |
| Status | Draft |
| Total Test Cases | 42 |
| Requirements Coverage | 8 of 8 Functional Requirements (100%) |
| Use Case Coverage | 10 of 10 (100%) |
| API Endpoint Coverage | 16 of 16 (100%) |
| Screen Coverage | 8 of 8 (100%) |
| Validation Rule Coverage | 7 of 7 categories (100%) |
| Critical Priority | 25 test cases |
| High Priority | 15 test cases |
| Medium Priority | 2 test cases |
| Low Priority | 0 test cases |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Review | Yes |
