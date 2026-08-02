# System Components — DYS Financial Management System (DYS FMS)

Related:
- concept-paper.md
- project-memory.md
- blueprint/system-architecture.md
- blueprint/user-flow.md
- blueprint/er-diagram.md

## Architecture Overview
Four-layer architecture:
- Client Tier (Flutter Mobile App)
- API Communication Layer (REST API via Laravel Sanctum)
- Backend Application Layer (Laravel 12)
- Data Tier (MySQL Database)

## Client Tier Components
- Login screen
- Dashboard
- Sales entry
- Expenses entry
- Payroll view
- Reports/Analytics
- Business Sector Switcher
- Manage Users (Business Owner only)

## Backend Services
- Authentication & Role Management
- Sales Management
- Expense Management
- Financial Calculator
- Payroll Calculator
- Business Sector Management
- Reports & Analytics
- User Account Management (Business Owner only)

## Data Entities
- User
- Business Sector
- Sales Transaction
- Expense
- Payroll Record (computed salary stored permanently, viewable historically, automatically creates an Expense record)

## User Flow
1. Login → Role-based dashboard
2. Record Sales/Expenses (Owner, Manager only)
3. Generate Reports (role-specific views — monitor income, monitor expenses, view summaries, view reports, track sector performance)
4. Switch Business Sector (Owner only — Owner default sector: DYS Event Management, auto-refreshes Dashboard, Sales, Expenses, Reports)
5. Calculate/View Payroll (Business Owner calculates for any employee; formula: Hours Worked × Hourly Rate, stored permanently, viewable historically, automatically creates Expense record; Event Manager and Employees may only view their own payroll and cannot calculate)
6. Manage User Accounts (Business Owner only — create account, assign role, assign business sector, generate temporary password, activate/deactivate account; no public or self-registration)

## User Roles
- **Business Owner**: Full access to all features, cross-sector visibility, can switch sectors; can calculate payroll for every employee and view payroll for every employee; can create, assign roles/sectors for, and activate/deactivate Event Manager and Employee accounts; default sector on login: DYS Event Management
- **Event Manager**: Sector-specific access, cannot switch sectors, permanently assigned to one sector; cannot calculate payroll; can view only their own payroll (not other employees' payroll); default sector on login: assigned business sector
- **Employees/Event Staff**: View-only access; cannot calculate payroll; can view only their own payroll (not other employees' payroll); permanently assigned to one sector, cannot switch; default sector on login: assigned business sector
