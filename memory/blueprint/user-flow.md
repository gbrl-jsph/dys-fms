# User Flow — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- system-flowchart.md
- use-case.md

## Flows

### 1. Login
- **Actors**: All roles
- **Flow**: Open app → Enter credentials → System authenticates → Role-based dashboard (Owner defaults to DYS Event Management; EM/Employee defaults to assigned sector)

### 2. Record Sales
- **Actors**: Business Owner, Event Manager
- **Flow**: Dashboard → Record Sales → System processes → Result displayed

### 3. Record Expenses
- **Actors**: Business Owner, Event Manager
- **Flow**: Dashboard → Record Expense → System processes → Result displayed

### 4. Generate Reports
- **Actors**: All roles (role-specific views)
- **Flow**: Dashboard → Select report → System processes → Result displayed
- **Capabilities**: monitor income, monitor expenses, view summaries, view reports, track sector financial performance
- **Business Owner**: Analytics Dashboard, cross-sector reports; can calculate and view payroll for every employee
- **Event Manager**: Role-restricted Reports within assigned sector; can view only their own payroll, cannot calculate payroll
- **Employees**: Own Payroll only; cannot calculate payroll

### 5. Switch Business Sector
- **Actors**: Business Owner only
- **Flow**: Dashboard → Switch sector → System updates context → Dashboard, Sales, Expenses, Reports auto-refresh for selected sector

### 6. Payroll Processing
- **Actors**: Business Owner (calculates payroll for any employee); Event Manager and Employees (view own payroll only, cannot calculate)
- **Flow**: Business Owner selects employee and calculates payroll (Hours × Rate) → Salary stored permanently → Expense record auto-created → Results viewable historically (Business Owner: all employees; Event Manager/Employees: own record only)

### 7. Manage User Accounts
- **Actors**: Business Owner only
- **Flow**: Business Owner Dashboard → Manage Users → Create User → Assign Role → Assign Business Sector → Generate Temporary Password → Save Account → Display Credentials → Return to Dashboard
- **Note**: There is no public registration or self-registration; only the Business Owner can create accounts.

## Default Sector on Login
- **Business Owner**: DYS Event Management
- **Event Manager / Employee**: Their assigned business sector

## Business Rules
- Business Owner creates all Event Manager and Employee accounts; there is no public or self-registration
- Only the Business Owner can activate or deactivate user accounts
- Only the Business Owner can calculate payroll
- Business Owner can view payroll for every employee
- Event Manager cannot calculate payroll and can view only their own payroll (not other employees' payroll)
- Employees cannot record sales/expenses or switch sectors
- Employees cannot calculate payroll and can view only their own payroll (not other employees' payroll)
- Business Owner has cross-sector visibility, can switch sectors
- Event Manager has sector-specific access, permanently assigned to one sector, cannot switch
- Business Owner default sector on login: DYS Event Management
- Event Manager / Employee default sector on login: assigned business sector
