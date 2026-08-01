# Project Memory — DYS Financial Management System (DYS FMS)

Related:
- concept-paper.md
- client-interview.md
- project-index.md
- AI_INSTRUCTIONS.md
- blueprint/system-architecture.md
- blueprint/user-flow.md
- blueprint/consistency-review.md

*Optimized for AI context loading*

## Current Project Scope
A centralized financial transaction monitoring and management system for DYS Event Management, built as a mobile-first application with role-based access control.

## Project Name
DYS Financial Management System (DYS FMS)

## Tech Stack
- **Frontend**: Flutter (Mobile Application)
- **Backend**: Laravel 12
- **API**: REST API with Laravel Sanctum Authentication
- **Database**: MySQL
- **Communication**: HTTPS / JSON

## Approved Features
1. Role-Based Access Control (RBAC)
2. Sales Transaction Recording
3. Expense Recording
4. Automated Financial Calculator
5. Automated Payroll Calculator (Hours Worked × Hourly Rate; computed salary stored permanently, viewable historically, automatically creates an Expense record)
6. Business Sector Switcher (Owner only; Owner default sector: DYS Event Management; auto-refreshes Dashboard, Sales, Expenses, Reports on switch)
7. Interactive Visual Analytics Dashboard
8. Report Generation (monitor income, monitor expenses, view summaries, view reports, track sector financial performance)
9. User Account Management (Business Owner only — create accounts, assign role, assign business sector, generate temporary credentials, activate/deactivate accounts; no public or self-registration)

## Approved User Roles
- **Business Owner**
  - Full system access
  - Cross-sector visibility
  - Can record sales and expenses
  - Can switch business sectors (default sector after login: DYS Event Management)
  - Can view analytics dashboard
  - Can calculate payroll for every employee
  - Can view payroll for every employee
  - Can create, assign roles/sectors for, and activate/deactivate Event Manager and Employee accounts
- **Event Manager**
  - Sector-specific access
  - Can record sales and expenses
  - Permanently assigned to one business sector, cannot switch
  - Can view reports within assigned sector
  - Cannot calculate payroll
  - Can view only their own payroll (cannot view other employees' payroll)
- **Employees/Event Staff**
  - View-only access
  - Permanently assigned to one business sector, cannot switch
  - Cannot record sales or expenses
  - Cannot calculate payroll
  - Can view only their own payroll (cannot view other employees' payroll)

## Approved Workflows
1. **Login**: Authenticate → Role-based dashboard redirect
2. **Record Sales**: Dashboard → Record Sales → System processes → Result displayed
3. **Record Expenses**: Dashboard → Record Expense → System processes → Result displayed
4. **Generate Reports**: Dashboard → Select report type → System processes → Report displayed (monitor income, monitor expenses, view summaries, view reports, track sector performance)
5. **Switch Business Sector**: Owner only → Switch sector → System updates context → Dashboard, Sales, Expenses, Reports auto-refresh for selected sector
6. **Calculate/View Payroll**: Business Owner selects an employee and calculates payroll (Hours Worked × Hourly Rate) → Salary stored permanently → Expense record auto-created → Result displayed (viewable historically). Event Managers and Employees may only view their own payroll record; they cannot calculate payroll.
7. **Manage User Accounts**: Business Owner only → Open Manage Users → Create User → Assign Role → Assign Business Sector → Generate Temporary Password → Save Account → Display Credentials → Return to Dashboard. Employee may optionally change password on first login. No public or self-registration exists.

## Business Rules
- Business Owner creates all Event Manager and Employee accounts; there is no public or self-registration
- Only the Business Owner can activate or deactivate user accounts
- Only the Business Owner can calculate payroll
- Business Owner can view payroll for every employee
- Event Managers cannot calculate payroll and can view only their own payroll
- Employees cannot calculate payroll and can view only their own payroll
- Only Business Owners and Event Managers can record sales/expenses
- Employees/Event Staff cannot record transactions or switch sectors
- Business Owners can view analytics, and can switch sectors
- Event Managers can view reports within their assigned sector only, cannot switch sectors
- The system uses role-based dashboards (Role-Based Access Control)
- Business sector switching is available only to Owner
- Business Owner's default sector on login is DYS Event Management
- Event Managers and Employees default to their assigned business sector on login
- Switching sectors auto-refreshes Dashboard, Sales, Expenses, and Reports
- Payroll is calculated as Hours Worked × Hourly Rate, stored permanently, viewable historically, and automatically creates an Expense record
- Event Managers and Employees are permanently assigned to one business sector

## Naming Conventions
- **Project**: DYS Financial Management System (DYS FMS) (formerly DYS Event Management System / DYS Sales Tracker Management System)
- **Frontend**: Flutter mobile application
- **Backend**: Laravel 12
- **Database**: MySQL
- **API Style**: REST

## Current Completed Deliverables
- Concept Paper
- Client Interview Documentation
- System Architecture Documentation
- System Flowchart Documentation
- User Flow Diagram & Documentation
- Use Case Diagram & Documentation
- Use Case Diagram (Visual Mermaid)
- Wireframes (Hi-Fi HTML)
- ER Diagram Documentation
- Database Design Documentation
- System Architecture HTML visualization

## Finalized Diagrams
- System Architecture Diagram (v1.1 — amended for User Account Management) @ `.ai/diagrams/system-architecture.md`
- System Flowchart Diagram (v1.1 — amended for User Account Management) @ `.ai/diagrams/system-flowchart.md`
- User Flow Diagram (v1.1 — amended for User Account Management) @ `.ai/diagrams/user-flow.md`
- Wireframes (v1.1 — amended for User Account Management) @ `.ai/diagrams/wireframes.md`
- Use Case Diagram (v1.1 — amended for User Account Management) @ `.ai/blueprint/use-case-diagram.md`
- High-Fidelity Wireframes (updated and synchronized) @ `5 - Wireframes/wireframes-hifi/`

## Pending Deliverables
- Development Planning (empty directory)
- Low-fidelity wireframes (Figma file only, not converted)
- Database Design Diagrams (ER + Schema diagram form)

## Things AI Must NEVER Invent
- Additional user roles beyond the three approved (Business Owner, Event Manager, Employees/Event Staff)
- Features not listed in the approved Concept Paper
- Authentication failure handling flows (not depicted in approved diagrams)
- Admin role or Super Admin role
- Public registration, self-registration, Register/Sign Up screens, or invitation-link account creation
- Password reset via email
- Web application version (system is mobile-first via Flutter)
- API endpoints or database fields not documented in the source documents
- Payment processing or invoicing features

## Source of Truth Hierarchy
1. Latest Approved Client Clarifications (Highest priority)
2. Official Revised Concept Paper (Canonical feature definitions)
3. Approved Blueprint Documents (Architecture, Flowchart, User Flow, Use Case, Wireframes, ER Diagram, Database)
4. Definition of System Components
5. Client Interview (Historical reference only)
6. Curated `.ai/` documents

## Document Index
Extracted documents are in `.ai/extracted/`. Curated documents are at `.ai/`.
