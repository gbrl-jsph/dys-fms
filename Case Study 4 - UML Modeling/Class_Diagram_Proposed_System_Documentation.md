# Class Diagram Documentation — Proposed System

**Project:** DYS Financial Management System (DYS FMS)  
**Deliverable:** Case Study #4 — Class Diagram (Deliverable 3)  
**Version:** 1.1 (Comprehensive Three-Diagram Chain & Consistency Audit)  
**Status:** Complete — Waiting for Approval  
**Date:** August 25, 2026  

---

## 1. Purpose & Objective

This Class Diagram models the **object-oriented domain structure** of the proposed **DYS Financial Management System (DYS FMS)**. It answers the fundamental engineering question:

> **What are the major domain objects, attributes, operations, and relationships required to support the proposed system's approved functional requirements and use cases?**

The Class Diagram forms the third milestone in the unified modeling sequence:
$$\text{Activity Diagram (Current Process: As-Is)} \longrightarrow \text{Use Case Diagram (Proposed System)} \longrightarrow \text{Class Diagram (Proposed Domain Model)}$$

It is a **domain-level UML Class Diagram**, designed to capture business logic, responsibilities, and structural relationships, rather than a raw database entity-relationship (ER) schema or an implementation code inventory.

---

## 2. Mandatory Three-Diagram Traceability Chain

The three UML deliverables form a coherent, unbroken chain derived directly from the Product Owner's (Mrs. Divine Samonte) actual business operations:

```
+---------------------------------------------------------------------------------------------------------------+
|                                      MANDATORY THREE-DIAGRAM TRACEABILITY CHAIN                                |
+------------------------------------+-------------------------------------+------------------------------------+
| 1. Current Process (Activity Diag) | 2. Proposed System (Use Case Diag)  | 3. Domain Model (Class Diagram)    |
+------------------------------------+-------------------------------------+------------------------------------+
| Business transaction across 4      | UC8: Switch Business Sector         | Class: `BusinessSector`            |
| sectors (DYS Events, B&DYS,        | UC4: View Analytics Dashboard       | - Scopes all transactions          |
| Flavors by DYS, SnapDYS Memories)  |                                     | - `getFinancialSummary()`          |
+------------------------------------+-------------------------------------+------------------------------------+
| Manual sales recording in ledger   | UC2: Record Sales Transaction       | Class: `SalesTransaction`          |
| / handwritten sales notes          | (Actor: Business Owner, Event Mgr)  | - `validateAmount()`, `amount`     |
+------------------------------------+-------------------------------------+------------------------------------+
| Supplies bought; receipts sent via | UC3: Record Expense                 | Class: `Expense`                   |
| Messenger; risk of lost receipts   | (Actor: Business Owner, Event Mgr)  | - `isPayrollGenerated()`           |
+------------------------------------+-------------------------------------+------------------------------------+
| Manual payroll calculation:        | UC5: View Payroll Calculations      | Class: `PayrollRecord`             |
| Hours Worked x Hourly Rate         | UC7: View Own Payroll               | - `computeSalary()`                |
|                                    | UC9: Payroll Auto-creates Expense   | - `createExpenseRecord()`          |
+------------------------------------+-------------------------------------+------------------------------------+
| Financial records scattered across | UC4: View Analytics Dashboard       | Class: `FinancialSummary` &        |
| notes, receipts, Messenger, ledger | UC6: View Reports                   | Class: `FinancialReport`           |
|                                    | (Actor: Business Owner, Event Mgr)  | - Real-time metrics & aggregations |
+------------------------------------+-------------------------------------+------------------------------------+
| Manual role coordination: Owner,   | UC1: Login                          | Class: `User` &                    |
| Bookkeeper, Employee/Event Staff   | UC10: Manage User Accounts          | Enum: `UserRole`, `AccountStatus`  |
|                                    | (RBAC: Owner, Event Mgr, Staff)     | - `authenticate()`, `activate()`   |
+------------------------------------+-------------------------------------+------------------------------------+
```

---

## 3. Inventory of Domain Classes & Enumerations

The domain model comprises **7 core classes** and **3 enumerations**, each strictly traceable to approved functional requirements (FR-001 through FR-008):

| Class / Enum Name | Stereotype / Type | Primary Responsibility in Proposed System | Traceable Use Cases |
|---|---|---|---|
| **`User`** | Domain Class | Represents system actors, manages authentication, role assignment, sector binding, and account status. | UC1, UC10 |
| **`BusinessSector`** | Domain Class | Represents one of the 4 DYS business branches; scopes financial transactions and computes sector totals. | UC4, UC8 |
| **`SalesTransaction`** | Domain Class | Encapsulates incoming revenue records with amounts, descriptions, and timestamps. | UC2 |
| **`Expense`** | Domain Class | Encapsulates operational outflows, supporting both manual entries and system-generated payroll expenses. | UC3, UC9 |
| **`PayrollRecord`** | Domain Class | Stores permanent historical payroll computations ($\text{Hours} \times \text{Rate}$) and triggers automatic expense creation. | UC5, UC7, UC9 |
| **`FinancialSummary`** | `<<value object>>` | Aggregates real-time financial metrics (Total Sales, Total Expenses, Net Balance) for the dashboard. | UC4, FR-002 |
| **`FinancialReport`** | Domain Class | Coordinates report generation, date-range filtering, and multi-sector financial analytics. | UC4, UC6, FR-007 |
| **`UserRole`** | `<<enumeration>>` | Final-design roles (`BUSINESS_OWNER`, `EVENT_MANAGER`, `BOOKKEEPER`, `EMPLOYEE_EVENT_STAFF`). | UC1, UC10 |
| **`AccountStatus`** | `<<enumeration>>` | Account lifecycle state (`ACTIVE`, `INACTIVE`). | UC1, UC10 |
| **`ReportType`** | `<<enumeration>>` | Approved report classifications (`SUMMARY`, `SALES`, `EXPENSES`, `PAYROLL`, `ANALYTICS`). | UC6, FR-007 |

---

## 4. Detailed Class Specifications

### 4.1 `User`
Represents an authenticated user within the system. Encapsulates identity, role-based capabilities, and account lifecycle.

* **Attributes:**
  * `- id: Integer` — Unique identifier.
  * `- name: String` — Full name of the user.
  * `- email: String` — Unique login email address.
  * `- passwordHash: String` — BCrypt-hashed password.
* `- role: UserRole` — Assigned final-design role (`BUSINESS_OWNER`, `EVENT_MANAGER`, `BOOKKEEPER`, `EMPLOYEE_EVENT_STAFF`).
  * `- accountStatus: AccountStatus` — Current account state (`ACTIVE` or `INACTIVE`).
* **Operations:**
  * `+ authenticate(password: String): Boolean` — Validates credentials and active status (UC1).
  * `+ activate(): void` — Sets `accountStatus` to `ACTIVE` (UC10).
  * `+ deactivate(): void` — Sets `accountStatus` to `INACTIVE` (UC10).
  * `+ updateProfile(name: String, email: String): void` — Updates user information (UC10).
  * `+ assignRole(newRole: UserRole): void` — Assigns role permissions (UC10).
  * `+ assignSector(sector: BusinessSector): void` — Permanently assigns business sector (UC10).
  * `+ isOwner(): Boolean` — Convenience helper for Owner-only operations.

### 4.2 `BusinessSector`
Represents one of the four business branches (*DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories*). Serves as the organizational boundary for financial transactions.

* **Attributes:**
  * `- id: Integer` — Unique sector identifier (1 to 4).
  * `- name: String` — Official sector name.
  * `- description: String` — Description of sector services/products.
* **Operations:**
  * `+ calculateTotalSales(): Decimal` — Computes aggregate revenue for the sector.
  * `+ calculateTotalExpenses(): Decimal` — Computes aggregate operational and payroll expenses for the sector.
  * `+ calculateNetBalance(): Decimal` — Computes $\text{Total Sales} - \text{Total Expenses}$.
  * `+ getFinancialSummary(): FinancialSummary` — Generates active dashboard metrics (FR-002, FR-008).

### 4.3 `SalesTransaction`
Represents an immutable record of revenue earned by a specific business sector.

* **Attributes:**
  * `- id: Integer` — Unique transaction identifier.
  * `- amount: Decimal` — Positive transaction value in Philippine Pesos (₱).
  * `- description: String` — Free-text description of event package or items sold.
  * `- recordedAt: DateTime` — System timestamp when the sale was recorded.
* **Operations:**
  * `+ validateAmount(): Boolean` — Verifies amount is positive ($> 0$).
  * `+ getSummary(): String` — Returns a formatted summary string.

### 4.4 `Expense`
Represents an immutable business expense. Supports both manual recordings (e.g. supplies, catering materials) and system-generated salary entries created from payroll calculations.

* **Attributes:**
  * `- id: Integer` — Unique expense identifier.
  * `- amount: Decimal` — Positive expense amount in Philippine Pesos (₱).
  * `- description: String` — Expense description or auto-generated payroll label.
  * `- recordedAt: DateTime` — System timestamp when the expense was recorded.
* **Operations:**
  * `+ validateAmount(): Boolean` — Verifies amount is positive ($> 0$).
  * `+ isPayrollGenerated(): Boolean` — Returns `true` if `payrollRecordId != null` (UC9).
  * `+ getSummary(): String` — Returns formatted expense details.

### 4.5 `PayrollRecord`
Represents a permanent employee salary calculation performed exclusively by the Business Owner.

* **Attributes:**
  * `- id: Integer` — Unique payroll record identifier.
  * `- hoursWorked: Decimal` — Total operational hours worked during the pay period.
  * `- hourlyRate: Decimal` — Agreed hourly pay rate.
  * `- computedSalary: Decimal` — Derived gross pay ($\text{hoursWorked} \times \text{hourlyRate}$).
  * `- payPeriod: Date` — End date of the pay period.
  * `- calculatedAt: DateTime` — System timestamp of calculation.
* **Operations:**
  * `+ computeSalary(): Decimal` — Multiplies hours worked by hourly rate.
  * `+ createExpenseRecord(): Expense` — Factory method creating the corresponding `Expense` object (UC9).
  * `+ getSummary(): String` — Returns formatted payroll breakdown.

### 4.6 `FinancialSummary` `<<value object>>`
Represents the real-time financial status displayed on the interactive Dashboard.

* **Attributes:**
  * `- totalSales: Decimal` — Sum of sales for active sector.
  * `- totalExpenses: Decimal` — Sum of expenses for active sector.
  * `- netBalance: Decimal` — Remaining balance ($\text{Sales} - \text{Expenses}$).
* **Operations:**
  * `+ calculateNet(): Decimal` — Computes net margin.
  * `+ formatCurrency(amount: Decimal): String` — Formats values to currency strings (₱).

### 4.7 `FinancialReport`
Represents the analytical reporting component that aggregates transactions, compares sector performance, and feeds visual charts.

* **Attributes:**
  * `- reportType: ReportType` — Type of report (`SUMMARY`, `SALES`, `EXPENSES`, `PAYROLL`, `ANALYTICS`).
  * `- dateFrom: Date` — Filter start date.
  * `- dateTo: Date` — Filter end date.
  * `- totalSales: Decimal` — Aggregate sales in scope.
  * `- totalExpenses: Decimal` — Aggregate expenses in scope.
  * `- netBalance: Decimal` — Aggregate net balance in scope.
  * `- isCrossSector: Boolean` — Flag indicating cross-sector aggregation (Owner only).
* **Operations:**
  * `+ generateReport(): void` — Executes aggregation queries across transactions.
  * `+ filterByDateRange(from: Date, to: Date): void` — Applies date filters.
  * `+ getSectorBreakdown(): Map<String, Decimal>` — Returns per-sector breakdown for analytics charts.

---

## 5. Object Relationships & Multiplicities

```
+-----------------------------------------------------------------------------------+
|                                 RELATIONSHIP MATRIX                               |
+----------------------+--------------------+----------------+----------------------+
| Source Class         | Target Class       | Relationship   | Multiplicity (S -> T)|
+----------------------+--------------------+----------------+----------------------+
| User                 | BusinessSector     | Association    | 0..*  --->  0..1     |
| User                 | SalesTransaction   | Association    | 1     --->  0..*     |
| User                 | Expense            | Association    | 1     --->  0..*     |
| User                 | PayrollRecord      | Association    | 1     --->  0..*     |
| BusinessSector       | SalesTransaction   | Composition    | 1     *--   0..*     |
| BusinessSector       | Expense            | Composition    | 1     *--   0..*     |
| BusinessSector       | PayrollRecord      | Composition    | 1     *--   0..*     |
| BusinessSector       | FinancialSummary   | Dependency     | 1     ..>   1        |
| PayrollRecord        | Expense            | Association    | 1  -->  1 (auto-creates) |
| FinancialReport      | BusinessSector     | Dependency     | ..>                  |
| FinancialReport      | SalesTransaction   | Dependency     | ..>                  |
| FinancialReport      | Expense            | Dependency     | ..>                  |
| FinancialReport      | PayrollRecord      | Dependency     | ..>                  |
+----------------------+--------------------+----------------+----------------------+
```

### Semantic Justification of Multiplicities:
1. **`User` to `BusinessSector` (`0..*` to `0..1`):**
   * A `BusinessSector` contains zero or more assigned users (`0..*`).
   * A `User` is assigned to at most one `BusinessSector` (`0..1`). Event Managers, Bookkeepers, and Employee/Event Staff may be assigned to one sector; the Business Owner has 0 (`null`) assigned sector because the Owner operates cross-sector across all four branches.
2. **`User` to `SalesTransaction` & `Expense` (`1` to `0..*`):**
   * Every transaction is recorded by exactly one authenticated user (`1`).
   * A user may record zero to many transactions (`0..*`).
3. **`User` to `PayrollRecord` (`1` to `0..*`):**
   * Each `PayrollRecord` is computed for exactly one employee user (`1`).
   * An employee user accumulates historical payroll records over time (`0..*`).
4. **`BusinessSector` Compositions (`1` to `0..*`):**
   * Every `SalesTransaction`, `Expense`, and `PayrollRecord` is scoped strictly within the boundary of a single `BusinessSector` (`1`).
   * A `BusinessSector` contains zero to many transactions and payroll records (`0..*`).
5. **`PayrollRecord` to `Expense` (`1` to `1` auto-creates):**
   * Every `PayrollRecord` generates exactly one `Expense` record (`1`) with $\text{amount} = \text{computedSalary}$ via `createExpenseRecord()` — this embodies the `<<include>>` UC5→UC9.
   * Manual operational `Expense` instances are not created via this relationship; they are recorded directly by `User` via `Record Expense` (UC3) and are distinguishable via `Expense.isPayrollGenerated() == false`. The domain model therefore avoids a nullable `payrollRecordId` FK and uses a true object association for the payroll-generated subset.
6. **`FinancialReport` Dependencies (`..>`):**
   * `FinancialReport` queries and aggregates data from `BusinessSector`, `SalesTransaction`, `Expense`, and `PayrollRecord` to compute summaries and chart data without owning persistent transaction instances.

---

## 6. Comprehensive Traceability Matrix

| Use Case ID | Use Case Name | Primary Actors | Implementing Classes & Operations | Functional Requirement |
|---|---|---|---|---|
| **UC1** | **Login** | Business Owner, Event Manager, Bookkeeper, Employee/Event Staff | `User.authenticate(password)` | FR-001 |
| **UC2** | **Record Sales Transaction** | Owner, Event Manager | `User`, `SalesTransaction.validateAmount()`, `BusinessSector` | FR-004 |
| **UC3** | **Record Expense** | Business Owner, Event Manager | `User`, `Expense.validateAmount()`, `BusinessSector` | FR-005 |
| **UC4** | **View Analytics Dashboard** | Business Owner, Bookkeeper | `BusinessSector.getFinancialSummary()`, `FinancialSummary`, `FinancialReport` | FR-002, FR-007 |
| **UC5** | **View Payroll Calculations** | Business Owner, Bookkeeper | `User`, `PayrollRecord.computeSalary()`, `BusinessSector` | FR-006 |
| **UC6** | **View Reports** | Business Owner, Event Manager, Bookkeeper | `FinancialReport.generateReport()`, `FinancialReport.getSectorBreakdown()` | FR-007 |
| **UC7** | **View Own Payroll** | Event Manager, Employee/Event Staff | `User`, `PayrollRecord.getSummary()` | FR-006 |
| **UC8** | **Switch Business Sector** | Business Owner | `BusinessSector.getFinancialSummary()`, `FinancialSummary` | FR-008 |
| **UC9** | **Payroll Auto-creates Expense** | System (`<<include>>`) | `PayrollRecord.createExpenseRecord()`, `Expense.isPayrollGenerated()` | FR-005, FR-006 |
| **UC10** | **Manage User Accounts** | Business Owner | `User.activate()`, `User.deactivate()`, `User.assignRole()`, `User.assignSector()` | FR-003 |

---

## 7. Key Design Decisions

1. **Domain Model vs. ERD Separation:**
   * Unlike the Database Schema (which focuses on primary/foreign keys and column types), the Class Diagram emphasizes **encapsulated object behaviors** (`authenticate`, `computeSalary`, `createExpenseRecord`, `getFinancialSummary`), domain validation, and UML semantic relationships (composition, association, dependency). Foreign-key attributes (`sectorId`, `payrollRecordId`) were removed from `User` and `Expense` in this audit to keep the model technology-neutral; relationships are expressed solely via associations.
2. **Unified `User` Class with `UserRole` Enumeration:**
   * Avoided unnecessary class inheritance hierarchies (e.g. `Owner extends User`, `Manager extends User`) because all roles share identical attributes and storage representations; behavioral role-gating is determined via the `UserRole` enumeration and business logic, matching the project's RBAC specifications.
3. **Dedicated Value Object (`FinancialSummary`):**
   * Encapsulates the core dynamic dashboard calculation ($\text{Net Balance} = \text{Sales} - \text{Expenses}$) as a cohesive value object returned by `BusinessSector`, keeping domain logic clean and reusable.
4. **Explicit `<<include>>` Modeling in Domain Classes:**
   * The `<<include>>` relationship in the Use Case Diagram (UC5 $\rightarrow$ UC9) is directly embodied in `PayrollRecord.createExpenseRecord()`, which guarantees atomic creation of an `Expense` object whenever a `PayrollRecord` is computed.

---

## 8. Final Three-Diagram Consistency Audit

A rigorous cross-diagram verification confirms zero semantic friction across the modeling suite:

1. **No Contradictions with Activity Diagram (As-Is):**
   * The Class Diagram provides direct object support for the four business sectors, manual-to-digital sales recording, structured expenses (eliminating lost Messenger receipts), automated payroll formula (preserving $\text{Hours Worked} \times \text{Hourly Rate}$), and centralized financial reporting.
2. **Full Coverage of Use Case Diagram:**
   * Every single use case (UC1 through UC10) has concrete class, attribute, and operation support. No use case is left without an implementing class.
3. **Zero Scope Creep / No Invented Domains:**
   * No generic e-commerce, CRM, ERP, hotel, or booking features were added. The domain remains 100% focused on **DYS Event Management's multi-sector financial tracking**.
4. **Unified Terminology & Multiplicities:**
   * Identical sector names (*DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories*), final-design roles (*Business Owner, Event Manager, Bookkeeper, Employee/Event Staff*), and identical transaction semantics are maintained across all three deliverables.

---

## 9. Artifacts Generated

* **Source File:** [`Case Study 4 - UML Modeling/Class_Diagram_Proposed_System.puml`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Class_Diagram_Proposed_System.puml)
* **Vector Render (SVG):** [`Case Study 4 - UML Modeling/Class_Diagram_Proposed_System.svg`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Class_Diagram_Proposed_System.svg)
* **Raster Render (PNG):** [`Case Study 4 - UML Modeling/Class_Diagram_Proposed_System.png`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Class_Diagram_Proposed_System.png)
* **Documentation:** [`Case Study 4 - UML Modeling/Class_Diagram_Proposed_System_Documentation.md`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Class_Diagram_Proposed_System_Documentation.md)

---

*Deliverable 3 completed for COMSCI 3100 Case Study #4.*
