# Phase 1 Implementation Plan — Project Initialization & Authentication

**Project:** DYS Financial Management System (DYS FMS)
**Phase:** 1 of 10 — Authentication & Core Setup
**Source:** `.ai/development/development-roadmap.md` (Phase 1), `.ai/development/development-execution-plan.md`

---

## 1. Folder Structure

### 1.1 Laravel 12 Backend

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── AuthController.php       # Login/logout endpoints
│   │   ├── Middleware/
│   │   │   └── EnsureTokenIsValid.php        # Sanctum auth middleware (auto-generated)
│   │   └── Requests/
│   │       └── Auth/
│   │           └── LoginRequest.php          # Login validation: email required+format, password required
│   ├── Models/
│   │   ├── User.php                         # User model with role ENUM, account_status ENUM, sector_id FK
│   │   ├── BusinessSector.php               # Business Sector model (seeded data)
│   │   ├── SalesTransaction.php             # Placeholder model (no endpoints in Phase 1)
│   │   ├── Expense.php                      # Placeholder model (no endpoints in Phase 1)
│   │   └── PayrollRecord.php                # Placeholder model (no endpoints in Phase 1)
│   ├── Providers/
│   │   └── AppServiceProvider.php            # Service container bindings (default Laravel)
│   └── Services/
│       └── AuthService.php                  # Login logic: credential validation, role detection, default sector resolution, token issuance
├── config/
│   ├── sanctum.php                          # Sanctum configuration (token expiration, middleware)
│   ├── cors.php                             # CORS configuration for Flutter client
│   └── database.php                         # MySQL connection config
├── database/
│   ├── migrations/
│   │   ├── 0001_create_business_sectors_table.php
│   │   ├── 0002_create_users_table.php
│   │   ├── 0003_create_sales_transactions_table.php
│   │   ├── 0004_create_payroll_records_table.php
│   │   └── 0005_create_expenses_table.php
│   └── seeders/
│       ├── DatabaseSeeder.php               # Calls BusinessSectorSeeder + UserSeeder
│       ├── BusinessSectorSeeder.php          # Seeds 4 approved sectors
│       └── UserSeeder.php                   # Seeds 1 Business Owner account
├── routes/
│   └── api.php                              # All API route definitions
├── .env                                     # Environment configuration (DB, APP_URL, Sanctum)
└── composer.json                            # Dependencies: laravel/sanctum, etc.
```

**Why each folder exists:**

| Path | Purpose |
|------|---------|
| `app/Http/Controllers/Api/` | Houses all API controllers separated by domain. `AuthController` handles authentication only. |
| `app/Http/Middleware/` | Laravel middleware for request filtering. Sanctum middleware auto-generated via `php artisan install:api`. |
| `app/Http/Requests/Auth/` | Form request classes for validation. Keeps validation logic out of controllers. One request class per endpoint. |
| `app/Models/` | Eloquent models. All 5 models created in Phase 1 even though only User and BusinessSector are used — ensures FK relationships compile. |
| `app/Services/` | Business logic layer between controllers and models. `AuthService` encapsulates login, token issuance, default sector resolution. |
| `config/sanctum.php` | Sanctum package config. Controls token expiry, token abilities, middleware aliases. |
| `config/cors.php` | Cross-Origin Resource Sharing config. Required for Flutter HTTP client to reach the API. |
| `database/migrations/` | Ordered migration files. Laravel reads timestamp-prefixed files in order. The numbered prefix ensures FK-safe creation order. |
| `database/seeders/` | Seed data. `BusinessSectorSeeder` runs before `UserSeeder` because User has a FK to Business Sectors. |
| `routes/api.php` | All REST route definitions. Laravel automatically prefixes `/api` and applies Sanctum middleware where configured. |

### 1.2 Flutter Project

```
flutter_app/
├── lib/
│   ├── main.dart                             # App entry point, MaterialApp, route configuration
│   ├── app.dart                              # App widget with GoRouter/MaterialApp.router, theme setup
│   ├── config/
│   │   ├── api_config.dart                   # Base URL, timeout settings, endpoint constants (e.g., /api/login, /api/logout)
│   │   └── theme.dart                        # Material 3 theme using UI Style Guide tokens: --primary (#4338CA), typography, spacing
│   ├── core/
│   │   ├── network/
│   │   │   ├── api_client.dart               # Dio HTTP client instance with base URL, timeout, interceptors
│   │   │   └── auth_interceptor.dart         # Request interceptor: attaches Bearer token from secure storage to Authorization header
│   │   └── storage/
│   │       └── secure_storage.dart           # flutter_secure_storage wrapper: save/read/delete token, user data
│   ├── features/
│   │   └── auth/
│   │       ├── data/
│   │       │   ├── models/
│   │       │   │   ├── login_request.dart    # LoginRequest{ email, password } with toJson()
│   │       │   │   ├── login_response.dart   # LoginResponse{ user, token, defaultSector } with fromJson()
│   │       │   │   └── user_model.dart       # UserModel{ id, name, email, role, sectorId, accountStatus }
│   │       │   └── repositories/
│   │       │       └── auth_repository.dart  # AuthRepository: login(), logout(), getStoredUser(), isAuthenticated()
│   │       ├── domain/
│   │       │   └── auth_state.dart           # AuthState{ token, user, role, defaultSector, isAuthenticated, isLoading, error }
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── auth_provider.dart    # AuthProvider (ChangeNotifier): login(), logout(), checkAuth(), clearError()
│   │           └── screens/
│   │               └── login_screen.dart     # Login screen with email field, password field, Login button, error display
│   ├── routing/
│   │   └── app_router.dart                  # GoRouter configuration: /login (unauthenticated), /dashboard (authenticated, redirect)
│   └── shared/
│       └── widgets/
│           └── loading_button.dart           # Reusable button with loading spinner state (used for Login button)
├── pubspec.yaml                              # Dependencies: dio, flutter_secure_storage, provider/riverpod, go_router
└── android/
    └── app/src/main/AndroidManifest.xml      # Internet permission, application config
```

**Why each folder exists:**

| Path | Purpose |
|------|---------|
| `lib/config/` | Application-wide constants. `api_config.dart` keeps all URL strings in one place. `theme.dart` centralizes Material 3 theme from the UI Style Guide. |
| `lib/core/network/` | HTTP communication layer. `api_client.dart` creates the Dio singleton. `auth_interceptor.dart` globally attaches tokens — every endpoint benefits automatically. |
| `lib/core/storage/` | Secure persistence. `flutter_secure_storage` uses encrypted Android Keystore / iOS Keychain. Token is never stored in plain SharedPreferences. |
| `lib/features/auth/data/` | Data layer for the auth domain. Models serialize/deserialize JSON. Repository abstracts the data source (API vs local storage). |
| `lib/features/auth/domain/` | Domain/business logic. `auth_state.dart` defines the state object that the UI observes. |
| `lib/features/auth/presentation/` | UI layer. `AuthProvider` manages state and exposes actions. `login_screen.dart` is the only Phase 1 screen. |
| `lib/routing/` | Navigation. GoRouter handles auth redirect, role-based routing foundation, and named routes for all 8 screens (scaffold). |
| `lib/shared/widgets/` | Reusable widgets. `loading_button.dart` used across screens as the app grows. |

---

## 2. Database Implementation

### 2.1 Migration Order

The migration order is critical because of foreign key constraints. The sequence is:

```
1. create_business_sectors_table     (no FK dependencies — parent table)
2. create_users_table                (FK to business_sectors.id — nullable, child of sectors)
3. create_sales_transactions_table   (FKs to users.id, business_sectors.id)
4. create_payroll_records_table      (FKs to users.id, business_sectors.id)
5. create_expenses_table             (FKs to users.id, business_sectors.id, payroll_records.id — nullable)
```

**Why Expenses migration (5) must run after Payroll Records migration (4):**
The `Expenses.payroll_record_id` column is a FK referencing `Payroll Records.id`. This FK was defined in the Physical ERD and Database Schema. If Expenses were created before Payroll Records, the FK constraint would fail because the referenced table does not yet exist.

### 2.2 Migration Details (Per Blueprint: Database Schema, Data Dictionary, Physical ERD)

**Migration 1: `create_business_sectors_table`**

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT |
| name | VARCHAR(255) | NOT NULL, UNIQUE |
| description | TEXT | NULLABLE |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

**Migration 2: `create_users_table`**

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT |
| name | VARCHAR(255) | NOT NULL |
| email | VARCHAR(255) | NOT NULL, UNIQUE |
| password | VARCHAR(60) | NOT NULL |
| role | ENUM('Business Owner','Event Manager','Employee/Staff') | NOT NULL |
| sector_id | INTEGER | NULLABLE, FK → business_sectors.id ON DELETE SET NULL ON UPDATE CASCADE |
| account_status | ENUM('Active','Inactive') | NOT NULL, DEFAULT 'Active' |
| created_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

**Migration 3: `create_sales_transactions_table`**

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT |
| user_id | INTEGER | NOT NULL, FK → users.id ON DELETE RESTRICT ON UPDATE CASCADE |
| sector_id | INTEGER | NOT NULL, FK → business_sectors.id ON DELETE RESTRICT ON UPDATE CASCADE |
| amount | DECIMAL | NOT NULL |
| description | TEXT | NULLABLE |
| recorded_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

**Migration 4: `create_payroll_records_table`**

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT |
| user_id | INTEGER | NOT NULL, FK → users.id ON DELETE RESTRICT ON UPDATE CASCADE |
| sector_id | INTEGER | NOT NULL, FK → business_sectors.id ON DELETE RESTRICT ON UPDATE CASCADE |
| hours_worked | DECIMAL(10,2) | NOT NULL |
| hourly_rate | DECIMAL(10,2) | NOT NULL |
| computed_salary | DECIMAL(10,2) | NOT NULL |
| pay_period | DATE | NOT NULL |
| calculated_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |

**Migration 5: `create_expenses_table`**

| Column | Type | Constraints |
|--------|------|-------------|
| id | INTEGER | PK, AUTO_INCREMENT |
| user_id | INTEGER | NOT NULL, FK → users.id ON DELETE RESTRICT ON UPDATE CASCADE |
| sector_id | INTEGER | NOT NULL, FK → business_sectors.id ON DELETE RESTRICT ON UPDATE CASCADE |
| amount | DECIMAL | NOT NULL |
| description | TEXT | NULLABLE |
| recorded_at | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP |
| payroll_record_id | INTEGER | NULLABLE, FK → payroll_records.id ON DELETE RESTRICT ON UPDATE CASCADE |

### 2.3 Seeder Order

```
1. BusinessSectorSeeder    (runs first — User has FK to business_sectors.id)
2. UserSeeder              (runs second — depends on sectors existing for sector_id FK)
```

**BusinessSectorSeeder** — Inserts exactly 4 rows (per API Specification, Database Schema):

| id | name | description |
|:--:|------|-------------|
| 1 | DYS Events | Event coordination and styling main branch |
| 2 | B&DYS | Souvenirs |
| 3 | Flavors by DYS | Grazing tables and celebration drinks |
| 4 | SnapDYS Memories | Video guestbook |

**UserSeeder** — Inserts exactly 1 Business Owner (per Test Case Specification seed data):

| Field | Value |
|-------|-------|
| name | "Juan Dela Cruz" |
| email | "owner@dys.com" |
| password | BCrypt hash of a known password (e.g., `SecurePass123`) |
| role | "Business Owner" |
| sector_id | NULL (Owner has no fixed sector per Business Rules BR-25, BR-34) |
| account_status | "Active" |
| created_at | CURRENT_TIMESTAMP |

### 2.4 Foreign Key Implementation Sequence

| Step | FK | Builder Method | Phase | Rationale |
|:----:|----|:--------------:|:-----:|-----------|
| 1 | Users.sector_id → Business Sectors.id | `$table->foreignId('sector_id')->nullable()->constrained('business_sectors')->cascadeOnUpdate()->nullOnDelete()` | Migration 2 | Nullable because Business Owner has no sector (BR-25). SET NULL on delete ensures users aren't orphaned if a sector is removed. |
| 2 | Sales Transactions.user_id → Users.id | `$table->foreignId('user_id')->constrained('users')->cascadeOnUpdate()->restrictOnDelete()` | Migration 3 | RESTRICT on delete — sales records are permanent (BR-17). |
| 3 | Sales Transactions.sector_id → Business Sectors.id | `$table->foreignId('sector_id')->constrained('business_sectors')->cascadeOnUpdate()->restrictOnDelete()` | Migration 3 | RESTRICT on delete — each sale must belong to a valid sector. |
| 4 | Payroll Records.user_id → Users.id | `$table->foreignId('user_id')->constrained('users')->cascadeOnUpdate()->restrictOnDelete()` | Migration 4 | RESTRICT on delete — payroll is permanent (BR-24). |
| 5 | Payroll Records.sector_id → Business Sectors.id | `$table->foreignId('sector_id')->constrained('business_sectors')->cascadeOnUpdate()->restrictOnDelete()` | Migration 4 | RESTRICT on delete. |
| 6 | Expenses.user_id → Users.id | `$table->foreignId('user_id')->constrained('users')->cascadeOnUpdate()->restrictOnDelete()` | Migration 5 | RESTRICT on delete. |
| 7 | Expenses.sector_id → Business Sectors.id | `$table->foreignId('sector_id')->constrained('business_sectors')->cascadeOnUpdate()->restrictOnDelete()` | Migration 5 | RESTRICT on delete. |
| 8 | Expenses.payroll_record_id → Payroll Records.id | `$table->foreignId('payroll_record_id')->nullable()->constrained('payroll_records')->cascadeOnUpdate()->restrictOnDelete()` | Migration 5 | Nullable for manual entries. RESTRICT on delete — payroll records are permanent (BR-21, BR-24). |

---

## 3. Laravel Implementation Checklist

### 3.1 Project Initialization

- [ ] Create new Laravel 12 project: `composer create-project laravel/laravel backend`
- [ ] Install Sanctum: `composer require laravel/sanctum`
- [ ] Publish Sanctum config: `php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"`
- [ ] Run `php artisan install:api` (Laravel 12 default API scaffolding — creates `routes/api.php`, configures Sanctum)
- [ ] Configure `.env`: set `DB_CONNECTION=mysql`, `DB_DATABASE=dys_fms`, `DB_USERNAME`, `DB_PASSWORD`
- [ ] Configure `config/cors.php`: set `allowed_origins` for Flutter dev (e.g., `*` for development), `supports_credentials=true`
- [ ] Configure Sanctum token expiration in `config/sanctum.php` (Stateful domains, expiration — recommend 24h or null for no expiry per Phase 1 scope)
- [ ] Verify project boots: `php artisan serve` + `curl http://localhost:8000/api/up`

### 3.2 Models

- [ ] Create `User.php` model:
  - [ ] `HasApiTokens` trait (Sanctum)
  - [ ] `HasFactory` trait
  - [ ] `$fillable`: `['name', 'email', 'password', 'role', 'sector_id', 'account_status']`
  - [ ] `$hidden`: `['password']`
  - [ ] `$casts`: `['role' => 'string', 'account_status' => 'string']` (ENUMs stored as strings)
  - [ ] `sector_id` belongsTo BusinessSector relationship
  - [ ] Password mutator: `setPasswordAttribute()` with `bcrypt()`
- [ ] Create `BusinessSector.php` model:
  - [ ] `$fillable`: `['name', 'description']`
  - [ ] HasMany Users relationship
  - [ ] HasMany SalesTransactions, Expenses, PayrollRecords relationships
- [ ] Create `SalesTransaction.php` model (placeholder):
  - [ ] `$fillable`: `['user_id', 'sector_id', 'amount', 'description']`
  - [ ] belongsTo User, belongsTo BusinessSector
- [ ] Create `Expense.php` model (placeholder):
  - [ ] `$fillable`: `['user_id', 'sector_id', 'amount', 'description', 'payroll_record_id']`
  - [ ] belongsTo User, belongsTo BusinessSector, belongsTo PayrollRecord (nullable)
- [ ] Create `PayrollRecord.php` model (placeholder):
  - [ ] `$fillable`: `['user_id', 'sector_id', 'hours_worked', 'hourly_rate', 'computed_salary', 'pay_period']`
  - [ ] belongsTo User, belongsTo BusinessSector
  - [ ] hasOne Expense (via payroll_record_id)

### 3.3 Migrations

- [ ] Create and run migration for `business_sectors` table
- [ ] Create and run migration for `users` table
- [ ] Create and run migration for `sales_transactions` table
- [ ] Create and run migration for `payroll_records` table
- [ ] Create and run migration for `expenses` table
- [ ] Verify `php artisan migrate` runs without errors (all FK constraints satisfied)

### 3.4 Seeders

- [ ] Create `BusinessSectorSeeder` — insert 4 sectors
- [ ] Create `UserSeeder` — insert 1 Business Owner with BCrypt-hashed password
- [ ] Update `DatabaseSeeder` to call `$this->call([BusinessSectorSeeder::class, UserSeeder::class])`
- [ ] Run `php artisan db:seed` and verify data in database

### 3.5 Services

- [ ] Create `app/Services/AuthService.php`:
  - [ ] `login(array $credentials)` method:
    - [ ] Find user by email
    - [ ] Verify password with `Hash::check()`
    - [ ] Check `account_status === 'Active'` (per Validation Rules Matrix row 31)
    - [ ] If any check fails: return consistent error — never disclose whether email exists, password is wrong, or account is inactive (BR-41)
    - [ ] Determine default sector: if role is "Business Owner", sector_id = 1 (DYS Events per BR-34); else use user's assigned sector_id (BR-35, BR-36)
    - [ ] Revoke existing tokens (optional: keep only 1 active token per user, or allow multiple)
    - [ ] Create Sanctum token with `$user->createToken('auth-token')->plainTextToken`
    - [ ] Return: `{ user: { id, name, email, role, sector_id, account_status }, token, default_sector: { id, name } }`
  - [ ] `logout(User $user)` method:
    - [ ] Revoke current token: `$user->currentAccessToken()->delete()` (per API Specification)
    - [ ] Return success message
  - [ ] `getDefaultSector(User $user)` private method:
    - [ ] If role is Business Owner: return sector id=1, name="DYS Events"
    - [ ] If role is Event Manager or Employee: return user's assigned sector from `$user->sector_id`
    - [ ] If user has no sector assigned (shouldn't happen for non-Owner per BR-25): return null

### 3.6 Form Requests

- [ ] Create `app/Http/Requests/Auth/LoginRequest.php`:
  - [ ] `authorize()`: return `true` (public endpoint)
  - [ ] `rules()`:
    - [ ] `'email' => 'required|email'` (per Validation Rules Matrix rows 26-27)
    - [ ] `'password' => 'required|string'` (per Validation Rules Matrix row 29)
  - [ ] `messages()`:
    - [ ] `email.required`: "Email is required." (E01)
    - [ ] `email.email`: "Email must be a valid email address." (E02)
    - [ ] `password.required`: "Password is required." (E04)

### 3.7 Controller

- [ ] Create `app/Http/Controllers/Api/AuthController.php`:
  - [ ] `__construct(AuthService $authService)` — dependency injection
  - [ ] `login(LoginRequest $request)` method:
    - [ ] Call `AuthService::login($request->only('email', 'password'))`
    - [ ] If success: return `response()->json(['data' => {...}, 'message' => 'Login successful.'], 200)` (per API Spec login response, matches E40)
    - [ ] If failure: return `response()->json(['message' => 'Invalid username or password.'], 401)` (per API Spec error response, matches E05/E06)
  - [ ] `logout(Request $request)` method:
    - [ ] Call `AuthService::logout($request->user())`
    - [ ] Return `response()->json(['message' => 'Logged out successfully.'], 200)` (matches E41)
  - [ ] `user(Request $request)` method (optional utility, not in API Spec but useful):
    - [ ] Return `response()->json(['data' => $request->user()])`

### 3.8 Routes

- [ ] Define in `routes/api.php`:

```php
// Public routes (no authentication required)
Route::post('/login', [AuthController::class, 'login']);

// Authenticated routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    // Phase 2+ routes will be added here
});
```

**Route rules per API Specification and Validation Rules Matrix:**
- `POST /api/login` — PUBLIC. No token required. (API Spec § POST /login)
- `POST /api/logout` — AUTHENTICATED. Requires Bearer token. Revokes current token. (API Spec § POST /logout)
- All future endpoints (Phase 2+) will be placed inside the `auth:sanctum` middleware group.

### 3.9 Middleware

- [ ] Sanctum middleware auto-configured by `php artisan install:api`
- [ ] No custom middleware needed in Phase 1. Sanctum's `auth:sanctum` handles all authentication gating.
- [ ] Future phases will add role-checking middleware/policies.

### 3.10 Testing (Backend)

- [ ] Configure `phpunit.xml` with `DB_CONNECTION=sqlite` and `DB_DATABASE=:memory:` for test isolation
- [ ] Create `tests/Feature/Auth/AuthenticationTest.php`:
  - [ ] Test: login with valid Business Owner credentials returns 200 with token (maps to TC-FR001-01)
  - [ ] Test: login response includes role="Business Owner" (TC-FR001-01)
  - [ ] Test: login response includes default_sector.id=1 for Business Owner (TC-FR001-01)
  - [ ] Test: login with valid Event Manager credentials returns 200 with assigned sector (TC-FR001-02)
  - [ ] Test: login with non-existent email returns 401 with "Invalid username or password." (TC-FR001-03)
  - [ ] Test: login with wrong password returns 401 with "Invalid username or password." (TC-FR001-03)
  - [ ] Test: login with inactive account returns 401 with "Invalid username or password." and no status disclosure (TC-FR001-04)
  - [ ] Test: authenticated logout returns 200 (API Spec § POST /logout)
  - [ ] Test: accessing authenticated endpoint without token returns 401 (SV-01)
  - [ ] Test: login validation — empty email returns 422 with E01
  - [ ] Test: login validation — invalid email format returns 422 with E02
  - [ ] Test: login validation — empty password returns 422 with E04

---

## 4. Flutter Implementation Checklist

### 4.1 Project Initialization

- [ ] Create new Flutter project: `flutter create --org com.dys.fms --project-name dys_fms flutter_app`
- [ ] Update `pubspec.yaml` with dependencies:
  - [ ] `dio: ^5.x` (HTTP client)
  - [ ] `flutter_secure_storage: ^9.x` (encrypted token storage)
  - [ ] `provider: ^6.x` (state management)
  - [ ] `go_router: ^14.x` (declarative routing)
  - [ ] `google_fonts: ^6.x` (Inter font per UI Style Guide)
- [ ] Run `flutter pub get`
- [ ] Create folder structure under `lib/` as defined in section 1.2

### 4.2 Configuration

- [ ] Create `lib/config/api_config.dart`:
  - [ ] `static const String baseUrl = 'http://localhost:8000/api';` (dev default)
  - [ ] `static const Duration timeout = Duration(seconds: 30);`
  - [ ] `static const String loginEndpoint = '/login';`
  - [ ] `static const String logoutEndpoint = '/logout';`
  - [ ] All future endpoint constants will be added here in subsequent phases
- [ ] Create `lib/config/theme.dart`:
  - [ ] Define Material 3 theme with UI Style Guide colors:
    - [ ] `ColorScheme.fromSeed(seedColor: Color(0xFF4338CA))` as primary basis
    - [ ] Override specific colors to match Style Guide tokens:
      - [ ] `--primary`: `#4338CA`
      - [ ] `--success`: `#15803D`
      - [ ] `--danger`: `#DC2626`
      - [ ] `--warning`: `#B45309`
  - [ ] Set `useMaterial3: true`
  - [ ] Configure text theme with Inter font family (via `google_fonts`)
  - [ ] Configure `CardTheme`, `ElevatedButtonTheme`, `OutlinedButtonTheme`, `InputDecorationTheme` per UI Style Guide
  - [ ] Configure `NavigationBarTheme` for bottom nav (colors per Style Guide)
  - [ ] Configure font sizes per type scale: `--fs-display`=22px, `--fs-title`=17px, `--fs-body`=14px, `--fs-label`=12.5px, `--fs-caption`=11px

### 4.3 Secure Storage

- [ ] Create `lib/core/storage/secure_storage.dart`:
  - [ ] `FlutterSecureStorage` instance with `aesGcm` encryption (Android) / keychain (iOS)
  - [ ] `saveToken(String token)` — stores `auth_token` key
  - [ ] `getToken()` — retrieves `auth_token`, returns `String?`
  - [ ] `deleteToken()` — removes `auth_token`
  - [ ] `saveUserData(Map<String, dynamic> userData)` — stores JSON string of user info (role, sector_id, etc.)
  - [ ] `getUserData()` — retrieves and deserializes user data
  - [ ] `deleteAll()` — clears all stored data (used on logout)
  - [ ] `isLoggedIn()` — checks if token exists and is non-empty

### 4.4 API Layer

- [ ] Create `lib/core/network/api_client.dart`:
  - [ ] Create singleton `Dio` instance with:
    - [ ] `baseUrl` from `ApiConfig.baseUrl`
    - [ ] `connectTimeout` and `receiveTimeout` from `ApiConfig.timeout`
    - [ ] Default headers: `Content-Type: application/json`, `Accept: application/json`
  - [ ] Add `AuthInterceptor` to Dio interceptors list
  - [ ] Add logging interceptor for development (optional, `dio_logger` or custom)
- [ ] Create `lib/core/network/auth_interceptor.dart`:
  - [ ] Implement `QueuedInterceptor` (queues requests while token refresh is in progress — no token refresh in Phase 1, but queuing prevents race conditions)
  - [ ] `onRequest`: read token from `SecureStorage`, attach as `Authorization: Bearer <token>` header if present
  - [ ] `onError`: if 401 response received, trigger logout (clear stored data, redirect to login)
- [ ] Create error handling utility:
  - [ ] Map DioException to user-friendly error messages
  - [ ] Handle network errors (timeout, no internet) with generic message
  - [ ] Parse 422 validation errors from `errors` object

### 4.5 Data Models

- [ ] Create `lib/features/auth/data/models/login_request.dart`:
  - [ ] Fields: `String email`, `String password`
  - [ ] Method: `Map<String, dynamic> toJson()` → `{'email': email, 'password': password}`
- [ ] Create `lib/features/auth/data/models/login_response.dart`:
  - [ ] Fields: `UserModel user`, `String token`, `DefaultSector defaultSector`
  - [ ] Factory: `LoginResponse.fromJson(Map<String, dynamic> json)` — parses nested `data` object
  - [ ] Nested `DefaultSector` class: `int id`, `String name`
- [ ] Create `lib/features/auth/data/models/user_model.dart`:
  - [ ] Fields: `int id`, `String name`, `String email`, `String role`, `int? sectorId`, `String accountStatus`
  - [ ] Factory: `UserModel.fromJson(Map<String, dynamic> json)`
  - [ ] Getter: `bool get isBusinessOwner => role == 'Business Owner'`
  - [ ] Getter: `bool get isEventManager => role == 'Event Manager'`
  - [ ] Getter: `bool get isEmployee => role == 'Employee/Staff'`

### 4.6 Repository

- [ ] Create `lib/features/auth/data/repositories/auth_repository.dart`:
  - [ ] `AuthRepository(ApiClient apiClient, SecureStorage secureStorage)` constructor injection
  - [ ] `Future<LoginResponse> login(String email, String password)`:
    - [ ] Call `POST /api/login` with `LoginRequest(email, password).toJson()`
    - [ ] Parse response with `LoginResponse.fromJson(response.data)`
    - [ ] Save token to `SecureStorage.saveToken()`
    - [ ] Save user data to `SecureStorage.saveUserData()`
    - [ ] Return parsed LoginResponse
  - [ ] `Future<void> logout()`:
    - [ ] Call `POST /api/logout` (with token auto-attached by interceptor)
    - [ ] Call `SecureStorage.deleteAll()`
  - [ ] `Future<bool> isAuthenticated()`:
    - [ ] Return `SecureStorage.isLoggedIn()`
  - [ ] `Future<UserModel?> getStoredUser()`:
    - [ ] Read from `SecureStorage.getUserData()`, parse with `UserModel.fromJson()`

### 4.7 State Management

- [ ] Create `lib/features/auth/domain/auth_state.dart`:
  - [ ] Class `AuthState`:
    - [ ] `bool isLoading` (tracks login/logout in progress)
    - [ ] `bool isAuthenticated` (derived from token presence)
    - [ ] `UserModel? user` (authenticated user data)
    - [ ] `String? token`
    - [ ] `DefaultSector? defaultSector`
    - [ ] `String? error` (error message to display)
- [ ] Create `lib/features/auth/presentation/providers/auth_provider.dart`:
  - [ ] `AuthProvider extends ChangeNotifier`:
    - [ ] `AuthState _state = AuthState()` — private state
    - [ ] `AuthState get state` — public getter
    - [ ] `Future<void> login(String email, String password)`:
      - [ ] Set `_state.isLoading = true`, `_state.error = null`, notify
      - [ ] Try: call `_authRepository.login(email, password)`
      - [ ] On success: update `_state` with user, token, defaultSector, `isAuthenticated = true`
      - [ ] On error: set `_state.error = error message`, `isAuthenticated` unchanged
      - [ ] Set `_state.isLoading = false`, notify
    - [ ] `Future<void> logout()`:
      - [ ] Call `_authRepository.logout()`
      - [ ] Reset `_state` to initial values
      - [ ] Notify
    - [ ] `Future<void> checkAuthStatus()`:
      - [ ] Call `_authRepository.isAuthenticated()`
      - [ ] If true: load user data from storage, set `isAuthenticated = true`
      - [ ] If false: set `isAuthenticated = false`
    - [ ] `void clearError()` — sets `_state.error = null`, notify

### 4.8 Routing

- [ ] Create `lib/routing/app_router.dart`:
  - [ ] Define `GoRouter` with:
    - [ ] `/login` — Login screen (unauthenticated)
    - [ ] `/dashboard` — Dashboard screen (authenticated, placeholder for Phase 8)
    - [ ] `/sales` — placeholder route (Phase 3)
    - [ ] `/expenses` — placeholder route (Phase 4)
    - [ ] `/payroll` — placeholder route (Phase 5)
    - [ ] `/reports` — placeholder route (Phase 6)
    - [ ] `/sector-switcher` — placeholder route (Phase 7)
    - [ ] `/users` — placeholder route (Phase 2)
  - [ ] `redirect` logic:
    - [ ] If not authenticated and not on `/login`: redirect to `/login`
    - [ ] If authenticated and on `/login`: redirect to `/dashboard`
  - [ ] `refreshListenable` — listen to `AuthProvider` for auth state changes
  - [ ] Pass `AuthProvider` to router via `Provider`/`ChangeNotifierProvider` at app level

### 4.9 Navigation Scaffold

- [ ] Create `lib/features/auth/presentation/screens/login_screen.dart`:
  - [ ] Per UI Style Guide Login Screen component inventory:
    - [ ] DYS logo mark (64×64 `#4338CA` container with centered text "DYS", `--r-lg` radius)
    - [ ] Title text: "DYS Financial Management System (DYS FMS)" (`--fs-display`, 800 weight)
    - [ ] Subtitle: "Management System" (secondary text)
    - [ ] Email `TextField` with "Enter email" placeholder, `TextInputType.emailAddress`
    - [ ] Password `TextField` with "Enter password" placeholder, obscured, `TextInputType.visiblePassword`
    - [ ] "Log In" `ElevatedButton` full-width, primary variant (`--primary` bg, white text, `--shadow-cta`)
    - [ ] Error container (hidden by default): red bg (`--danger-container`) with warning icon + error text (`--danger` color)
    - [ ] Loading state: button shows spinner, fields disabled
    - [ ] Form validation: inline errors below fields per UI Style Guide validation patterns
  - [ ] Consume `AuthProvider` via `Provider.of` or `context.watch`
  - [ ] On successful login: navigate to `/dashboard` (GoRouter handles redirect)
  - [ ] On error: display error message in error container

### 4.10 Dashboard Placeholder (Scaffold for Phase 8)

- [ ] Create placeholder `lib/features/dashboard/presentation/screens/dashboard_screen.dart`:
  - [ ] Minimal dashboard with app bar showing "Dashboard" title and avatar (user initials from `UserModel`)
  - [ ] Placeholder text: "Dashboard — Phase 8"
  - [ ] Bottom navigation bar with role-based items (scaffold for later):
    - [ ] Business Owner: 6 items (Dashboard, Sales, Expenses, Payroll, Users, Reports)
    - [ ] Event Manager: 5 items (Dashboard, Sales, Expenses, Payroll, Reports)
    - [ ] Employee: 3 items (Dashboard, Payroll, Reports)
  - [ ] Logout button/logic in avatar menu

### 4.11 Theme & MaterialApp

- [ ] Create `lib/app.dart`:
  - [ ] `MaterialApp.router` with:
    - [ ] `theme` from `ThemeConfig`
    - [ ] `routerConfig` from `AppRouter`
    - [ ] `MultiProvider` wrapping: `ChangeNotifierProvider<AuthProvider>`
    - [ ] `title`: "DYS FMS"

- [ ] Update `lib/main.dart`:
  - [ ] Call `WidgetsFlutterBinding.ensureInitialized()`
  - [ ] Initialize `SecureStorage`
  - [ ] Initialize `ApiClient` with `AuthInterceptor`
  - [ ] Create `AuthRepository` with dependencies
  - [ ] Create `AuthProvider` with `AuthRepository`
  - [ ] Run `App` widget with providers

### 4.12 Testing (Flutter)

- [ ] Create `test/features/auth/login_screen_test.dart`:
  - [ ] Test: Login screen renders email field, password field, Login button
  - [ ] Test: Empty email shows "Email is required." validation error
  - [ ] Test: Empty password shows "Password is required." validation error
  - [ ] Test: Login button shows loading state on tap
  - [ ] Test: Login API error displays error message container
  - [ ] Test: Successful login navigates away from login screen
- [ ] Create `test/features/auth/auth_provider_test.dart`:
  - [ ] Test: `login()` updates state with user and token on success
  - [ ] Test: `login()` sets error on failure
  - [ ] Test: `logout()` clears state
  - [ ] Test: `checkAuthStatus()` detects stored token

---

## 5. Authentication Implementation Order

The authentication system must be implemented in this exact sequence. Each step depends on the previous one.

```
Step 1: Database
  └── Migrations (all 5 tables) + Seeders (4 sectors + 1 BO)
      └── Step 2: Laravel Auth Service
          └── AuthService.login() — credential validation, sector resolution
              └── Step 3: Laravel Auth Controller
                  └── AuthController — wires LoginRequest + AuthService + response
                      └── Step 4: Laravel Routes
                          └── POST /api/login (public), POST /api/logout (sanctum)
                              └── Step 5: Laravel Tests
                                  └── Feature test — verify all login flows TC-FR001-01–04
                                      └── Step 6: Flutter API Layer
                                          └── Dio client, AuthInterceptor, SecureStorage
                                              └── Step 7: Flutter Auth State
                                                  └── AuthState, AuthProvider, AuthRepository
                                                      └── Step 8: Flutter Login Screen
                                                          └── UI + form validation + api call + navigation
                                                              └── Step 9: Flutter Routing
                                                                  └── GoRouter with auth redirect + role-based scaffolding
                                                                      └── Step 10: Flutter Tests
                                                                          └── Widget + unit tests for auth flow
```

### Detailed Step-by-Step

**Step 1 — Database (Backend)**
1. Create migration files in the defined order
2. Run `php artisan migrate`
3. Create seeder files
4. Run `php artisan db:seed`
5. Verify data in MySQL directly

**Step 2 — AuthService (Backend)**
1. Create `AuthService.php` with constructor (no dependencies)
2. Implement `login()`:
   - Query `User::where('email', $email)->first()`
   - `Hash::check($password, $user->password)`
   - Check `$user->account_status === 'Active'`
   - Determine default sector
   - Create Sanctum token
   - Return structured response data
3. Implement `logout()`:
   - `$user->currentAccessToken()->delete()`
4. Implement `getDefaultSector()`:
   - Role-based logic per BR-34, BR-35, BR-36

**Step 3 — LoginRequest (Backend)**
1. Create form request with validation rules
2. Custom error messages matching Validation Rules Matrix E01, E02, E04

**Step 4 — AuthController (Backend)**
1. Constructor injection of `AuthService`
2. `login()`: call service, return 200 or 401
3. `logout()`: call service, return 200

**Step 5 — Routes (Backend)**
1. Define `/api/login` outside Sanctum group
2. Define `/api/logout` inside Sanctum group
3. Verify with curl:
   - `curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d '{"email":"owner@dys.com","password":"SecurePass123"}'`
   - Expect 200 with token
   - `curl -X POST http://localhost:8000/api/login -H "Content-Type: application/json" -d '{"email":"nonexistent@dys.com","password":"wrong"}'`
   - Expect 401 with "Invalid username or password."

**Step 6 — Backend Tests**
1. Set up SQLite in-memory test database
2. Run migrations and seeders in test setUp
3. Execute all login flow tests
4. Verify all pass

**Step 7 — Flutter API Layer**
1. Initialize Flutter project with dependencies
2. Create `SecureStorage` wrapper
3. Create `ApiClient` with Dio
4. Create `AuthInterceptor` for token attachment
5. Create `AuthRepository` with login/logout/isAuthenticated methods

**Step 8 — Flutter Auth State**
1. Create `AuthState` model
2. Create `AuthProvider` with login/logout/checkAuth/clearError
3. Test provider logic with mock repository

**Step 9 — Flutter Login Screen**
1. Build UI per UI Style Guide Login Screen component inventory
2. Wire form fields to provider
3. Implement form validation (email format, non-empty password)
4. Show loading state during API call
5. Show error messages on failure
6. Navigate to dashboard on success

**Step 10 — Flutter Routing**
1. Set up `GoRouter` with `/login` and `/dashboard` routes
2. Implement auth redirect logic
3. Create `MaterialApp.router` with router config
4. Wire `refreshListenable` to `AuthProvider`
5. Create placeholder dashboard screen with bottom nav scaffold

**Step 11 — Flutter Tests**
1. Write widget tests for login screen
2. Write unit tests for auth provider
3. Write unit tests for auth repository (mocked)
4. Verify all pass

---

## 6. Development Checklist

### 6.1 Laravel Backend

**Project Setup**
- [ ] Create Laravel 12 project (`composer create-project laravel/laravel backend`)
- [ ] Install Sanctum (`composer require laravel/sanctum`)
- [ ] Publish Sanctum config (`php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"`)
- [ ] Run `php artisan install:api` (Laravel 12 scaffolding)
- [ ] Configure `.env` with MySQL connection (`DB_DATABASE=dys_fms`)
- [ ] Configure `config/cors.php` (allow Flutter origins)
- [ ] Verify `php artisan serve` starts without errors
- [ ] Create MySQL database `dys_fms`

**Migration: Business Sectors**
- [ ] Create migration `0001_create_business_sectors_table.php`
- [ ] Add columns: id (PK), name (VARCHAR, UNIQUE), description (TEXT, nullable), created_at (TIMESTAMP)
- [ ] Run migration (`php artisan migrate`)

**Migration: Users**
- [ ] Create migration `0002_create_users_table.php`
- [ ] Add columns: id, name, email (UNIQUE), password (VARCHAR 60), role (ENUM with 3 values), sector_id (FK nullable → business_sectors.id, ON DELETE SET NULL), account_status (ENUM: Active/Inactive, default Active), created_at
- [ ] Run migration

**Migration: Sales Transactions**
- [ ] Create migration `0003_create_sales_transactions_table.php`
- [ ] Add columns: id, user_id (FK → users.id, RESTRICT), sector_id (FK → business_sectors.id, RESTRICT), amount (DECIMAL), description (TEXT, nullable), recorded_at (TIMESTAMP)
- [ ] Run migration

**Migration: Payroll Records**
- [ ] Create migration `0004_create_payroll_records_table.php`
- [ ] Add columns: id, user_id (FK → users.id, RESTRICT), sector_id (FK → business_sectors.id, RESTRICT), hours_worked (DECIMAL 10,2), hourly_rate (DECIMAL 10,2), computed_salary (DECIMAL 10,2), pay_period (DATE), calculated_at (TIMESTAMP)
- [ ] Run migration

**Migration: Expenses**
- [ ] Create migration `0005_create_expenses_table.php`
- [ ] Add columns: id, user_id (FK → users.id, RESTRICT), sector_id (FK → business_sectors.id, RESTRICT), amount (DECIMAL), description (TEXT, nullable), recorded_at (TIMESTAMP), payroll_record_id (FK → payroll_records.id, RESTRICT, nullable)
- [ ] Run migration

**All Migrations**
- [ ] Verify `php artisan migrate` completes with zero errors
- [ ] Verify all 5 tables exist in MySQL with correct columns

**Models**
- [ ] Create `User.php` model with HasApiTokens, fillable, casts, password mutator, relationships
- [ ] Create `BusinessSector.php` model with fillable, relationships
- [ ] Create `SalesTransaction.php` model (placeholder) with fillable, relationships
- [ ] Create `Expense.php` model (placeholder) with fillable, relationships
- [ ] Create `PayrollRecord.php` model (placeholder) with fillable, relationships

**Seeders**
- [ ] Create `BusinessSectorSeeder.php` — 4 sectors
- [ ] Create `UserSeeder.php` — 1 Business Owner with BCrypt password
- [ ] Update `DatabaseSeeder.php` to call seeders in correct order
- [ ] Run `php artisan db:seed`
- [ ] Verify sectors and Business Owner exist in database

**AuthService**
- [ ] Create `app/Services/AuthService.php`
- [ ] Implement `login()` with credential validation
- [ ] Implement inactive account check with generic error (BR-41, BR-43)
- [ ] Implement default sector resolution (BR-34, BR-35, BR-36)
- [ ] Implement Sanctum token creation
- [ ] Implement `logout()` with token revocation
- [ ] Implement `getDefaultSector()` private method

**LoginRequest**
- [ ] Create `LoginRequest.php` with rules: email required|email, password required|string
- [ ] Set custom error messages matching E01, E02, E04

**AuthController**
- [ ] Create `AuthController.php` with AuthService injection
- [ ] Implement `login()` returning 200 or 401
- [ ] Implement `logout()` returning 200
- [ ] Ensure error responses match API Specification exactly

**Routes**
- [ ] Define `POST /api/login` (public)
- [ ] Define `POST /api/logout` (auth:sanctum)
- [ ] Verify routes with `php artisan route:list`

**Backend Tests**
- [ ] Configure PHPUnit for SQLite in-memory testing
- [ ] Write test: BO login returns 200 + token + role + default sector (TC-FR001-01)
- [ ] Write test: EM login returns 200 + assigned sector (TC-FR001-02)
- [ ] Write test: Invalid credentials returns 401 with generic message (TC-FR001-03)
- [ ] Write test: Inactive account returns 401 with generic message, no status disclosure (TC-FR001-04)
- [ ] Write test: Logout revokes token and subsequent requests fail
- [ ] Write test: Accessing protected endpoint without token returns 401
- [ ] Write test: Validation errors return 422 with correct messages
- [ ] Run `php artisan test` — all pass

### 6.2 Flutter Frontend

**Project Setup**
- [ ] Create Flutter project (`flutter create --org com.dys.fms dys_fms`)
- [ ] Add dependencies to `pubspec.yaml`
- [ ] Run `flutter pub get`
- [ ] Create folder structure under `lib/`
- [ ] Verify `flutter run` launches default app

**Configuration**
- [ ] Create `api_config.dart` with base URL and endpoint constants
- [ ] Create `theme.dart` with Material 3 theme using UI Style Guide tokens

**Secure Storage**
- [ ] Create `secure_storage.dart` with save/get/delete for token and user data
- [ ] Verify platform-specific setup (Android: minSdkVersion for encrypting shared preferences, no additional config for API 23+)

**API Layer**
- [ ] Create `api_client.dart` with Dio singleton
- [ ] Create `auth_interceptor.dart` for Bearer token injection
- [ ] Handle 401 responses in interceptor (trigger logout)
- [ ] Add error mapping utility for user-friendly messages

**Data Models**
- [ ] Create `login_request.dart`
- [ ] Create `user_model.dart` with role-check getters
- [ ] Create `login_response.dart` with nested DefaultSector

**Repository**
- [ ] Create `auth_repository.dart` with login, logout, isAuthenticated, getStoredUser
- [ ] Test repository with mock API client

**State Management**
- [ ] Create `auth_state.dart`
- [ ] Create `auth_provider.dart` with login, logout, checkAuthStatus, clearError
- [ ] Test provider with mock repository

**Routing**
- [ ] Create `app_router.dart` with GoRouter + auth redirect
- [ ] Register route placeholders for all 8 screens
- [ ] Wire `refreshListenable` to AuthProvider

**Login Screen**
- [ ] Build DYS logo widget
- [ ] Build title and subtitle text
- [ ] Build email TextField with email keyboard type
- [ ] Build password TextField with obscured input
- [ ] Build Log In ElevatedButton with primary styling
- [ ] Build error message container (hidden by default)
- [ ] Implement form validation (email format, non-empty)
- [ ] Implement loading state (button spinner, fields disabled)
- [ ] Connect to AuthProvider.login()
- [ ] Navigate to dashboard on success

**Dashboard Placeholder**
- [ ] Create dashboard_screen.dart with app bar and title
- [ ] Add avatar button with user initials
- [ ] Add logout button in avatar dropdown
- [ ] Add bottom navigation bar with role-based items
- [ ] Wire logout to AuthProvider.logout()

**App Entry Point**
- [ ] Create `app.dart` with MaterialApp.router + MultiProvider
- [ ] Update `main.dart` to initialize dependencies and run app

**Flutter Tests**
- [ ] Write widget test: login screen renders correctly
- [ ] Write widget test: empty form shows validation errors
- [ ] Write widget test: login loading state
- [ ] Write widget test: login error displays error message
- [ ] Write unit test: auth provider login success
- [ ] Write unit test: auth provider login failure
- [ ] Write unit test: auth provider logout clears state
- [ ] Run `flutter test` — all pass

### 6.3 Integration (End-to-End)

- [ ] Start Laravel backend: `php artisan serve`
- [ ] Run Flutter app: `flutter run`
- [ ] Verify login screen loads on Flutter
- [ ] Log in as Business Owner (owner@dys.com)
- [ ] Verify token received and stored
- [ ] Verify redirected to dashboard (placeholder)
- [ ] Verify dashboard shows "Dashboard" title + avatar initials
- [ ] Verify bottom nav shows 6 items (Owner)
- [ ] Verify logout clears token and returns to login
- [ ] Verify accessing authenticated screen without token redirects to login
- [ ] Verify invalid credentials show error on login screen
- [ ] Verify inactive account shows generic error on login screen
- [ ] Verify login as non-Owner routes to dashboard with appropriate bottom nav items (test after seeding EM/EE in a later phase)

---

## 7. Risks During Implementation

Only risks documented in the approved blueprint. No new risks are introduced.

### From Concept Paper — Software Engineering Challenges

| # | Risk | Phase 1 Impact | Mitigation |
|:-:|------|----------------|:-----------|
| R1 | **Password encryption and authentication security** | Sanctioned token generation and storage must be secure. If token is leaked, attacker gains authenticated access. | Sanctum uses BCrypt hashing + random token strings. Token stored in `flutter_secure_storage` (Android Keystore / iOS Keychain). Token never persisted in plaintext or SharedPreferences. |
| R3 | **Data migration from manual formats** | Business Owner must manually enter the 4 sectors and their own account. No import mechanism exists. | Seeders handle initial data. Manual entry is the approved workflow. |
| C1 | **Six-month time constraint** | Phase 1 is the foundation — delays here cascade to all later phases. | Phase 1 is self-contained with clear exit criteria. No dependencies on external teams or services. |
| C3 | **Student developers with evolving skills** | Sanctum configuration, Flutter secure storage, GoRouter auth redirect — each has a learning curve. | Each step has explicit documentation references. Start with well-known Laravel patterns before Flutter auth implementation. |

### From Blueprint — Architectural Risks

| # | Risk | Phase 1 Impact | Mitigation |
|:-:|------|----------------|:-----------|
| R4 | **No DELETE endpoints** | Not applicable in Phase 1 (auth has no data mutation beyond token creation). | Foundations are correctly set — no DELETE introduced. |
| R5 | **Sector context client-side** | Login response must correctly include `default_sector`. If sector resolution is wrong, all subsequent data will be scoped incorrectly. | `AuthService.getDefaultSector()` explicitly implements BR-34/BR-35/BR-36. Tested in TC-FR001-01 and TC-FR001-02. |
| R6 | **Temporary password visible once** | Not applicable in Phase 1 (User Management is Phase 2). | No risk in Phase 1. |

### Implementation-Specific Risks

| # | Risk | Mitigation |
|:-:|------|:-----------|
| I1 | **MySQL connection fails** during first migration | Verify `.env` credentials match MySQL running instance. Create database `dys_fms` manually before migrating. |
| I2 | **Flutter secure storage requires minSdkVersion 18+** | Flutter's default project already sets `minSdkVersion 21` (Android). No additional config needed. |
| I3 | **CORS blocking Flutter requests during development** | Set `'allowed_origins' => ['*']` in `config/cors.php` for dev. For staging/production, restrict to specific origins. |
| I4 | **GoRouter redirect loop** if auth state is not initialized before routing | Use `refreshListenable` tied to `AuthProvider`. Initialize `checkAuthStatus()` in app startup before `MaterialApp.router` builds. |
| I5 | **Token expiry during development** | Set token expiry to `null` or a long duration (e.g., 365 days) in Sanctum config during development. Production expiry should be defined later. |

---

## 8. Completion Criteria

Phase 1 is complete and ready to move to Phase 2 (User Account Management) when ALL of the following criteria are met:

### 8.1 Database

| # | Criterion | Verification |
|:-:|-----------|:-------------|
| D1 | All 5 database tables exist with correct columns, types, and constraints | `DESCRIBE` each table matches Database Schema |
| D2 | All 8 foreign key constraints are active | `SELECT * FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY'` |
| D3 | Business Sectors table has exactly 4 seeded rows: DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories | `SELECT * FROM business_sectors` |
| D4 | Users table has exactly 1 Business Owner: owner@dys.com, role=Business Owner, sector_id=NULL, account_status=Active, password BCrypt-hashed | `SELECT * FROM users` |

### 8.2 Backend

| # | Criterion | Verification |
|:-:|-----------|:-------------|
| B1 | `POST /api/login` returns 200 with token, user object, and default_sector for valid credentials | API test TC-FR001-01, TC-FR001-02 |
| B2 | `POST /api/login` returns 401 with "Invalid username or password." for invalid credentials | API test TC-FR001-03 |
| B3 | `POST /api/login` returns 401 with "Invalid username or password." for inactive accounts (no status disclosure) | API test TC-FR001-04 |
| B4 | `POST /api/login` returns 422 with correct error messages for empty/invalid email and empty password | Validation test |
| B5 | `POST /api/logout` returns 200 and revokes the token | API test |
| B6 | Authenticated endpoints return 401 when no token is provided | API test |
| B7 | All 5 Eloquent models exist with correct relationships | Unit test or manual verify |
| B8 | Business Owner login returns `default_sector.id = 1` (DYS Events) | TC-FR001-01 |
| B9 | All backend feature tests pass (TC-FR001-01 through TC-FR001-04) | `php artisan test` — 0 failures |

### 8.3 Flutter

| # | Criterion | Verification |
|:-:|-----------|:-------------|
| F1 | Login screen renders with email field, password field, Log In button | Widget test |
| F2 | Form validation shows errors for empty/invalid email and empty password | Widget test |
| F3 | Login button shows loading state when tapped | Widget test |
| F4 | Successful login stores token in secure storage and navigates to Dashboard | Integration test |
| F5 | Failed login shows error message on login screen | Widget test |
| F6 | Logout clears token and returns to login screen | Integration test |
| F7 | Unauthenticated user is redirected to login for any protected route | GoRouter redirect test |
| F8 | Dashboard placeholder shows title, avatar, and role-based bottom nav | Widget test |
| F9 | Inter font renders correctly in theme | Visual test |
| F10 | All Flutter tests pass | `flutter test` — 0 failures |

### 8.4 Integration (End-to-End)

| # | Criterion | Verification |
|:-:|-----------|:-------------|
| E1 | Flutter app connects to Laravel API via HTTP | Manual: login flow works end-to-end |
| E2 | Token flows: API issues → Flutter stores → Flutter attaches to subsequent requests → API validates | Manual: log in, then verify authenticated request returns 200 |
| E3 | Invalid credentials error: API returns 401 → Flutter displays "Invalid username or password." | Manual: enter wrong password, see error on login screen |
| E4 | Logout: Flutter calls API → token revoked → redirected to login → can't access dashboard without re-login | Manual: log in, log out, try navigating to dashboard |

### 8.5 Required Test Case Pass Rates

| TC ID | Test | Phase 1 Required |
|-------|------|:----------------:|
| TC-FR001-01 | BO login — success, default sector = DYS Events | MUST PASS |
| TC-FR001-02 | EM/Employee login — success, assigned sector | MUST PASS |
| TC-FR001-03 | Invalid credentials — generic error 401 | MUST PASS |
| TC-FR001-04 | Inactive account — generic error 401, no disclosure | MUST PASS |

### 8.6 Gate to Phase 2

Phase 1 is considered COMPLETE when:

- [ ] All 5 database tables migrated and seeded
- [ ] All 8 FKs verified in MySQL
- [ ] All 4 login test cases pass (PHPUnit + Flutter)
- [ ] Login/logout round-trip works end-to-end (Flutter → API → DB → API → Flutter)
- [ ] Token management works: issue → store → attach → validate → revoke
- [ ] Role-based default sector works for all 3 roles
- [ ] Flutter app starts, shows login screen, can authenticate successfully
- [ ] 0 failing tests in both Laravel (`php artisan test`) and Flutter (`flutter test`)

**Phase 2 (User Account Management) may begin immediately after the above checklist is 100% complete.**
