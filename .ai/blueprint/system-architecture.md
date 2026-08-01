# System Architecture — DYS Financial Management System (DYS FMS)

Related:
- ../concept-paper.md
- ../project-memory.md
- ../system-components.md
- system-flowchart.md
- er-diagram.md

## Architecture Style
Four-layer architecture

## Layers

### 1. Client Tier (Frontend)
- **Technology**: Flutter Mobile Application
- **Screens**: Login, Dashboard, Sales, Expenses, Payroll, Reports, Business Sector Switcher, Manage Users
- **Purpose**: User interface for input, display, and secure HTTPS requests

### 2. API Communication Layer
- **Technology**: REST API (HTTP/JSON) with Laravel Sanctum Authentication
- **Components**: REST Endpoints, API Routing
- **Purpose**: Receives, authenticates, routes, and returns requests as JSON

### 3. Backend Application Layer
- **Technology**: Laravel 12
- **Services**: Authentication & Role Management, Sales Management, Expense Management, Financial Calculator, Payroll Calculator, Business Sector Management, Reports & Analytics, User Account Management
- **Purpose**: Business logic, validation, RBAC, calculations, and report generation

### 4. Data Tier (Database)
- **Technology**: MySQL
- **Entities**: User, Business Sector, Sales Transaction, Expense, Payroll Record
- **Purpose**: Persistent storage for financial records

## Communication Flow
Users → HTTPS Requests → Flutter App → JSON → REST API → Laravel Backend → SQL → MySQL
