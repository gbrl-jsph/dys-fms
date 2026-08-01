# Concept Paper — DYS Financial Management System (DYS FMS)

Related:
- client-interview.md
- project-memory.md
- project-index.md
- blueprint/use-case.md
- AI_INSTRUCTIONS.md

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
- User Account Management (Business Owner only — creates and manages all Event Manager and Employee accounts; assigns role and business sector; generates temporary credentials; activates/deactivates accounts; no public or self-registration)
- Sales and Expense Recording
- Automated Financial Calculator
- Automated Payroll Calculator (Hours Worked × Hourly Rate; computed salary stored permanently, viewable historically, automatically creates an Expense record)
- Business Sector Switcher (Owner only; Owner default sector: DYS Event Management; auto-refreshes Dashboard, Sales, Expenses, Reports on switch)
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
- Business Owner creates all Event Manager and Employee accounts; there is no public registration or self-registration
- Only the Business Owner can activate or deactivate user accounts
- Only the Business Owner can calculate payroll
- Business Owner can view payroll for every employee
- Event Managers cannot calculate payroll and can view only their own payroll (not other employees' payroll)
- Employees/Event Staff cannot calculate payroll and can view only their own payroll (not other employees' payroll)
- Only Business Owners and Event Managers can record sales/expenses
- Business sector switching is available to Business Owner only
- Event Managers and Employees are permanently assigned to one business sector
- Business Owner's default sector on login is DYS Event Management
- Event Managers and Employees default to their assigned business sector on login
- Switching sectors auto-refreshes Dashboard, Sales, Expenses, and Reports
- Payroll is calculated as Hours Worked × Hourly Rate, stored permanently, viewable historically, and automatically creates an Expense record

## Source Excerpts

**CENTRAL LUZON STATE UNIVERSITY**
Science City of Muñoz
Nueva Ecija
Development of a Centralized Financial Transaction Monitoring and Management System for DYS Event Management
Concept Paper
Herrera, Samantha Ysabella G.
Cacalda, Krizeth Joi C.
Lopez, Cassandra I.
Miranda, Gabriel Joseph A.
Oca, Bea Marie M.
Santiago, Mariah Nicole M.
1st Semester of SY 2026-2027
**PROJECT OVERVIEW**
This project aims to develop a centralized financial transaction monitoring system for DYS Event Management. At present, the business relies on a manual process to record transactions and cash flows across its four branches, which is inefficient, disorganized, and vulnerable to human error. The lack of a unified platform makes it difficult to track inflows and outflows accurately, often resulting in discrepancies and reduced transparency in financial records. By introducing a digital system that consolidates all transaction data, the project will enable real-time monitoring of cashflows, minimize risks of mismanagement, and ensure accountability across branches. The overall objective is to provide DYS Event Management with a reliable tool to streamline financial tracking, enhance transparency, and support better decision-making for sustainable growth.
**PROBLEM STATEMENT**
The DYS event management faces problems in monitoring their financial transactions because they do not have a centralized platform to track all of the cash inflows and outflows in the business. This lack of proper tracking hinders the effective expense management and compromises financial transparency. If left unresolved, the problem may result in unnoticed errors, potential fraud, and a decline in trust toward financial reporting and overall financial stability. Addressing this issue is crucial, as reliable financial monitoring ensures accountability, and prevents mismanagement of funds.
**PROPOSED SOLUTION**
The DYS Sales Tracking System is a mobile application designed to help DYS Event Management record, organize, and monitor sales transactions, business expenses and other financial records in a centralized platform. The application will enable the owner and authorized department heads to record daily transactions and expenses. It will also have a feature to automatedly compute the total sales and expenses based on the records to improve accuracy of financial records. In addition, the system will allow the owner user to easily switch between the financial records of the different branches of DYS Event Management.
The mobile application is designed to address the challenges experienced by the business owner in managing sales and expenses records. Since transactions are currently recorded through handwritten notes, receipts, and Messenger conversation, the important information may be forgotten, misplaced, or be recorded inaccurately, especially during busy schedules. By storing all transaction records in one application, users can conveniently access, update, and monitor records anytime using their mobile devices. The system will also include role-based access for authorized users and visual reports such as graphs and charts to provide a clearer summary of sales and expenses.
**TARGET USER**
The proposed system will primarily benefit the **Business Owner** by providing easier access to financial records, automated payroll, and monitor business performance visually across different business sectors. The **Event Managers** will benefit from secure access to financial data based on their specific branch, which allows them to track budgets and items, and to reduce manual effort in calculating daily logs and team sales. As for the **Employees**, they will experience faster transaction recording, reduced paperwork, and greater transparency in salary computations through automated payroll processing.
**MAJOR FEATURES**
An **automated financial calculator** and **payroll calculator** that automatically computes daily sales, expenses, and salary computations to eliminate manual accounting errors. A **role-based access control** to protect sensitive financial information and employee records by restricting system access to authorized personnel. Additionally, a **business sector switcher** enables users to toggle between different business branches within a single interface, while an **interactive visual analytics dashboard** transforms raw data into real-time charts and graphs for quick performance monitoring.
**SOFTWARE ENGINEERING CHALLENGES**
First is **data security**, the system stores confidential business information, such as the financial data used by several people at once, creating a possibility of unauthorized access and changes. To address this, the system needs user authentication, role-based access control, encryption of passwords, and regular backups. Second is **user adoption**, as DYS Event Management has long relied on manual tracking of financial records, from physical notes to Messenger conversations, the system requires careful system planning so clients can adopt the system into their work process seamlessly with little to no difficulty. Lastly is **data migration**, the existing financial records are stored in different formats across different platforms and may be incomplete or inconsistent. Migrating these records into the new system requires careful validation to ensure data accuracy and integrity. Without proper validation, inaccurate or missing data may reduce the reliability of the system and affect the business.
**PROJECT CONSTRAINTS**
As student developers, the team faces **time**, **budget**, and **limited technical experience challenges** that directly affect the project’s development scope. The system must be completed within approximately six months while the team continuously balances a full academic workload. Budget limitations further constrain the project, requiring reliance on free, open-source software and development tools rather than premium cloud infrastructure or paid third-party integrations. Additionally, as student developers with evolving skill sets, the team faces limited technical experience in implementing advanced functionalities such as role-based access control, automated financial computations, interactive data visualization, and multi-branch database management.
