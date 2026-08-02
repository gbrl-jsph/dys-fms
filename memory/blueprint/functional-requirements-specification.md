# Functional Requirements Specification — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Draft (pending consistency audit)
**Project:** DYS Financial Management System (DYS FMS)

---

## Document Overview

This document defines every functional requirement for the DYS Financial Management System. Each requirement is derived exclusively from the approved and frozen blueprint documents. No feature, role, workflow, or behavior is introduced beyond what is documented in the approved source of truth.

### Source Documents

- Concept Paper
- Client Clarifications
- System Architecture
- System Flowchart
- User Flow
- Use Case
- Use Case Diagram
- Wireframes (Low-Fi)
- Wireframes (Hi-Fi)
- ER Diagram
- Database Schema
- Data Dictionary
- Physical ERD
- Definition of System Components
- Project Memory
- AI Instructions

---

## FR-001 Authentication

### Purpose

Authenticate users and route them to the appropriate role-based dashboard.

### Actors

- Business Owner
- Event Manager
- Employee / Event Staff

### Preconditions

- User has a pre-created account (accounts are created exclusively by the Business Owner)
- Account status is Active

### Trigger

User opens the application and is presented with the Login screen.

### Main Flow

1. System displays the Login screen containing:
   - Email field
   - Password field
   - Login button
2. User enters email and password
3. User taps Login
4. System validates credentials against the Users table
5. System checks account_status is Active
6. System determines the user's role
7. System sets the default business sector:
   - Business Owner → DYS Event Management
   - Event Manager → assigned business sector
   - Employee → assigned business sector
8. System redirects user to the role-based Dashboard

### Alternative Flow

**Invalid Credentials:**
1. System displays error message: "Invalid username or password."
2. User remains on the Login screen
3. User may retry

**Inactive Account:**
1. System denies access
2. User remains on the Login screen
3. No indication of account status is exposed

### Postconditions

- User is authenticated
- User session is established with role and default sector context
- User is on the role-based Dashboard (Owner: DYS Event Management; EM/Employee: assigned sector)

### Validation Rules

| Field | Rule |
|-------|------|
| Email | Required; must match an existing user record |
| Password | Required; must match the hashed password for the given email |
| account_status | Must be Active |

### Business Rules

- There is no self-registration or public account creation
- There is no Forgot Password or password reset workflow
- There is no Register or Sign Up screen
- There is no email verification
- Account status is managed exclusively by the Business Owner
- Failed login attempts do not lock the account (no lockout mechanism is defined)

### Data Used

- Users.email
- Users.password
- Users.role
- Users.account_status
- Users.sector_id

### Related Database Tables

- Users
- Business Sectors (for default sector resolution)

### Referenced Wireframe

- Hi-Fi: `login.html`
- Low-Fi: Wireframes section 1 — Login Screen

### Referenced Flowchart Process

- Process 1: Login & Authentication

### Referenced Use Case

- UC1: Login/Authenticate

---

## FR-002 Dashboard

### Purpose

Provide a role-based landing page that surfaces permitted functions and financial summary data.

### Actors

- Business Owner
- Event Manager
- Employee / Event Staff

### Preconditions

- User is authenticated
- User session contains role and current sector context

### Trigger

Successful login, or user navigates to Dashboard from another screen.

### Main Flow

**Business Owner:**
1. System displays Dashboard with title "Dashboard"
2. Default sector is DYS Event Management
3. System shows sector chip/selector displaying current sector
4. System displays financial summary cards (Total Sales, Total Expenses, Net Balance)
5. System displays chart/graph placeholder
6. System displays quick action buttons:
   - Record Sale
   - Record Expense
   - View Reports
   - View Payroll
   - Manage Users
   - Switch Sector
7. System displays bottom navigation: Dashboard, Sales, Expenses, Payroll, Users, Reports

**Event Manager:**
1. System displays Dashboard with title "Dashboard"
2. Default sector is the Event Manager's assigned business sector
3. System shows sector chip (read-only — no switching)
4. System displays financial summary cards scoped to assigned sector
5. System displays quick action buttons:
   - Record Sale
   - Record Expense
   - View Reports
   - View Payroll
6. System displays bottom navigation: Dashboard, Sales, Expenses, Payroll, Reports
7. Sector Switcher is NOT available
8. Manage Users is NOT available

**Employee / Event Staff:**
1. System displays Dashboard with title "Dashboard"
2. Default sector is the Employee's assigned business sector
3. System displays quick action button:
   - View Payroll
4. System displays bottom navigation: Dashboard, Payroll, Reports
5. Record Sale is NOT available
6. Record Expense is NOT available
7. Sector Switcher is NOT available
8. Manage Users is NOT available
9. Employee has no separate Reports screen — payroll view is the only reporting access

### Alternative Flow

N/A — Dashboard is always displayed after successful login. No alternative rendering is defined.

### Postconditions

- User sees role-appropriate data and navigation
- Sector context is applied to all subsequent queries

### Validation Rules

N/A — Dashboard is a presentation screen with no user input fields.

### Business Rules

- Business Owner default sector on login: DYS Event Management
- Event Manager default sector on login: assigned business sector
- Employee default sector on login: assigned business sector
- Only the Business Owner can switch sectors
- Event Managers and Employees are permanently assigned to one sector
- Financial summary data is scoped by the current sector
- Chart/graph area is a placeholder — populates once transactions exist

### Data Used

- Users.sector_id (for default sector)
- Aggregated Sales Transactions (for summary cards)
- Aggregated Expenses (for summary cards)

### Related Database Tables

- Users
- Business Sectors
- Sales Transactions
- Expenses

### Referenced Wireframe

- Hi-Fi: `dashboard.html`
- Low-Fi: Wireframes section 2 — Dashboard (Owner, Event Manager, Employee variants)

### Referenced Flowchart Process

- Process 1: Login & Authentication (role determination and default sector assignment)

### Referenced Use Case

- UC4: View Analytics Dashboard (Owner only — the Owner dashboard includes the analytics view)

---

## FR-003 User Account Management

### Purpose

Enable the Business Owner to create, manage, and control user accounts. No other actor may create or manage accounts. There is no public registration or self-registration.

### Actors

- Business Owner (only)

### Preconditions

- Business Owner is authenticated
- Business Owner is on the Dashboard

### Trigger

Business Owner taps "Manage Users" from the Dashboard.

### Main Flow

1. System displays the Manage Users screen showing:
   - User list table (Name, Role, Sector, Status)
   - Add User button
   - Add/Edit User form (Name, Email, Role, Sector fields)
2. Business Owner taps "Add User"
3. Business Owner fills in:
   - Name
   - Email
   - Role (Event Manager or Employee/Staff)
   - Business Sector (one of the four approved sectors)
4. Business Owner taps "Generate Temporary Password"
5. System generates a temporary password
6. Business Owner taps "Save Account"
7. System creates a new Users record with:
   - account_status = Active
   - Hashed password
8. System displays the temporary credentials
9. Business Owner provides credentials to the user manually

**Edit User:**
1. Business Owner selects an existing user from the list
2. System populates the Add/Edit form with current values
3. Business Owner modifies fields as needed
4. Business Owner taps "Save Account"
5. System updates the Users record

**Deactivate User:**
1. Business Owner selects an existing user from the list
2. Business Owner taps "Deactivate"
3. System sets account_status = Inactive
4. User can no longer log in

**Activate User:**
1. Business Owner selects an inactive user from the list
2. Business Owner taps "Activate"
3. System sets account_status = Active
4. User can now log in

### Alternative Flow

**Event Manager or Employee attempts to access Manage Users:**
1. System denies access
2. No Manage Users option appears in navigation

**Invalid input during account creation:**
1. System displays validation error
2. Business Owner corrects the input
3. Business Owner retries

### Postconditions

- New user account exists in the Users table
- Account has correct role, sector, and status
- Credentials can be delivered to the user by the Business Owner

### Validation Rules

| Field | Rule |
|-------|------|
| Name | Required; 1–255 characters |
| Email | Required; valid email format; must be unique |
| Role | Required; must be Event Manager or Employee/Staff (Business Owner role is not assignable) |
| Sector | Required for Event Manager and Employee; must be an existing Business Sector |
| Password | Auto-generated (minimum complexity enforced by system) |

### Business Rules

- Only the Business Owner can create user accounts
- Only the Business Owner can assign roles
- Only the Business Owner can assign or change business sectors
- Only the Business Owner can activate or deactivate accounts
- Event Managers cannot create or manage accounts
- Employees cannot create or manage accounts
- Every account must belong to one assigned business sector
- Accounts are deactivated, not deleted
- There is no public registration, self-registration, invitation links, or email verification
- The Business Owner role cannot be created through this interface (seeded directly)
- The canonical term for this module is "User Account Management" (not "Manage Users", "User Management", or "Manage Accounts")

### Data Used

- Users.name
- Users.email
- Users.password (hashed)
- Users.role
- Users.sector_id
- Users.account_status

### Related Database Tables

- Users
- Business Sectors

### Referenced Wireframe

- Hi-Fi: `users.html`
- Low-Fi: Wireframes section 8 — Manage Users

### Referenced Flowchart Process

- Process 7: User Account Management

### Referenced Use Case

- UC10: Manage User Accounts

---

## FR-004 Record Sales

### Purpose

Record sales transactions and store them permanently for reporting and financial tracking.

### Actors

- Business Owner
- Event Manager

### Preconditions

- User is authenticated
- User has permission to record sales (Owner or Event Manager)

### Trigger

User taps "Record Sale" from the Dashboard or navigates to the Sales screen.

### Main Flow

1. System displays the Sales screen with:
   - Amount field
   - Description field
   - Save Sale Record button
   - Recent transactions list
2. User enters:
   - Amount (required)
   - Description (optional)
3. User taps "Save Sale Record"
4. System validates input
5. System creates a Sales Transactions record with:
   - user_id = authenticated user
   - sector_id = current sector context
   - amount = entered amount
   - description = entered description
   - recorded_at = current timestamp
6. System displays success confirmation
7. Recent transactions list refreshes

### Alternative Flow

**Employee attempts to record a sale:**
1. Sales screen is not available in navigation
2. Access is denied

**Invalid input:**
1. System displays validation error
2. User corrects the input
3. User retries

### Postconditions

- Sales Transactions record is created and stored
- Dashboard financial summaries reflect the new transaction
- Reports data includes the new transaction

### Validation Rules

| Field | Rule |
|-------|------|
| Amount | Required; must be a positive decimal value |
| Description | Optional; free text |

### Business Rules

- Only Business Owners and Event Managers can record sales
- Employees cannot record sales
- Each sale is scoped to the user's current business sector
- Sales records are immutable after creation — corrections require a new entry
- There is no edit or delete functionality for sales records

### Data Used

- Sales Transactions.amount
- Sales Transactions.description
- Sales Transactions.user_id
- Sales Transactions.sector_id
- Sales Transactions.recorded_at

### Related Database Tables

- Sales Transactions
- Users (via user_id)
- Business Sectors (via sector_id)

### Referenced Wireframe

- Hi-Fi: `sales.html`
- Low-Fi: Wireframes section 3 — Sales

### Referenced Flowchart Process

- Process 2: Record Sales

### Referenced Use Case

- UC2: Record Sales Transaction

---

## FR-005 Record Expenses

### Purpose

Record business expenses manually and support system-generated expense records from payroll.

### Actors

- Business Owner
- Event Manager
- System (for payroll-generated expenses)

### Preconditions

- For manual entry: user is authenticated and has permission (Owner or Event Manager)
- For system-generated entry: Payroll Record has been created

### Trigger

**Manual:** User taps "Record Expense" from the Dashboard or navigates to the Expenses screen.
**System:** Payroll Record is saved (see FR-006).

### Main Flow

**Manual Expense:**
1. System displays the Expenses screen with:
   - Amount field
   - Description field
   - Save Expense Record button
   - Recent expenses list
2. User enters:
   - Amount (required)
   - Description (optional)
3. User taps "Save Expense Record"
4. System validates input
5. System creates an Expenses record with:
   - user_id = authenticated user
   - sector_id = current sector context
   - amount = entered amount
   - description = entered description
   - recorded_at = current timestamp
   - payroll_record_id = NULL (manual entry)
6. System displays success confirmation
7. Recent expenses list refreshes

**System-Generated Expense (see FR-006):**
1. Triggered by Payroll Record creation
2. System creates an Expenses record with:
   - user_id = authenticated Business Owner
   - sector_id = same as originating Payroll Record
   - amount = computed_salary from Payroll Record
   - description = indicating payroll origin (e.g., "Payroll — [employee name] — [pay period]")
   - recorded_at = same as calculated_at
   - payroll_record_id = FK to the originating Payroll Record

### Alternative Flow

**Employee attempts to record an expense:**
1. Expenses screen is not available in navigation
2. Access is denied

**Invalid input (manual):**
1. System displays validation error
2. User corrects the input
3. User retries

### Postconditions

- Expenses record is created and stored
- For payroll-generated expenses, the record is permanently linked to the originating Payroll Record
- Dashboard financial summaries reflect the new expense
- Reports data includes the new expense

### Validation Rules

| Field | Rule |
|-------|------|
| Amount | Required; must be a positive decimal value |
| Description | Optional; free text (system-generated expenses use a standard template) |

### Business Rules

- Only Business Owners and Event Managers can record expenses manually
- Employees cannot record expenses
- Each expense is scoped to the current business sector
- Payroll-generated expenses cannot be manually deleted
- Manually recorded expenses have payroll_record_id = NULL
- There is no edit or delete functionality for expense records

### Data Used

- Expenses.amount
- Expenses.description
- Expenses.user_id
- Expenses.sector_id
- Expenses.recorded_at
- Expenses.payroll_record_id (for system-generated entries)

### Related Database Tables

- Expenses
- Users (via user_id)
- Business Sectors (via sector_id)
- Payroll Records (via payroll_record_id, for system-generated entries)

### Referenced Wireframe

- Hi-Fi: `expenses.html`
- Low-Fi: Wireframes section 4 — Expenses

### Referenced Flowchart Process

- Process 3: Record Expenses

### Referenced Use Case

- UC3: Record Expense

---

## FR-006 Payroll

### Purpose

Calculate employee payroll, store payroll records permanently, and automatically create associated expense records.

### Actors

- Business Owner (calculate and view all payroll)
- Event Manager (view own payroll only)
- Employee / Event Staff (view own payroll only)
- System (auto-creates Expense record)

### Preconditions

- Business Owner is authenticated
- Target employee exists in the Users table with role = Event Manager or Employee/Staff

### Trigger

Business Owner navigates to the Payroll screen and selects an employee.

### Main Flow

**Calculate Payroll (Business Owner only):**
1. Business Owner opens the Payroll screen
2. System displays:
   - Employee selector
   - Hours Worked field
   - Hourly Rate field
   - Computed Salary field (read-only, auto-calculated)
   - Calculate & Save button
   - Payroll History list
3. Business Owner selects an employee (Event Manager or Employee/Staff)
4. Business Owner enters:
   - Hours Worked
   - Hourly Rate
5. System computes: computed_salary = hours_worked × hourly_rate
6. System displays the computed salary
7. Business Owner taps "Calculate & Save"
8. System creates a Payroll Records record with:
   - user_id = selected employee
   - sector_id = employee's assigned sector
   - hours_worked, hourly_rate, computed_salary
   - pay_period
   - calculated_at = current timestamp
9. **System automatically** creates an Expenses record (same transaction):
   - user_id = authenticated Business Owner
   - sector_id = same as Payroll Record
   - amount = computed_salary
   - description = indicating payroll origin
   - recorded_at = same as calculated_at
   - payroll_record_id = FK to the new Payroll Record
10. System displays success confirmation
11. Payroll History list refreshes

**View Payroll — Business Owner:**
1. Business Owner opens Payroll screen
2. System displays payroll records for all employees across all sectors
3. Business Owner can view any past payroll record

**View Payroll — Event Manager:**
1. Event Manager opens Payroll screen
2. System displays only the Event Manager's own payroll records
3. Event Manager cannot calculate payroll
4. Event Manager cannot view other employees' payroll

**View Payroll — Employee:**
1. Employee opens Payroll screen
2. System displays only the Employee's own payroll records
3. Employee cannot calculate payroll
4. Employee cannot view other employees' payroll

### Alternative Flow

**Event Manager or Employee attempts to calculate payroll:**
1. Payroll calculation interface is not available
2. Only the view-only payroll history is displayed

**Invalid input:**
1. System displays validation error
2. Business Owner corrects the input
3. Business Owner retries

### Postconditions

- Payroll Records record is created and stored permanently
- Expenses record is created with FK to the Payroll Record
- Dashboard financial summaries reflect the new expense
- Payroll History includes the new record

### Validation Rules

| Field | Rule |
|-------|------|
| Employee | Required; must be an existing user with role Event Manager or Employee/Staff |
| Hours Worked | Required; must be a positive decimal |
| Hourly Rate | Required; must be a positive decimal |

### Business Rules

- Only the Business Owner can calculate payroll
- Business Owner can view payroll for every employee
- Event Manager cannot calculate payroll; can view only their own payroll
- Employee cannot calculate payroll; can view only their own payroll
- computed_salary = hours_worked × hourly_rate
- Payroll records are stored permanently and viewable historically
- Each Payroll Record automatically creates an associated Expense record with amount = computed_salary
- Hourly rate is recorded at the time of calculation (not fetched from a master rate table)
- There is no edit or delete functionality for payroll records

### Data Used

- Payroll Records.hours_worked
- Payroll Records.hourly_rate
- Payroll Records.computed_salary
- Payroll Records.pay_period
- Payroll Records.calculated_at
- Payroll Records.user_id
- Payroll Records.sector_id

### Related Database Tables

- Payroll Records
- Users (via user_id — employee and Business Owner)
- Business Sectors (via sector_id)
- Expenses (auto-created record)

### Referenced Wireframe

- Hi-Fi: `payroll.html`
- Low-Fi: Wireframes section 5 — Payroll (Owner, Event Manager, Employee variants)

### Referenced Flowchart Process

- Process 4: Payroll Processing

### Referenced Use Case

- UC5: View Payroll Calculations
- UC7: View Own Payroll
- UC9: Payroll Auto-creates Expense

---

## FR-007 Reports

### Purpose

Provide financial reports and analytics tailored to each role's scope.

### Actors

- Business Owner
- Event Manager
- Employee / Event Staff

### Preconditions

- User is authenticated

### Trigger

User navigates to the Reports screen.

### Main Flow

**Business Owner:**
1. System displays the Reports screen
2. Business Owner can access:
   - Analytics Dashboard (charts, graphs)
   - Cross-sector Reports (aggregated across all sectors)
   - Per-sector Reports (filtered by selected sector)
3. System displays chart/graph area
4. Business Owner selects a report type
5. System generates the report based on Sales Transactions and Expenses data
6. System displays the report

**Event Manager:**
1. System displays the Reports screen
2. Event Manager can access:
   - Sector Reports (assigned sector only)
3. System displays sector summary chart/graph
4. Event Manager views report scoped to assigned sector

**Employee / Event Staff:**
1. Employee has no separate Reports screen
2. Employee's own payroll view is their only reporting access

### Alternative Flow

N/A — Reports are display-only. No input validation is required.

### Postconditions

- Report data is displayed
- No data is modified

### Validation Rules

N/A — Reports are read-only views. No user input fields are present beyond report type selection.

### Business Rules

- Business Owner: all sectors, analytics dashboard, cross-sector reports
- Event Manager: assigned sector reports only
- Employee: no separate Reports screen — own payroll view is the only reporting access
- Reports are generated from Sales Transactions and Expenses data
- Chart/graph area displays visual summaries of financial data

### Data Used

- Sales Transactions (aggregated by sector and date)
- Expenses (aggregated by sector and date)
- Payroll Records (for Employee's own payroll view)

### Related Database Tables

- Sales Transactions
- Expenses
- Payroll Records (for Employee)

### Referenced Wireframe

- Hi-Fi: `reports.html`
- Low-Fi: Wireframes section 6 — Reports (Owner and Event Manager variants)

### Referenced Flowchart Process

- Process 6: Generate Reports

### Referenced Use Case

- UC6: View Reports

---

## FR-008 Business Sector Switching

### Purpose

Allow the Business Owner to switch between business sectors, refreshing all data to the selected sector's scope.

### Actors

- Business Owner (only)

### Preconditions

- Business Owner is authenticated
- Current sector context is active

### Trigger

Business Owner taps the sector selector on the Dashboard or navigates to the Sector Switcher screen.

### Main Flow

1. System displays the Sector Switcher screen showing the four business sectors:
   - DYS Events
   - B&DYS
   - Flavors by DYS
   - SnapDYS Memories
2. Current sector is highlighted
3. Business Owner taps a target sector
4. System updates the sector context
5. System automatically refreshes:
   - Dashboard (sector-specific financial summary)
   - Sales (sector-specific transactions)
   - Expenses (sector-specific expenses)
   - Reports (sector-specific reports)
6. System returns to the Dashboard with the new sector active
7. No confirmation dialog is shown

### Alternative Flow

**Event Manager or Employee attempts to switch sectors:**
1. Sector Switcher is not available in navigation
2. Access is denied

### Postconditions

- Current sector context is updated to the selected sector
- All data screens reflect the new sector's data
- No data is modified

### Validation Rules

N/A — Sector selection is a navigation action with no data input fields.

### Business Rules

- Only the Business Owner can switch sectors
- Event Managers and Employees are permanently assigned to one sector and cannot switch
- Switching sectors auto-refreshes Dashboard, Sales, Expenses, and Reports
- No confirmation dialog is displayed on switch
- The four approved sectors are:
  - DYS Events (event coordination and styling)
  - B&DYS (souvenirs)
  - Flavors by DYS (grazing tables and celebration drinks)
  - SnapDYS Memories (video guestbook)
- Business Owner's default sector on login is DYS Event Management

### Data Used

- Business Sectors.id (selected sector)
- Business Sectors.name

### Related Database Tables

- Business Sectors

### Referenced Wireframe

- Hi-Fi: `sector-switcher.html`
- Low-Fi: Wireframes section 7 — Business Sector Switcher

### Referenced Flowchart Process

- Process 5: Business Sector Switching

### Referenced Use Case

- UC8: Switch Business Sector

---

## Functional Requirements Matrix

| ID | Requirement | Actor | Priority | Status |
|----|-------------|-------|----------|--------|
| FR-001 | Authentication | All roles | Critical | Approved |
| FR-002 | Dashboard | All roles | Critical | Approved |
| FR-003 | User Account Management | Business Owner only | Critical | Approved |
| FR-004 | Record Sales | Business Owner, Event Manager | Critical | Approved |
| FR-005 | Record Expenses | Business Owner, Event Manager, System | Critical | Approved |
| FR-006 | Payroll | Business Owner, Event Manager, Employee, System | Critical | Approved |
| FR-007 | Reports | Business Owner, Event Manager | High | Approved |
| FR-008 | Business Sector Switching | Business Owner only | High | Approved |

---

## Traceability Matrix

| FR ID | Use Case | Flowchart Process | User Flow | Screen (Hi-Fi) | Database Table |
|-------|----------|------------------|-----------|----------------|----------------|
| FR-001 | UC1: Login | Process 1: Login & Authentication | All role flows | login.html | Users |
| FR-002 | UC4: View Analytics Dashboard | Process 1 (role determination) | All role Dashboards | dashboard.html | Users, Business Sectors, Sales Transactions, Expenses |
| FR-003 | UC10: Manage User Accounts | Process 7: User Account Management | Owner: Manage Users | users.html | Users, Business Sectors |
| FR-004 | UC2: Record Sales Transaction | Process 2: Record Sales | Owner/EM: Record Sales | sales.html | Sales Transactions, Users, Business Sectors |
| FR-005 | UC3: Record Expense | Process 3: Record Expenses | Owner/EM: Record Expenses | expenses.html | Expenses, Users, Business Sectors, Payroll Records |
| FR-006 | UC5, UC7, UC9: Payroll | Process 4: Payroll Processing | Owner/EM/Employee: Payroll | payroll.html | Payroll Records, Users, Business Sectors, Expenses |
| FR-007 | UC6: View Reports | Process 6: Generate Reports | Owner/EM: Reports; Employee: N/A | reports.html | Sales Transactions, Expenses, Payroll Records |
| FR-008 | UC8: Switch Business Sector | Process 5: Business Sector Switching | Owner: Switch Sector | sector-switcher.html | Business Sectors |

---

## Non-Functional References

The following non-functional constraints are defined in the Concept Paper and are referenced here (not rewritten):

- **Security:** Password encryption, authentication, RBAC, regular backups (Concept Paper — Software Engineering Challenges)
- **User Adoption:** Careful onboarding for users accustomed to manual processes (Concept Paper — Software Engineering Challenges)
- **Data Migration:** Validation of existing records during migration from manual formats (Concept Paper — Software Engineering Challenges)
- **Time Constraint:** Project must be completed within approximately six months (Concept Paper — Constraints)
- **Budget Constraint:** Reliance on free, open-source software and development tools (Concept Paper — Constraints)
- **Technical Experience:** Student developers with evolving skill sets (Concept Paper — Constraints)

---

## Consistency Audit

| Source | Status |
|--------|--------|
| Concept Paper | ✓ |
| Client Clarifications | ✓ |
| System Architecture | ✓ |
| System Flowchart | ✓ |
| User Flow | ✓ |
| Use Case | ✓ |
| Use Case Diagram | ✓ |
| Wireframes (Low-Fi) | ✓ |
| Wireframes (Hi-Fi) | ✓ |
| ER Diagram | ✓ |
| Database Schema | ✓ |
| Data Dictionary | ✓ |
| Physical ERD | ✓ |
| Definition of System Components | ✓ |
| Project Memory | ✓ |
| AI Instructions | ✓ |
| CHANGELOG | ✓ |
| VERSION | ✓ |

**Issues Found:** None

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | Functional Requirements Specification (FRS) |
| Version | 1.0 |
| Status | Draft — Pending Audit |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Review | Yes |
