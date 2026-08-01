# DYS Event Management System – User Flow Documentation

This document describes each User Flow shown in the approved User Flow Diagram. It is consistent with the approved Concept Paper, System Architecture, and Flowcharts. No features, roles, or steps beyond what is depicted in the approved diagram are introduced.

---

## 1. Login

### 1. Purpose
To authenticate a user and grant access to the system based on their assigned role.

### 2. Actor(s)
- Business Owner
- Event Manager
- Employees/Event Staff

### 3. Preconditions
- The user has a registered account with an assigned role.
- The mobile application is installed and accessible.

### 4. Main Flow
1. User opens the application and reaches the Login screen.
2. User enters login credentials.
3. System performs authentication.
4. System identifies the user's role.
5. System directs the user to the corresponding role-based dashboard (Business Owner, Event Manager, or Employee/Staff).

### 5. Alternative Flows
- None depicted in the approved User Flow diagram.

### 6. Postconditions
- The user is authenticated and viewing their role-specific dashboard.

### 7. Notes
- The diagram does not define behavior for failed authentication attempts; only the successful authentication path is represented.

---

## 2. Record Sales

### 1. Purpose
To allow authorized users to record a sales transaction within their assigned business sector.

### 2. Actor(s)
- Business Owner
- Event Manager

### 3. Preconditions
- The user has successfully logged in.
- The user is on their role-specific dashboard.

### 4. Main Flow
1. User selects the feature to record a sales/expense entry from the dashboard.
2. User performs the action to record the sales transaction.
3. System processes the entry.
4. System displays the result to the user.

### 5. Alternative Flows
- None depicted in the approved User Flow diagram.

### 6. Postconditions
- The sales transaction result is displayed to the user.

### 7. Notes
- Employees/Event Staff do not have this action available, per the approved User Flow diagram.
- The diagram groups "Record Sales" and "Record Expense" under a single combined action for the Business Owner ("Record Sales/Expense Entry").

---

## 3. Record Expenses

### 1. Purpose
To allow authorized users to record a business expense within their assigned business sector.

### 2. Actor(s)
- Business Owner
- Event Manager

### 3. Preconditions
- The user has successfully logged in.
- The user is on their role-specific dashboard.

### 4. Main Flow
1. User selects the feature to record an expense from the dashboard.
2. User performs the action to record the expense.
3. System processes the entry.
4. System displays the result to the user.

### 5. Alternative Flows
- None depicted in the approved User Flow diagram.

### 6. Postconditions
- The expense entry result is displayed to the user.

### 7. Notes
- Employees/Event Staff do not have this action available, per the approved User Flow diagram.

---

## 4. Generate Reports

### 1. Purpose
To allow authorized users to view financial reports, analytics, or payroll calculations relevant to their role.

### 2. Actor(s)
- Business Owner (View Analytics Dashboard, View Payroll Calculations)
- Event Manager (View Reports)
- Employees/Event Staff (View Own Payroll Calculation)

### 3. Preconditions
- The user has successfully logged in.
- The user is on their role-specific dashboard.

### 4. Main Flow
1. User selects the reporting/analytics/payroll feature available to their role.
2. User performs the action to view the report.
3. System processes the request.
4. System displays the result to the user.

### 5. Alternative Flows
- Business Owner may choose between viewing the Analytics Dashboard or Payroll Calculations.
- Event Manager views role-restricted Reports.
- Employees/Event Staff view only their own Payroll Calculation.

### 6. Postconditions
- The requested report or calculation result is displayed to the user.

### 7. Notes
- Access to specific report types is limited by role, consistent with Role-Based Access Control.
- Employees/Event Staff have access only to their own payroll data, with no access to sales, expense, or analytics reports.

---

## 5. Switch Business Sector

### 1. Purpose
To allow authorized users to change the active business sector, so that displayed data corresponds to the selected sector.

### 2. Actor(s)
- Business Owner
- Event Manager

### 3. Preconditions
- The user has successfully logged in.
- The user is on their role-specific dashboard.

### 4. Main Flow
1. User selects the "Switch Business Sector" feature from the dashboard.
2. User performs the action to switch the sector.
3. System processes the request.
4. System displays the result to the user.

### 5. Alternative Flows
- None depicted in the approved User Flow diagram.

### 6. Postconditions
- The user's active business sector context is updated, and the result is displayed.

### 7. Notes
- Employees/Event Staff do not have this action available, per the approved User Flow diagram.

---

## Document Consistency Statement

This documentation reflects only the actors, features, and steps depicted in the approved User Flow Diagram. It aligns with the approved Concept Paper's stated features (Automated Financial Calculator, Automated Payroll Calculator, Role-Based Access Control, Business Sector Switcher, Interactive Visual Analytics Dashboard) and the three confirmed system actors (Business Owner, Event Manager, Employees/Event Staff). No additional workflows, roles, or system behaviors have been introduced.
