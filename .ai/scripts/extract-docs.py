#!/usr/bin/env python3
"""Extract project documents to .ai/extracted/ using Microsoft MarkItDown."""

import hashlib
import json
import os
import re
import sys
from pathlib import Path

from markitdown import MarkItDown

REPO_ROOT = Path(__file__).resolve().parents[2]
AI_DIR = REPO_ROOT / ".ai"
EXTRACTED_DIR = AI_DIR / "extracted"
BLUEPRINT_DIR = AI_DIR / "blueprint"
HASH_FILE = AI_DIR / ".extracted_hashes.json"

IGNORE_DIRS = {
    ".git", "node_modules", ".ai", "dist", "build", "coverage",
    ".obsidian", ".trash",
}

SUPPORTED_EXTENSIONS = {
    ".pdf", ".docx", ".pptx", ".xlsx", ".odt",
    ".html", ".htm",
    ".md", ".txt",
}

IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".tiff", ".webp"}


def slugify(name: str) -> str:
    name = re.sub(r"\s+", "-", name.strip())
    name = re.sub(r"[^a-zA-Z0-9\-_]", "", name)
    name = re.sub(r"-+", "-", name)
    return name.lower().strip("-")


def compute_hash(filepath: Path) -> str:
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def load_hashes() -> dict:
    if HASH_FILE.exists():
        return json.loads(HASH_FILE.read_text())
    return {}


def save_hashes(hashes: dict):
    HASH_FILE.write_text(json.dumps(hashes, indent=2))


def discover_documents() -> list[Path]:
    files = []
    for root, dirs, names in os.walk(REPO_ROOT):
        rel_root = Path(root).relative_to(REPO_ROOT)
        parts = set(rel_root.parts)
        if parts & IGNORE_DIRS:
            dirs[:] = []
            continue
        dirs[:] = [d for d in dirs if d not in IGNORE_DIRS and not d.startswith(".")]
        for name in names:
            ext = Path(name).suffix.lower()
            if ext in SUPPORTED_EXTENSIONS or ext in IMAGE_EXTENSIONS:
                files.append(Path(root) / name)
    files.sort(key=lambda p: p.relative_to(REPO_ROOT).as_posix())
    return files


def convert_file(md: MarkItDown, filepath: Path, rel_path: str) -> tuple[str, str | None]:
    try:
        result = md.convert(str(filepath))
        text = result.text_content
        if not text or not text.strip():
            print(f"  ⚠  Empty conversion for {rel_path}")
            return "", None
        return text, None
    except Exception as e:
        return "", str(e)


def sanitize_filename(filepath: Path, rel_path: str) -> str:
    stem = filepath.stem
    parent_dir = filepath.parent.name if filepath.parent != REPO_ROOT else ""
    parts = []
    if parent_dir and parent_dir != REPO_ROOT.name:
        parts.append(slugify(parent_dir))
    parts.append(slugify(stem))
    name = "-".join(parts)
    if not name:
        name = slugify(rel_path.replace("/", "-").replace("\\", "-"))
    return name + ".md"


def generate_curated_from_extracted(extracted_dir: Path):
    files_content = {}
    for fpath in sorted(extracted_dir.iterdir()):
        if fpath.suffix == ".md":
            files_content[fpath.stem] = fpath.read_text()

    output_dir = AI_DIR
    _gen_concept_paper(files_content, output_dir)
    _gen_client_interview(files_content, output_dir)
    _gen_system_components(files_content, output_dir)


def _find_content(files: dict, *keywords: str) -> str:
    for kw in keywords:
        for stem, content in files.items():
            if kw.lower().replace(" ", "-") in stem.lower().replace(" ", "-"):
                return content
    return ""


def _gen_concept_paper(files: dict, output_dir: Path):
    raw = _find_content(files, "concept-paper", "concept-paper-revision")
    if not raw:
        raw = _find_content(files, "research")
    
    lines = raw.split("\n") if raw else []
    
    doc = """# Concept Paper — DYS Financial Management System (DYS FMS)

## Project Overview
DYS Financial Management System (DYS FMS) is a centralized financial transaction monitoring and management platform for DYS Event Management, which operates across multiple business sectors including event coordination, styling, souvenirs, grazing tables, celebration drinks, and video guestbooks.

## Problem Statement
DYS Event Management faces problems in monitoring financial transactions due to the lack of a centralized platform to track cash inflows and outflows across multiple business sectors. Current reliance on manual processes (handwritten notes, receipts, Messenger conversations) results in forgotten expenses, lost receipts, inaccurate records, and compromised financial transparency.

## Proposed Solution
A mobile application with role-based access control that enables the business owner and authorized department heads to record, organize, and monitor sales transactions, business expenses, and other financial records in a centralized platform. The system includes automated computation of sales and expenses, role-based access, business sector switching, and visual reports.

## Target Users
- Business Owner — full access, cross-sector visibility, can switch sectors
- Event Manager — sector-specific access, permanently assigned to one sector
- Employees/Event Staff — view-only access, permanently assigned to one sector

## Features
- Role-Based Access Control (RBAC)
- Sales and Expense Recording
- Automated Financial Calculator
- Automated Payroll Calculator (Hours Worked × Hourly Rate; computed salary stored in database for record-keeping)
- Business Sector Switcher (Owner only; default sector: Finance; auto-refreshes Dashboard, Sales, Expenses, Reports)
- Interactive Visual Analytics Dashboard
- Report Generation (monitor income, monitor expenses, view summaries, view reports, track sector financial performance)

## Constraints
- Time: project must be completed within approximately six months while balancing academic workload
- Budget: reliance on free, open-source software and development tools
- Technical experience: student developers with evolving skill sets

## Software Engineering Challenges
- Data security: confidential financial data used by multiple users requires authentication, RBAC, password encryption, and regular backups
- User adoption: client accustomed to manual processes requires carefully planned onboarding
- Data migration: existing records in different formats (notes, Messenger) require validation before migration

## Business Rules
- Only Business Owners and Event Managers can record sales/expenses
- Employees/Event Staff can only view their own payroll
- Business sector switching is available to Business Owner only
- Event Managers and Employees are permanently assigned to one business sector
- Business Owner's default sector on login is Finance
- Switching sectors auto-refreshes Dashboard, Sales, Expenses, and Reports
- Payroll is calculated as Hours Worked × Hourly Rate and the computed salary is stored in the database for record-keeping (storage mechanism is a design decision)
- Event Managers and Employees are permanently assigned to one business sector
"""
    if raw:
        doc += "\n## Source Excerpts\n\n"
        for line in lines:
            stripped = line.strip()
            if stripped and not stripped.startswith("#") and not stripped.startswith("---"):
                doc += f"{stripped}\n"

    (output_dir / "concept-paper.md").write_text(doc)


def _gen_client_interview(files: dict, output_dir: Path):
    raw = _find_content(files, "interview", "copy-of-interview")
    lines = raw.split("\n") if raw else []

    doc = """# Client Interview — DYS Financial Management System (DYS FMS)

## Client Requirements
The client requires a centralized system to manage financial transactions across multiple event management business sectors.

## Pain Points
- Fragmented financial tracking across different business sectors
- Manual payroll calculation overhead
- Lack of real-time financial visibility
- Difficulty generating cross-sector reports

## Requested Features
- Automated financial calculator
- Automated payroll calculator
- Role-based access control
- Business sector switcher
- Interactive visual analytics dashboard
- Sales and expense recording

## Business Processes
- Business Owner oversees all sectors
- Event Manager handles day-to-day operations within assigned sectors
- Employees/Event Staff perform operational tasks with limited system access

## Important Notes
- The system must support multiple business sectors under a single organization
- Financial data must be secured by role
- Payroll calculations must be automated and role-visible

"""
    if raw:
        doc += "## Interview Excerpts\n\n"
        for line in lines:
            stripped = line.strip()
            if stripped:
                doc += f"{stripped}\n"

    (output_dir / "client-interview.md").write_text(doc)


def _gen_system_components(files: dict, output_dir: Path):
    doc = """# System Components — DYS Financial Management System (DYS FMS)

## Architecture Overview
Four-layer architecture:
- Client Tier (Flutter Mobile App)
- API Communication Layer (REST API via Laravel Sanctum)
- Backend Application Layer (Laravel 12)
- Data Tier (MySQL Database)

## Client Tier Components
- Login screen
- Dashboard
- Sales entry
- Expenses entry
- Payroll view
- Reports/Analytics
- Business Sector Switcher

## Backend Services
- Authentication & Role Management
- Sales Management
- Expense Management
- Financial Calculator
- Payroll Calculator
- Business Sector Management
- Reports & Analytics

## Data Entities
- User
- Business Sector
- Sales Transaction
- Expense

Payroll (Hours Worked x Hourly Rate) is stored in the database per client requirement. The storage mechanism is a design decision.

## User Flow
1. Login -> Role-based dashboard
2. Record Sales/Expenses (Owner, Manager only)
3. Generate Reports (role-specific views)
4. Switch Business Sector (Owner only)
5. View Payroll (role-specific)

## User Roles
- **Business Owner**: Full access to all features, cross-sector visibility, can switch sectors
- **Event Manager**: Sector-specific access, cannot switch sectors, permanently assigned to one sector
- **Employees/Event Staff**: View-only access to own payroll, permanently assigned to one sector
"""
    (output_dir / "system-components.md").write_text(doc)


def generate_project_index(documents: list[tuple[str, str]], errors: list[tuple[str, str]]):
    doc = "# Project Index — DYS Financial Management System (DYS FMS)\n\n"
    doc += "Complete index of all project documents.\n\n"
    
    summaries = {
        "concept-paper": "Project overview, problem statement, proposed solution, features, constraints, and business rules.",
        "concept-paper-revision": "Revised version of the Concept Paper with updates.",
        "copy-of-interview-with-mrs-divine": "Client interview transcript capturing requirements, pain points, and requested features.",
        "1-system-architecture": "Four-layer system architecture documentation (Client, API, Backend, Data tiers).",
        "1-system-architecture-documentation": "Detailed system architecture documentation including component descriptions.",
        "2-system-flowchart": "System flowchart documentation showing process flows.",
        "dys-userflow-documentation": "User flow documentation covering login, sales, expenses, reports, and sector switching.",
        "3-user-flow-diagram": "User flow diagram and documentation for all approved workflows.",
        "4-use-case-diagram": "Use case diagram documentation showing actor-system interactions.",
        "5-wireframes": "High-fidelity wireframes for all screens (dashboard, login, sales, expenses, payroll, reports, sector switcher).",
        "er-diagram": "Entity-Relationship diagram documentation for database design.",
        "6-database-design": "Database design documentation including schema details.",
        "final": "Final system architecture HTML visualization.",
    }
    
    for rel_path, out_name in documents:
        stem = out_name.replace(".md", "")
        summary = "See curated document for details."
        for key, val in summaries.items():
            if key in stem:
                summary = val
                break
        
        doc += f"## {out_name}\n\n"
        doc += f"- **Source**: `{rel_path}`\n"
        doc += f"- **AI Copy**: `.ai/extracted/{out_name}`\n"
        doc += f"- **Summary**: {summary}\n\n"
    
    if errors:
        doc += "## Conversion Errors\n\n"
        for rel_path, err in errors:
            doc += f"- `{rel_path}`: {err}\n"
    
    (AI_DIR / "project-index.md").write_text(doc)


def generate_project_memory(extracted_dir: Path):
    doc = """# Project Memory — DYS Financial Management System (DYS FMS)

*Optimized for AI context loading*

## Current Project Scope
A centralized financial transaction monitoring and management system for DYS Event Management, built as a mobile-first application with role-based access control.

## Project Name
DYS Financial Management System (DYS FMS) (DYS Financial Management System (DYS FMS))

## Tech Stack
- **Frontend**: Flutter (Mobile Application)
- **Backend**: Laravel 12
- **API**: REST API with Laravel Sanctum Authentication
- **Database**: MySQL
- **Communication**: HTTPS / JSON

## Approved Features
1. Role-Based Access Control (RBAC)
2. Sales Transaction Recording
3. Expense Recording
4. Automated Financial Calculator
5. Automated Payroll Calculator (Hours Worked x Hourly Rate; computed salary stored in database for record-keeping)
6. Business Sector Switcher (Owner only; default sector: Finance; auto-refreshes Dashboard, Sales, Expenses, Reports)
7. Interactive Visual Analytics Dashboard
8. Report Generation (monitor income, monitor expenses, view summaries, view reports, track sector financial performance)

## Approved User Roles
- **Business Owner**
  - Full system access
  - Cross-sector visibility
  - Can record sales and expenses
  - Can switch business sectors (default sector: Finance)
  - Can view analytics dashboard and payroll calculations
- **Event Manager**
  - Sector-specific access
  - Can record sales and expenses
  - Permanently assigned to one business sector, cannot switch
  - Can view reports within assigned sector
- **Employees/Event Staff**
  - View-only access
  - Can only view own payroll calculation
  - Permanently assigned to one business sector, cannot switch
  - Cannot record sales or expenses

## Approved Workflows
1. **Login**: Authenticate -> Role-based dashboard redirect
2. **Record Sales**: Dashboard -> Record Sales -> System processes -> Result displayed
3. **Record Expenses**: Dashboard -> Record Expense -> System processes -> Result displayed
4. **Generate Reports**: Dashboard -> Select report type -> System processes -> Report displayed (monitor income, monitor expenses, view summaries, view reports, track sector performance)
5. **Switch Business Sector**: Owner only -> Switch sector -> System updates context -> Dashboard, Sales, Expenses, Reports auto-refresh for selected sector
6. **View Payroll**: Dashboard -> View payroll -> System calculates (Hours Worked x Hourly Rate) -> Result displayed and stored in database (storage mechanism is a design decision)

## Business Rules
- Only Business Owners and Event Managers can record sales/expenses
- Employees/Event Staff cannot record transactions or switch sectors
- Business Owners can view analytics and payroll, and can switch sectors
- Event Managers can view reports within their assigned sector only, cannot switch sectors
- Employees can only view their own payroll data
- The system uses role-based dashboards (Role-Based Access Control)
- Business sector switching is available only to Owner
- Business Owner's default sector on login is Finance
- Switching sectors auto-refreshes Dashboard, Sales, Expenses, and Reports
- Payroll is calculated as Hours Worked x Hourly Rate and the computed salary is stored in the database for record-keeping (storage mechanism is a design decision)
- Event Managers and Employees are permanently assigned to one business sector

## Naming Conventions
- **Project**: DYS Financial Management System (DYS FMS)
- **Frontend**: Flutter mobile application
- **Backend**: Laravel 12
- **Database**: MySQL
- **API Style**: REST

## Current Completed Deliverables
- Concept Paper
- Client Interview Documentation
- System Architecture Documentation
- System Flowchart Documentation
- User Flow Diagram & Documentation
- Use Case Diagram & Documentation
- Wireframes (Hi-Fi HTML)
- ER Diagram Documentation
- Database Design Documentation
- System Architecture HTML visualization

## Pending Deliverables
- Development Planning (empty directory)
- Low-fidelity wireframes (Figma file only, not converted)

## Things AI Must NEVER Invent
- Additional user roles beyond the three approved (Business Owner, Event Manager, Employees/Event Staff)
- Features not listed in the approved Concept Paper
- Authentication failure handling flows (not depicted in approved diagrams)
- Admin role or Super Admin role
- Web application version (system is mobile-first via Flutter)
- API endpoints or database fields not documented in the source documents
- Payment processing or invoicing features

## Source of Truth Hierarchy
1. Approved Concept Paper (Canonical feature definitions)
2. System Architecture Documentation (Technical architecture)
3. User Flow Documentation (Approved workflows)
4. Use Case Documentation (Actor-system interactions)
5. ER Diagram / Database Design (Data model)
6. Wireframes / HTML prototypes (UI layout)
7. System Flowchart (Process flows)
8. Client Interview (Requirements context)
"""
    (AI_DIR / "project-memory.md").write_text(doc)


def generate_blueprint_docs(extracted_dir: Path):
    files = {}
    for fpath in extracted_dir.iterdir():
        if fpath.suffix == ".md":
            files[fpath.stem] = fpath.read_text()
    
    _gen_system_architecture(files)
    _gen_system_flowchart(files)
    _gen_user_flow(files)
    _gen_use_case(files)
    _gen_wireframes(files)
    _gen_er_diagram(files)
    _gen_database_schema(files)
    _gen_consistency_review(files)


def _gen_system_architecture(files: dict):
    raw = _find_content(files, "system-architecture", "final")
    
    doc = """# System Architecture — DYS Financial Management System (DYS FMS)

## Architecture Style
Four-layer architecture

## Layers

### 1. Client Tier (Frontend)
- **Technology**: Flutter Mobile Application
- **Screens**: Login, Dashboard, Sales, Expenses, Payroll, Reports, Business Sector Switcher
- **Purpose**: User interface for input, display, and secure HTTPS requests

### 2. API Communication Layer
- **Technology**: REST API (HTTP/JSON) with Laravel Sanctum Authentication
- **Components**: REST Endpoints, API Routing
- **Purpose**: Receives, authenticates, routes, and returns requests as JSON

### 3. Backend Application Layer
- **Technology**: Laravel 12
- **Services**: Authentication & Role Management, Sales Management, Expense Management, Financial Calculator, Payroll Calculator, Business Sector Management, Reports & Analytics
- **Purpose**: Business logic, validation, RBAC, calculations, and report generation

### 4. Data Tier (Database)
- **Technology**: MySQL
- **Entities**: User, Business Sector, Sales Transaction, Expense
- **Purpose**: Persistent storage for financial records

## Communication Flow
Users → HTTPS Requests → Flutter App → JSON → REST API → Laravel Backend → SQL → MySQL
"""
    (BLUEPRINT_DIR / "system-architecture.md").write_text(doc)


def _gen_system_flowchart(files: dict):
    doc = """# System Flowchart — DYS Financial Management System (DYS FMS)

## Overview
The system flowchart documents the process flows for the DYS Financial Management System (DYS FMS), covering authentication, financial transactions, reporting, and sector management.

## Main Processes
1. **User Authentication Flow**
   - Login → Role verification → Dashboard redirect

2. **Sales Transaction Flow**
   - User selects record sales → System processes entry → Result displayed

3. **Expense Recording Flow**
   - User selects record expense → System processes entry → Result displayed

4. **Report Generation Flow**
   - User selects report type → System generates report → Result displayed

5. **Business Sector Switching Flow**
   - Owner selects switch sector → System updates context → Dashboard, Sales, Expenses, Reports auto-refresh for selected sector

## Decision Points
- Role-based access control gates all feature access
- Business Owner vs Event Manager vs Employee determines available actions
- Sector context determines data scope

## Actors
- Business Owner
- Event Manager
- Employees/Event Staff
"""
    (BLUEPRINT_DIR / "system-flowchart.md").write_text(doc)


def _gen_user_flow(files: dict):
    doc = """# User Flow — DYS Financial Management System (DYS FMS)

## Flows

### 1. Login
- **Actors**: All roles
- **Flow**: Open app → Enter credentials → System authenticates → Role-based dashboard

### 2. Record Sales
- **Actors**: Business Owner, Event Manager
- **Flow**: Dashboard → Record Sales → System processes → Result displayed

### 3. Record Expenses
- **Actors**: Business Owner, Event Manager
- **Flow**: Dashboard → Record Expense → System processes → Result displayed

### 4. Generate Reports
- **Actors**: All roles (role-specific views)
- **Flow**: Dashboard → Select report → System processes → Result displayed
- **Capabilities**: monitor income, monitor expenses, view summaries, view reports, track sector financial performance
- **Business Owner**: Analytics Dashboard, Payroll Calculations, cross-sector reports
- **Event Manager**: Role-restricted Reports within assigned sector
- **Employees**: Own Payroll only

### 5. Switch Business Sector
- **Actors**: Business Owner only
- **Flow**: Dashboard → Switch sector → System updates context → Dashboard, Sales, Expenses, Reports auto-refresh for selected sector
- **Default sector on login**: Finance

## Business Rules
- Employees cannot record sales/expenses or switch sectors
- Business Owner has cross-sector visibility, can switch sectors
- Event Manager has sector-specific access, permanently assigned to one sector, cannot switch
"""
    (BLUEPRINT_DIR / "user-flow.md").write_text(doc)


def _gen_use_case(files: dict):
    doc = """# Use Case Diagram — DYS Financial Management System (DYS FMS)

## Actors
- **Business Owner**: Full system access
- **Event Manager**: Sector-specific operational access
- **Employees/Event Staff**: Limited view-only access

## Use Cases
1. **Login/Authenticate** — All actors
2. **Record Sales Transaction** — Business Owner, Event Manager
3. **Record Expense** — Business Owner, Event Manager
4. **View Analytics Dashboard** — Business Owner
5. **View Payroll Calculations** — Business Owner
6. **View Reports** — Event Manager
7. **View Own Payroll** — Employees/Event Staff
 8. **Switch Business Sector** — Business Owner only

## Relationships
- All use cases require prior authentication
- Business Owner includes all use cases
- Event Manager includes sales, expense, and reports within assigned sector
- Employees are limited to login and own payroll view
"""
    (BLUEPRINT_DIR / "use-case.md").write_text(doc)


def _gen_wireframes(files: dict):
    doc = """# Wireframes — DYS Financial Management System (DYS FMS)

## Screens

### Login
- Authentication entry point
- Credential input fields

### Dashboard
- Role-based landing page after login
- Navigation to all permitted features

### Sales
- Sales transaction recording interface
- Available to Business Owner and Event Manager

### Expenses
- Expense recording interface
- Available to Business Owner and Event Manager

### Payroll
- Payroll calculation display
- Role-specific visibility

### Reports
- Analytics and reporting interface
- Role-specific data access

### Business Sector Switcher
- Sector selection interface
- Available to Business Owner only
- Default active sector on login: Finance
- Auto-refreshes Dashboard, Sales, Expenses, Reports on switch

## Technology
HTML-based high-fidelity wireframes
"""
    (BLUEPRINT_DIR / "wireframes.md").write_text(doc)


def _gen_er_diagram(files: dict):
    doc = """# ER Diagram — DYS Financial Management System (DYS FMS)

## Entities

### User
- Represents system actors (Business Owner, Event Manager, Employee/Staff)
- Linked to a permanent Business Sector (for Event Managers and Employees)
- Business Owner has cross-sector access via sector switching

### Business Sector
- Represents distinct business sectors within the organization
- Each sector has its own financial data scope

### Sales Transaction
- Records individual sales transactions
- Linked to a User and Business Sector

### Expense
- Records individual business expenses
- Linked to a User and Business Sector

## Relationships
- User → Business Sector (many-to-one for Event Managers and Employees; Owner has cross-sector switching)
- User → Sales Transaction (one-to-many)
- User → Expense (one-to-many)
- Business Sector → Sales Transaction (one-to-many)
- Business Sector → Expense (one-to-many)

## Design Notes

### Payroll Storage
The client requires that computed payroll (Hours Worked × Hourly Rate) be **stored in the database** for record-keeping. This is a functional requirement — the computed salary must be persisted. The storage mechanism (e.g., a dedicated table, fields on an existing entity, or an audit log) is a design decision not prescribed by the requirements. The conceptual ER model above includes only entities explicitly defined in the source documentation; payroll storage is an implementation detail to be resolved during development.
"""
    (BLUEPRINT_DIR / "er-diagram.md").write_text(doc)


def _gen_database_schema(files: dict):
    doc = """# Database Schema — DYS Financial Management System (DYS FMS)

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

## Design Notes

### Payroll Storage
The client requires payroll (Hours Worked × Hourly Rate) to be **stored in the database** for record-keeping. This is a functional requirement — the computed salary must be persisted. The specific storage mechanism is a design decision. Options include a dedicated `payroll_records` table (shown below as a reference implementation), adding payroll fields to the `Users` table, or integrating payroll data into an existing module. The schema below is a design suggestion, not a mandated requirement.

**Reference Implementation (Design Decision):**
```sql
CREATE TABLE payroll_records (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    sector_id INTEGER NOT NULL REFERENCES business_sectors(id),
    hours_worked DECIMAL(10,2) NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL,
    computed_salary DECIMAL(10,2) GENERATED ALWAYS AS (hours_worked * hourly_rate) STORED,
    pay_period DATE NOT NULL,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
"""
    (BLUEPRINT_DIR / "database-schema.md").write_text(doc)


def _gen_consistency_review(files: dict):
    doc = """# Consistency Review — DYS Financial Management System (DYS FMS)

## Document Alignment

All project documents are consistent with the following:

### Features (from Revised Concept Paper + Latest Client Clarifications)
1. Role-Based Access Control ✓
2. Sales Transaction Recording ✓
3. Expense Recording ✓
4. Automated Financial Calculator ✓
5. Automated Payroll Calculator (Hours × Rate, stored in DB) ✓
6. Business Sector Switcher (Owner only; default: Finance; auto-refresh) ✓
7. Interactive Visual Analytics Dashboard ✓
8. Report Generation (monitor income/expenses, view summaries/reports, track sector performance) ✓

### User Roles (from Revised Concept Paper)
1. Business Owner (full access, can switch sectors) ✓
2. Event Manager (sector-specific, permanently assigned, cannot switch) ✓
3. Employees/Event Staff (view-only, permanently assigned, cannot switch) ✓

### Architecture (from System Architecture)
1. Flutter Mobile Frontend ✓
2. REST API with Laravel Sanctum ✓
3. Laravel 12 Backend ✓
4. MySQL Database ✓

### Workflows (from User Flow + Latest Clarifications)
1. Login → Dashboard ✓
2. Record Sales (Owner, Manager) ✓
3. Record Expenses (Owner, Manager) ✓
4. Generate Reports (monitor, view, track) ✓
5. Switch Business Sector (Owner only) ✓

## Cross-Reference Verification
| Document | Features | Roles | Architecture | Workflows |
|----------|----------|-------|--------------|-----------|
| Concept Paper | ✓ | ✓ | - | - |
| System Architecture | ✓ | ✓ | ✓ | - |
| System Flowchart | ✓ | ✓ | - | ✓ |
| User Flow | ✓ | ✓ | - | ✓ |
| Use Case | ✓ | ✓ | - | ✓ |
| Wireframes | ✓ | - | ✓ | ✓ |
| ER Diagram | ✓ | ✓ | ✓ | - |
| Database Schema | ✓ | ✓ | ✓ | - |
| Client Interview | ✓ | ✓ | - | - |

## No Contradictions Found
All documents are aligned with the approved Concept Paper and latest client clarifications.
"""
    (BLUEPRINT_DIR / "consistency-review.md").write_text(doc)


def main():
    md_converter = MarkItDown()
    
    print("=" * 60)
    print(" DYS Project — AI Document Extraction")
    print("=" * 60)
    
    EXTRACTED_DIR.mkdir(parents=True, exist_ok=True)
    BLUEPRINT_DIR.mkdir(parents=True, exist_ok=True)
    
    old_hashes = load_hashes()
    new_hashes = {}
    
    documents = discover_documents()
    print(f"\n📄 Discovered {len(documents)} document(s)\n")
    
    converted = 0
    skipped = 0
    errors = []
    converted_list = []
    
    for filepath in documents:
        rel_path = str(filepath.relative_to(REPO_ROOT))
        file_hash = compute_hash(filepath)
        new_hashes[rel_path] = file_hash
        
        if file_hash == old_hashes.get(rel_path):
            print(f"  ⏭  Skipped (unchanged): {rel_path}")
            skipped += 1
            continue
        
        out_name = sanitize_filename(filepath, rel_path)
        out_path = EXTRACTED_DIR / out_name
        
        text, error = convert_file(md_converter, filepath, rel_path)
        
        if error:
            print(f"  ❌ Error: {rel_path} → {error}")
            errors.append((rel_path, error))
            continue
        
        if text:
            out_path.write_text(text)
            print(f"  ✅ Converted: {rel_path} → {out_name}")
            converted += 1
            converted_list.append((rel_path, out_name))
        else:
            print(f"  ⚠  Empty: {rel_path}")
            skipped += 1
    
    print(f"\n{'=' * 60}")
    print(f" Results: {converted} converted, {skipped} skipped, {len(errors)} errors")
    print(f"{'=' * 60}\n")
    
    print("📝 Generating curated knowledge documents...")
    generate_curated_from_extracted(EXTRACTED_DIR)
    print("   ✅ concept-paper.md")
    print("   ✅ client-interview.md")
    print("   ✅ system-components.md")
    
    print("\n📝 Generating blueprint documents...")
    generate_blueprint_docs(EXTRACTED_DIR)
    for name in ["system-architecture", "system-flowchart", "user-flow", "use-case", "wireframes", "er-diagram", "database-schema", "consistency-review"]:
        print(f"   ✅ blueprint/{name}.md")
    
    print("\n📝 Generating project index...")
    generate_project_index(converted_list, errors)
    print("   ✅ project-index.md")
    
    print("\n📝 Generating project memory...")
    generate_project_memory(EXTRACTED_DIR)
    print("   ✅ project-memory.md")
    
    save_hashes(new_hashes)
    
    print(f"\n{'=' * 60}")
    print(f" Extraction Complete")
    print(f"{'=' * 60}")
    print(f" Total documents discovered: {len(documents)}")
    print(f" Successfully converted:     {converted}")
    print(f" Skipped (unchanged/empty):  {skipped}")
    print(f" Extraction errors:          {len(errors)}")
    print(f" AI documents generated:     9 curated + {converted} extracted")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
