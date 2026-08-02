# Wireframes — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- use-case.md
- user-flow.md

## Screens

### Login
- Authentication entry point
- Credential input fields

### Dashboard
- Role-based landing page after login
- Navigation to all permitted features

### Sales
- Sales transaction recording interface
- Available to Business Owner and Event Manager

### Expenses
- Expense recording interface
- Available to Business Owner and Event Manager

### Payroll
- Payroll calculation display
- Business Owner: can calculate and view payroll for every employee
- Event Manager / Employee: view-only, limited to their own payroll; cannot calculate

### Reports
- Analytics and reporting interface
- Role-specific data access (Employees do not have a separate Reports screen — their own-payroll view is their only reporting access)

### Business Sector Switcher
- Sector selection interface
- Available to Business Owner only
- Owner default active sector on login: DYS Event Management
- Event Manager / Employee default active sector on login: their assigned business sector
- Auto-refreshes Dashboard, Sales, Expenses, Reports on switch

### Manage Users
- User account management interface
- Available to Business Owner only
- Functions: user list, add user, edit user, activate/deactivate user, assign role, assign sector, generate temporary password
- No public registration, self-registration, Register/Sign Up screen, or invitation links

## Technology
HTML-based high-fidelity wireframes
