# DYS Financial Management System – User Flow Documentation

This document describes each User Flow shown in the approved User Flow Diagram. It is consistent with the approved Concept Paper, System Architecture, and Use Case model. It covers the four authorized system roles: Business Owner, Event Manager, Bookkeeper, and Employee/Event Staff.

---

## 1. Authentication & Role Routing Flow

### 1. Purpose
To authenticate users upon opening the application and direct them to their authorized role-based dashboard.

### 2. Actor(s)
- Business Owner
- Event Manager
- Bookkeeper
- Employee/Event Staff

### 3. Main Flow
1. User opens the application.
2. User enters login credentials (email and password).
3. System validates credentials.
4. If authentication fails, an error message is displayed, allowing retry.
5. If authentication succeeds, the system identifies the user's role and redirects them to the corresponding role-based dashboard.

---

## 2. Business Owner Flow

### 1. Purpose
Provides the highest level of system privilege, featuring financial summary overview, active sector context, and full administrative and operational control.

### 2. Available Actions
- **Manage User Accounts:** Create User, Update User, Activate/Deactivate, Generate Temporary Password.
- **Switch Business Sector:** Switch active business sector context.
- **Record Sales:** Record sales transactions.
- **Record Expenses:** Record business expenses.
- **Calculate Payroll:** Calculate employee payroll and generate associated expenses.
- **View Reports:** Access comprehensive financial reports.
- **View Analytics Dashboard:** Access interactive visual analytics.
- **Logout:** Terminate session and return to start.

---

## 3. Event Manager Flow

### 1. Purpose
Provides sector-restricted operational and reporting access for event operations.

### 2. Available Actions
- **Record Sales:** Record sales within the assigned business sector.
- **Record Expenses:** Record expenses within the assigned business sector.
- **View Reports:** Access assigned-sector reports.
- **View Own Payroll:** View personal payroll calculations.
- **Logout:** Terminate session and return to start.

---

## 4. Bookkeeper Flow

### 1. Purpose
Provides viewing-only financial and analytics oversight for auditing and bookkeeping.

### 2. Available Actions
- **View Analytics Dashboard:** Access financial analytics views.
- **View Records:** Access sales, expenses, and other approved financial records (viewing-only).
- **View Payroll Calculation:** Access payroll calculations (viewing-only).
- **Logout:** Terminate session and return to start.

*Note: Bookkeeper cannot record sales or expenses, calculate payroll, switch business sectors, or manage user accounts.*

---

## 5. Employee / Event Staff Flow

### 1. Purpose
Provides limited access for staff members to view their own payroll details.

### 2. Available Actions
- **View Own Payroll:** View personal payroll calculation records.
- **Logout:** Terminate session and return to start.

---

## Document Consistency Statement
This documentation reflects the four authorized system roles and workflows depicted in the approved User Flow Diagram.
