# Use Case Diagram — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- user-flow.md
- wireframes.md

## Actors
- **Business Owner**: Full system access; default sector on login: DYS Event Management; can switch sectors
- **Event Manager**: Sector-specific operational access; default sector on login: assigned business sector; permanently assigned, cannot switch
- **Employees/Event Staff**: Limited view-only access; default sector on login: assigned business sector; permanently assigned, cannot switch

## Use Cases
1. **Login/Authenticate** — All actors
2. **Record Sales Transaction** — Business Owner, Event Manager
3. **Record Expense** — Business Owner, Event Manager
4. **View Analytics Dashboard** — Business Owner
5. **View Payroll Calculations** — Business Owner only (includes calculating payroll for any employee; no other role may calculate payroll)
6. **View Reports** — Event Manager
7. **View Own Payroll** — Event Manager, Employees/Event Staff
8. **Switch Business Sector** — Business Owner only
9. **Payroll Auto-creates Expense** — System action when payroll is calculated
10. **Manage User Accounts** — Business Owner only (create account, assign role, assign business sector, generate temporary password, activate/deactivate account)

## Relationships
- All use cases require prior authentication
- Business Owner includes all use cases
- Only the Business Owner can calculate payroll; Event Manager and Employees cannot calculate payroll and may only view their own payroll record
- Only the Business Owner can manage user accounts; there is no public registration or self-registration
- Event Manager includes sales, expense, and reports within assigned sector, plus viewing their own payroll only
- Employees are limited to login and viewing their own payroll only
- Payroll Processing (use case 5) → automatically triggers Expense creation (use case 9)
