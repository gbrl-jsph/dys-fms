# Data Dictionary — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Last Updated:** 2026-07-28
**Project:** DYS Financial Management System (DYS FMS)

## Purpose

This document defines every approved database table, column, relationship, and business rule for the DYS Financial Management System. It serves as the authoritative reference for database design and implementation.

## Database Overview

| Attribute | Value |
|-----------|-------|
| RDBMS | MySQL |
| Tables | 5 |
| Schema Name | dys_fms |
| Entity Count | 5 (User, Business Sector, Sales Transaction, Expense, Payroll Record) |

---

## Users

**Purpose:** Stores system actor accounts. Every person who interacts with the system has a User record. Accounts are provisioned exclusively by the Business Owner.

**Primary Key:** `id`

**Foreign Keys:** `sector_id` → Business Sectors

**Relationships:**
- Many-to-One with Business Sectors (via `sector_id`) — each Event Manager or Employee is assigned to one permanent sector; Business Owner has no fixed sector (`sector_id` is null)
- One-to-Many with Sales Transactions (user_id in Sales Transactions)
- One-to-Many with Expenses (user_id in Expenses)
- One-to-Many with Payroll Records (user_id in Payroll Records)

**Business Rules:**
- Only the Business Owner can create user accounts
- Only the Business Owner can change `account_status`
- There is no public registration or self-registration
- `account_status = Inactive` prevents login (used instead of deleting records)
- The Business Owner has cross-sector access; `sector_id` is null for Owner
- Event Managers and Employees are permanently assigned to one sector (`sector_id` is required and immutable except by Business Owner)
- Passwords are stored hashed (not plaintext)
- Email must be unique per user

| Field | Type | Null | Default | Key | Description | Validation | Example |
|-------|------|------|---------|-----|-------------|------------|---------|
| id | INTEGER | NO | — | PK | Unique user identifier | Auto-increment | 1 |
| name | VARCHAR | NO | — | — | User's full name | 1–255 characters | Juan Dela Cruz |
| email | VARCHAR | NO | — | UNIQUE | Login email address | Valid email format | juan@dys.com |
| password | VARCHAR | NO | — | — | Hashed password | BCrypt hash (60 chars) | $2y$12$... |
| role | ENUM | NO | — | — | System role determining permissions | One of: Business Owner, Event Manager, Employee/Staff | Event Manager |
| sector_id | INTEGER | YES | NULL | FK | Assigned business sector | FK to Business Sectors.id; null for Owner | 2 |
| account_status | ENUM | NO | Active | — | Determines login eligibility | One of: Active, Inactive | Active |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | — | Record creation timestamp | Valid timestamp | 2026-07-28 10:00:00 |

---

## Business Sectors

**Purpose:** Stores the four business sectors under DYS Event Management. Each sector represents a distinct operational and financial scope.

**Primary Key:** `id`

**Foreign Keys:** None (parent table referenced by other tables)

**Relationships:**
- One-to-Many with Users (via `sector_id` in Users)
- One-to-Many with Sales Transactions (via `sector_id` in Sales Transactions)
- One-to-Many with Expenses (via `sector_id` in Expenses)
- One-to-Many with Payroll Records (via `sector_id` in Payroll Records)

**Business Rules:**
- The four approved sectors are: DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories
- Each sector has its own financial data scope — records are isolated per sector
- The Business Owner can switch between sectors; all other roles are permanently assigned to one sector
- Sector names are unique

| Field | Type | Null | Default | Key | Description | Validation | Example |
|-------|------|------|---------|-----|-------------|------------|---------|
| id | INTEGER | NO | — | PK | Unique sector identifier | Auto-increment | 1 |
| name | VARCHAR | NO | — | UNIQUE | Sector name | 1–255 characters | DYS Events |
| description | TEXT | YES | NULL | — | Sector description | Free text | Event coordination and styling main branch |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | — | Record creation timestamp | Valid timestamp | 2026-07-28 10:00:00 |

---

## Sales Transactions

**Purpose:** Records individual sales transactions. Each sale is linked to the user who recorded it and the business sector under which the sale occurred.

**Primary Key:** `id`

**Foreign Keys:** `user_id` → Users, `sector_id` → Business Sectors

**Relationships:**
- Many-to-One with Users (each sale is recorded by one user)
- Many-to-One with Business Sectors (each sale belongs to one sector)

**Business Rules:**
- Only Business Owners and Event Managers can record sales
- Employees/Event Staff cannot record sales
- Amount must be a positive decimal value
- Each sale is automatically scoped to the user's current sector (for Event Managers) or selected sector (for Business Owner)
- Sales records are immutable after creation (no update or delete — corrections require a new entry)

| Field | Type | Null | Default | Key | Description | Validation | Example |
|-------|------|------|---------|-----|-------------|------------|---------|
| id | INTEGER | NO | — | PK | Unique transaction identifier | Auto-increment | 101 |
| user_id | INTEGER | NO | — | FK | User who recorded the sale | FK to Users.id | 1 |
| sector_id | INTEGER | NO | — | FK | Business sector for the sale | FK to Business Sectors.id | 1 |
| amount | DECIMAL | NO | — | — | Transaction amount | Positive decimal | 15000.00 |
| description | TEXT | YES | NULL | — | Transaction description | Free text | Full event coordination package |
| recorded_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | — | When the transaction was recorded | Valid timestamp | 2026-07-28 14:30:00 |

---

## Expenses

**Purpose:** Records business expenses. Expenses can be recorded manually by authorized users or automatically created by the payroll system when a Payroll Record is generated.

**Primary Key:** `id`

**Foreign Keys:** `user_id` → Users, `sector_id` → Business Sectors, `payroll_record_id` → Payroll Records

**Relationships:**
- Many-to-One with Users (each expense is recorded by one user, or system-generated)
- Many-to-One with Business Sectors (each expense belongs to one sector)
- One-to-One with Payroll Records (via `payroll_record_id` — only when auto-created by payroll)

**Business Rules:**
- Only Business Owners and Event Managers can record expenses manually
- Employees/Event Staff cannot record expenses
- When payroll is calculated, the system automatically inserts an Expense record with:
  - `amount` = `computed_salary` from the Payroll Record
  - `description` indicating payroll origin
  - `payroll_record_id` referencing the source Payroll Record
- Manually recorded expenses have `payroll_record_id = NULL`
- Amount must be a positive decimal value
- Payroll-generated expenses are system-created and cannot be manually deleted

| Field | Type | Null | Default | Key | Description | Validation | Example |
|-------|------|------|---------|-----|-------------|------------|---------|
| id | INTEGER | NO | — | PK | Unique expense identifier | Auto-increment | 201 |
| user_id | INTEGER | NO | — | FK | User who recorded the expense (or system user for auto-created) | FK to Users.id | 2 |
| sector_id | INTEGER | NO | — | FK | Business sector for the expense | FK to Business Sectors.id | 2 |
| amount | DECIMAL | NO | — | — | Expense amount | Positive decimal | 5000.00 |
| description | TEXT | YES | NULL | — | Expense description | Free text | Catering supplies |
| recorded_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | — | When the expense was recorded | Valid timestamp | 2026-07-28 15:00:00 |
| payroll_record_id | INTEGER | YES | NULL | FK | Links to originating Payroll Record when auto-created | FK to Payroll Records.id; null for manual expenses | 50 |

---

## Payroll Records

**Purpose:** Stores computed salary calculations for employees. Each record represents a single payroll calculation for one employee in a specific pay period.

**Primary Key:** `id`

**Foreign Keys:** `user_id` → Users, `sector_id` → Business Sectors

**Relationships:**
- Many-to-One with Users (each payroll record belongs to one employee)
- Many-to-One with Business Sectors (each payroll record is scoped to one sector)
- One-to-One with Expenses (each payroll record auto-creates one Expense record via `payroll_record_id`)

**Business Rules:**
- Only the Business Owner can calculate payroll
- Event Managers and Employees cannot calculate payroll
- `computed_salary` is derived as `hours_worked × hourly_rate`
- Payroll records are stored permanently and viewable historically
- Each Payroll Record automatically creates an associated Expense record with `amount = computed_salary`
- Hourly rate is recorded at time of calculation (not fetched dynamically from a master rate)
- Hours worked must be a positive decimal value
- Hourly rate must be a positive decimal value

| Field | Type | Null | Default | Key | Description | Validation | Example |
|-------|------|------|---------|-----|-------------|------------|---------|
| id | INTEGER | NO | — | PK | Unique payroll record identifier | Auto-increment | 50 |
| user_id | INTEGER | NO | — | FK | Employee who received the payroll | FK to Users.id | 3 |
| sector_id | INTEGER | NO | — | FK | Business sector for the payroll | FK to Business Sectors.id | 1 |
| hours_worked | DECIMAL(10,2) | NO | — | — | Hours worked in the pay period | Positive decimal, max 99999999.99 | 160.00 |
| hourly_rate | DECIMAL(10,2) | NO | — | — | Hourly rate for the employee | Positive decimal, max 99999999.99 | 125.00 |
| computed_salary | DECIMAL(10,2) | NO | — | — | Calculated salary (hours_worked × hourly_rate) | Derived value, positive decimal | 20000.00 |
| pay_period | DATE | NO | — | — | Pay period end date | Valid date | 2026-07-15 |
| calculated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | — | When the payroll was calculated | Valid timestamp | 2026-07-28 16:00:00 |

---

## Entity Relationship Summary

| Relationship | Type | Source | Target | Description |
|-------------|------|--------|--------|-------------|
| User → Business Sector | Many-to-One | Users.sector_id | Business Sectors.id | Event Managers and Employees assigned to one sector; Owner has no sector |
| User → Sales Transaction | One-to-Many | Users.id | Sales Transactions.user_id | A user can record many sales transactions |
| User → Expense | One-to-Many | Users.id | Expenses.user_id | A user can record many expenses |
| User → Payroll Record | One-to-Many | Users.id | Payroll Records.user_id | An employee can have many payroll records |
| Business Sector → Sales Transaction | One-to-Many | Business Sectors.id | Sales Transactions.sector_id | A sector contains many sales transactions |
| Business Sector → Expense | One-to-Many | Business Sectors.id | Expenses.sector_id | A sector contains many expenses |
| Business Sector → Payroll Record | One-to-Many | Business Sectors.id | Payroll Records.sector_id | A sector contains many payroll records |
| Payroll Record → Expense | One-to-One | Payroll Records.id | Expenses.payroll_record_id | Each payroll record generates exactly one Expense record |

---

## Cross-Reference Matrix

| Table | Concept Paper | ER Diagram | Database Schema | Project Memory |
|-------|:-------------:|:----------:|:---------------:|:--------------:|
| Users | ✓ | ✓ | ✓ | ✓ |
| Business Sectors | ✓ | ✓ | ✓ | ✓ |
| Sales Transactions | ✓ | ✓ | ✓ | ✓ |
| Expenses | ✓ | ✓ | ✓ | ✓ |
| Payroll Records | — | ✓ | ✓ | ✓ |

---

## Consistency Check

| Source | Status |
|--------|--------|
| Concept Paper | ✓ |
| ER Diagram | ✓ |
| Database Schema | ✓ |
| User Account Management | ✓ |
| Payroll Clarification | ✓ |
| Project Memory | ✓ |
| System Components | ✓ |

**Issues Found:** None

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | Data Dictionary |
| Version | 1.0 |
| Status | Ready for Approval |
