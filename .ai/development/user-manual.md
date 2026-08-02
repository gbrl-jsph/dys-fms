# User Manual — DYS Financial Management System (DYS FMS)

**Document:** User Manual
**Audience:** End users of the application (Business Owner, Event Managers, Employees/Staff)
**Basis:** Approved project documents and the implemented application
**Version:** 1.0

---

## 1. Introduction

### 1.1 System overview

The DYS Financial Management System (DYS FMS) is an application that helps DYS run its four business sectors:

- **B&DYS**
- **DYS Events**
- **Flavors by DYS**
- **SnapDYS Memories**

The system keeps track of sales, expenses, payroll, and business performance. All amounts are shown in Philippine Pesos (₱).

### 1.2 Purpose

The system gives the Business Owner a single place to:

- See how each business sector is performing at a glance
- Record sales and expenses
- Calculate payroll
- Generate reports
- Manage user accounts
- Switch the active business sector

Event Managers use the system to record sales and expenses for their sector and to view payroll and reports. Employees use the system to see their own payroll records.

### 1.3 Intended users

- The **Business Owner** of DYS (primary user)
- **Event Managers** assigned to each business sector
- **Employees/Staff** of DYS

### 1.4 Supported user roles

| Role | What the role can do |
|------|----------------------|
| **Business Owner** | Everything: Dashboard, Sales, Expenses, Payroll (record and view), Reports, User Management, Business Sector switching, Logout |
| **Event Manager** | Dashboard, Sales, Expenses, Payroll (view only), Reports, Logout |
| **Employee/Staff** | Dashboard, Payroll (view only their own records), Logout |

---

## 2. Getting Started

### 2.1 Logging in

1. Open the DYS FMS application. The Login screen appears.
2. Enter your **Email** address.
3. Enter your **Password**.
4. Press **Log In**.

You are taken to your Dashboard. The menus you see depend on your role.

> If you enter a wrong email or password, the app shows "Invalid username or password." Check your details and try again.

### 2.2 Dashboard overview

The Dashboard is the first screen after logging in. It shows:

- **Total Sales** — total sales for the current sector
- **Total Expenses** — total expenses for the current sector
- **Net Balance** — sales minus expenses (the remaining amount)
- **Quick Actions** — shortcuts to the screens you use most, based on your role
- Your name, role, and current business sector at the top

### 2.3 Navigation

Use the menu bar at the bottom of the screen to move between sections:

| Role | Menu items |
|------|-----------|
| Business Owner | Dashboard, Sales, Expenses, Payroll, Users, Reports |
| Event Manager | Dashboard, Sales, Expenses, Payroll, Reports |
| Employee/Staff | Dashboard, Payroll |

The menu always shows Dashboard first. Tap an item to open that section.

### 2.4 Logging out

1. Tap your avatar (profile picture) at the top of the Dashboard.
2. Choose **Logout** from the menu.
3. You are returned to the Login screen. Your session is closed, and you can close the app or hand the device to the next user.

---

## 3. Business Owner Guide

The Business Owner can use every part of the system. All steps below apply to the Business Owner account only.

### 3.1 Dashboard

1. After logging in, the Dashboard shows the summary for the current business sector.
2. Check **Total Sales**, **Total Expenses**, and **Net Balance** for the active sector.
3. The sector chip at the top shows which sector the Dashboard is viewing. Tap it to open the Sector Switcher.
4. Use **Quick Actions** to jump to User Management, Sales, Expenses, Payroll, or Reports.

### 3.2 User Management

1. Tap **Users** in the bottom menu.
2. To add an account, fill in the form (only available to the Business Owner):
   - **Name** — the person's full name
   - **Email** — the email they will use to log in
   - **Role** — choose **Event Manager** or **Employee/Staff** (you cannot create another Business Owner)
   - **Sector** — the business sector the person belongs to
3. Press **Generate Temporary Password** to create a temporary password for the new account. The app shows it in a message — note it down and give it to the new user.
4. Press **Save Account**. A message confirms the account was created.
5. To edit an account, tap the account in the list, change the details, and press **Save Account** again.
6. To stop a person from logging in, press **Deactivate** on their account. To let them back in, press **Activate**. Accounts are deactivated, not deleted.

> Tip: New accounts receive a temporary password, as noted in the form. Share it with the employee so they can log in.

### 3.3 Sales Recording

1. Tap **Sales** in the bottom menu.
2. Enter the **Amount** of the sale.
3. Enter a **Description** (what was sold).
4. Choose the **Sector** the sale belongs to.
5. Press **Record Sale**. A message confirms the sale was recorded, and the Dashboard totals update to include it.

### 3.4 Expense Recording

1. Tap **Expenses** in the bottom menu.
2. Enter the **Amount** of the expense.
3. Enter a **Description** (what the money was spent on).
4. Choose the **Sector** the expense belongs to.
5. Press **Record Expense**. A message confirms the expense was recorded.

### 3.5 Payroll Calculation

1. Tap **Payroll** in the bottom menu.
2. Choose the **Employee** from the list.
3. Enter **Hours Worked** for the pay period.
4. Enter the **Hourly Rate** for that employee.
5. Pick the **Pay Period** end date (the date the pay period ends).
6. Press **Save Payroll Record**.

The app calculates the salary (hours × rate), saves the payroll record, and automatically creates an Expense record for the salary. The payroll record is stored permanently and cannot be changed later, so double-check the hours, rate, and pay period before saving.

### 3.6 Reports

1. Tap **Reports** in the bottom menu.
2. Choose a **Report Type**:
   - **Financial Summary** — overall summary for the selected sector
   - **Sales** — sales figures
   - **Expenses** — expense figures
   - **Payroll Expenses** — payroll figures
   - **Analytics** — charts for the selected sector
3. Choose the **Sector**. **All Sectors** generates a cross-sector report (this option is only available to the Business Owner).
4. Pick **From** and **To** dates for the report period (format: MM/DD/YYYY).
5. Press **Generate Report**. The report appears below with the figures and charts.

### 3.7 Business Sector Switching

1. Tap the sector chip at the top of the Dashboard (or open the Sector Switcher from the Dashboard).
2. The **Switch Business Sector** screen shows the four sectors: B&DYS, DYS Events, Flavors by DYS, and SnapDYS Memories.
3. The current sector is marked **Active**.
4. Tap the sector you want to switch to, then press **Switch Sector**.
5. The app switches immediately and returns you to the Dashboard, which now shows the new sector's totals. Sales, Expenses, Payroll, and Reports also follow the new sector.

### 3.8 Logout

1. Tap your avatar at the top of the Dashboard.
2. Choose **Logout**.
3. You are returned to the Login screen.

---

## 4. Event Manager Guide

This section covers only the features available to Event Managers.

### 4.1 Login

1. Open the DYS FMS application.
2. Enter the **Email** and **Password** your Business Owner gave you.
3. Press **Log In**. You land on your Dashboard.

### 4.2 Dashboard

Your Dashboard shows **Total Sales**, **Total Expenses**, and **Net Balance** for **your assigned sector only**. The sector chip at the top shows your sector and is read-only — Event Managers cannot switch sectors. Use the **Quick Actions** to jump to Sales, Expenses, Payroll, or Reports.

### 4.3 Sales

1. Tap **Sales** in the bottom menu.
2. Enter the **Amount** and a **Description**.
3. Press **Record Sale**. The sale is recorded under your assigned sector — you do not choose the sector yourself.

### 4.4 Expenses

1. Tap **Expenses** in the bottom menu.
2. Enter the **Amount** and a **Description**.
3. Press **Record Expense**. The expense is recorded under your assigned sector.

### 4.5 Payroll (view)

1. Tap **Payroll** in the bottom menu.
2. You can view the payroll records for your sector. Only the Business Owner can calculate payroll, so the form to create payroll records is not shown to you.

### 4.6 Reports

1. Tap **Reports** in the bottom menu.
2. Choose a **Report Type** (**Financial Summary**, **Sales**, **Expenses**, or **Payroll Expenses** — Analytics is for the Business Owner only).
3. Your reports are scoped to your assigned sector; you do not choose the sector.
4. Pick **From** and **To** dates, then press **Generate Report**.

### 4.7 Logout

1. Tap your avatar at the top of the Dashboard.
2. Choose **Logout**. You are returned to the Login screen.

---

## 5. Employee Guide

This section covers only the features available to Employees/Staff.

### 5.1 Login

1. Open the DYS FMS application.
2. Enter the **Email** and **Password** your Business Owner gave you.
3. Press **Log In**. You land on your Dashboard.

### 5.2 Dashboard

Your Dashboard shows the read-only sector chip and the **View Payroll** quick action. The **Total Sales**, **Total Expenses**, and **Net Balance** summary cards are shown only to Business Owners and Event Managers; as an Employee you do not see financial totals. The **View Payroll** quick action takes you to your payroll records.

### 5.3 Payroll viewing

1. Tap **Payroll** in the bottom menu.
2. You can only view **your own** payroll records — the hours worked, hourly rate, and computed salary for each pay period. Payroll is calculated by the Business Owner.

### 5.4 Logout

1. Tap your avatar at the top of the Dashboard.
2. Choose **Logout**. You are returned to the Login screen.

---

## 6. Screen Guide

### 6.1 Login Screen

- **Purpose:** Sign in to the application.
- **Main controls:** Email field, Password field, Show/Hide password toggle, **Log In** button.
- **Expected behavior:** After a successful login you are taken to your Dashboard. The menu you see depends on your role.
- **Validation messages:**
  - "Email is required." — the Email field was left empty
  - "Enter a valid email address." — the email format is not valid
  - "Password is required." — the Password field was left empty
  - "Invalid username or password." — the email or password is wrong (shown by the app after you press Log In)

### 6.2 Dashboard Screen

- **Purpose:** Shows the current sector's financial summary and shortcuts to other sections.
- **Main controls:** Summary cards (**Total Sales**, **Total Expenses**, **Net Balance** — Business Owner and Event Manager only), sector chip (top), Quick Actions, avatar menu (**Profile**, **Logout**).
- **Expected behavior:**
  - Business Owner: tappable sector chip (opens the Sector Switcher), Quick Actions include **Manage Users**, **Record Sale**, **Record Expense**, **View Payroll**, and **View Reports**.
  - Event Manager: read-only sector chip, Quick Actions include **Record Sale**, **Record Expense**, **View Payroll**, and **View Reports** (no Manage Users). Summary cards are shown but the Sales Overview chart is not.
  - Employee/Staff: no summary cards — only the read-only sector chip and the **View Payroll** quick action.
- **Validation messages:** None — this screen displays information only.

### 6.3 Sales Screen

- **Purpose:** Record a sale for a business sector.
- **Main controls:** **Amount** field, **Description** field, **Sector** selector (Business Owner only), **Record Sale** button.
- **Expected behavior:** After recording, the app shows "Sale recorded successfully." and the Dashboard totals update.
- **Validation messages:**
  - "Amount is required."
  - "Amount must be a positive number."
  - "Sector is required." (Business Owner — shown when no sector is chosen)

### 6.4 Expenses Screen

- **Purpose:** Record an expense for a business sector.
- **Main controls:** **Amount** field, **Description** field, **Sector** selector (Business Owner only), **Record Expense** button.
- **Expected behavior:** After recording, the app shows "Expense recorded successfully." and the Dashboard totals update.
- **Validation messages:**
  - "Amount is required."
  - "Amount must be a positive number."
  - "Sector is required." (Business Owner — shown when no sector is chosen)

### 6.5 Payroll Screen

- **Purpose:** Calculate and save payroll records (Business Owner) or view payroll records (all roles).
- **Main controls:**
  - Business Owner: **Employee** selector, **Hours Worked** field, **Hourly Rate** field, **Pay Period** date picker, **Save Payroll Record** button, and the payroll records list.
  - Event Manager: payroll records list only (with a note that only the Business Owner can calculate payroll).
  - Employee/Staff: their own payroll records list only.
- **Expected behavior:**
  - The salary is computed as hours × rate, saved, and an Expense record is automatically created — the screen explains this: "Computed salary (hours × rate) is calculated and saved by the system, and an Expense record is auto-created."
  - Payroll records are immutable and stored permanently, so review the values before saving.
  - When there are no records, the screen shows "No payroll records yet."
- **Validation messages:**
  - "Employee is required."
  - "Hours worked is required." / "Hours worked must be a positive number." / "Hours worked must not exceed 99999999.99."
  - "Hourly rate is required." / "Hourly rate must be a positive number." / "Hourly rate must not exceed 99999999.99."
  - "Pay period is required."

### 6.6 Reports Screen

- **Purpose:** Generate financial reports for a sector.
- **Main controls:** **Report Type** selector, **Sector** selector (Business Owner only), **From** and **To** date fields (format MM/DD/YYYY), **Generate Report** button.
- **Expected behavior:**
  - Business Owner: Report Types include **Financial Summary**, **Sales**, **Expenses**, **Payroll Expenses**, and **Analytics**. The sector selector includes **All Sectors**, with the note "All Sectors generates a cross-sector report."
  - Event Manager: Report Types are **Financial Summary**, **Sales**, **Expenses**, and **Payroll Expenses**. Reports are scoped to the assigned sector — the screen notes "Reports are scoped to your assigned sector."
  - Before generating, the screen shows "Select a report type and press Generate Report." After generating, the report appears with figures and charts (e.g., Sales Graph, Expense Breakdown). If there is nothing to show, the screen shows "No report yet."
- **Validation messages:** None — the report type and dates are selected with controls, not typed.

### 6.7 Business Sector Switcher Screen

- **Purpose:** Change the active business sector (Business Owner only).
- **Main controls:** List of the four sectors (B&DYS, DYS Events, Flavors by DYS, SnapDYS Memories), **Switch Sector** button.
- **Expected behavior:** The screen shows "Select the business sector you want to switch to." and marks the current sector as **Active** ("Currently active: [sector name]"). After switching, the app returns you to the Dashboard, which now shows the new sector's totals. There is no confirmation step — the switch happens immediately.
- **Validation messages:** None — the sector is chosen from the list, and at least one sector is always available.

### 6.8 User Management Screen

- **Purpose:** Create, edit, and manage user accounts (Business Owner only).
- **Main controls:** **Name** field, **Email** field, **Role** selector (**Event Manager** or **Employee/Staff**), **Sector** selector, **Generate Temporary Password** button, **Save Account** button, and the list of accounts with **Deactivate**/**Activate** buttons.
- **Expected behavior:**
  - The screen is titled **Manage Users** and the form is **Add / Edit User**.
  - Pressing **Generate Temporary Password** creates a temporary password for the new account; the app shows it in a message.
  - The form notes: "New accounts receive a temporary password. Employee may change on first login."
  - Saving shows "User account created successfully." (new) or "User updated successfully." (edit). Deactivating or activating shows "User status updated successfully."
  - Deactivated accounts are not deleted; only the Business Owner can manage users.
- **Validation messages:**
  - "Name is required."
  - "Email is required." / "Enter a valid email address." / "Email has already been taken."
  - "Role is required."
  - "Sector is required."

---

## 7. Common Error Messages

These are the messages the application itself shows. If you see one, here is what it means and what to do.

| Message | When it appears | What to do |
|---------|-----------------|------------|
| "Invalid username or password." | Wrong email or password on the Login screen | Check your email and password, then try again |
| "Email is required." | Login or User Management — Email left empty | Type your email address |
| "Password is required." | Login — Password left empty | Type your password |
| "Enter a valid email address." | Login or User Management — email format is not valid (e.g., missing the "@" or the domain part) | Check the email format, e.g. name@example.com |
| "Email has already been taken." | User Management — an account with that email already exists | Use a different email |
| "Name is required." | User Management — Name left empty | Type the person's name |
| "Role is required." / "Sector is required." | User Management, Sales, or Expenses — nothing chosen | Choose the missing option |
| "Amount is required." / "Amount must be a positive number." | Sales or Expenses — amount empty or not a positive number | Enter a valid amount greater than zero |
| "Employee is required." | Payroll — no employee chosen | Choose an employee |
| "Hours worked is required." / "Hours worked must be a positive number." / "Hours worked must not exceed 99999999.99." | Payroll — hours field empty, not positive, or too large | Enter a valid number of hours |
| "Hourly rate is required." / "Hourly rate must be a positive number." / "Hourly rate must not exceed 99999999.99." | Payroll — rate field empty, not positive, or too large | Enter a valid hourly rate |
| "Pay period is required." | Payroll — no pay period date chosen | Pick the pay period end date |
| "Forbidden." | You tried to do something your role does not allow (e.g., an Employee opening Reports, or a non-owner managing users) | Use your own role's screens; ask the Business Owner if you need more access |
| "Unauthenticated." | Your session is no longer valid (for example, after being logged out or when the session expired) | Log in again |
| "Unable to connect to the server. Please try again." | The app cannot reach the server (no internet, server not running) | Check your connection and that the server is running, then try again |
| "Something went wrong. Please try again." | An unexpected problem occurred | Try the action again; if it keeps happening, contact the Business Owner |

---

## 8. Frequently Asked Questions

**1. How do I switch sectors?**
Only the Business Owner can switch sectors. Tap the sector chip at the top of the Dashboard, choose a sector on the Switch Business Sector screen, then press **Switch Sector**. The Dashboard and the rest of the app switch to the new sector immediately.

**2. Why can't I access Reports?**
Employees cannot open Reports — the menu does not include it. If you are an Event Manager, you can open Reports, but the report types and sector options are limited to your assigned sector. If you believe you need more access, ask the Business Owner.

**3. Why can't I create users?**
Only the Business Owner sees the **Users** menu item. Event Managers and Employees do not have the User Management screen at all. Ask the Business Owner to create or edit accounts.

**4. Why is my Dashboard different?**
The Dashboard adapts to your role. The Business Owner sees a tappable sector chip and the full set of quick actions (including Manage Users). Event Managers see quick actions for Sales, Expenses, Payroll, and Reports. Employees only see the View Payroll quick action. The summary cards always show your sector's totals.

**5. What happens after logout?**
You are returned to the Login screen and your session is closed. Nobody else using the device can get into your account without logging in again.

**6. Why does my Dashboard show the wrong numbers?**
The Dashboard shows totals for the **current sector**. If you recently switched sectors, the numbers changed because the totals belong to the sector shown in the chip at the top. Check the sector chip to confirm which sector you are viewing.

**7. Why can't I see the Analytics report type?**
Analytics is available to the Business Owner only. Event Managers see the other report types, scoped to their assigned sector.

**8. Why can't I calculate payroll?**
Only the Business Owner can create payroll records. Event Managers and Employees can only view payroll records (Employees see only their own).

**9. What happens when I record a sale or expense?**
The app saves the record and shows a confirmation message. The totals on the Dashboard update to include the new record. If you record an expense for the wrong sector, ask the Business Owner — only a user with the right access can correct it.

**10. Can a deactivated user still log in?**
No. When the Business Owner deactivates an account, that person can no longer log in. The account is not deleted — the Business Owner can activate it again later.

**11. What is the temporary password for?**
When the Business Owner creates a new account and presses **Generate Temporary Password**, the app creates a temporary password shown in a message. The new user logs in with it the first time.

---

## 9. Tips

- **Start with the Dashboard.** Check Total Sales, Total Expenses, and Net Balance first to see how the current sector is doing before recording anything.
- **Watch the sector chip.** All figures are per sector. When the Business Owner switches sectors, every screen follows the new sector, so confirm which sector is active before entering data.
- **Write down temporary passwords.** When creating an account, press **Generate Temporary Password** and give the password to the new user right away — the temporary password is shown once in a message.
- **Record descriptions that help you later.** The Description field on Sales and Expenses makes records easier to identify in reports.
- **Double-check payroll before saving.** Payroll records are stored permanently and cannot be changed afterwards. Confirm the employee, hours, rate, and pay period end date first. The salary is hours × rate, and an Expense record is created automatically.
- **Use the date picker for pay periods.** Pick the pay period end date instead of typing it, to avoid format mistakes.
- **Choose the right sector when recording.** The Business Owner picks the sector on the Sales and Expenses screens; Event Managers' records go to their assigned sector automatically.
- **Use All Sectors for an overall view.** As the Business Owner, choose **All Sectors** in Reports to see the whole business instead of one sector at a time.
- **Log out when you finish.** If you leave the app open, someone else could use your session. Log out when you are done, especially on a shared device.
- **Use the Show/Hide password toggle.** The eye button on the Login screen lets you check the password you typed before pressing Log In.

---

## 10. Troubleshooting

### 10.1 Cannot log in

- Check the email and password — the app shows "Invalid username or password." when either is wrong.
- Make sure your account is active. If the Business Owner deactivated it, you cannot log in — contact the Business Owner.
- Check that the Email field contains a valid address (format like name@example.com) — the app shows "Enter a valid email address." otherwise.

### 10.2 Cannot connect to the server

- The app shows "Unable to connect to the server. Please try again." when it cannot reach the server.
- Check your internet or network connection.
- Make sure the server is running. If you are not sure, contact the person who runs the system.
- Try the action again after a moment.

### 10.3 Validation errors

- Messages such as "Amount is required." or "Hours worked must be a positive number." mean a field is empty, in the wrong format, or out of range.
- Read the message under the field, fix the value, and press the button again (Record Sale, Record Expense, Save Payroll Record, Save Account, or Log In).
- For the amount, hours, and rate fields, enter positive numbers only.

### 10.4 No data displayed

- If Reports shows "No report yet", press **Generate Report** after choosing a report type — the report is not generated until you press the button.
- If Payroll shows "No payroll records yet", the Business Owner has not calculated payroll for the sector (or you have no payroll records yet).
- If the Dashboard shows no figures, try reopening the app. Figures always belong to the current sector shown in the chip.

### 10.5 Permission denied

- If the app returns you to the Dashboard when you try to open a section, your role does not include it (for example, Employees opening Reports, or anyone other than the Business Owner opening User Management or the Sector Switcher).
- If a screen shows "Forbidden.", the action is not allowed for your role.
- Use the menu items shown for your role. If you need more access, ask the Business Owner.

---

## 11. Document Summary

| Item | Value |
|------|-------|
| File created | `.ai/development/user-manual.md` (this document) |
| Sections completed | 10 (Introduction, Getting Started, Business Owner Guide, Event Manager Guide, Employee Guide, Screen Guide, Common Error Messages, FAQ, Tips, Troubleshooting) plus Document Summary |
| User roles covered | Business Owner, Event Manager, Employee/Staff |
| Screens documented | 8 (Login, Dashboard, Sales, Expenses, Payroll, Reports, Business Sector Switcher, User Management) |
| FAQ count | 11 |
| Assumptions | See below |

**Assumptions**

1. The manual describes only the implemented application; screens, features, and messages not present in the application are not included.
2. Login credentials are issued by the Business Owner; the manual does not publish or reset any passwords.
3. The manual does not cover server installation or maintenance — that is the subject of the Deployment & Installation Guide and the Troubleshooting section assumes the server is already set up.
4. Amounts are displayed in Philippine Pesos (₱), matching the application's currency formatting.
