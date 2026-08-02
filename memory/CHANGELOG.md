# Changelog — AI Knowledge Base

## 2026-07-29

### Requirements Traceability Matrix (RTM) Created
- Created `memory/blueprint/requirements-traceability-matrix.md` — v1.0, Draft — master verification document tracing all 8 FRs across 20 artifacts
- 8 FRs mapped to: 10 use cases, 8 screens, 16 API endpoints, 5 database tables, 7 validation rule categories (59 rules), 10 development phases
- 42 placeholder test case IDs generated for future Test Case Specification
- 200+ traceability links verified across all blueprint documents
- Coverage summary confirms 100% FR traceability — zero orphan artifacts
- Gap analysis documents 3 observations (Dashboard has no validation rules; Dashboard serves all roles vs UC4 being BO-only; no dedicated Change Password screen/endpoint defined)
- Consistency audit passed against all 20 approved source documents
- VERSION.md bumped to v3.7

### Use Case Diagram Rebuilt (Strict UML Notation)
- Replaced Mermaid diagram with PlantUML strict UML 2.x notation at `memory/diagrams/use-case-diagram.puml`
- Rendered PNG (31.9 KB) and SVG (16.0 KB) via PlantUML server
- Updated `memory/blueprint/use-case-diagram.md` to v2.0 with PlantUML source, UML notation guide, and expanded documentation
- Documented conflict: use-case.md:20 lists UC6 as Event Manager only, contradicting Concept Paper, FRS FR-007, and Validation Rules Matrix (resolved per your confirmation — BO + EM both mapped to UC6)

## 2026-07-28

### New Approved Scope Change: User Account Management (Official Project Decision)
Business Owner is responsible for creating all Event Manager and Employee accounts. There is no public registration, no self-registration, and no admin role. Workflow: Business Owner → Create User Account → Assign Role → Assign Business Sector → Generate Temporary Password → Provide Credentials to Employee → Employee Logs In → Employee Changes Password on First Login (optional).

New feature added: **User Account Management** (Business Owner only) — create Event Manager/Employee accounts, assign business sector, assign role, generate temporary credentials, activate/deactivate accounts (instead of deleting).

Explicitly excluded, per instruction: public registration, Register/Sign Up screens, admin/super-admin roles, password reset by email, invitation links, self-registration.

Database: added `account_status` ENUM column to the existing Users table (Active/Inactive). No new tables introduced.

### Files Updated (User Account Management)
- `memory/concept-paper.md` — Features, Business Rules
- `memory/project-memory.md` — Approved Features, Approved User Roles, Approved Workflows, Business Rules, Things AI Must NEVER Invent, Finalized Diagrams (bumped to v1.1)
- `memory/system-components.md` — Client Tier Components, Backend Services, User Flow, User Roles
- `memory/AI_INSTRUCTIONS.md` — Approved Features, Approved User Roles, Workflows, Things AI Must Never Do; version bumped 3.0 → 3.1
- `memory/project-index.md` — summaries for system-flowchart.md, user-flow.md, use-case-diagram.md, wireframes.md
- `memory/blueprint/system-architecture.md` — Client Tier Screens, Backend Services
- `memory/blueprint/system-flowchart.md` — added Process 7 (User Account Management Flow)
- `memory/blueprint/user-flow.md` — added Flow 7 (Manage User Accounts), Business Rules
- `memory/blueprint/use-case.md` — added Use Case 10 (Manage User Accounts), Relationships
- `memory/blueprint/use-case-diagram.md` — added UC10 node + Business Owner association, Actor Permissions Mapping row
- `memory/blueprint/wireframes.md` — added Manage Users screen description
- `memory/blueprint/er-diagram.md` — User entity: added account status attribute and account-creation note
- `memory/blueprint/database-schema.md` — Users table: added `account_status` column; Notes
- `memory/blueprint/consistency-review.md` — added User Account Management section, updated Final Result
- `memory/diagrams/system-architecture.md` — added Manage Users screen node, User Account Management service node, Screens/Services tables, RBAC block
- `memory/diagrams/system-flowchart.md` — added Process 7 subgraph (role-gated: Business Owner only), Process Summary, Business Rules Enforced, Decision Points
- `memory/diagrams/user-flow.md` — added Manage Users nodes/edges to Business Owner subgraph, Flow Summary, Screen Navigation Matrix, Business Rules Enforced
- `memory/diagrams/wireframes.md` — added Manage Users nav button to Owner dashboard, new Manage Users mockup section, Screen Descriptions, Navigation Mapping, Role Access Matrix, Business Rules Enforced

Note: `memory/blueprint/system-flowchart.md`'s new Process 7 subgraph is physically positioned in the Mermaid source between Process 4 and Process 5 (cosmetic only — the diagram renders correctly and the process is correctly labeled "7"; file section is simply out of strict numeric order).

### High-Fidelity Wireframes Updated (User Account Management)
- Created `5 - Wireframes/wireframes-hifi/users.html` — Screen 8: Manage Users (user list table, Add/Edit form, Generate Temporary Password, Save/Deactivate, bottom nav)
- Updated `dashboard.html` — added Manage Users to quick actions, bottom nav, notes
- Updated `index.html` — screen count 7→8, added screen 8 link
- Updated `login.html` — notes mention no self-registration
- Updated `sales.html`, `expenses.html`, `payroll.html`, `reports.html`, `sector-switcher.html` — nav bars updated

### New Approved Client Clarification: Payroll Permissions (Highest Priority Source of Truth)
Supersedes any previous ambiguity regarding payroll permissions.
- Business Owner: can calculate payroll for every employee; can view payroll for every employee
- Event Manager: cannot calculate payroll; can view only their own payroll; cannot view other employees' payroll
- Employee/Event Staff: cannot calculate payroll; can view only their own payroll; cannot view other employees' payroll
- Canonical rule: Only the Business Owner can calculate payroll. Event Managers and Employees are restricted to viewing only their own payroll. No role except the Business Owner may view another employee's payroll.
- Resolves the prior Event Manager "sector-scoped payroll" model and removes Employees' separate "View Reports" capability (folded into "View Own Payroll only")

### Files Updated
- `memory/concept-paper.md` — Business Rules
- `memory/project-memory.md` — Approved User Roles, Approved Workflows, Business Rules
- `memory/system-components.md` — User Flow, User Roles
- `memory/AI_INSTRUCTIONS.md` — Approved User Roles, Workflows
- `memory/blueprint/user-flow.md` — Generate Reports, Payroll Processing, Business Rules
- `memory/blueprint/use-case.md` — Use Cases, Relationships
- `memory/blueprint/use-case-diagram.md` — Mermaid actor associations, Actor Permissions Mapping table
- `memory/blueprint/wireframes.md` — Payroll, Reports
- `memory/blueprint/consistency-review.md` — added Payroll & Reports Permissions section, updated Final Result
- `memory/diagrams/user-flow.md` — Mermaid nodes/edges, Flow Summary, Screen Navigation Matrix, Business Rules Enforced (not in original request list; included per AI_INSTRUCTIONS.md "never update only one document if the change affects multiple project artifacts" — this file contained the exact superseded "View Payroll (Sector-scoped)" wording)
- `memory/diagrams/system-flowchart.md` — Payroll Processing flow role gate, Process Summary, Business Rules Enforced, Decision Points (not in original request list; same rationale)
- `memory/diagrams/system-architecture.md` — Screens table, RBAC block (not in original request list; same rationale)
- `memory/diagrams/wireframes.md` — Employee dashboard mockup, Payroll mockups (added Event Manager view), Reports mockup (removed Employee version), Screen Descriptions, Role Access Matrix, Business Rules Enforced (not in original request list; same rationale)
- `memory/project-index.md` — reviewed, no change needed (summaries are generic and do not enumerate role-specific payroll permissions)

## 2026-07-27

### Earlier
- Removed Activity Diagrams
- Updated Wireframes
- Revised Concept Paper
- Regenerated AI knowledge base
- Updated Business Sector Switching: Owner only can switch; Event Managers and Employees permanently assigned
- Updated Payroll: formula Hours × Rate, stored in database
- Updated Reports: monitor income, monitor expenses, view summaries, view reports, track sector performance
- Removed curation artifacts: immutability rule, rewritten challenges/constraints
- Added Payroll Records table to ER Diagram and Database Schema
- Added sector_id to Users table for permanent sector assignment
- Regenerated concept-paper.md, project-memory.md, project-index.md with latest clarifications

### Latest Client Clarifications Applied
- Updated AI_INSTRUCTIONS.md to v3.0 with new governance rules
- Changed default sector from "Finance" to "DYS Event Management" for Business Owner
- Added default sector rule: Event Managers/Employees default to their assigned business sector
- Updated Payroll requirement: stored permanently, viewable historically, auto-creates Expense record
- Added Payroll Record entity to ER Diagram with Expense auto-creation relationship
- Added Payroll Records table to Database Schema with Expense FK linkage
- Added Payroll auto-creates Expense to all workflow documents (flowchart, user-flow, use-case)
- Updated System Architecture: added Payroll Record to data entities
- Updated System Components: added Payroll Record as data entity
- Updated Wireframes: fixed default sector from Finance to DYS Event Management / assigned sector
- Updated Consistency Review with default sector rules and new data entity verification
- Performed full consistency audit across 11 curated documents — no contradictions found

### Diagrams Finalized
- Created System Architecture diagram (`diagrams/system-architecture.md`) — v1.0 frozen
- Created System Flowchart diagram (`diagrams/system-flowchart.md`) — v1.0 frozen
- Created User Flow diagram (`diagrams/user-flow.md`) — v1.0 frozen
- Created Wireframes (`diagrams/wireframes.md`) — v1.0 frozen
- Updated High-Fidelity Wireframes (`5 - Wireframes/wireframes-hifi/`) to match approved low-fi blueprint
- Project-wide rename: "DYS Event Management System" / "DYS Sales Tracker Management System" → "DYS Financial Management System (DYS FMS)"
- Updated VERSION.md to v3.1, project-memory.md with diagram tracking

### Use Case Diagram Finalized
- Created Use Case Diagram (`blueprint/use-case-diagram.md`) — v1.0 frozen
- 3 actors (Business Owner, Event Manager, Employee/Event Staff), 9 use cases, `<<include>>` relationship from View Payroll Calculations to Payroll Auto-creates Expense
- Mermaid `graph TB` layout with actor permissions table and consistency check
- Updated VERSION.md to v3.3, project-memory.md pending deliverables
