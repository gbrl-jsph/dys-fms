# ER Diagram — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- ../system-components.md
- database-schema.md
- system-architecture.md

## Entities

### User
- Represents system actors (Business Owner, Event Manager, Employee/Staff)
- Linked to a permanent Business Sector (for Event Managers and Employees)
- Business Owner has cross-sector access via sector switching
- Includes an account status attribute (active/inactive), managed exclusively by the Business Owner; used instead of deleting user records
- All Event Manager and Employee accounts are created exclusively by the Business Owner; there is no public or self-registration

### Business Sector
- Represents distinct business sectors within the organization
- Each sector has its own financial data scope

### Sales Transaction
- Records individual sales transactions
- Linked to a User and Business Sector

### Expense
- Records individual business expenses
- Linked to a User and Business Sector
- Auto-created when Payroll Record is generated

### Payroll Record
- Represents computed salary for a user in a pay period
- Calculated as Hours Worked × Hourly Rate
- Stored permanently for historical records and viewability
- Automatically creates an associated Expense record

## Relationships
- User → Business Sector (many-to-one for Event Managers and Employees; Owner has cross-sector switching)
- User → Sales Transaction (one-to-many)
- User → Expense (one-to-many)
- User → Payroll Record (one-to-many)
- Business Sector → Sales Transaction (one-to-many)
- Business Sector → Expense (one-to-many)
- Business Sector → Payroll Record (one-to-many)
- Payroll Record → Expense (one-to-one; auto-created when payroll is calculated)
