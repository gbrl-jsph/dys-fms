# Activity Diagram Documentation — Current Business Process (As-Is)

**Project:** DYS Financial Management System (DYS FMS)  
**Deliverable:** Case Study #4 — Activity Diagram (Deliverable 1)  
**Version:** 11.0 (Single rejoin, clean merges, shared operational note)  
**Status:** Updated — Waiting for Approval  
**Date:** August 25, 2026  

---

## 1. Overview & Objective

This Activity Diagram models the **current manual business process** (As-Is) of DYS Event Management. It is derived strictly from the authoritative project sources:
* **Client Interview with Mrs. Divine Samonte** (Owner/Operator of DYS Event Management)
* **Official Revised Concept Paper** (`memory/concept-paper.md` / `8 - Research/Concept Paper Revision.docx`)
* **Project Memory & AI Instructions** (`memory/project-memory.md`, `memory/AI_INSTRUCTIONS.md`)
* **New PO Clarification (Aug 2026):** Employee/Event Staff can record expenses; Manager/Head shares same operational responsibilities as Employees/Event Staff, additionally supervises employees and reviews sector-scoped financial reports; supervision is **not** mandatory per expense; expense-recording ability must be shown for **both** roles without implying exclusivity.

It visually depicts how sales, expenses, and payroll are currently managed manually across multiple business sectors without a centralized application or database. It contains **no proposed-system features** (no login, mobile app, automated calculations, database transactions, RBAC, or digital sector switching).

---

## 2. Swimlanes (Actors Involved — 4 Levels)

| Swimlane (left→right) | Actor / Role | Description & Responsibilities in Current Process | Source Reference |
|---|---|---|---|
| 1 | **Employees / Event Staff** | Operational staff who purchase event/operational supplies, **record expense details**, and communicate expense amounts and physical receipts to the Business Owner via Facebook Messenger. | Interview Q1, Q2; Concept Paper; New Clarification (can record) |
| 2 | **Manager/Head** | Department/branch head — performs **same operational responsibilities as Employees/Event Staff** (purchase supplies, record expense details when assigned), **supervises employees/event staff** as a separate responsibility (not per-transaction mandatory), and **reviews financial reports within assigned sector range**. | New PO Clarification; Concept Paper |
| 3 | **Business Owner** | Mrs. Divine Samonte — oversees all four business sectors, determines transaction types, forwards sales/expense data, receives receipts via Messenger, keeps personal notes, reviews disparate financial records across all sectors, and manually calculates employee salaries. | Interview Q1, Q2, Q3; Concept Paper |
| 4 | **Bookkeeper** | Independent accounting personnel who manually records sales and forwarded business expenses into physical/manual ledgers upon receiving details from the Business Owner. | Interview Q1, Q2 |

Lane order `Employees | Manager | Business Owner | Bookkeeper` places Business Owner centrally — the hub for all handoffs — so `Business Owner ↔ Bookkeeper` (Sales and Forward-Yes) and `Employees → Business Owner` (Messenger) are single-lane adjacent short transitions. Manager lane is adjacent to Employees for supervision context and to Business Owner for report review.

*Note:* Manager/Head is a current-process participant only where supported by the clarification above; no login/RBAC/database/automation is implied.

---

## 3. End-to-End Workflow & Process Steps

Single top-to-bottom flow with one clean rejoin after Sales/Expense alternatives (preferred over duplicated tails). The expense operational activity is phrased to show **shared responsibility without duplication**.

```
[Start] (Business Owner)
   │
   ▼
[Business transaction occurs across business sector] (DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories)
   │
   ▼
[Determine transaction type]
   │
   ├── (Sales) ───────► [Receive sales details or keep handwritten notes] (Owner)
   │                        │
   │                        ▼
   │                    [Forward sales info to Bookkeeper] (Owner)
   │                        │
   │                        ▼
   │                    [Record sales in ledger] (Bookkeeper)
   │                        │
   │                        └─────────────┐
   │                                     │
   └── (Expense) ─────► [Purchase supplies and record expense details] (Employees)
   │                        │  Note: Performed by Employees/Event Staff
   │                        │        or Manager/Head when assigned
   │                        ▼
   │                    [Send expense details and receipt via Messenger] (Employees)
   │                        │
   │                        ▼
   │                    [Receive expense info and receipt] (Owner)
   │                        │
   │                        ▼
   │                    <Forward to Bookkeeper?>
   │                         │          │
   │                      (yes)        (no)
   │                         │          │
   │                         ▼          ▼
   │                [Forward expense    [Keep in personal notes] (Owner)
   │                 to Bookkeeper]     *Risk: forgotten expenses/lost receipts*
   │                 (Owner)                │
   │                         │              │
   │                         ▼              │
   │                [Record expense         │
   │                 in ledger]            │
   │                (Bookkeeper)           │
   │                         │              │
   │                         └──────┬───────┘
   │                                │ (Inner Merge in Business Owner lane)
   │                                ▼
   └────────────────────────────────┘
                                    │ (Outer Merge in Business Owner lane)
                                    ▼
                    [Review manual records across disparate sources] (Owner)
                                    │
                                    ▼
                    [Supervise employees/event staff] (Manager/Head)
                    Note: Separate responsibility (not per-transaction)
                                    │
                                    ▼
                    [Review financial reports within assigned sector range] (Manager/Head)
                                    │
                                    ▼
                    [Manually calculate salary: Hours x Hourly Rate] (Owner)
                                    │
                                    ▼
                    [Financial information remains across notes, receipts, Messenger, and ledger]
                                    │
                                    ▼
                                  [Stop]
```

### Detailed Step Breakdown:

1. **Initial Trigger:** A business transaction occurs within one of the four business branches (*DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories*).
2. **Transaction Classification:** The Business Owner determines if the transaction represents incoming revenue (**Sales**) or outgoing operational cost (**Expense**).
3. **Sales Path:**
   - The Business Owner receives sales details or writes notes.
   - The Business Owner forwards the sales details to the Bookkeeper.
   - The **Bookkeeper** manually records the sales entry into the ledger.
4. **Expense Path:**
   - **Purchase supplies and record expense details** — single activity with note *“Performed by Employees/Event Staff or Manager/Head when assigned”* — clearly shows **both** roles can perform the operation without duplicating the same activity or implying exclusivity.
   - Employees send expense figures and photo receipts to the Business Owner via Facebook Messenger.
   - The Business Owner receives the expense details and receipt.
   - **Decision Point:** *Forward to Bookkeeper?*
     - **Yes Branch:** The Business Owner forwards the expense to the Bookkeeper → the **Bookkeeper** records the expense in the ledger.
     - **No Branch:** Due to busy schedules, the Business Owner keeps the receipt/details in personal notes. *(Risk: forgotten expenses and lost receipts).*
   - **Inner Merge:** Joins the two expense forwarding alternatives **in the Business Owner lane** (short connector, no cross-lane horizontals).
5. **Outer Merge:** Joins the Sales branch and the merged Expense branch **in the Business Owner lane** — clean, centered rejoin before the common tail (no floating diamond across lanes).
6. **Common Tail (single, not duplicated):**
   - **Business Owner** reviews manual records across disparate sources.
   - **Manager/Head** supervises employees/event staff — shown as **separate Manager responsibility after the rejoin** with note *“Separate responsibility (not per-transaction)”* — visually simple, not inserted as mandatory `Employee → Manager → Owner` step in the expense handling sequence.
   - **Manager/Head** reviews financial reports within assigned sector range — clearly inside Manager/Head lane, distinct from Owner’s fragmented review.
   - **Business Owner** manually calculates employee salaries using $\text{Hours Worked} \times \text{Hourly Rate}$.
   - **Financial information remains fragmented** across notes, receipts, Messenger, and ledger → `Stop`.

---

## 4. UML 2.x Semantics & Diagram Structure

### 4.1 Decision and Merge Nodes
* **2 Decision Diamonds (retained, legitimate):**
  1. `Transaction type?` → guards `[Sales]` vs `[Expense]`.
  2. `Forward to Bookkeeper?` → guards `[yes]` vs `[no]`.
* **2 Merge Diamonds (cleanly positioned):**
  * **Inner merge** (Forward Yes/No) and **outer merge** (Sales/Expense) both reside **in the Business Owner lane** (`x≈1123/1254`, gap 131px, short vertical). No empty diamond floats across lanes or over notes/activities. Only the 2 legitimate decisions + their 2 required merges are visible (SVG: 2× 14-point decision hexagons + 2× 10-point merges).

### 4.2 Grouped Cross-Swimlane Handoffs (short, adjacent only)
1. **Business Owner → Bookkeeper:** Forwarding sales/expense details (adjacent, Sales and Forward-Yes) — short vertical after lane switch.
2. **Employees → Business Owner:** Employees communicating expense figures and receipts via Messenger (Employees lane → Business Owner lane via single Manager lane gap, short horizontal, no text crossing).
3. **Business Owner → Manager/Head → Business Owner:** Common tail (Review → Supervise → Review sector reports → Calculate) — each adjacent.

All handoffs are at most one lane apart; no arrow spans multiple lanes, no arrow crosses activity/note.

### 4.3 Notes Without Interference
* **Sector note** — right of Business Owner start activity, no arrow crossing.
* **Expense risk note** — right of `Keep in personal notes` in Business Owner lane, no arrow crossing.
* **Shared operational note** — right of `Purchase supplies and record expense details` in Employees lane, clarifies both Employees and Manager can perform without duplicating activity.
* **Supervision note** — right of `Supervise employees/event staff` in Manager lane, clarifies separate non-mandatory responsibility.

---

## 5. Verification & Consistency Audit

| Verification Item | Requirement | Status | Evidence / Source |
|---|---|:---:|---|
| **As-Is Scope Only** | Zero proposed-system features | **PASS** | Manual notes/receipts/Messenger/ledger/supervision |
| **Employees Can Record** | Employees/Event Staff can record expenses | **PASS** | :Purchase supplies and record expense details in Employees lane + shared note |
| **Manager Can Also Record** | Manager/Head same operational as Employees | **PASS** | Shared note: Performed by Employees or Manager when assigned (no exclusivity, no duplicate box) |
| **Manager Supervision Separate** | Supervision not mandatory per expense | **PASS** | Supervise placed after outer merge in common tail with note Separate responsibility (not per-transaction), not in Employee→Manager→Owner expense chain |
| **Manager Sector Report Review** | Manager reviews sector-scoped reports | **PASS** | :Review financial reports within assigned sector range in Manager lane, distinct from Owner’s review |
| **Business Owner Unchanged** | Determine type, receive, forward, keep notes, review fragmented records, calculate salary | **PASS** | All retained in Business Owner lane |
| **Bookkeeper Unchanged** | Manual ledger recording only | **PASS** | Only :Record sales/expense in ledger in Bookkeeper lane |
| **Four Swimlanes** | Employees, Manager, Business Owner, Bookkeeper | **PASS** | Exact names, left→right Employees\|Manager\|Business Owner\|Bookkeeper |
| **Four Sectors Preserved** | DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories | **PASS** | Note on start activity |
| **No Proposed-System Features** | No login/RBAC/dashboard/DB/automation | **PASS** | No such elements |
| **No Duplicate Activities** | Shared operational activity not duplicated | **PASS** | Single Purchase/Record activity + note |
| **No Long Cross-Lane Arrows** | Minimal switching, short adjacents | **PASS** | SVG: 2 decisions + 2 merges both in BO lane, short connectors |
| **PlantUML Syntax** | Zero errors, clean compilation | **PASS** | SVG 21,478 bytes / PNG 46,197 bytes |
| **Academic Quality** | Presentation-ready for COMSCI 3100 | **PASS** | Single top-to-bottom flow, symmetrical branches, clean rejoin |

---

## 6. Rendering & Submission Guide

* **Source File:** [`Case Study 4 - UML Modeling/Activity_Diagram_Current_Process.puml`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Activity_Diagram_Current_Process.puml)
* **Vector Render:** [`Case Study 4 - UML Modeling/Activity_Diagram_Current_Process.svg`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Activity_Diagram_Current_Process.svg)
* **Raster Render:** [`Case Study 4 - UML Modeling/Activity_Diagram_Current_Process.png`](file:///home/deck/Desktop/Vault/Case%20Study%204%20-%20UML%20Modeling/Activity_Diagram_Current_Process.png)
* **Rendering Tools:**
  1. **PlantUML Online / Server:** Paste `.puml` into [plantuml.com/plantuml](http://www.plantuml.com/plantuml/) or [planttext.com](https://www.planttext.com/) to export high-resolution PNG/SVG.
  2. **VS Code:** Open `.puml` with PlantUML extension (`jebbs.plantuml`) → `Alt+D` preview → Export.

---

*Deliverable 1 refined to v11.0 for COMSCI 3100 Case Study #4 per new PO clarification and visual-quality refinement — single rejoin, clean merges, no mandatory supervision chain; Use Case/Class diagrams intentionally unchanged in this task.*

