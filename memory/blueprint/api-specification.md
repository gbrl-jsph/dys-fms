# API Specification — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Draft (Pending Audit)
**Project:** DYS Financial Management System (DYS FMS)

---

## API Overview

### Architecture

The DYS FMS uses a RESTful JSON API architecture:

- **Protocol**: HTTPS
- **Format**: JSON request/response bodies
- **Base URL**: `https://api.dys-fms.example.com/api`
- **Framework**: Laravel 12
- **Authentication**: Laravel Sanctum (token-based)

### Authentication Flow

1. Client sends `POST /api/login` with `email` and `password`
2. Server validates credentials, checks `account_status = Active`, determines role and default sector
3. Server issues a Sanctum token with role and sector metadata
4. Client includes the token in subsequent requests via the `Authorization: Bearer <token>` header
5. Client sends `POST /api/logout` to revoke the token

### Sector Context

Financial data is scoped by business sector. The sector context is maintained by the client and sent with scoped requests:

- **Query parameter**: `?sector_id={id}` for GET requests
- **Request body field**: `sector_id` for POST requests (for records that require sector scoping)
- **Header**: `X-Sector-ID` may be used as an alternative — the server supports both mechanisms

The server validates that:
- Event Managers and Employees can only access data for their assigned sector
- Business Owner can access data for any sector

### Request/Response Format

All responses follow a consistent envelope:

**Success:**
```json
{
    "data": { ... },
    "message": "Operation successful."
}
```

**Error:**
```json
{
    "message": "Error description.",
    "errors": { "field": ["validation message"] }
}
```

---

## Authentication API

### POST /login

Authenticate a user and issue a Sanctum token.

**Purpose:** Authenticate user credentials, verify account is active, determine role and default sector, return a session token.

**HTTP Method:** POST
**Route:** `/api/login`
**Authentication:** None (public)

**Allowed Roles:** All (Business Owner, Event Manager, Employee/Staff)

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User's email address |
| password | string | Yes | User's password |

**Example Request:**
```json
{
    "email": "owner@dys.com",
    "password": "securePassword123"
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| email | Required; valid email format; must exist in Users table |
| password | Required; must match the hashed password for the given email |
| account_status | Must be Active |

#### Success Response

**Status:** 200 OK

```json
{
    "data": {
        "user": {
            "id": 1,
            "name": "Juan Dela Cruz",
            "email": "owner@dys.com",
            "role": "Business Owner",
            "sector_id": null,
            "account_status": "Active"
        },
        "token": "1|abc123sanctumtoken...",
        "default_sector": {
            "id": 1,
            "name": "DYS Events"
        }
    },
    "message": "Login successful."
}
```

**Business Owner:** `default_sector` is always DYS Event Management (id 1).
**Event Manager / Employee:** `default_sector` is their assigned business sector.

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | Invalid credentials | `{"message": "Invalid username or password."}` |
| 401 | Inactive account | `{"message": "Invalid username or password."}` (same message — no status disclosure) |

#### Business Rules

- There is no self-registration or public account creation
- There is no Forgot Password or password reset workflow
- There is no Register or Sign Up endpoint
- There is no email verification
- Account status is managed exclusively by the Business Owner
- Failed login attempts do not lock the account (no lockout mechanism)
- Inactive accounts receive the same error message as invalid credentials (no status disclosure)
- `default_sector` returned in response so the client can set the initial sector context

#### Related Tables

- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-001: Authentication

---

### POST /logout

Revoke the current Sanctum token.

**Purpose:** End the authenticated session by revoking the bearer token.

**HTTP Method:** POST
**Route:** `/api/logout`
**Authentication:** Required (Bearer token)

**Allowed Roles:** All

#### Request Body

None.

**Example Request:**
```
POST /api/logout
Authorization: Bearer 1|abc123sanctumtoken...
```

#### Validation Rules

N/A — Token validity is checked by Sanctum middleware.

#### Success Response

**Status:** 200 OK

```json
{
    "message": "Logged out successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |

#### Business Rules

- The current bearer token is revoked immediately
- Other active tokens for the same user (if any) remain valid
- Client should discard the token after logout

#### Related Tables

- Personal Access Tokens (Sanctum)

#### Referenced Functional Requirement

- FR-001: Authentication

---

## User Account Management API

All endpoints in this section require **Business Owner** role.

### GET /users

Retrieve a list of all user accounts.

**Purpose:** List all users with their role, sector assignment, and account status for management display.

**HTTP Method:** GET
**Route:** `/api/users`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Parameters

None.

#### Validation Rules

N/A — No input parameters.

#### Success Response

**Status:** 200 OK

```json
{
    "data": [
        {
            "id": 1,
            "name": "Juan Dela Cruz",
            "email": "owner@dys.com",
            "role": "Business Owner",
            "sector_id": null,
            "sector_name": null,
            "account_status": "Active",
            "created_at": "2026-07-28T10:00:00.000000Z"
        },
        {
            "id": 2,
            "name": "Maria Santos",
            "email": "maria@dys.com",
            "role": "Event Manager",
            "sector_id": 2,
            "sector_name": "B&DYS",
            "account_status": "Active",
            "created_at": "2026-07-28T11:00:00.000000Z"
        }
    ],
    "message": "Users retrieved successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |

#### Business Rules

- Only the Business Owner can list all users
- Event Managers and Employees cannot access this endpoint
- The list includes all users regardless of account_status
- The Business Owner account itself appears in the list
- Response includes sector_name (denormalized) for display convenience

#### Related Tables

- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-003: User Account Management

---

### POST /users

Create a new user account.

**Purpose:** Create a new Event Manager or Employee/Staff account with assigned role, sector, and auto-generated temporary password.

**HTTP Method:** POST
**Route:** `/api/users`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | User's full name (1–255 characters) |
| email | string | Yes | Login email (must be unique, valid format) |
| role | string | Yes | Must be "Event Manager" or "Employee/Staff" |
| sector_id | integer | Yes | FK to Business Sectors.id |

**Note:** `sector_id` is required for Event Manager and Employee/Staff. The Business Owner role cannot be created through this endpoint (seeded directly).

**Example Request:**
```json
{
    "name": "Pedro Reyes",
    "email": "pedro@dys.com",
    "role": "Event Manager",
    "sector_id": 2
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| name | Required; string; 1–255 characters |
| email | Required; valid email format; unique in Users table |
| role | Required; must be "Event Manager" or "Employee/Staff" ("Business Owner" is rejected) |
| sector_id | Required; must reference an existing Business Sectors.id |

#### Success Response

**Status:** 201 Created

```json
{
    "data": {
        "id": 4,
        "name": "Pedro Reyes",
        "email": "pedro@dys.com",
        "role": "Event Manager",
        "sector_id": 2,
        "account_status": "Active",
        "temporary_password": "Temp@12345",
        "created_at": "2026-07-28T12:00:00.000000Z"
    },
    "message": "User account created successfully."
}
```

**Important:** The `temporary_password` is returned only in this response. It cannot be retrieved later.

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 422 | Validation failure | `{"message": "Validation failed.", "errors": {"email": ["The email has already been taken."]}}` |

#### Business Rules

- Only the Business Owner can create user accounts
- Business Owner role cannot be created through this endpoint (seeded directly in database)
- Role must be "Event Manager" or "Employee/Staff"
- System generates a temporary password (minimum complexity: 8+ characters, mixed case, numbers, special character)
- Temporary password is returned only once in the creation response
- New account automatically has `account_status = Active`
- Email must be unique across all users
- There is no public registration, self-registration, or invitation-link account creation

#### Related Tables

- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-003: User Account Management

---

### GET /users/{id}

Retrieve a single user account.

**Purpose:** Get detailed information about a specific user.

**HTTP Method:** GET
**Route:** `/api/users/{id}`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | User ID (path parameter) |

#### Validation Rules

- `id` must reference an existing Users record

#### Success Response

**Status:** 200 OK

```json
{
    "data": {
        "id": 2,
        "name": "Maria Santos",
        "email": "maria@dys.com",
        "role": "Event Manager",
        "sector_id": 2,
        "sector_name": "B&DYS",
        "account_status": "Active",
        "created_at": "2026-07-28T11:00:00.000000Z"
    },
    "message": "User retrieved successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 404 | User not found | `{"message": "User not found."}` |

#### Business Rules

- Only the Business Owner can view any user's details
- Users cannot view other users' account details

#### Related Tables

- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-003: User Account Management

---

### PUT /users/{id}

Update an existing user account.

**Purpose:** Modify user details (name, email, role, sector assignment).

**HTTP Method:** PUT
**Route:** `/api/users/{id}`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | string | Yes | User's full name |
| email | string | Yes | Login email (must be unique, valid format) |
| role | string | Yes | Must be "Event Manager" or "Employee/Staff" |
| sector_id | integer | Yes | FK to Business Sectors.id (required for Event Manager and Employee/Staff) |

**Note:** The Business Owner account cannot be modified through this endpoint.

**Example Request:**
```json
{
    "name": "Pedro Reyes Jr.",
    "email": "pedro.jr@dys.com",
    "role": "Employee/Staff",
    "sector_id": 3
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| name | Required; string; 1–255 characters |
| email | Required; valid email format; unique except for current user's own email |
| role | Required; must be "Event Manager" or "Employee/Staff" |
| sector_id | Required; must reference an existing Business Sectors.id |

#### Success Response

**Status:** 200 OK

```json
{
    "data": {
        "id": 4,
        "name": "Pedro Reyes Jr.",
        "email": "pedro.jr@dys.com",
        "role": "Employee/Staff",
        "sector_id": 3,
        "account_status": "Active",
        "created_at": "2026-07-28T12:00:00.000000Z",
        "updated_at": "2026-07-28T13:00:00.000000Z"
    },
    "message": "User updated successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 404 | User not found | `{"message": "User not found."}` |
| 422 | Validation failure | `{"message": "Validation failed.", "errors": { ... }}` |

#### Business Rules

- Only the Business Owner can update user accounts
- The Business Owner account itself cannot be modified
- Role can be changed between Event Manager and Employee/Staff
- Sector assignment can be changed by the Business Owner at any time
- Email uniqueness is enforced (excluding the current user's own email)
- Password is NOT changed through this endpoint (no password field)

#### Related Tables

- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-003: User Account Management

---

### PATCH /users/{id}/status

Activate or deactivate a user account.

**Purpose:** Set a user's `account_status` to "Active" or "Inactive". Inactive accounts cannot log in.

**HTTP Method:** PATCH
**Route:** `/api/users/{id}/status`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| account_status | string | Yes | Must be "Active" or "Inactive" |

**Example Request:**
```json
{
    "account_status": "Inactive"
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| account_status | Required; must be "Active" or "Inactive" |

#### Success Response

**Status:** 200 OK

```json
{
    "data": {
        "id": 2,
        "name": "Maria Santos",
        "email": "maria@dys.com",
        "role": "Event Manager",
        "sector_id": 2,
        "account_status": "Inactive",
        "updated_at": "2026-07-28T14:00:00.000000Z"
    },
    "message": "User status updated successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 404 | User not found | `{"message": "User not found."}` |
| 422 | Invalid status value | `{"message": "Validation failed.", "errors": {"account_status": ["The selected account_status is invalid."]}}` |

#### Business Rules

- Only the Business Owner can activate or deactivate accounts
- The Business Owner's own account cannot be deactivated
- Inactive accounts receive "Invalid username or password." on login (no status disclosure)
- Accounts are deactivated, not deleted (record remains in database)
- Reactivation sets account_status back to "Active"

#### Related Tables

- Users

#### Referenced Functional Requirement

- FR-003: User Account Management

---

## Sales API

### GET /sales

Retrieve sales transactions.

**Purpose:** List sales transactions scoped by sector and filtered by role.

**HTTP Method:** GET
**Route:** `/api/sales`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner, Event Manager

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sector_id | integer | No | Filter by sector (query parameter). Required for Owner; EM uses own sector |
| per_page | integer | No | Pagination: items per page (default 15, max 100) |
| page | integer | No | Pagination: page number |

#### Validation Rules

| Field | Rule |
|-------|------|
| sector_id | Required for Business Owner (must reference existing Business Sector). Ignored/overridden for Event Manager (uses assigned sector) |

#### Success Response

**Status:** 200 OK

```json
{
    "data": [
        {
            "id": 101,
            "amount": 15000.00,
            "description": "Full event coordination package",
            "recorded_by": {
                "id": 1,
                "name": "Juan Dela Cruz"
            },
            "sector": {
                "id": 1,
                "name": "DYS Events"
            },
            "recorded_at": "2026-07-28T14:30:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 15,
        "total": 42,
        "last_page": 3
    },
    "message": "Sales transactions retrieved successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Employee role (cannot view sales) | `{"message": "Forbidden."}` |
| 403 | Event Manager requests different sector | `{"message": "Forbidden. You can only access your assigned sector."}` |

#### Business Rules

- Business Owner: can view sales for any sector (sector_id parameter required)
- Event Manager: can view sales for assigned sector only (sector_id parameter ignored/overridden)
- Employee: cannot access this endpoint (403 Forbidden)
- Results are ordered by `recorded_at` descending (most recent first)

#### Related Tables

- Sales Transactions
- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-004: Record Sales

---

### POST /sales

Record a new sales transaction.

**Purpose:** Create a new sales transaction record scoped to the current sector.

**HTTP Method:** POST
**Route:** `/api/sales`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner, Event Manager

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| amount | decimal | Yes | Transaction amount (positive decimal) |
| description | string | No | Transaction description (free text) |
| sector_id | integer | No | Sector ID. Required for Owner; EM uses assigned sector |

**Example Request:**
```json
{
    "amount": 25000.00,
    "description": "Birthday party package",
    "sector_id": 1
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| amount | Required; numeric; must be positive (> 0) |
| description | Optional; string; nullable |
| sector_id | Required for Business Owner (must reference existing Business Sector). Ignored/overridden for Event Manager |

#### Success Response

**Status:** 201 Created

```json
{
    "data": {
        "id": 143,
        "amount": 25000.00,
        "description": "Birthday party package",
        "recorded_by": {
            "id": 1,
            "name": "Juan Dela Cruz"
        },
        "sector": {
            "id": 1,
            "name": "DYS Events"
        },
        "recorded_at": "2026-07-28T15:00:00.000000Z"
    },
    "message": "Sale recorded successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Employee role (cannot record sales) | `{"message": "Forbidden."}` |
| 403 | Event Manager provides wrong sector | `{"message": "Forbidden. You can only record sales for your assigned sector."}` |
| 422 | Validation failure | `{"message": "Validation failed.", "errors": {"amount": ["The amount must be a positive number."]}}` |

#### Business Rules

- Only Business Owners and Event Managers can record sales
- Employees cannot record sales
- Sales records are immutable after creation (no PUT/PATCH/DELETE endpoints — corrections require a new entry)
- `user_id` is set to the authenticated user automatically (not client-supplied)
- `recorded_at` is set by the server (not client-supplied)
- Description is optional (nullable)

#### Related Tables

- Sales Transactions
- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-004: Record Sales

---

## Expenses API

### GET /expenses

Retrieve expense records.

**Purpose:** List expense transactions scoped by sector and filtered by role. Includes both manually recorded and system-generated (payroll) expenses.

**HTTP Method:** GET
**Route:** `/api/expenses`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner, Event Manager

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sector_id | integer | No | Filter by sector (query parameter). Required for Owner; EM uses own sector |
| per_page | integer | No | Pagination: items per page (default 15, max 100) |
| page | integer | No | Pagination: page number |

#### Validation Rules

| Field | Rule |
|-------|------|
| sector_id | Required for Business Owner (must reference existing Business Sector). Ignored/overridden for Event Manager (uses assigned sector) |

#### Success Response

**Status:** 200 OK

```json
{
    "data": [
        {
            "id": 201,
            "amount": 5000.00,
            "description": "Catering supplies",
            "recorded_by": {
                "id": 1,
                "name": "Juan Dela Cruz"
            },
            "sector": {
                "id": 1,
                "name": "DYS Events"
            },
            "payroll_record_id": null,
            "recorded_at": "2026-07-28T15:30:00.000000Z"
        },
        {
            "id": 202,
            "amount": 20000.00,
            "description": "Payroll — Maria Santos — 2026-07-15",
            "recorded_by": {
                "id": 1,
                "name": "Juan Dela Cruz"
            },
            "sector": {
                "id": 1,
                "name": "DYS Events"
            },
            "payroll_record_id": 50,
            "recorded_at": "2026-07-28T16:00:00.000000Z"
        }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 15,
        "total": 28,
        "last_page": 2
    },
    "message": "Expenses retrieved successfully."
}
```

The `payroll_record_id` field distinguishes:
- `null` → manually recorded expense
- integer value → system-generated expense linked to a specific Payroll Record

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Employee role (cannot view expenses) | `{"message": "Forbidden."}` |
| 403 | Event Manager requests different sector | `{"message": "Forbidden. You can only access your assigned sector."}` |

#### Business Rules

- Business Owner: can view expenses for any sector (sector_id parameter required)
- Event Manager: can view expenses for assigned sector only
- Employee: cannot access this endpoint (403 Forbidden)
- Both manual and system-generated expenses are returned in the same list
- Results are ordered by `recorded_at` descending (most recent first)

#### Related Tables

- Expenses
- Users
- Business Sectors
- Payroll Records (via payroll_record_id)

#### Referenced Functional Requirement

- FR-005: Record Expenses

---

### POST /expenses

Record a new expense manually.

**Purpose:** Create a new manual expense record. System-generated expenses are created automatically by the payroll endpoint (see POST /payroll).

**HTTP Method:** POST
**Route:** `/api/expenses`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner, Event Manager

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| amount | decimal | Yes | Expense amount (positive decimal) |
| description | string | No | Expense description (free text) |
| sector_id | integer | No | Sector ID. Required for Owner; EM uses assigned sector |

**Example Request:**
```json
{
    "amount": 3500.00,
    "description": "Office supplies",
    "sector_id": 2
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| amount | Required; numeric; must be positive (> 0) |
| description | Optional; string; nullable |
| sector_id | Required for Business Owner (must reference existing Business Sector). Ignored/overridden for Event Manager |

#### Success Response

**Status:** 201 Created

```json
{
    "data": {
        "id": 230,
        "amount": 3500.00,
        "description": "Office supplies",
        "recorded_by": {
            "id": 1,
            "name": "Juan Dela Cruz"
        },
        "sector": {
            "id": 2,
            "name": "B&DYS"
        },
        "payroll_record_id": null,
        "recorded_at": "2026-07-28T17:00:00.000000Z"
    },
    "message": "Expense recorded successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Employee role (cannot record expenses) | `{"message": "Forbidden."}` |
| 403 | Event Manager provides wrong sector | `{"message": "Forbidden. You can only record expenses for your assigned sector."}` |
| 422 | Validation failure | `{"message": "Validation failed.", "errors": {"amount": ["The amount must be a positive number."]}}` |

#### Business Rules

- Only Business Owners and Event Managers can record expenses manually
- Employees cannot record expenses
- `payroll_record_id` is always null for manually recorded expenses (set only by system)
- Expense records are immutable after creation (no PUT/PATCH/DELETE endpoints)
- `user_id` is set to the authenticated user automatically
- `recorded_at` is set by the server

#### Related Tables

- Expenses
- Users
- Business Sectors

#### Referenced Functional Requirement

- FR-005: Record Expenses

---

## Payroll API

### GET /payroll

Retrieve payroll records.

**Purpose:** List payroll records with role-based filtering:
- Business Owner: all payroll records across all sectors
- Event Manager: own payroll records only
- Employee/Staff: own payroll records only

**HTTP Method:** GET
**Route:** `/api/payroll`
**Authentication:** Required (Bearer token)

**Allowed Roles:** All roles (with role-based filtering)

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sector_id | integer | No | Filter by sector (query parameter). Optional for Owner; ignored for EM/Employee |
| user_id | integer | No | Filter by employee. Optional for Owner; ignored for EM/Employee |
| per_page | integer | No | Pagination: items per page (default 15, max 100) |
| page | integer | No | Pagination: page number |

#### Validation Rules

None — filtering parameters are advisory and overridden by role scoping.

#### Success Response

**Status:** 200 OK

**Business Owner response (all employees):**
```json
{
    "data": [
        {
            "id": 50,
            "employee": {
                "id": 3,
                "name": "Ana Gomez"
            },
            "sector": {
                "id": 1,
                "name": "DYS Events"
            },
            "hours_worked": 160.00,
            "hourly_rate": 125.00,
            "computed_salary": 20000.00,
            "pay_period": "2026-07-15",
            "calculated_at": "2026-07-28T16:00:00.000000Z",
            "expense": {
                "id": 202,
                "amount": 20000.00
            }
        }
    ],
    "meta": {
        "current_page": 1,
        "per_page": 15,
        "total": 10,
        "last_page": 1
    },
    "message": "Payroll records retrieved successfully."
}
```

**Event Manager / Employee response (own payroll only):**
```json
{
    "data": [
        {
            "id": 50,
            "employee": {
                "id": 3,
                "name": "Ana Gomez"
            },
            "sector": {
                "id": 1,
                "name": "DYS Events"
            },
            "hours_worked": 160.00,
            "hourly_rate": 125.00,
            "computed_salary": 20000.00,
            "pay_period": "2026-07-15",
            "calculated_at": "2026-07-28T16:00:00.000000Z",
            "expense": {
                "id": 202,
                "amount": 20000.00
            }
        }
    ],
    "message": "Payroll records retrieved successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |

#### Business Rules

- Business Owner: can view all payroll records for all employees across all sectors
- Event Manager: can view only their own payroll records; sector_id parameter is ignored
- Employee: can view only their own payroll records; sector_id parameter is ignored
- Payroll records are stored permanently and viewable historically
- Results are ordered by `calculated_at` descending (most recent first)
- The linked Expense record id is included in the response for traceability

#### Related Tables

- Payroll Records
- Users
- Business Sectors
- Expenses

#### Referenced Functional Requirement

- FR-006: Payroll

---

### POST /payroll

Calculate and save a new payroll record.

**Purpose:** Calculate payroll for an employee (salary = hours_worked × hourly_rate), store the record permanently, and automatically create an associated Expense record.

**HTTP Method:** POST
**Route:** `/api/payroll`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| user_id | integer | Yes | Employee ID (must be Event Manager or Employee/Staff) |
| hours_worked | decimal | Yes | Hours worked in the pay period (positive decimal) |
| hourly_rate | decimal | Yes | Hourly rate for the employee (positive decimal) |
| pay_period | date | Yes | Pay period end date (YYYY-MM-DD) |

**Example Request:**
```json
{
    "user_id": 3,
    "hours_worked": 160.00,
    "hourly_rate": 125.00,
    "pay_period": "2026-07-15"
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| user_id | Required; must reference existing Users record; user's role must be Event Manager or Employee/Staff (not Business Owner) |
| hours_worked | Required; numeric; must be positive (> 0); max 99999999.99 |
| hourly_rate | Required; numeric; must be positive (> 0); max 99999999.99 |
| pay_period | Required; valid date format (YYYY-MM-DD) |

#### Success Response

**Status:** 201 Created

```json
{
    "data": {
        "id": 51,
        "employee": {
            "id": 3,
            "name": "Ana Gomez"
        },
        "sector": {
            "id": 1,
            "name": "DYS Events"
        },
        "hours_worked": 160.00,
        "hourly_rate": 125.00,
        "computed_salary": 20000.00,
        "pay_period": "2026-07-15",
        "calculated_at": "2026-07-28T18:00:00.000000Z",
        "expense": {
            "id": 203,
            "amount": 20000.00,
            "description": "Payroll — Ana Gomez — 2026-07-15"
        }
    },
    "message": "Payroll calculated and saved successfully. Expense record auto-created."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 422 | Validation failure | `{"message": "Validation failed.", "errors": {"hours_worked": ["The hours worked must be a positive number."]}}` |
| 422 | Target user is Business Owner | `{"message": "Validation failed.", "errors": {"user_id": ["Payroll cannot be calculated for the Business Owner."]}}` |

#### Business Rules

- Only the Business Owner can calculate payroll
- Event Managers and Employees cannot calculate payroll (403 Forbidden)
- `computed_salary = hours_worked × hourly_rate` (calculated server-side, not client-supplied)
- The system automatically creates an Expense record in the same database transaction:
  - `amount` = `computed_salary`
  - `description` = `"Payroll — {employee_name} — {pay_period}"`
  - `payroll_record_id` = FK to the new Payroll Record
  - `user_id` = authenticated Business Owner
  - `sector_id` = employee's assigned sector
- Hourly rate is recorded at time of calculation (not fetched from a master rate table)
- Payroll records are stored permanently and viewable historically
- There is no edit or delete functionality for payroll records

#### Related Tables

- Payroll Records
- Users
- Business Sectors
- Expenses (auto-created)

#### Referenced Functional Requirement

- FR-006: Payroll

---

## Reports API

### GET /reports

Retrieve financial reports and analytics data.

**Purpose:** Provide aggregated financial data (sales, expenses, net balance) for reports and analytics dashboards, scoped by role and sector.

**HTTP Method:** GET
**Route:** `/api/reports`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner, Event Manager

**Note:** Employees have no separate Reports screen — they access their own payroll data through the GET /payroll endpoint instead.

#### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| sector_id | integer | No | Filter by sector. Optional for Owner (if omitted, returns cross-sector/aggregate); EM uses assigned sector |
| type | string | No | Report type: "summary", "sales", "expenses", "analytics" (default: "summary") |
| date_from | date | No | Start date filter (YYYY-MM-DD) |
| date_to | date | No | End date filter (YYYY-MM-DD) |

#### Validation Rules

| Field | Rule |
|-------|------|
| sector_id | Must reference existing Business Sector if provided. Overridden for EM (assigned sector only) |
| type | Must be one of: "summary", "sales", "expenses", "analytics" |
| date_from | Must be a valid date if provided |
| date_to | Must be a valid date if provided |

#### Success Response

**Type: "summary" (default):**
```json
{
    "data": {
        "sector": {
            "id": 1,
            "name": "DYS Events"
        },
        "summary": {
            "total_sales": 150000.00,
            "total_expenses": 85000.00,
            "net_balance": 65000.00,
            "payroll_expenses": 40000.00
        },
        "period": {
            "date_from": "2026-01-01",
            "date_to": "2026-07-28"
        }
    },
    "message": "Report generated successfully."
}
```

**Business Owner — cross-sector (no sector_id parameter):**
```json
{
    "data": {
        "cross_sector": true,
        "sectors": [
            {
                "id": 1,
                "name": "DYS Events",
                "total_sales": 150000.00,
                "total_expenses": 85000.00,
                "net_balance": 65000.00
            },
            {
                "id": 2,
                "name": "B&DYS",
                "total_sales": 75000.00,
                "total_expenses": 32000.00,
                "net_balance": 43000.00
            }
        ],
        "grand_total": {
            "total_sales": 225000.00,
            "total_expenses": 117000.00,
            "net_balance": 108000.00
        },
        "period": {
            "date_from": "2026-01-01",
            "date_to": "2026-07-28"
        }
    },
    "message": "Cross-sector report generated successfully."
}
```

**Type: "analytics" (Business Owner only):**
```json
{
    "data": {
        "charts": {
            "sales_trend": [],
            "expense_breakdown": [],
            "sector_comparison": []
        },
        "summary": {
            "total_sales": 225000.00,
            "total_expenses": 117000.00,
            "net_balance": 108000.00
        }
    },
    "message": "Analytics report generated successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Employee role (no reports access) | `{"message": "Forbidden."}` |
| 403 | Event Manager requests analytics type | `{"message": "Forbidden. Analytics dashboard is available for Business Owner only."}` |
| 422 | Invalid report type | `{"message": "Validation failed.", "errors": {"type": ["The selected type is invalid."]}}` |

#### Business Rules

- Business Owner: all sectors, analytics dashboard, cross-sector reports, per-sector reports
- Event Manager: assigned sector reports only (sector_id parameter overridden); cannot access analytics/cross-sector
- Employee: no Reports API access (403 Forbidden); own payroll is accessed via GET /payroll
- Report type "analytics" is Business Owner only
- When no sector_id is provided for Owner, cross-sector aggregated data is returned
- Chart data arrays may be empty when no transactions exist (placeholder state)

#### Related Tables

- Sales Transactions
- Expenses
- Business Sectors

#### Referenced Functional Requirement

- FR-007: Reports

---

## Business Sector API

### GET /business-sectors

Retrieve all business sectors.

**Purpose:** List the four approved business sectors. Used to populate sector selectors on the client side.

**HTTP Method:** GET
**Route:** `/api/business-sectors`
**Authentication:** Required (Bearer token)

**Allowed Roles:** All roles

#### Request Parameters

None.

#### Validation Rules

N/A — No input parameters.

#### Success Response

**Status:** 200 OK

```json
{
    "data": [
        {
            "id": 1,
            "name": "DYS Events",
            "description": "Event coordination and styling main branch"
        },
        {
            "id": 2,
            "name": "B&DYS",
            "description": "Souvenirs"
        },
        {
            "id": 3,
            "name": "Flavors by DYS",
            "description": "Grazing tables and celebration drinks"
        },
        {
            "id": 4,
            "name": "SnapDYS Memories",
            "description": "Video guestbook"
        }
    ],
    "message": "Business sectors retrieved successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |

#### Business Rules

- Available to all authenticated roles
- The four sectors are: DYS Events (1), B&DYS (2), Flavors by DYS (3), SnapDYS Memories (4)
- This is a read-only endpoint (no POST/PUT/DELETE for sectors)
- Event Managers and Employees see all four sectors but can only operate in their assigned sector
- The response does not indicate which sector the user is assigned to (that is available from the login response and /users endpoint)

#### Related Tables

- Business Sectors

#### Referenced Functional Requirement

- FR-008: Business Sector Switching

---

### POST /business-sectors/switch

Switch the current sector context.

**Purpose:** Update the authenticated user's sector context. For Business Owner only — updates the session's current sector. Used to trigger client-side data refresh across screens.

**HTTP Method:** POST
**Route:** `/api/business-sectors/switch`
**Authentication:** Required (Bearer token)

**Allowed Roles:** Business Owner only

#### Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| sector_id | integer | Yes | Target sector ID to switch to |

**Example Request:**
```json
{
    "sector_id": 2
}
```

#### Validation Rules

| Field | Rule |
|-------|------|
| sector_id | Required; must reference an existing Business Sectors.id |

#### Success Response

**Status:** 200 OK

```json
{
    "data": {
        "previous_sector": {
            "id": 1,
            "name": "DYS Events"
        },
        "current_sector": {
            "id": 2,
            "name": "B&DYS"
        }
    },
    "message": "Sector switched successfully."
}
```

#### Error Responses

| Status | Condition | Response |
|--------|-----------|----------|
| 401 | No token or invalid token | `{"message": "Unauthenticated."}` |
| 403 | Non-Owner role | `{"message": "Forbidden."}` |
| 422 | Invalid sector_id | `{"message": "Validation failed.", "errors": {"sector_id": ["The selected sector_id is invalid."]}}` |

#### Business Rules

- Only the Business Owner can switch sectors
- Event Managers and Employees cannot use this endpoint (403 Forbidden)
- The server acknowledges the switch and returns both previous and current sector for client-side synchronization
- The switch itself is stateless on the server (the sector context is maintained client-side and sent with subsequent scoped requests)
- No confirmation is required from the server beyond a 200 response
- Client is responsible for refreshing Dashboard, Sales, Expenses, and Reports after switch
- No data is modified on the server (the switch is a context change, not a data mutation)

#### Related Tables

- Business Sectors

#### Referenced Functional Requirement

- FR-008: Business Sector Switching

---

## Error Codes

The API uses standard HTTP status codes:

| Status | Code | Description |
|--------|------|-------------|
| 200 | OK | Successful GET, PUT, PATCH requests |
| 201 | Created | Successful POST requests (resource created) |
| 401 | Unauthorized | Missing or invalid authentication token |
| 403 | Forbidden | Authenticated but insufficient permissions |
| 404 | Not Found | Requested resource does not exist |
| 422 | Unprocessable Entity | Validation failure (see `errors` object in response body) |
| 500 | Internal Server Error | Unexpected server error |

**Standard 401 Response:**
```json
{
    "message": "Unauthenticated."
}
```

**Standard 403 Response:**
```json
{
    "message": "Forbidden."
}
```

**Standard 404 Response:**
```json
{
    "message": "Resource not found."
}
```

**Standard 422 Response:**
```json
{
    "message": "Validation failed.",
    "errors": {
        "field_name": [
            "The field_name field is required."
        ]
    }
}
```

**Standard 500 Response:**
```json
{
    "message": "An unexpected error occurred. Please try again later."
}
```

---

## API Permission Matrix

| Endpoint | Business Owner | Event Manager | Employee/Staff |
|----------|:--------------:|:-------------:|:--------------:|
| POST /api/login | ✓ | ✓ | ✓ |
| POST /api/logout | ✓ | ✓ | ✓ |
| GET /api/users | ✓ | — | — |
| POST /api/users | ✓ | — | — |
| GET /api/users/{id} | ✓ | — | — |
| PUT /api/users/{id} | ✓ | — | — |
| PATCH /api/users/{id}/status | ✓ | — | — |
| GET /api/sales | ✓ | ✓ (assigned sector only) | — |
| POST /api/sales | ✓ | ✓ (assigned sector only) | — |
| GET /api/expenses | ✓ | ✓ (assigned sector only) | — |
| POST /api/expenses | ✓ | ✓ (assigned sector only) | — |
| GET /api/payroll | ✓ (all employees) | ✓ (own only) | ✓ (own only) |
| POST /api/payroll | ✓ | — | — |
| GET /api/reports | ✓ (all sectors, analytics) | ✓ (assigned sector only) | — |
| GET /api/business-sectors | ✓ | ✓ | ✓ |
| POST /api/business-sectors/switch | ✓ | — | — |

---

## Functional Traceability Matrix

| Endpoint | FR | Use Case | Wireframe (Hi-Fi) | Database Tables |
|----------|:--:|:--------:|:------------------:|:---------------:|
| POST /api/login | FR-001 | UC1: Login | login.html | Users, Business Sectors |
| POST /api/logout | FR-001 | UC1: Login | login.html | (Personal Access Tokens) |
| GET /api/users | FR-003 | UC10: Manage User Accounts | users.html | Users, Business Sectors |
| POST /api/users | FR-003 | UC10: Manage User Accounts | users.html | Users, Business Sectors |
| GET /api/users/{id} | FR-003 | UC10: Manage User Accounts | users.html | Users, Business Sectors |
| PUT /api/users/{id} | FR-003 | UC10: Manage User Accounts | users.html | Users, Business Sectors |
| PATCH /api/users/{id}/status | FR-003 | UC10: Manage User Accounts | users.html | Users |
| GET /api/sales | FR-004 | UC2: Record Sales Transaction | sales.html | Sales Transactions, Users, Business Sectors |
| POST /api/sales | FR-004 | UC2: Record Sales Transaction | sales.html | Sales Transactions, Users, Business Sectors |
| GET /api/expenses | FR-005 | UC3: Record Expense | expenses.html | Expenses, Users, Business Sectors, Payroll Records |
| POST /api/expenses | FR-005 | UC3: Record Expense | expenses.html | Expenses, Users, Business Sectors |
| GET /api/payroll | FR-006 | UC5, UC7: View Payroll Calculations, View Own Payroll | payroll.html | Payroll Records, Users, Business Sectors, Expenses |
| POST /api/payroll | FR-006 | UC5, UC9: View Payroll Calculations, Payroll Auto-creates Expense | payroll.html | Payroll Records, Users, Business Sectors, Expenses |
| GET /api/reports | FR-007 | UC6: View Reports | reports.html | Sales Transactions, Expenses, Business Sectors |
| GET /api/business-sectors | FR-008 | UC8: Switch Business Sector | sector-switcher.html | Business Sectors |
| POST /api/business-sectors/switch | FR-008 | UC8: Switch Business Sector | sector-switcher.html | Business Sectors |

---

## Summary of All Endpoints

| Method | Route | Auth | Allowed Roles | Purpose |
|--------|-------|:----:|:-------------:|---------|
| POST | /api/login | No | All | Authenticate and receive token |
| POST | /api/logout | Yes | All | Revoke token |
| GET | /api/users | Yes | Owner only | List all user accounts |
| POST | /api/users | Yes | Owner only | Create user account |
| GET | /api/users/{id} | Yes | Owner only | Get single user |
| PUT | /api/users/{id} | Yes | Owner only | Update user account |
| PATCH | /api/users/{id}/status | Yes | Owner only | Activate/deactivate user |
| GET | /api/sales | Yes | Owner, EM | List sales transactions |
| POST | /api/sales | Yes | Owner, EM | Record a sale |
| GET | /api/expenses | Yes | Owner, EM | List expense records |
| POST | /api/expenses | Yes | Owner, EM | Record an expense |
| GET | /api/payroll | Yes | All | List payroll records (role-filtered) |
| POST | /api/payroll | Yes | Owner only | Calculate and save payroll |
| GET | /api/reports | Yes | Owner, EM | Generate financial reports |
| GET | /api/business-sectors | Yes | All | List business sectors |
| POST | /api/business-sectors/switch | Yes | Owner only | Switch sector context |

---

## Consistency Audit

| Source | Status |
|--------|--------|
| Functional Requirements Specification (FRS) | ✓ |
| Concept Paper | ✓ |
| Client Clarifications | ✓ |
| System Architecture | ✓ |
| System Flowchart | ✓ |
| User Flow | ✓ |
| Use Case | ✓ |
| Use Case Diagram | ✓ |
| Wireframes (Low-Fi) | ✓ |
| Wireframes (Hi-Fi) | ✓ |
| ER Diagram | ✓ |
| Database Schema | ✓ |
| Data Dictionary | ✓ |
| Physical ERD | ✓ |
| Definition of System Components | ✓ |
| Project Memory | ✓ |
| AI Instructions | ✓ |
| CHANGELOG | ✓ |
| VERSION | ✓ |

**Issues Found:** None

**Verification summary:**
- 16 endpoints total (2 auth, 5 user management, 2 sales, 2 expenses, 2 payroll, 1 reports, 2 business sectors)
- No Register, Sign Up, Forgot Password, Invite, or self-registration endpoints introduced
- No Admin or Super Admin roles or endpoints introduced
- No payment gateway, notifications, messaging, or QR code endpoints introduced
- No PUT/PATCH/DELETE on Sales, Expenses, or Payroll Records (immutable by design)
- All endpoints map to approved FRS requirements and use cases
- All role permissions match the approved RBAC model

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | API Specification |
| Version | 1.0 |
| Status | Draft — Pending Audit |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Review | Yes |
