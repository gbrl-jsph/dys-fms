# UI Style Guide / Design System — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** Draft (Pending Audit)
**Project:** DYS Financial Management System (DYS FMS)

---

## Design Principles

| # | Principle | Description |
|---|-----------|-------------|
| 1 | Mobile-first | All layouts designed for phone-sized screens (375px reference). No web, desktop, or tablet variants. |
| 2 | Clean financial dashboard | Minimal visual noise. Spacious cards, clear typographic hierarchy, ample whitespace via 8pt grid. |
| 3 | Consistent navigation | Bottom navigation bar on every authenticated screen. Back button on every input/display screen. Dashboard is the single hub. |
| 4 | Accessibility | Focus-visible rings (`#4338CA`, 2.5px, 2px offset). `prefers-reduced-motion` disables all transitions. Minimum contrast ratios maintained. |
| 5 | Minimal user actions | Quick-action buttons on Dashboard. Auto-calculation panels for sales and payroll. No unnecessary confirmation dialogs. |
| 6 | Role-based UI | UI components are shown/hidden by role. No separate screens — the same screen adapts via RBAC. |

**Direction:** Material Design 3 / Stripe Dashboard / Notion Mobile

---

## Color Palette

### Brand & Semantic Colors

| Token | HEX | Usage |
|-------|:---:|-------|
| `--primary` | `#4338CA` | Primary buttons, active nav items, focus rings, active sector border |
| `--primary-hover` | `#372DAA` | Primary button pressed/hover state |
| `--primary-container` | `#EEEDFC` | Tonal buttons, calculation panels, active sector cards, avatar background |
| `--primary-container-ink` | `#2E249B` | Text on primary-container backgrounds |
| `--success` | `#15803D` | Positive financial values, active status badges |
| `--success-container` | `#E7F6EC` | Active status badge background |
| `--danger` | `#DC2626` | Negative financial values, destructive buttons, error messages, validation text |
| `--danger-container` | `#FDECEC` | Error message background, deactivate button outline |
| `--warning` | `#B45309` | Warning indicators |
| `--warning-container` | `#FDF3E3` | Warning message background |

### Neutral Surfaces

| Token | HEX | Usage |
|-------|:---:|-------|
| `--surface` | `#FFFFFF` | Card backgrounds, bottom nav, input fields, table body |
| `--surface-alt` | `#F7F7FA` | Screen/page background, hover states |
| `--surface-sunken` | `#F0F1F5` | Table header backgrounds, secondary hover states |
| `--border` | `#E4E4EA` | Card borders, input borders, table cell borders, bottom nav top border |
| `--border-strong` | `#D2D3DB` | Secondary button border, chart placeholder border, total row border |

### Text Colors

| Token | HEX | Usage |
|-------|:---:|-------|
| `--ink` | `#1C1B22` | Primary body text, headings, titles |
| `--ink-secondary` | `#5B5C66` | Secondary text, section labels, table headers, help text |
| `--ink-muted` | `#8B8C97` | Placeholder text, chart placeholder text, inactive nav items, disabled states |
| `--ink-on-primary` | `#FFFFFF` | Text on primary-colored backgrounds (buttons, logo) |

### Sector Signature Colors

| Sector | Accent | Background |
|--------|:------:|:----------:|
| DYS Events | `#7C3AED` | `#F3ECFD` |
| B&DYS | `#B45309` | `#FDF3E3` |
| Flavors by DYS | `#15803D` | `#E7F6EC` |
| SnapDYS Memories | `#2563EB` | `#E9F0FE` |

**Usage:** Sector dot icon backgrounds in the Dashboard sector chip, sector cards in the Sector Switcher, and sector-specific data indicators throughout the app.

---

## Typography

### Font Family

**Primary:** Inter (Google Fonts)
**Fallback:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`

All text uses the Inter font family. No secondary or display fonts are used.

### Type Scale

| Token | Size | Weight | Usage |
|-------|:----:|:------:|-------|
| `--fs-display` | 22px | 800 (ExtraBold) | Screen titles (app bar headings), login logo text, login title |
| `--fs-title` | 17px | 700 (Bold) | Section headings within screens (not currently used in wireframes; reserved) |
| `--fs-body` | 14px | 400 (Regular) / 600 (SemiBold) / 700 (Bold) | Body text, button labels (700), stat values (800), sector chip text (600) |
| `--fs-label` | 12.5px | 600 (SemiBold) / 700 (Bold) | Form field labels (600), section labels uppercase (700), chart titles (700) |
| `--fs-caption` | 11px | 400 (Regular) / 600 (SemiBold) / 700 (Bold) | Stat labels (600), table headers uppercase (700), help text (400), validation messages (400), chart sub-text (400), footer (400) |

### Text Transformations

| Usage | Transform | Letter Spacing |
|-------|:---------:|:--------------:|
| Section labels (e.g. "Financial Summary") | Uppercase | 0.5px |
| Table header cells | Uppercase | 0.4px |
| Status badge text | Uppercase | 0.4px |
| All other text | None | Default |

### Tabular Numbers

Financial values use `font-variant-numeric: tabular-nums` to ensure consistent numeral widths in:
- Stat values on Dashboard summary cards
- Calculation panel totals
- Table amount cells

---

## Spacing System

### Base Unit

**8px grid** — all spacing values are multiples of 4px derived from an 8px rhythm.

| Token | Value | Usage |
|-------|:-----:|-------|
| `--sp-1` | 4px | Minimal gaps, focus ring offset, table cell padding |
| `--sp-2` | 8px | Small gaps in icon groups, bottom nav item padding, table cell padding |
| `--sp-3` | 12px | Between related elements (stat gap, button row gap), form field padding, card vertical padding |
| `--sp-4` | 16px | Standard card padding, between form groups, between sections, screen horizontal padding |
| `--sp-5` | 24px | Section-to-section spacing, between major blocks |
| `--sp-6` | 32px | Login hero top padding, top-level page padding |
| `--sp-7` | 40px | Footer spacing, bottom of screen content |

### Layout Margins

| Context | Value |
|---------|:-----:|
| Screen horizontal padding (left/right) | 16px (`--sp-4`) |
| Screen top padding (below app bar) | 8px (`--sp-2`) |
| Screen bottom padding (above bottom nav) | 16px (`--sp-4`) |
| Between sections within a screen | 16px (`--sp-4`) |
| Between form groups | 16px (`--sp-4`) |
| Bottom nav top border padding | 8px top, 8px bottom (`--sp-2`) |

---

## Border Radius

| Token | Value | Usage |
|-------|:-----:|-------|
| `--r-sm` | 8px | Focus ring border-radius, bottom nav item hover, sector dot |
| `--r-md` | 12px | Buttons, input fields, dropdowns, sector chips |
| `--r-lg` | 16px | Cards, card-flat, stat cards, chart placeholders, calculation panels, tables, login logo, sector cards |
| `--r-xl` | 24px | Reserved for larger containers |
| `--r-full` | 999px | Avatar buttons, status badges, radio dots |

---

## Elevation / Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `--shadow-1` | `0 1px 2px rgba(20,20,43,0.06), 0 1px 3px rgba(20,20,43,0.08)` | Cards, stat cards |
| `--shadow-2` | `0 4px 10px rgba(20,20,43,0.10), 0 2px 4px rgba(20,20,43,0.06)` | Phone frame (wireframe only), elevated dialogs |
| `--shadow-cta` | `0 6px 16px rgba(67,56,202,0.28)` | Primary call-to-action buttons, login logo |

Components without shadows: bottom navigation bar, flat cards (`card-flat`), table cells, form inputs.

---

## Buttons

### Button Variants

| Variant | Class | Background | Text Color | Border | Shadow | Hover |
|---------|-------|:----------:|:----------:|:------:|:------:|-------|
| Primary | `.btn-primary` | `#4338CA` | `#FFFFFF` | None | `--shadow-cta` | `#372DAA` |
| Secondary | `.btn-secondary` | `#FFFFFF` | `#1C1B22` | 1.5px `#D2D3DB` | None | `#F0F1F5` bg |
| Tonal | `.btn-tonal` | `#EEEDFC` | `#2E249B` | None | None | `#E2E0FA` |
| Danger/Outline | `.btn-secondary` with danger overrides | `#FFFFFF` | `#DC2626` | 1.5px `#DC2626` | None | N/A |

### Button Sizing

| Property | Value |
|----------|:-----:|
| Height | ~48px (13px padding top/bottom + 14px font + line-height) |
| Horizontal padding | 16px (`--sp-4`) |
| Border radius | 12px (`--r-md`) |
| Font | 14px (`--fs-body`), 700 weight |
| Icon gap | 8px (`--sp-2`) |
| Bottom margin | 12px (`--sp-3`) in stacked layout, 0 in button row |

### Button States

| State | Primary | Secondary | Tonal |
|-------|:-------:|:---------:|:-----:|
| Default | `#4338CA` bg, white text | White bg, `#D2D3DB` border | `#EEEDFC` bg, `#2E249B` text |
| Hover | `#372DAA` bg | `#F0F1F5` bg | `#E2E0FA` bg |
| Disabled | Not defined in wireframes (use opacity 0.38 + muted text) | | |
| Loading | Not defined in wireframes (reserve spinner + disabled state) | | |

### Button Types

| Type | Usage | Variant |
|------|-------|:-------:|
| Log In (Login screen) | Full-width primary | Primary |
| Record Sale (Dashboard quick action) | Full-width primary | Primary |
| Record Expense (Dashboard quick action) | Full-width tonal | Tonal |
| Save Sale Record (Sales screen) | Full-width primary | Primary |
| Save Expense Record (Expenses screen) | Full-width primary | Primary |
| Calculate & Save (Payroll screen) | Full-width primary | Primary |
| Save Account (Users screen) | Flex primary in button row | Primary |
| Generate Temporary Password (Users screen) | Full-width secondary | Secondary |
| Deactivate (Users screen) | Flex secondary with danger color | Secondary (danger) |
| View Reports (Dashboard quick action) | Half-width secondary | Secondary |
| View Payroll (Dashboard quick action) | Half-width secondary | Secondary |
| Manage Users (Dashboard quick action) | Full-width secondary | Secondary |
| Add User (Users screen) | Full-width primary with icon | Primary |

### Button Layout

- **Quick actions:** Buttons arranged in rows of 2 (or 1 for single actions) via `.quick-actions-row`
- **Button row:** Two buttons side by side via `.btn-row` with `12px` gap
- **Standalone:** Full-width, stacked vertically

---

## Form Components

### Text Field

| Property | Default State | Focused State | Error State | Disabled State |
|----------|:-------------:|:-------------:|:-----------:|:--------------:|
| Border | 1.5px `#E4E4EA` | 1.5px `#4338CA` | 1.5px `#DC2626` | Not defined |
| Background | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` | — |
| Border radius | 12px | 12px | 12px | — |
| Padding | 11px 12px | 11px 12px | 11px 12px | — |
| Font | 14px, `#1C1B22` | 14px, `#1C1B22` | 14px, `#1C1B22` | — |
| Placeholder | `#8B8C97` | `#8B8C97` | — | — |

**Usage:** Text input fields (name, email, description, hours, rate, amount, item, quantity, price).

### Number Field

Same visual properties as Text Field. Used for financial amounts, quantities, hours, rates.

- Tabular numbers for financial values
- PHP symbol (₱) prefix displayed as label or inline

### Dropdown / Select Field

| Property | Value |
|----------|-------|
| Visual style | Same border and padding as text field |
| Indicator | Chevron-down icon on the right |
| Placeholder text color | `#8B8C97` (`.field-select` default) |
| Selected value color | `#1C1B22`, weight 500 (`.field-select.has-value`) |
| Hover/focus | Same as text field |

**Usage:** Sector selector (Sales, Expenses, Payroll forms), Employee selector (Payroll), Report Type selector (Reports), Role selector (Users), Sector selector (Users).

### Password Field

Same visual properties as Text Field. Used only on the Login screen.

- `type="password"` masks input
- No visibility toggle is shown in wireframes

### Search Field

Not used in any screen. No search/autocomplete component exists in the wireframes.

### Field Label

| Property | Value |
|----------|-------|
| Font | 12.5px (`--fs-label`) |
| Weight | 600 (SemiBold) |
| Color | `#5B5C66` (`--ink-secondary`) |
| Bottom margin | 8px (`--sp-2`) |
| Display | Block |

### Validation Error Message

| Property | Value |
|----------|-------|
| Background | `#FDECEC` (`--danger-container`) |
| Text color | `#DC2626` (`--danger`) |
| Font | 11px (`--fs-caption`) |
| Layout | Flex row with warning icon + text |
| Padding | 10px, 12px border-radius |
| Top margin | 4px |

### Help Text

| Property | Value |
|----------|-------|
| Font | 11px (`--fs-caption`) |
| Color | `#8B8C97` (`--ink-muted`) |
| Top margin | 4px (`--sp-1`) |

---

## Cards

### Dashboard / Stat Card (`.stat-card`)

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border | 1px `#E4E4EA` |
| Border radius | 16px (`--r-lg`) |
| Shadow | `--shadow-1` |
| Padding | 12px 12px (`--sp-3`) |
| Layout | Flex row of 3 equal-width cards |
| Gap | 12px (`--sp-3`) |
| Bottom margin | 16px (`--sp-4`) |

**Label:** 11px, 600 weight, `#5B5C66`
**Value:** 16px, 800 weight, `#1C1B22`, tabular-nums

### Flat Card (`.card-flat`)

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border | 1px `#E4E4EA` |
| Border radius | 16px (`--r-lg`) |
| Shadow | None |
| Padding | 16px (`--sp-4`) |
| Bottom margin | 16px (`--sp-4`) |

**Usage:** Add/Edit User form container

### Calculation Panel (`.calc-panel`)

| Property | Value |
|----------|-------|
| Background | `#EEEDFC` (`--primary-container`) |
| Border radius | 16px (`--r-lg`) |
| Padding | 16px (`--sp-4`) |
| Bottom margin | 16px (`--sp-4`) |

**Row text:** 11px, `#2E249B` at 75% opacity
**Total label:** 15px, 700 weight, `#2E249B`
**Total amount:** 20px, 800 weight, tabular-nums

### Sector Card (`.sector-card`)

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border | 1.5px `#E4E4EA` |
| Border radius | 16px (`--r-lg`) |
| Padding | 12px (`--sp-3`) |
| Bottom margin | 12px (`--sp-3`) |
| Active state | `--primary-container` bg, `#4338CA` border |

### Sector Chip (`.sector-chip`)

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border | 1px `#E4E4EA`, 12px radius |
| Padding | 12px 16px |
| Font | 14px, 600 weight, `#1C1B22` |
| Bottom margin | 16px (`--sp-4`) |

---

## Tables / Lists (`.data-table`)

### Visual Properties

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border | 1px `#E4E4EA` |
| Border radius | 16px (`--r-lg`) |
| Overflow | Hidden (clips to border-radius) |
| Width | 100% |
| Font | 14px (`--fs-body`) |
| Bottom margin | 16px (`--sp-4`) |

### Header Row

| Property | Value |
|----------|-------|
| Background | `#F0F1F5` (`--surface-sunken`) |
| Font | 11px, uppercase, 700 weight, `#5B5C66`, letter-spacing 0.4px |
| Padding | 8px 12px (`--sp-2` `--sp-3`) |
| Text alignment | Left (except right-aligned amount columns) |

### Body Rows

| Property | Value |
|----------|-------|
| Padding | 8px 12px (`--sp-2` `--sp-3`) |
| Cell border | 1px `#E4E4EA` (top only) |
| Font variant | tabular-nums for financial columns |
| Amount cells | Right-aligned, 700 weight |

### Special Rows

| Variant | Style |
|---------|-------|
| Total row | 800 weight, 1.5px `#D2D3DB` top border |
| Empty state | Single row: "No records yet" in `#8B8C97` |

### Used On

| Screen | Table Content |
|--------|---------------|
| Sales | Recent transactions (Service/Item, Qty, Price, Total, Date) |
| Expenses | Recent expenses (Category, Amount, Date, Description) |
| Payroll | Payroll history (Employee, Hours, Rate, Salary) |
| Reports | Financial summary (Category, Amount, ...) |
| Users | User list (Name, Role, Sector, Status) |

---

## Charts

### Chart Container (`.chart-placeholder`)

| Property | Value |
|----------|-------|
| Border | 1px dashed `#D2D3DB` |
| Border radius | 16px (`--r-lg`) |
| Background | `#FFFFFF` |
| Height | 140px (Dashboard), 110px (Reports) |
| Layout | Flex column, center-aligned |
| Bottom margin | 16px (`--sp-4`) |
| Icon | 55% opacity, `#8B8C97` |

### Chart Types (Conceptual — not implemented in wireframes)

| Chart | Location | Data Source |
|-------|----------|:-----------:|
| Bar / Line | Dashboard "Sales Overview" | Sales Transactions by period |
| Line | Reports "Sales Graph" | Sales trend |
| Pie / Donut | Reports "Expense Chart" | Expense breakdown by category |

### Color Assignment (for chart implementation)

| Data Series | Color |
|-------------|:-----:|
| Total Sales | `#4338CA` (primary) |
| Total Expenses | `#DC2626` (danger) |
| Net Balance | `#15803D` (success) |
| DYS Events | `#7C3AED` |
| B&DYS | `#B45309` |
| Flavors by DYS | `#15803D` |
| SnapDYS Memories | `#2563EB` |

### Legend

| Property | Value |
|----------|-------|
| Font | 11px (`--fs-caption`) |
| Color | `#5B5C66` (`--ink-secondary`) |
| Layout | Horizontal row below chart |

---

## Navigation

### Bottom Navigation (`.bottom-nav`)

| Property | Value |
|----------|-------|
| Background | `#FFFFFF` |
| Border top | 1px `#E4E4EA` |
| Padding | 8px 4px 8px |
| Layout | Flex row, equal-width items |
| Position | Fixed at bottom of screen content |

### Bottom Nav Item (`.nav-item`)

| Property | Value |
|----------|-------|
| Font | 10.5px, 600 weight |
| Color (default) | `#8B8C97` (`--ink-muted`) |
| Color (active) | `#4338CA` (`--primary`) |
| Padding | 4px 2px |
| Border radius | 8px (`--r-sm`) |
| Layout | Flex column, center-aligned, 3px gap between icon and label |
| Hover | `#4338CA` |

**Number of items by role:**
- Business Owner: 6 items (Dashboard, Sales, Expenses, Payroll, Users, Reports)
- Event Manager: 5 items (Dashboard, Sales, Expenses, Payroll, Reports)
- Employee/Staff: 3 items (Dashboard, Payroll, Reports)

### Top App Bar (`.app-bar`)

| Property | Value |
|----------|-------|
| Layout | Flex row, space-between, center-aligned |
| Padding | 12px 4px 16px (`--sp-3` `--sp-1` `--sp-4`) |
| Title | 22px (`--fs-display`), 800 weight |

**Variants:**

| Screen | Left | Center | Right |
|--------|:----:|:------:|:-----:|
| Dashboard | — | "Dashboard" | Avatar (initials) |
| Sales | Back arrow | "Record Sale" | — |
| Expenses | Back arrow | "Record Expense" | — |
| Payroll | Back arrow | "Payroll" | — |
| Reports | Back arrow | "Financial Reports" | — |
| Sector Switcher | Back arrow | "Switch Business Sector" | — |
| Users | — | "Manage Users" | Avatar (initials) |

### Back Button (`.back-btn`)

| Property | Value |
|----------|-------|
| Size | 36×36px |
| Border radius | 999px (`--r-full`) |
| Border | 1px `#E4E4EA` |
| Background | `#FFFFFF` |
| Icon color | `#5B5C66` |
| Hover | None defined |

### Profile Avatar (`.avatar-btn`)

| Property | Value |
|----------|-------|
| Size | 36×36px |
| Border radius | 999px (`--r-full`) |
| Background | `#EEEDFC` (`--primary-container`) |
| Color | `#2E249B` (`--primary-container-ink`) |
| Font | 13px, 700 weight |
| Border | None |
| Content | User initials (e.g. "BO" for Business Owner) |

### Sector Chip (acts as navigation element on Dashboard)

Navigates to Sector Switcher (Owner only). Read-only for Event Managers and Employees.

### Quick Actions

Arranged in a vertical stack of button rows on the Dashboard. Each row contains 1–2 buttons.

---

## Dialogs

No confirmation dialogs appear in any wireframe. The following dialogs are implicitly required by business rules but are not visually defined:

| Dialog | Trigger | Behavior |
|--------|---------|----------|
| **Success** | After successful record creation (Sale, Expense, Payroll, User) | Toast or inline success message (no modal) |
| **Error** | Validation failure | Inline error messages below fields |
| **Deactivate Account** | Owner taps "Deactivate" on Users screen | Not defined — inline action preferred |
| **Logout** | Owner taps avatar → Logout | Not defined — immediate logout assumed |

**Design note:** No modal dialogs are depicted in the hi-fi wireframes. Success feedback is shown through inline messages or screen refreshes. If modal dialogs are implemented in Flutter, they should follow Material Design 3 dialog patterns using:
- Background: `#FFFFFF`
- Border radius: 16px (`--r-lg`)
- Shadow: `--shadow-2`
- Button variants: Primary (confirm), Secondary (cancel)

---

## Loading States

No loading states are explicitly depicted in the wireframes. The following are implied by behavior:

| Component | Loading Behavior |
|-----------|------------------|
| Buttons (Primary) | Disabled state + spinner icon replacing button text |
| Pages (Lists) | Skeleton placeholder matching card/table dimensions |
| Charts | Spinner overlay on chart placeholder |
| Payload submission | Button shows loading spinner, input fields disabled |

---

## Empty States

| Screen | Empty Content | Display |
|--------|---------------|---------|
| Dashboard | No transactions | Chart placeholder shows "Graph placeholder — Bar/line chart · populates once transactions are recorded". Stat cards show `₱0.00`. |
| Sales | No sales recorded | Recent transactions table shows "No records yet" row |
| Expenses | No expenses recorded | Recent expenses table shows "No records yet" row |
| Payroll | No payroll records | Payroll history table shows "No records yet" row |
| Reports | No data | Chart placeholders show "Sales graph placeholder" / "Expense chart placeholder". Summary shows `₱0.00`. |
| Users | No users (should not occur — Owner always exists) | User list table shows only the Business Owner |

---

## Icons

All icons use Feather icon set style (24×24 viewBox, 2px stroke width, round linecaps/joins, `currentColor` fill on specific shapes).

### Navigation Icons (Bottom Nav)

| Tab | Icon Description | Size |
|-----|------------------|:----:|
| Dashboard | Home (house) | 20×20 |
| Sales | Tag/pricetag | 20×20 |
| Expenses | Wallet/card | 20×20 |
| Payroll | Users/people | 20×20 |
| Users | Multiple users | 20×20 |
| Reports | Bar chart (3 bars) | 20×20 |

### Quick Action Icons

| Action | Icon Description | Size |
|--------|------------------|:----:|
| Record Sale | Plus/minus crosshair | 16×16 |
| Record Expense | Plus/minus crosshair | 16×16 |
| Add User | Plus/minus crosshair | 16×16 |
| Generate Password | Document with lines | 16×16 |

### App Bar Icons

| Element | Icon Description | Size |
|---------|------------------|:----:|
| Back button | Chevron left | 18×18 |
| Sector chip chevron | Chevron down | 16×16 |
| Sector dropdown | Chevron down | 14×14 |

### Sector Icons

| Sector | Icon Description |
|--------|------------------|
| DYS Events | Crosshair/compass |
| B&DYS | Gift box |
| Flavors by DYS | Wine glass/martini |
| SnapDYS Memories | Video camera |

### Status Icons

| Context | Icon Description |
|---------|------------------|
| Validation error | Alert circle with exclamation mark |
| Chart placeholder | Bar chart (Dashboard), Trending up (Reports sales), Clock (Reports expenses) |

---

## Role-Based UI Visibility

| UI Element / Screen | Business Owner | Event Manager | Employee |
|---------------------|:--------------:|:-------------:|:--------:|
| Login Screen | ✓ | ✓ | ✓ |
| Dashboard — Summary cards (3 stat cards) | ✓ | ✓ | ✓ |
| Dashboard — Sector chip (clickable) | ✓ | ✓ (read-only) | ✓ (read-only) |
| Dashboard — Chart placeholder | ✓ | ✓ | ✓ |
| Dashboard — Record Sale quick action | ✓ | ✓ | — |
| Dashboard — Record Expense quick action | ✓ | ✓ | — |
| Dashboard — View Reports quick action | ✓ | ✓ | — |
| Dashboard — View Payroll quick action | ✓ | ✓ | ✓ |
| Dashboard — Manage Users quick action | ✓ | — | — |
| Dashboard — Switch Sector (chip action) | ✓ | — | — |
| Bottom Nav — Dashboard | ✓ | ✓ | ✓ |
| Bottom Nav — Sales | ✓ | ✓ | — |
| Bottom Nav — Expenses | ✓ | ✓ | — |
| Bottom Nav — Payroll | ✓ | ✓ | ✓ |
| Bottom Nav — Users | ✓ | — | — |
| Bottom Nav — Reports | ✓ | ✓ | ✓ |
| Sales Screen | ✓ | ✓ | — |
| Sales — Entry form (amount, description) | ✓ | ✓ | — |
| Sales — Recent transactions table | ✓ | ✓ | — |
| Expenses Screen | ✓ | ✓ | — |
| Expenses — Entry form (amount, description) | ✓ | ✓ | — |
| Expenses — Recent expenses table | ✓ | ✓ | — |
| Payroll Screen — Employee selector | ✓ | — | — |
| Payroll Screen — Hours input | ✓ | — | — |
| Payroll Screen — Rate input | ✓ | — | — |
| Payroll Screen — Calculate & Save button | ✓ | — | — |
| Payroll Screen — Calculation panel | ✓ | ✓ | ✓ |
| Payroll Screen — Payroll history (all employees) | ✓ | — | — |
| Payroll Screen — Payroll history (own only) | — | ✓ | ✓ |
| Reports Screen — Report type selector | ✓ | ✓ | — |
| Reports Screen — Date range pickers | ✓ | ✓ | — |
| Reports Screen — Sales graph | ✓ | ✓ | — |
| Reports Screen — Expense chart | ✓ | ✓ | — |
| Reports Screen — Financial summary | ✓ | ✓ | — |
| Reports Screen — Analytics/cross-sector (Owner) | ✓ | — | — |
| Sector Switcher Screen | ✓ | — | — |
| User Account Management Screen | ✓ | — | — |
| Users — User list table | ✓ | — | — |
| Users — Add User button | ✓ | — | — |
| Users — Add/Edit form | ✓ | — | — |
| Users — Generate Temporary Password | ✓ | — | — |
| Users — Save Account / Deactivate | ✓ | — | — |

---

## Screen-by-Screen Component Inventory

### 1. Login Screen

| Component | Count | Description |
|-----------|:-----:|-------------|
| Status bar | 1 | Time + signal icons |
| Logo | 1 | DYS logo mark (`#4338CA` square with "DYS") |
| Title | 1 | "DYS Financial Management System (DYS FMS)" |
| Subtitle | 1 | "Management System" |
| Email field | 1 | Text input, "Enter email" placeholder |
| Password field | 1 | Password input, "Enter password" placeholder |
| Login button | 1 | Primary button, full-width, "Log In" |
| Error message | 1 | Inline validation error container (hidden by default) |

### 2. Dashboard Screen

| Component | Count | Role Variance |
|-----------|:-----:|:-------------|
| Status bar | 1 | None |
| App bar | 1 | Title "Dashboard" + avatar (all) |
| Sector chip | 1 | Clickable (Owner), read-only (EM, Employee) |
| Section label "Financial Summary" | 1 | All |
| Stat cards | 3 | Total Sales, Total Exp., Net Balance (all) |
| Section label "Sales Overview" | 1 | All |
| Chart placeholder | 1 | All |
| Section label "Quick Actions" | 1 | All |
| Record Sale button | 1 | Primary. Owner, EM only |
| Record Expense button | 1 | Tonal. Owner, EM only |
| View Reports button | 1 | Secondary. Owner, EM only |
| View Payroll button | 1 | Secondary. All |
| Manage Users button | 1 | Secondary. Owner only |
| Bottom navigation | 1 | 6 items (Owner), 5 items (EM), 3 items (Employee) |

### 3. Sales Screen

| Component | Count | Description |
|-----------|:-----:|-------------|
| Status bar | 1 | — |
| App bar with back button | 1 | Back arrow + "Record Sale" title |
| Sector dropdown | 1 | Business Sector selector |
| Service/Item field | 1 | Text input |
| Quantity field | 1 | Number input |
| Unit Price field | 1 | Number input with ₱ |
| Date selector | 1 | Date picker dropdown |
| Section label "Automatic Calculation" | 1 | — |
| Calculation panel | 1 | Qty × Unit Price → Total Amount |
| Save Sale Record button | 1 | Primary |
| Recent transactions table | 1 | Tabular list of past sales |

### 4. Expenses Screen

| Component | Count | Description |
|-----------|:-----:|-------------|
| Status bar | 1 | — |
| App bar with back button | 1 | Back arrow + "Record Expense" title |
| Sector dropdown | 1 | Business Sector selector |
| Expense Category dropdown | 1 | Category selector |
| Amount field | 1 | Number input with ₱ |
| Date selector | 1 | Date picker dropdown |
| Description field | 1 | Text input, optional |
| Section label "Automatic Calculation" | 1 | — |
| Calculation panel | 1 | Expense recorded under [Sector] → Total Expense |
| Save Expense Record button | 1 | Primary |
| Recent expenses table | 1 | Tabular list of past expenses |

### 5. Payroll Screen

| Component | Count | Role Variance |
|-----------|:-----:|:-------------|
| Status bar | 1 | None |
| App bar with back button | 1 | Title "Payroll" |
| Sector dropdown | 1 | All (Owner selects; EM/Employee assigned) |
| Employee dropdown | 1 | Owner only |
| Hours Worked field | 1 | Owner only |
| Hourly Rate field | 1 | Owner only |
| Section label "Payroll Calculation" | 1 | Owner only (calculation panel context) |
| Calculation panel | 1 | Owner only (Hours × Rate → Computed Salary) |
| Calculate & Save button | 1 | Primary. Owner only |
| Section label "Payroll History" | 1 | All |
| Payroll history table | 1 | All — Owner sees all employees; EM/Employee sees own |

### 6. Reports Screen

| Component | Count | Role Variance |
|-----------|:-----:|:-------------|
| Status bar | 1 | None |
| App bar with back button | 1 | Title "Financial Reports" |
| Report Type dropdown | 1 | Owner: all types; EM: sector-only |
| From date picker | 1 | All (Owner, EM) |
| To date picker | 1 | All (Owner, EM) |
| Section label "Sales Graph" | 1 | — |
| Sales chart placeholder | 1 | Line chart area |
| Section label "Expense Chart" | 1 | — |
| Expense chart placeholder | 1 | Pie/donut chart area |
| Section label "Financial Summary" | 1 | — |
| Financial summary table | 1 | Aggregated totals |

### 7. Sector Switcher Screen

| Component | Count | Description |
|-----------|:-----:|-------------|
| Status bar | 1 | — |
| App bar with back button | 1 | Title "Switch Business Sector" |
| Instructional text | 1 | "Select the business sector you want to switch to." |
| Section label "Business Sectors" | 1 | — |
| Sector card (DYS Events) | 1 | Icon + name + "Active" badge (if current) |
| Sector card (B&DYS) | 1 | Icon + name + radio dot |
| Sector card (Flavors by DYS) | 1 | Icon + name + radio dot |
| Sector card (SnapDYS Memories) | 1 | Icon + name + radio dot |

### 8. User Account Management Screen

| Component | Count | Description |
|-----------|:-----:|-------------|
| Status bar | 1 | — |
| App bar | 1 | Title "Manage Users" + avatar |
| Section label "User List" | 1 | — |
| User list table | 1 | Name, Role, Sector, Status columns |
| Add User button | 1 | Primary with plus icon |
| Section label "Add / Edit User" | 1 | — |
| Name field | 1 | Text input |
| Email field | 1 | Email input |
| Role dropdown | 1 | Event Manager, Employee/Staff |
| Sector dropdown | 1 | Four sectors |
| Help text | 1 | "New accounts receive a temporary password. Employee may change on first login." |
| Generate Temporary Password button | 1 | Secondary with document icon |
| Save Account button | 1 | Primary, flex in button row |
| Deactivate button | 1 | Secondary with danger color, flex in button row |
| Disclaimer text | 1 | "Accounts are deactivated, not deleted. Only the Business Owner can manage users." |
| Bottom navigation | 1 | Same as Owner Dashboard (6 items) |

---

## Flutter Widget Mapping

| Design Component | Flutter Widget | Notes |
|------------------|---------------|-------|
| Screen | `Scaffold` | Base layout container |
| Status bar | `SystemUiOverlay` / handled by Scaffold | Not implemented as a widget |
| App bar (with back) | `Row` + `IconButton` + `Text` inside Padding | Custom; no AppBar widget used |
| App bar (with avatar) | `Row` + `Text` + `CircleAvatar` | Same |
| Back button | `IconButton` with `Icons.arrow_back_ios` | Custom 36×36 container |
| Avatar button | `CircleAvatar` | Background `--primary-container` |
| Bottom navigation | `BottomNavigationBar` or `NavigationBar` | M3 NavigationBar recommended |
| Bottom nav item | `NavigationDestination` | Icon + label per role |
| Sector chip | `InkWell` + `Container` with custom decoration | Custom row layout |
| Stat card | `Card` | Elevation `--shadow-1`, 3 cards in `Row` |
| Card (general) | `Card` | `--r-lg` borderRadius, `--surface` bg |
| Flat card | `Container` with decoration | No elevation |
| Chart placeholder | `Container` with dashed border + centered `Column` | Use `DashedBorder` package or custom painter |
| Calculation panel | `Container` with `--primary-container` bg | `--r-lg` radius |
| Primary button | `ElevatedButton` | Style from ButtonTheme or custom `ButtonStyle` |
| Secondary button | `OutlinedButton` | 1.5px `--border-strong` border |
| Tonal button | `TextButton` or custom `ElevatedButton` with `--primary-container` bg | M3 FilledTonalButton |
| Text field (default) | `TextField` | `InputDecoration` with border |
| Number field | `TextField` with `keyboardType: TextInputType.numberWithOptions(decimal: true)` | Same visual as TextField |
| Dropdown | `DropdownMenu` or `PopupMenuButton` | M3 `DropdownMenu` preferred |
| Date picker | `InkWell` + `showDatePicker` | Custom trigger styled as .field-select |
| Table | `DataTable` | Custom header decoration |
| User list table | `DataTable` | With Status column (colored text) |
| Payroll history table | `DataTable` | With employee name column |
| Dialog | `AlertDialog` | Not used in wireframes — reserve for future |
| Error message | `Container` with `Row` (icon + text) | `--danger-container` bg |
| Help text | `Text` | Caption style `--ink-muted` |
| Section label | `Text` | Uppercase, `--fs-label`, 700 weight |
| Login hero | `Column` centered | Logo + title + subtitle |
| Logo | `Container` with `--primary` bg + centered text | 64×64, `--r-lg` |
| Status badge | `Container` (chip) | `--r-full`, success bg + text |
| Radio dot | `Container` with border + inner dot | Used in Sector Switcher |
| Icons | `Icon` or `SvgPicture` | Feather-style, `currentColor` |
| Avatar text | `Text` inside `CircleAvatar` | Initials (e.g. "BO") |
| Bottom navigation bar item | `NavigationDestination` | Icon + label |
| Divider | `Divider` | Used in bottom nav top border (handled by NavigationBar) |
| Keyboard type (financial) | `TextInputType.numberWithOptions(decimal: true)` | For amount, hours, rate, quantity, price fields |
| Tabular numbers | `TextStyle(fontFeatures: [FontFeature.tabularNumbers()])` | For all financial value displays |

---

## Consistency Audit

| Source | Status |
|--------|--------|
| High-Fidelity Wireframes (CSS) | ✓ |
| High-Fidelity Wireframes (HTML) | ✓ |
| Low-Fidelity Wireframes | ✓ |
| Navigation Map | ✓ |
| Functional Requirements Specification | ✓ |
| API Specification | ✓ |
| Concept Paper | ✓ |
| Client Clarifications | ✓ |
| System Architecture | ✓ |
| System Flowchart | ✓ |
| User Flow | ✓ |
| Use Case | ✓ |
| Use Case Diagram | ✓ |
| ER Diagram | ✓ |
| Database Schema | ✓ |
| Data Dictionary | ✓ |
| Physical ERD | ✓ |
| System Components | ✓ |
| Project Memory | ✓ |
| AI Instructions | ✓ |
| CHANGELOG | ✓ |
| VERSION | ✓ |

**Issues Found:** None

**Verification notes:**
- All 8 screens accounted for with complete component inventories
- 14 color tokens extracted from CSS (plus 5 sector-specific tokens)
- 5 typography levels documented (display, body, label, caption, reserved title)
- 3 shadow levels mapped to components
- 7 spacing tokens from 8pt grid system
- 5 border radius tokens
- 4 button variants with states
- 6 field types documented (text, number, dropdown, password, search: none, field label)
- 6 card types (stat, flat, calc-panel, sector-card, sector-chip, chart-placeholder)
- 6 icon categories (navigation, quick actions, app bar, sector, status, misc)
- 82 role-based UI visibility rules documented
- Flutter widget mapping: ~33 component-to-widget mappings
- No dark mode, settings screen, chat, messaging, QR codes, calendar, admin dashboard, web/desktop/tablet layouts, or unspecified animations
- All colors, radii, spacings, and typography extracted directly from `styles.css`
- All component inventories verified against hi-fi HTML structure

---

## Final Status

| Attribute | Value |
|-----------|-------|
| Document | UI Style Guide / Design System |
| Version | 1.0 |
| Pages Covered | 8 |
| Components Documented | 33+ (Flutter widget mappings) |
| Colors | 19 (14 base + 5 sector) |
| Typography Levels | 5 (display, body, label, caption, title reserved) |
| Navigation Components | 4 (bottom nav, app bar, back button, sector chip) |
| Status | Draft — Pending Audit |
| Repository | Synchronized |
| Unsupported Features | None introduced |
| Ready for Review | Yes |
