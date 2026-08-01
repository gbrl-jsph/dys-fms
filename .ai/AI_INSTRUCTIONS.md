# DYS Financial Management System (DYS FMS) — AI Instructions

Related:
- concept-paper.md
- project-memory.md
- client-interview.md
- project-index.md

## Source of Truth

When documents conflict, use this precedence:

1. Latest Approved Client Clarifications
2. Official Revised Concept Paper
3. Approved Blueprint Documents
4. Definition of System Components
5. Client Interview (historical reference)
6. Curated `.ai/` documents

If a lower-priority document conflicts with a higher-priority one, update the lower-priority document and report the change.

## Never Invent
- Features
- User roles
- Business processes
- Database entities
- Permissions
- Technologies

unless explicitly approved.

## Current Scope

### Functional Scope
- Mobile application
- Financial transaction monitoring and management
- Four business sectors (DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories)
- Owner-only sector switching (Event Managers and Employees permanently assigned to one sector)

### Approved Implementation
- Flutter (mobile frontend)
- Laravel 12 REST API backend
- MySQL database

## Approved Features
- Login and Authentication
- Role-Based Access Control (RBAC)
- User Account Management (Business Owner only — creates and manages all Event Manager and Employee accounts; assigns role and business sector; generates temporary credentials; activates/deactivates accounts; no public or self-registration)
- Sales Transaction Recording
- Expense Recording
- Automatic Financial Calculator
- Automatic Payroll Calculator (Hours Worked × Hourly Rate; computed salary stored permanently, viewable historically, automatically creates an Expense record)
- Business Sector Switcher (Owner only; Owner default sector: DYS Event Management; auto-refreshes Dashboard, Sales, Expenses, Reports on switch)
- Visual Reports (Analytics Dashboard, monitor income/expenses, view summaries, track sector performance)

## Approved User Roles
- Business Owner — full access, cross-sector visibility, can switch sectors, can calculate payroll for every employee and view payroll for every employee, can create/assign roles/sectors for/activate/deactivate Event Manager and Employee accounts; default sector on login: DYS Event Management
- Event Manager — sector-specific operational access, permanently assigned to one sector, cannot switch, cannot calculate payroll, can view only their own payroll (not other employees' payroll); default sector on login: assigned business sector
- Employees/Event Staff — view-only, cannot calculate payroll, can view only their own payroll (not other employees' payroll), permanently assigned to one sector, cannot switch; default sector on login: assigned business sector

## Workflows
1. Login → Role-based dashboard (Owner: DYS Event Management; EM/Employee: assigned sector)
2. Record Sales (Owner, Manager)
3. Record Expenses (Owner, Manager)
4. Generate Reports (role-specific — monitor income/expenses, view summaries, track sector performance)
5. Switch Business Sector (Owner only) — default sector after login: DYS Event Management, auto-refreshes Dashboard, Sales, Expenses, Reports
6. Payroll — calculated by the Business Owner only (Hours × Rate) for any employee, stored permanently, viewable historically, and auto-creates an Expense record. Event Managers and Employees may only view their own payroll and cannot calculate payroll.
7. Manage User Accounts (Business Owner only) — Open Manage Users → Create User → Assign Role → Assign Business Sector → Generate Temporary Password → Save Account → Display Credentials → Return to Dashboard. No public or self-registration exists.

## Things AI Must Never Do
- Add features not in the approved list
- Create new user roles
- Assume a web version (mobile-first via Flutter)
- Add admin/super-admin roles
- Add public registration, self-registration, Register/Sign Up screens, or invitation-link account creation
- Add password reset via email
- Add payment processing or invoicing
- Design API endpoints or database fields beyond documented scope
- Do not modify original project files unless explicitly instructed by the user
- By default, write AI-generated knowledge and summaries only to `.ai/`

Always verify consistency against the Source of Truth before making changes.

## Client Clarifications

A client clarification becomes "approved" only when it has been confirmed by the user and incorporated into the project.

Examples include:
- Meeting notes
- Client interviews
- Professor-approved revisions
- Written client confirmations

Do not treat assumptions or AI suggestions as client clarifications.

## Uncertainty Policy

If the required information is not explicitly supported by the Concept Paper, approved blueprint, or latest client-approved clarification:

- Stop.
- Report the missing information.
- Ask for clarification.
- Do not invent, infer, or assume requirements.

Unknown information is preferable to incorrect information.

## Requirements vs Design

Always distinguish between:

- Functional requirements (what the client requires)
- Design decisions (how the system implements those requirements)

Never convert a design decision into a requirement.

Examples:
- "Salary must be stored." → Requirement.
- "Use a payroll_records table." → Design decision.
- "Use PostgreSQL." → Design decision.
- "Use Flutter." → Design decision unless explicitly approved.

## Documentation Consistency

Whenever a requirement changes:

1. Identify every affected document.
2. Update all affected documentation.
3. Regenerate the corresponding `.ai/` files.
4. Report which files changed.
5. Perform a final consistency check before completion.

Never update only one document if the change affects multiple project artifacts.

## AI Instructions Version

Version: 3.1
Last Updated: 2026-07-28

This document governs all AI-assisted work on the DYS Financial Management System (DYS FMS).

Whenever this document changes:
- Record the change in `.ai/CHANGELOG.md`.
- Increment the version number.
- Regenerate any affected `.ai/` documents.
- Notify the user which governance rules changed.

## Before Starting Any Task

Before making changes:

1. Read AI_INSTRUCTIONS.md.
2. Identify the relevant Source of Truth document.
3. Verify the requested task does not conflict with approved requirements.
4. If a conflict exists, stop and report it before making changes.
5. After completing the task, perform a consistency check if documentation was modified.
