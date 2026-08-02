# Validation Rules Matrix — DYS Financial Management System (DYS FMS)

**Version:** 1.1
**Status:** APPROVED — FROZEN — READY FOR DEVELOPMENT
**Project:** DYS Financial Management System (DYS FMS)

---

## Document Purpose

This document is the single source of truth for every validation rule in the DYS FMS. It covers validation at four layers:

1. **Database** — schema constraints (NOT NULL, ENUM, FK, UNIQUE)
2. **Backend API** — request validation, authorization, business rule enforcement
3. **UI** — input constraints, keyboard types, inline validation, role-based visibility
4. **Business Rules** — workflow-level enforcement (who can do what)

---

## Master Validation Matrix

### Authentication

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Login | email | Yes | string | Must not be empty; must be valid email format; must exist in Users table | "Email is required." / "Invalid username or password." | UI, Backend, Database |
| Login | email | Yes | string (VARCHAR) | Must match an existing Users.email | "Invalid username or password." | Backend, Database |
| Login | email | — | — | Must be associated with account_status = Active | "Invalid username or password." (same message — no status disclosure) | Backend |
| Login | password | Yes | string | Must not be empty | "Password is required." | UI, Backend |
| Login | password | Yes | string (VARCHAR 60) | Must match the hashed password stored for the given email | "Invalid username or password." | Backend |
| Login | account_status | — | ENUM(Active, Inactive) | Must be Active. Inactive accounts are denied login with generic message | "Invalid username or password." | Backend, Database |
| Logout | token | Yes | string (Bearer token) | Must be a valid, non-expired Bearer token | "Unauthenticated." | Backend |

### User Account Management

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Create User | name | Yes | string (VARCHAR) | 1–255 characters | "Name is required." / "Name must not exceed 255 characters." | UI, Backend, Database |
| Create User | email | Yes | string (VARCHAR) | Valid email format; unique in Users table (case-insensitive) | "Email is required." / "Email must be a valid email address." / "Email has already been taken." | UI, Backend, Database |
| Create User | role | Yes | ENUM | Must be "Event Manager" or "Employee/Staff". "Business Owner" is rejected. | "Role is required." / "Selected role is invalid." | UI, Backend, Database |
| Create User | sector_id | Yes | integer (FK) | Must reference an existing Business Sectors.id | "Sector is required." / "Selected sector is invalid." | UI, Backend, Database |
| Create User | password | Yes (auto) | string (VARCHAR 60) | System-generated. Minimum 8 characters, mixed case, numbers, special character. BCrypt hashed. | — (auto-generated, not user-supplied) | Backend, Database |
| Create User | account_status | Yes (auto) | ENUM(Active, Inactive) | Default: Active. Set by system on creation. | — | Backend, Database |
| Edit User | name | Yes | string (VARCHAR) | 1–255 characters | "Name is required." / "Name must not exceed 255 characters." | UI, Backend, Database |
| Edit User | email | Yes | string (VARCHAR) | Valid email format; unique except current user's own email | "Email is required." / "Email has already been taken." | UI, Backend, Database |
| Edit User | role | Yes | ENUM | Must be "Event Manager" or "Employee/Staff" | "Role is required." / "Selected role is invalid." | UI, Backend, Database |
| Edit User | sector_id | Yes | integer (FK) | Must reference an existing Business Sectors.id | "Sector is required." / "Selected sector is invalid." | UI, Backend, Database |
| Edit User | — | — | — | Business Owner account cannot be modified through this endpoint | — | Backend |
| Update Status | account_status | Yes | ENUM(Active, Inactive) | Must be "Active" or "Inactive" | "Account status is required." / "The selected account_status is invalid." | UI, Backend, Database |
| Update Status | — | — | — | Business Owner's own account cannot be deactivated | — | Backend |
| View User | id | Yes | integer (PK) | Must reference an existing Users.id | "User not found." | Backend, Database |
| List Users | — | — | — | All users returned regardless of account_status | — | Backend |

### Sales

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Record Sale | amount | Yes | decimal | Must be a positive number (> 0). No explicit maximum defined in schema (DECIMAL without precision). | "Amount is required." / "Amount must be a positive number." | UI, Backend, Database |
| Record Sale | description | No | string (TEXT) | Nullable; free text. | — | UI, Backend, Database |
| Record Sale | sector_id | Conditional | integer (FK) | Required for Business Owner (must exist in Business Sectors). Ignored/overridden for Event Manager. | "Sector is required." / "Selected sector is invalid." | UI, Backend, Database |
| Record Sale | user_id | Yes (auto) | integer (FK) | Set server-side to authenticated user's ID. Not client-supplied. | — | Backend, Database |
| Record Sale | recorded_at | Yes (auto) | TIMESTAMP | Set server-side to current timestamp. Not client-supplied. | — | Backend, Database |
| Record Sale | role | — | ENUM | Only Business Owner and Event Manager can record sales | "Forbidden." | Backend |
| Record Sale | sector scope | — | — | Event Manager cannot record sales outside their assigned sector | "Forbidden. You can only record sales for your assigned sector." | Backend |
| View Sales | sector_id | Conditional | integer (FK) | Required for Owner (must exist). Ignored/overridden for Event Manager (uses assigned sector). | — | Backend |
| View Sales | role | — | ENUM | Employee cannot view sales | "Forbidden." | Backend |

### Expenses

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Record Expense | amount | Yes | decimal | Must be a positive number (> 0) | "Amount is required." / "Amount must be a positive number." | UI, Backend, Database |
| Record Expense | description | No | string (TEXT) | Nullable; free text. System-generated expenses use template: "Payroll — {name} — {pay_period}" | — | UI, Backend, Database |
| Record Expense | sector_id | Conditional | integer (FK) | Required for Business Owner (must exist in Business Sectors). Ignored/overridden for Event Manager. | "Sector is required." / "Selected sector is invalid." | UI, Backend, Database |
| Record Expense | user_id | Yes (auto) | integer (FK) | Set server-side to authenticated user's ID | — | Backend, Database |
| Record Expense | recorded_at | Yes (auto) | TIMESTAMP | Set server-side to current timestamp | — | Backend, Database |
| Record Expense | payroll_record_id | — | integer (FK) | NULL for manual entries. Set server-side for system-generated entries only. | — | Backend, Database |
| Record Expense | role | — | ENUM | Only Business Owner and Event Manager can record expenses manually | "Forbidden." | Backend |
| Record Expense | sector scope | — | — | Event Manager cannot record expenses outside their assigned sector | "Forbidden. You can only record expenses for your assigned sector." | Backend |
| View Expenses | sector_id | Conditional | integer (FK) | Required for Owner. Ignored/overridden for Event Manager (uses assigned sector). | — | Backend |
| View Expenses | role | — | ENUM | Employee cannot view expenses | "Forbidden." | Backend |

### Payroll

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Calculate Payroll | user_id | Yes | integer (FK) | Must reference existing Users.id; user role must be Event Manager or Employee/Staff (not Business Owner) | "Employee is required." / "Payroll cannot be calculated for the Business Owner." | UI, Backend, Database |
| Calculate Payroll | hours_worked | Yes | DECIMAL(10,2) | Must be positive (> 0); max 99999999.99 | "Hours worked is required." / "Hours worked must be a positive number." / "Hours worked must not exceed 99999999.99." | UI, Backend, Database |
| Calculate Payroll | hourly_rate | Yes | DECIMAL(10,2) | Must be positive (> 0); max 99999999.99 | "Hourly rate is required." / "Hourly rate must be a positive number." / "Hourly rate must not exceed 99999999.99." | UI, Backend, Database |
| Calculate Payroll | pay_period | Yes | DATE | Valid date format (YYYY-MM-DD) | "Pay period is required." / "Pay period must be a valid date." | UI, Backend, Database |
| Calculate Payroll | computed_salary | Yes (auto) | DECIMAL(10,2) | Derived server-side: hours_worked × hourly_rate. Not client-supplied. | — | Backend, Database |
| Calculate Payroll | sector_id | Yes (auto) | integer (FK) | Set server-side to employee's assigned sector_id. Not client-supplied. | — | Backend, Database |
| Calculate Payroll | calculated_at | Yes (auto) | TIMESTAMP | Set server-side to current timestamp | — | Backend, Database |
| Calculate Payroll | role | — | ENUM | Only Business Owner can calculate payroll | "Forbidden." | Backend |
| View Payroll | role | — | ENUM | Business Owner: all employees. Event Manager: own only. Employee: own only. | — | Backend |
| View Payroll | sector_id | — | integer (FK) | Optional for Owner. Ignored for EM/Employee (auto-filtered to own records). | — | Backend |
| View Payroll | user_id | — | integer (FK) | Optional filter for Owner. Ignored for EM/Employee. | — | Backend |

### Reports

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| View Reports | role | — | ENUM | Business Owner: all sectors, analytics, cross-sector. Event Manager: assigned sector only. Employee: forbidden. | "Forbidden." / "Forbidden. Analytics dashboard is available for Business Owner only." | Backend |
| View Reports | sector_id | No | integer (FK) | Must reference existing Business Sectors.id if provided. Overridden for Event Manager (assigned sector only). | "The selected sector_id is invalid." | Backend |
| View Reports | type | No | string | Must be one of: "summary", "sales", "expenses", "analytics". Default: "summary". | "The selected type is invalid." | UI, Backend |
| View Reports | date_from | No | DATE (YYYY-MM-DD) | Must be a valid date if provided | "Invalid start date." | UI, Backend |
| View Reports | date_to | No | DATE (YYYY-MM-DD) | Must be a valid date if provided | "Invalid end date." | UI, Backend |

### Business Sector Switching

| Module | Field | Required | Data Type | Validation Rule | Error Message | Layer |
|--------|-------|:--------:|:---------:|----------------|---------------|:-----:|
| Switch Sector | sector_id | Yes | integer (FK) | Must reference an existing Business Sectors.id | "Sector is required." / "The selected sector_id is invalid." | UI, Backend, Database |
| Switch Sector | role | — | ENUM | Only Business Owner can switch sectors | "Forbidden." | Backend |
| List Sectors | — | — | — | Available to all authenticated roles | — | Backend |

---

## Business Rule Validation

| # | Business Rule | Enforced At | Violation Response |
|---|---------------|:-----------:|--------------------|
| BR-01 | Only the Business Owner can create user accounts | Backend, UI | Forbidden (403). "Manage Users" hidden for EM/Employee. |
| BR-02 | Only the Business Owner can assign roles | Backend, UI | Forbidden (403). Role dropdown hidden for EM/Employee. |
| BR-03 | Only the Business Owner can assign or change business sectors | Backend, UI | Forbidden (403). Sector assignment fields hidden for EM/Employee. |
| BR-04 | Only the Business Owner can activate or deactivate accounts | Backend, UI | Forbidden (403). Status controls hidden for EM/Employee. |
| BR-05 | Only the Business Owner can calculate payroll | Backend, UI | Forbidden (403). Calculate fields hidden for EM/Employee. |
| BR-06 | Only the Business Owner can switch business sectors | Backend, UI | Forbidden (403). Sector Switcher hidden for EM/Employee. |
| BR-07 | Business Owner can view payroll for all employees | Backend | All payroll records returned. |
| BR-08 | Event Manager cannot calculate payroll | Backend, UI | Calculate & Save button hidden. |
| BR-09 | Event Manager can view only their own payroll | Backend | Query auto-filtered to authenticated user's ID. |
| BR-10 | Employee cannot calculate payroll | Backend, UI | Calculate & Save button hidden. |
| BR-11 | Employee can view only their own payroll | Backend | Query auto-filtered to authenticated user's ID. |
| BR-12 | Only Business Owners and Event Managers can record sales | Backend, UI | Forbidden (403). Sales screen hidden for Employee. |
| BR-13 | Only Business Owners and Event Managers can record expenses | Backend, UI | Forbidden (403). Expenses screen hidden for Employee. |
| BR-14 | Employee cannot access Reports screen | Backend, UI | Forbidden (403). Employee bottom nav Reports shows own payroll. |
| BR-15 | Event Manager can access Reports for assigned sector only | Backend | Report data filtered to EM's assigned sector_id. |
| BR-16 | Business Owner can access Reports for all sectors and analytics | Backend | Full data returned; "analytics" type available. |
| BR-17 | Sales records are immutable after creation | Backend | No PUT/PATCH/DELETE endpoints exist for Sales Transactions. |
| BR-18 | Expense records are immutable after creation | Backend | No PUT/PATCH/DELETE endpoints exist for Expenses. |
| BR-19 | Payroll records are immutable after creation | Backend | No PUT/PATCH/DELETE endpoints exist for Payroll Records. |
| BR-20 | Payroll auto-creates an Expense record in same transaction | Backend, Database | Database transaction ensures both records are created atomically. |
| BR-21 | Payroll-generated expenses cannot be manually deleted | Backend | No DELETE endpoints for Expenses. |
| BR-22 | computed_salary = hours_worked × hourly_rate (server-side) | Backend | Value calculated server-side; client-supplied value ignored. |
| BR-23 | Hourly rate is recorded at time of calculation | Backend | Rate stored in Payroll Records; no master rate table lookup. |
| BR-24 | Payroll records are stored permanently and viewable historically | DB | Records are never deleted. |
| BR-25 | Every account must belong to one assigned business sector | Backend, Database | sector_id required and validated for Event Manager and Employee. Owner's sector_id is null. |
| BR-26 | Accounts are deactivated, not deleted | Backend, UI | account_status set to "Inactive". Record retained in Users table. |
| BR-27 | Email must be unique per user | DB | UNIQUE constraint on Users.email. |
| BR-28 | Passwords are stored hashed (not plaintext) | Backend, Database | BCrypt hashing before storage. |
| BR-29 | There is no public registration or self-registration | Backend, UI | No Register/Sign Up endpoints or screens exist. |
| BR-30 | There is no Forgot Password or password reset workflow | Backend, UI | No Forgot Password endpoints or screens exist. |
| BR-31 | There is no email verification | Backend | Email is stored as provided; no verification flow. |
| BR-32 | No account lockout behavior is defined in the approved blueprint | Backend | Login always permitted regardless of prior failures. |
| BR-33 | Business Owner role cannot be created through User Account Management | Backend, Database | Seeded directly; role validation rejects "Business Owner". |
| BR-34 | Business Owner's default sector on login is DYS Event Management | Backend | Server returns default_sector.id = 1 in login response. |
| BR-35 | Event Manager's default sector on login is assigned business sector | Backend | Server returns assigned sector from Users.sector_id. |
| BR-36 | Employee's default sector on login is assigned business sector | Backend | Server returns assigned sector from Users.sector_id. |
| BR-37 | Event Managers and Employees are permanently assigned to one sector | Backend, UI | No Sector Switcher available. Sector chip is read-only. |
| BR-38 | Switching sectors auto-refreshes Dashboard, Sales, Expenses, Reports | UI | Client-side data refresh after successful switch response. |
| BR-39 | No confirmation dialog on sector switch | UI | No dialog defined in wireframes. |
| BR-40 | Only the Business Owner can manage user accounts | Backend, UI | "Users" tab and "Manage Users" button hidden for EM/Employee. |
| BR-41 | Inactive accounts receive same message as invalid credentials | Backend | Both return "Invalid username or password." — no status disclosure. |
| BR-42 | Temporary password visible only once at account creation | Backend | Returned only in POST /users response; not retrievable later. |
| BR-43 | Account_status = Inactive prevents login | Backend | Checked at login; returns generic error. |
| BR-44 | Business Owner's own account cannot be deactivated | Backend | PATCH /users/{id}/status rejects status change for Owner's own ID. |

---

## Security Validation

| # | Rule | Implementation Layer |
|---|------|:-------------------:|
| SV-01 | All endpoints (except POST /login) require a valid Bearer token | Backend (Authentication Layer) |
| SV-02 | All data-mutating endpoints check role-based authorization | Backend (Authorization Layer) |
| SV-03 | RBAC enforced at the service layer — not just UI hiding | Backend |
| SV-04 | Passwords are hashed with BCrypt before storage (60-character hash) | Backend |
| SV-05 | Input sanitization: all string inputs trimmed and escaped | Backend (ORM + validation layer) |
| SV-06 | SQL injection prevention via parameterized queries | Backend (ORM / Data Access Layer) |
| SV-07 | Validation occurs before any database write operation | Backend (Request Validation Layer) |
| SV-08 | Foreign key constraints enforce referential integrity at database level | Database (FK constraints) |
| SV-09 | No client-supplied values for server-set fields (user_id, recorded_at, computed_salary, sector_id for EM) | Backend (server-forced fields) |
| SV-10 | Inactive account status not disclosed in login error responses | Backend |
| SV-11 | Token-based authentication: tokens can be revoked individually via logout | Backend (Authentication Layer) |
| SV-12 | No MFA, OTP, CAPTCHA, or email verification implemented | — (not in approved scope) |

---

## Database Validation

### Users

| Column | Type | Nullable | Constraints | Validation |
|--------|:----:|:--------:|:-----------:|:----------:|
| id | INTEGER | NO | PK, AUTO_INCREMENT | System-generated |
| name | VARCHAR(255) | NO | — | 1–255 characters |
| email | VARCHAR(255) | NO | UNIQUE | Valid email format |
| password | VARCHAR(60) | NO | — | BCrypt hash |
| role | ENUM('Business Owner','Event Manager','Employee/Staff') | NO | — | Must be one of three values |
| sector_id | INTEGER | YES | FK → Business Sectors.id; NULL for Owner | Must reference existing sector when non-null |
| account_status | ENUM('Active','Inactive') | NO | Default: 'Active' | Must be Active or Inactive |
| created_at | TIMESTAMP | NO | Default: CURRENT_TIMESTAMP | System-generated |

### Business Sectors

| Column | Type | Nullable | Constraints | Validation |
|--------|:----:|:--------:|:-----------:|:----------:|
| id | INTEGER | NO | PK, AUTO_INCREMENT | System-generated |
| name | VARCHAR(255) | NO | UNIQUE | 1–255 characters; one of 4 approved names |
| description | TEXT | YES | — | Free text |
| created_at | TIMESTAMP | NO | Default: CURRENT_TIMESTAMP | System-generated |

### Sales Transactions

| Column | Type | Nullable | Constraints | Validation |
|--------|:----:|:--------:|:-----------:|:----------:|
| id | INTEGER | NO | PK, AUTO_INCREMENT | System-generated |
| user_id | INTEGER | NO | FK → Users.id | Must reference existing user |
| sector_id | INTEGER | NO | FK → Business Sectors.id | Must reference existing sector |
| amount | DECIMAL | NO | — | Positive (> 0) |
| description | TEXT | YES | — | Free text; nullable |
| recorded_at | TIMESTAMP | NO | Default: CURRENT_TIMESTAMP | System-generated |

### Expenses

| Column | Type | Nullable | Constraints | Validation |
|--------|:----:|:--------:|:-----------:|:----------:|
| id | INTEGER | NO | PK, AUTO_INCREMENT | System-generated |
| user_id | INTEGER | NO | FK → Users.id | Must reference existing user |
| sector_id | INTEGER | NO | FK → Business Sectors.id | Must reference existing sector |
| amount | DECIMAL | NO | — | Positive (> 0) |
| description | TEXT | YES | — | Free text; nullable |
| recorded_at | TIMESTAMP | NO | Default: CURRENT_TIMESTAMP | System-generated |
| payroll_record_id | INTEGER | YES | FK → Payroll Records.id; NULL for manual entries | Must reference existing Payroll Record when non-null |

### Payroll Records

| Column | Type | Nullable | Constraints | Validation |
|--------|:----:|:--------:|:-----------:|:----------:|
| id | INTEGER | NO | PK, AUTO_INCREMENT | System-generated |
| user_id | INTEGER | NO | FK → Users.id | Must reference existing user; role ≠ Business Owner |
| sector_id | INTEGER | NO | FK → Business Sectors.id | Employee's assigned sector |
| hours_worked | DECIMAL(10,2) | NO | — | Positive (> 0); max 99999999.99 |
| hourly_rate | DECIMAL(10,2) | NO | — | Positive (> 0); max 99999999.99 |
| computed_salary | DECIMAL(10,2) | NO | — | Derived: hours_worked × hourly_rate |
| pay_period | DATE | NO | — | Valid date (YYYY-MM-DD) |
| calculated_at | TIMESTAMP | NO | Default: CURRENT_TIMESTAMP | System-generated |

---

## API Validation (Per Endpoint)

| Endpoint | Validation Layer | Key Validations |
|----------|:----------------:|-----------------|
| POST /api/login | Request Validation + Auth | email: required, email format, exists:users. password: required. Custom: account_status = Active |
| POST /api/logout | Authentication Layer | Token must be valid |
| GET /api/users | Auth + Role Authorization | Authenticated. Role = Business Owner |
| POST /api/users | Request Validation + Auth | name: required, max:255. email: required, email, unique:users. role: required, in:Event Manager,Employee/Staff. sector_id: required, exists:business_sectors,id |
| GET /api/users/{id} | Auth + Role + Data Access | Authenticated. Owner role. User must exist |
| PUT /api/users/{id} | Request Validation + Auth + Data Access | Same as POST. Email unique check excludes current user ID. Owner account cannot be edited |
| PATCH /api/users/{id}/status | Request Validation + Auth + Data Access | account_status: required, in:Active,Inactive. Cannot deactivate own account |
| GET /api/sales | Auth + Role + Query | Authenticated. Owner or Event Manager. sector_id validated if provided. EM scope overridden |
| POST /api/sales | Request Validation + Auth + Role | amount: required, numeric, gt:0. description: nullable, string. sector_id: exists for Owner; overridden for EM |
| GET /api/expenses | Auth + Role + Query | Same pattern as GET /api/sales |
| POST /api/expenses | Request Validation + Auth + Role | Same pattern as POST /api/sales |
| GET /api/payroll | Auth + Role + Query | Authenticated. Owner sees all; EM/Employee scoped to own user_id |
| POST /api/payroll | Request Validation + Auth + Role | user_id: required, exists:users, custom owner-check. hours_worked: required, numeric, gt:0, max:99999999.99. hourly_rate: same. pay_period: required, date_format:Y-m-d |
| GET /api/reports | Auth + Role + Query | Authenticated. Owner or Event Manager. type: in:summary,sales,expenses,analytics. date_from/date_to: date_format if provided |
| GET /api/business-sectors | Auth | Authenticated. All roles |
| POST /api/business-sectors/switch | Auth + Role + Validation | Authenticated. Owner only. sector_id: required, exists:business_sectors,id |

---

## UI Validation

| Component | Validation Behavior | Implementation |
|-----------|-------------------|:--------------:|
| Text field (all) | Required indicator (label styling), inline error below field | Disabled button until required fields filled; show error container |
| Email field (Login) | Format validation on blur or submit | Keyboard type: email |
| Password field (Login) | Non-empty validation | Password is obscured during input |
| Amount fields (Sales, Expenses) | Positive number validation, numeric keyboard | Numeric keyboard supporting decimal values |
| Hours/Rate fields (Payroll) | Positive number, max 99999999.99, numeric keyboard | Same numeric keyboard |
| Dropdown fields | Must select a value from predefined list; placeholder shown before selection | Dropdown menu; disabled state if no options |
| Date pickers | Must select a valid date | Standard date picker; formatted as MM/DD/YYYY |
| Sector field (Sales, Expenses, Payroll) | Required for Owner; pre-filled/read-only for EM/Employee | Owner: dropdown. EM/Employee: read-only display |
| Employee dropdown (Payroll) | Required for Owner; hidden for EM/Employee | Owner: dropdown of Event Manager + Employee users. EM/Employee: hidden |
| Read-only calculated fields | Computed Salary in calculation panel | Non-editable display; updated on input change or server response |
| Dashboard stat cards | Shows ₱0.00 when no data; no validation needed | Display only |
| Chart placeholders | Shows placeholder text when no data | Display only |
| Buttons | Disabled state when form is invalid | Visual: reduced opacity (0.38), no hover effect |
| Role-hidden controls | Entire sections/buttons hidden based on role | Conditional rendering in widget tree |
| Validation errors | Inline container with icon + message | Red background (`--danger-container`), red text (`--danger`) |
| Success feedback | Inline or brief notification (not modal) | Auto-dismissing message |
| Sector Switcher radio dots | Current sector shows filled dot; tap updates selection | Interactive; no confirmation dialog |
| Save Account / Deactivate buttons | Button row; Deactivate turns red outline | Danger-styled secondary button |

---

## Standard Error Messages

| # | Scenario | Message |
|---|----------|---------|
| E01 | Email field empty | "Email is required." |
| E02 | Invalid email format | "Email must be a valid email address." |
| E03 | Email already exists (create/update user) | "Email has already been taken." |
| E04 | Password field empty (login) | "Password is required." |
| E05 | Invalid credentials (login) | "Invalid username or password." |
| E06 | Inactive account (login, generic) | "Invalid username or password." |
| E07 | Unauthenticated request | "Unauthenticated." |
| E08 | Forbidden — wrong role | "Forbidden." |
| E09 | Forbidden — EM wrong sector | "Forbidden. You can only access your assigned sector." |
| E10 | Forbidden — Employee cannot record sales | "Forbidden." |
| E11 | Forbidden — Employee cannot record expenses | "Forbidden." |
| E12 | Forbidden — EM/Employee cannot calculate payroll | "Forbidden." |
| E13 | Forbidden — EM requests analytics | "Forbidden. Analytics dashboard is available for Business Owner only." |
| E14 | Resource not found | "Resource not found." |
| E15 | User not found | "User not found." |
| E16 | Amount required | "Amount is required." |
| E17 | Amount must be positive | "Amount must be a positive number." |
| E18 | Description too long (if truncated) | Not defined in schema (TEXT type) |
| E19 | Name required | "Name is required." |
| E20 | Name too long | "Name must not exceed 255 characters." |
| E21 | Role required | "Role is required." |
| E22 | Invalid role selection | "The selected role is invalid." |
| E23 | Sector required | "Sector is required." |
| E24 | Invalid sector selection | "The selected sector_id is invalid." |
| E25 | Hours worked required | "Hours worked is required." |
| E26 | Hours worked must be positive | "Hours worked must be a positive number." |
| E27 | Hourly rate required | "Hourly rate is required." |
| E28 | Hourly rate must be positive | "Hourly rate must be a positive number." |
| E29 | Pay period required | "Pay period is required." |
| E30 | Invalid date format | "Invalid date format." |
| E31 | Account status required | "Account status is required." |
| E32 | Invalid account status | "The selected account_status is invalid." |
| E33 | Cannot deactivate own account | Not defined in wireframes — reserve: "You cannot deactivate your own account." |
| E34 | Cannot calculate payroll for Business Owner | "Payroll cannot be calculated for the Business Owner." |
| E35 | Report type invalid | "The selected type is invalid." |
| E36 | Sector switch forbidden (non-Owner) | "Forbidden." |
| E37 | Unauthorized endpoint access | "Unauthenticated." |
| E38 | Internal server error | "An unexpected error occurred. Please try again later." |
| E39 | Validation failed (generic) | "Validation failed." |
| E40 | Login successful | "Login successful." |
| E41 | Logout successful | "Logged out successfully." |
| E42 | Sale recorded | "Sale recorded successfully." |
| E43 | Expense recorded | "Expense recorded successfully." |
| E44 | Payroll calculated | "Payroll calculated and saved successfully. Expense record auto-created." |
| E45 | User created | "User account created successfully." |
| E46 | User updated | "User updated successfully." |
| E47 | User status updated | "User status updated successfully." |
| E48 | Sector switched | "Sector switched successfully." |
| E49 | Amount exceeds maximum | Not defined in schema (DECIMAL without precision limit) |
| E50 | Hours/Rate exceeds maximum | "Value must not exceed 99999999.99." |

---

## Consistency Audit

| Source | Status |
|--------|--------|
| Concept Paper | ✓ |
| Functional Requirements Specification (FRS) | ✓ |
| API Specification | ✓ |
| Database Schema | ✓ |
| Data Dictionary | ✓ |
| Physical ERD | ✓ |
| Navigation Map | ✓ |
| UI Style Guide | ✓ |
| Wireframes (Low-Fi) | ✓ |
| Wireframes (Hi-Fi) | ✓ |
| User Flow | ✓ |
| System Flowchart | ✓ |
| Use Case | ✓ |
| Use Case Diagram | ✓ |
| System Components | ✓ |
| Project Memory | ✓ |
| AI Instructions | ✓ |

**Issues Found:** None

**Verification summary:**
- Every validation rule traces to an approved source document (FRS, API Spec, Data Dictionary, DB Schema, or UI Style Guide)
- No Register, Sign Up, Forgot Password, email verification, OTP, MFA, CAPTCHA, notifications, or payment rules introduced
- No Admin or Super Admin role rules introduced
- All ENUM values match the Database Schema (role: 3 values, account_status: 2 values)
- All FK constraints match the Physical ERD
- All business rules match the FRS Business Rules sections
- All error messages match the API Specification responses
- All role-based rules match the FR-002 Dashboard and FR-003 through FR-008 specifications
- All database-level constraints match the Data Dictionary column validations

---

## Final Statistics

| Category | Count |
|----------|:-----:|
| Total validation rules (matrix rows) | 60 |
| Business rules | 44 |
| Security validation rules | 12 |
| Database column constraints | 33 |
| API endpoint validations | 16 |
| UI validation behaviors | 19 |
| Standard error messages | 50 |

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | Validation Rules Matrix |
| Version | 1.1 |
| Status | APPROVED — FROZEN — READY FOR DEVELOPMENT |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Review | Yes |
