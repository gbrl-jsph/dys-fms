# System Flowchart — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- system-architecture.md
- user-flow.md
- use-case.md

## Overview
The system flowchart documents the process flows for the DYS Financial Management System (DYS FMS), covering authentication, financial transactions, reporting, and sector management.

## Main Processes
1. **User Authentication Flow**
   - Login → Role verification → Dashboard redirect

2. **Sales Transaction Flow**
   - User selects record sales → System processes entry → Result displayed

3. **Expense Recording Flow**
   - User selects record expense → System processes entry → Result displayed
   - Payroll auto-creates an Expense record when salary is calculated

4. **Report Generation Flow**
   - User selects report type → System generates report → Result displayed

5. **Payroll Processing Flow**
   - System calculates salary (Hours × Rate) → Salary stored permanently → Expense record auto-created → Result displayed and viewable historically

6. **Business Sector Switching Flow**
   - Owner selects switch sector → System updates context → Dashboard, Sales, Expenses, Reports auto-refresh for selected sector

7. **Manage User Accounts Flow**
   - Business Owner only → Open Manage Users → Create User → Assign Role → Assign Business Sector → Generate Temporary Password → Save Account → Display Credentials to provide to the employee. No public or self-registration exists.

## Decision Points
- Role-based access control gates all feature access
- Business Owner vs Event Manager vs Employee determines available actions
- Sector context determines data scope

## Actors
- Business Owner
- Event Manager
- Employees/Event Staff
