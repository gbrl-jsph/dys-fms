# Knowledge Base Version

**Version:** 3.7

**Last Updated:** 2026-07-29

**Generated From:**
- Revised Concept Paper
- Latest Client Clarifications (Sector Switching + Payroll Persistence + Payroll Permissions + User Account Management)
- Finalized Blueprint Documents

**Key Updates:**
- Default sector on login: Owner → DYS Event Management; EM/Employee → assigned sector
- Payroll: stored permanently, viewable historically, auto-creates Expense record
- Payroll Record entity added to ER Diagram and Database Schema
- Expense table includes payroll_record_id FK for auto-created expenses
- Business sector switching rules fully enforced across all documents
- System Architecture diagram created and frozen (v1.0), amended to v1.1 for User Account Management
- System Flowchart diagram created and frozen (v1.0), amended to v1.1 for User Account Management
- Project-wide rename: DYS Financial Management System (DYS FMS)
- Use Case Diagram created and frozen (v1.0), amended to v1.1 (10 use cases) for User Account Management
- Payroll Permissions clarification applied: only Business Owner can calculate payroll; Event Manager and Employees may only view their own payroll (not other employees'); Event Manager's prior "sector-scoped" payroll view removed
- Employees' separate "View Reports" capability removed and folded into "View Own Payroll only" across all curated, blueprint, and diagram documents
- User Account Management feature added: Business Owner creates all Event Manager and Employee accounts; assigns role and business sector; generates temporary credentials; activates/deactivates accounts (account_status column, no deletion); no public registration, self-registration, admin role, email password reset, or invitation links
- AI_INSTRUCTIONS.md version bumped 3.0 → 3.1
- High-Fidelity Wireframes synchronized: Manage Users screen added (users.html), all nav bars updated, dashboard quick-actions/bottom-nav updated
- Requirements Traceability Matrix (RTM) created — 8 FRs traced across 20 artifacts, 42 placeholder test case IDs
- Use Case Diagram rebuilt in strict UML PlantUML notation (stick figures, ovals, system boundary, <<include>>) — replaces Mermaid
