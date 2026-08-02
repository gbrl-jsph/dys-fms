# Database Schema — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- er-diagram.md
- system-architecture.md

## Tables

### Users
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| name | VARCHAR | User's full name |
| email | VARCHAR | Login email |
| password | VARCHAR | Hashed password |
| role | ENUM | Business Owner, Event Manager, Employee/Staff |
| sector_id | INTEGER | FK to Business Sectors (nullable — Owner has no fixed sector) |
| account_status | ENUM | Active, Inactive (managed exclusively by the Business Owner; used instead of deleting user records) |
| created_at | TIMESTAMP | Record creation time |

### Business Sectors
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| name | VARCHAR | Sector name |
| description | TEXT | Sector description |
| created_at | TIMESTAMP | Record creation time |

### Sales Transactions
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| user_id | INTEGER | FK to Users |
| sector_id | INTEGER | FK to Business Sectors |
| amount | DECIMAL | Transaction amount |
| description | TEXT | Transaction description |
| recorded_at | TIMESTAMP | Transaction timestamp |

### Expenses
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| user_id | INTEGER | FK to Users |
| sector_id | INTEGER | FK to Business Sectors |
| amount | DECIMAL | Expense amount |
| description | TEXT | Expense description |
| recorded_at | TIMESTAMP | Expense timestamp |
| payroll_record_id | INTEGER | FK to Payroll Records (nullable; set when auto-created by payroll) |

### Payroll Records
| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| user_id | INTEGER | FK to Users |
| sector_id | INTEGER | FK to Business Sectors |
| hours_worked | DECIMAL(10,2) | Hours worked in pay period |
| hourly_rate | DECIMAL(10,2) | Hourly rate for the user |
| computed_salary | DECIMAL(10,2) | Calculated salary (hours_worked × hourly_rate) |
| pay_period | DATE | Pay period end date |
| calculated_at | TIMESTAMP | When payroll was calculated |

## Notes
- `computed_salary` is derived as `hours_worked * hourly_rate`
- When a Payroll Record is created, the system automatically inserts an Expense record with amount = computed_salary, description indicating payroll, and payroll_record_id referencing the source Payroll Record
- The `payroll_record_id` column on Expenses links the auto-created expense back to the originating payroll calculation
- Only the Business Owner can create Event Manager or Employee accounts, and only the Business Owner can change `account_status`. There is no public registration, self-registration, or admin role.
