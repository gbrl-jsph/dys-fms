# Client Interview — DYS Financial Management System (DYS FMS)

Related:
- concept-paper.md
- project-memory.md
- project-index.md
- blueprint/use-case.md

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

## Business Processes (AS-IS — Current Manual Process)
- Business Owner oversees all sectors
- Manager / Head handles day-to-day operations within assigned sectors; supervises Employees / Event Staff; reviews financial reports within their assigned sector range
- Employees / Event Staff perform operational tasks including manually recording expense details when assigned (e.g., purchasing supplies, recording via notes, receipts, Messenger)
- Event Manager can perform the same expense-recording activity as Employees when assigned

*Note (2026-08-25): This AS-IS process description was clarified by authoritative confirmation. The proposed digital system's RBAC does not automatically mirror all AS-IS activities — "Record Expenses" in the proposed system remains restricted to Business Owner and Event Manager.*

## Important Notes
- The system must support multiple business sectors under a single organization
- Financial data must be secured by role
- Payroll calculations must be automated and role-visible

## Interview Excerpts

**Interview With Mrs. Divine Samonte ( DYS Events Management Owner)**
**1. How do you currently record and track your sales transactions?**
I have my own bookkeeper who records most of my sales transactions. Sometimes, I also keep written notes or communicate with my employees who I assign to buy supplies then message me the expenses through messenger.
**2. What challenges do you encounter in monitoring and managing your records?**
DYS Events Management offers different services such as full event coordination, event styling, grazing tables, celebration drink, video guestbooks, and souvenirs. Since the business has several sectors I sometimes forget to record some expenses. There are times I lost receipts, forget to write down business expenses, or forgot, or inform my bookkeeper.
My schedule is also very busy because I have meetings with clients, suppliers, and my staff. When my appointments are back to back, I sometimes forget to record business expenses.
**3. What features would you like to have in a Sales Tracker Management System?**
If you're creating a customized sales tracker for my business, I would like to have an **automatic calculator** for daily sales transactions. It should automatically compute my employee salaries, expenses, product prices, quantities, and total sales with the date that is recorded.
Since I manage multiple business sectors, **I also want my department heads or manager to have access to the system** with limited permission to protect sensitive information.
I would also like a system to **allow me to switch easily between my different business sectors**:
DYS Events(main branch) – Event coordination and styling
B&DYS – Souvenirs
Flavors by DYS – Grazing tables and celebration drinks
SnapDYS Memories – Video guestbook
\*Additional suggestion from interviewer(Bea)
I suggest adding a bar graph or pie chart to the system so that sales, expenses, and other records can be presented in a more organized and easy to understand **visual format.**
