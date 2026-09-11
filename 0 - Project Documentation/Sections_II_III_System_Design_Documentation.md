# II. System Architecture & Environment

## A. System Architecture / System Framework

The DYS Financial Management System (DYS FMS) implements a robust multi-tier layered architecture connecting a Flutter mobile client to a centralized Laravel REST API and MySQL database. The system is architected into six distinct operational layers: Presentation Layer, State Layer, Repository Layer, Network Layer, Backend Layer, and Data Layer. This design strictly separates user interface presentation, state management, data mapping, network communication, backend business logic, and database persistence.

**Figure II-1. DYS Financial Management System Architecture**

<div class="figure-container">
  <img src="../1 - System Architecture/DYS_FMS_System_Architecture.svg" alt="DYS FMS System Architecture" />
</div>

The **Users** tier comprises the four authorized system roles defined in the final RBAC specification: Business Owner, Event Manager, Bookkeeper, and Employee/Event Staff. Users interact exclusively with the **Presentation Layer**, which is built using Flutter and Dart. This layer provides the mobile application interfaces for Login, Dashboard, Sales, Expenses, Payroll, Reports, Business Sector Switcher, and User Management screens.

The **State Layer** utilizes Provider and Flutter Secure Storage to manage reactive application state, authentication sessions, user roles, active business sector context, and screen loading states while securely caching session tokens for seamless session restoration. The **Repository Layer** provides feature repositories and DTO data mapping, abstracting network operations from UI components.

The **Network Layer** uses Dio to transmit HTTPS requests containing JSON payloads and Bearer authentication tokens to the **Backend Layer**. Powered by Laravel 12 and PHP 8.2+, the Backend Layer handles authentication via Laravel Sanctum, request validation, Role-Based Access Control (RBAC) policy enforcement, sales and expense management, automated payroll calculation, and cross-sector reporting. The backend utilizes **Eloquent ORM** to execute secure SQL operations against the persistent **Data Layer** (MySQL database), which stores User accounts, Business Sectors, Sales Transactions, Expenses, and Payroll Records.

Data flow operates bidirectionally: user interactions in the Flutter UI propagate through Provider state and feature repositories into Dio, which sends an HTTPS REST request to the Laravel API. Laravel validates the request against RBAC permissions and business logic, invokes Eloquent ORM to query or modify MySQL, and returns a structured JSON response through the network, repository, and state layers to update the presentation interface. The active business sector context dynamically scopes financial data across Dashboard, Sales, Expenses, and Reports. Crucially, the mobile client never connects directly to MySQL, and payroll calculations computed on the backend automatically generate corresponding expense records.

## B. Technology Stack with Discussion

| Layer / Component | Technology | Discussion |
|---|---|---|
| Frontend | Flutter & Dart | Provides a high-performance cross-platform mobile framework for building responsive role-based financial interfaces. |
| State Management | Provider | Manages reactive UI state, user sessions, and role contexts efficiently across application screens. |
| Navigation | GoRouter | Delivers declarative routing and secure navigation control between role-authorized application views. |
| Network | Dio | Facilitates robust HTTP client communication, request interceptors, and JSON data transfer. |
| Secure Storage | Flutter Secure Storage | Encrypts and securely caches authentication tokens on the client device for session persistence. |
| Backend Framework | Laravel 12 & PHP 8.2+ | Powers backend REST endpoints, middleware, validation rules, and structured application services. |
| API Authentication | Laravel Sanctum | Issues and validates API tokens to secure communication between the Flutter client and Laravel backend. |
| Data Mapping | Eloquent ORM | Translates object-oriented backend models into secure SQL queries for MySQL database operations. |
| Database | MySQL | Relational database management system ensuring persistent storage and referential integrity for all financial records. |

The approved technology stack strictly implements the Flutter-to-Laravel-to-MySQL architecture without introducing unapproved microservices, Firebase services, payment gateways, or hardware integrations.

## C. Updated System Environment

### 1. Software Requirements
- **Development Environment:** Visual Studio Code or Android Studio with Flutter/Dart extensions, Git version control, PHP 8.2+ CLI, Composer, and MySQL server.
- **Backend Server:** Linux/Ubuntu or compatible web server running PHP 8.2+, Composer, Nginx or Apache, and MySQL 8.0+.
- **Database:** MySQL relational database instance configured with appropriate user privileges and schema migrations.
- **Client Application:** Android 8.0+ / iOS 12.0+ supporting Flutter runtime environment and secure local storage.

### 2. Backend / Server Requirements
The server hosting the Laravel backend must support PHP 8.2 or later with required extensions (OpenSSL, PDO, Mbstring, Tokenizer, XML, Ctype, JSON), support Composer dependency management, and maintain secure connectivity to the MySQL database.

### 3. Database Requirements
MySQL 8.0+ provides persistent relational storage for user accounts, business sectors, sales transactions, expenses, and payroll records. Foreign key constraints enforce relational integrity between transactions, users, and sectors.

### 4. Mobile / Client Requirements
Mobile client devices require adequate storage capacity, network connectivity (Wi-Fi or cellular data) to communicate with the REST API, and hardware support for Flutter UI rendering.

### 5. Hardware Requirements
- **Development Workstation:** Quad-core processor, 8 GB RAM, 20 GB available storage.
- **Server Host:** Dual-core processor, 4 GB RAM, 50 GB SSD storage.
- **Mobile Device:** Smartphone with minimum 2 GB RAM and ARM64 architecture.

---

# III. System Logic & Behavior

## A. Updated Use Case Diagram

**Figure III-1. DYS Financial Management System Use Case Diagram**

<div class="figure-container landscape-fig">
  <img src="../4 - Use Case Diagram/DYS_FMS_Use_Case_Diagram.svg" alt="DYS FMS Use Case Diagram" />
</div>

## B. Discussion of the Use Case Diagram

The use case diagram models the functional requirements of the DYS Financial Management System across four distinct actors defined in the final RBAC Security Matrix: Business Owner, Event Manager, Bookkeeper, and Employee/Event Staff. All actors interact with foundational authentication use cases (Login, Logout, Restore Session) and their role-based dashboard.

The Business Owner exercises full administrative and operational privileges, including recording sales and expenses, calculating payroll, managing user accounts (create, update, activate/deactivate, temporary passwords), switching business sectors, and accessing comprehensive reports and analytics. The Event Manager operates within assigned branch sectors to record sales and expenses, view reports, and view their own payroll. The Bookkeeper holds viewing-oriented access, reviewing financial reports, analytics dashboards, and payroll records without transaction-recording, account-management, or sector-switching privileges. Employee/Event Staff members have restricted access limited to viewing their own payroll. Standard associations govern feature access, complemented by report specialization relationships.

## C. Updated User Flow Diagram

**Figure III-2. DYS Financial Management System User Flow Diagram**

<div class="figure-container landscape-fig">
  <img src="../3 - User Flow Diagram/DYS_FMS_User_Flow_Diagram.svg" alt="DYS FMS User Flow Diagram" />
</div>

## D. Discussion of the User Flow Diagram

The user flow diagram outlines the sequential execution paths from application launch to session termination across all four user roles. Upon opening the application, users enter credentials on the Login screen. Following successful authentication via Laravel Sanctum, the system identifies the user role and directs them to their respective role-based dashboard.

The Business Owner dashboard provides access to financial summaries and the active business sector switcher, enabling navigation to Sales Management, Expense Management, Payroll Processing, Reports & Analytics, and User Management. The Event Manager dashboard scopes operational actions (sales and expense recording, report generation) to the assigned business sector. The Bookkeeper dashboard provides read-only navigation across financial reports, analytics, and payroll records. The Employee/Event Staff interface provides restricted access to personal payroll viewing. All workflows conclude with a secure logout action returning the user to the login screen.
