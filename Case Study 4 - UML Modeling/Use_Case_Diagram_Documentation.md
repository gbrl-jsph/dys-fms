# Use Case Diagram Documentation — Proposed System

**Project:** DYS Financial Management System (DYS FMS)  
**Deliverable:** Case Study #4 — Deliverable 2  
**Notation authority:** Instructor-provided `UML.pdf`

## Purpose

This proposed-system use case diagram presents approved actor goals and system relationships only. It models actor-facing scenarios, high-level use cases, and structural includes/extends as defined in the approved reference model.

## Actors

| Actor | Scope |
|---|---|
| Business Owner | Full authorized financial-management access, administration, reporting, and sector switching. |
| Event Manager | Assigned-sector sales and expenses, login, dashboard, and reporting access. |
| Bookkeeper | Viewing-only financial and analytics access (Login, View Analytics, and reporting/payroll viewing). |
| Employee/Event Staff | Authenticated system access and viewing own payroll. |

## Use Cases & Relationships

### Authentication & Core
* `Login`
* `Logout` (`<<include>>` from Login)
* `View Dashboard` (`<<include>>` from Login)

### Management & Administration
* `Manage User Accounts` (Business Owner only: create, update, activate/deactivate, generate temporary password)
* `Switch Business Sector` (Business Owner only)

### Financial Transactions & Operations
* `Record Sales` (Business Owner & Event Manager; `<<include>>` to View Reports)
* `Record Expenses` (Business Owner & Event Manager; `<<include>>` to View Reports)
* `Calculate Payroll` (Business Owner only; `<<include>>` to View Reports; automatically creates associated expense)

### Reports & Analytics
* `View Reports` (Parent reporting use case)
  * `View Financial Summary` (`<<extend>>` from View Reports)
  * `View Sales Reports` (`<<extend>>` from View Reports)
  * `View Expense Reports` (`<<extend>>` from View Reports)
  * `View Payroll Reports` (`<<extend>>` from View Reports)
  * `View Analytics` (`<<extend>>` from View Reports; accessible by Business Owner & Bookkeeper)

### Staff Payroll
* `View Own Payroll` (Event Manager and Employee/Event Staff viewing their own payroll information only)

## Actor Access Summary

| Use Case | Business Owner | Event Manager | Bookkeeper | Employees/Event Staff |
|---|:---:|:---:|:---:|:---:|
| Login / Logout | Yes | Yes | Yes | Yes |
| View Dashboard | Yes | Yes | Yes | Yes |
| Manage User Accounts | Yes | No | No | No |
| Switch Business Sector | Yes | No | No | No |
| Record Sales | Yes | Assigned sector | No | No |
| Record Expenses | Yes | Assigned sector | No | No |
| Calculate Payroll | Yes | No | No | No |
| View Reports (and specializations) | Yes | Yes | View-only | No |
| View Analytics | Yes | No | Yes | No |
| View Own Payroll | No | Yes | No | Yes |

## Business Rules & Constraints

* **Manage User Accounts:** Business Owner only. Covers user creation, updates, status toggling, and temporary password generation/delivery.
* **Switch Business Sector:** Business Owner only. Allows dynamic switching between active business sectors.
* **Record Sales / Record Expenses:** Restricted to Business Owner and Event Manager in their authorized sector context.
* **Calculate Payroll:** Business Owner only. Computes hours × rate, stores payroll records, and automatically generates an associated expense record.
* **Bookkeeper Access:** Viewing-only access to Login, View Analytics, View Reports/financial records, and payroll reporting. Cannot record sales, record expenses, calculate payroll, switch sectors, or manage users.
* **View Own Payroll:** Restricted strictly to Event Manager and Employee/Event Staff for their own payroll records.

## UML.pdf Compliance

* Four actors positioned outside the `DYS Financial Management System` boundary.
* Use cases represented as gold/yellow ovals inside the boundary.
* Solid, arrowless actor associations alongside standard `<<include>>` and `<<extend>>` dashed relationships where required by the approved model.
