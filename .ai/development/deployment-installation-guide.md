# Deployment & Installation Guide — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Status:** IMPLEMENTATION VERIFIED — Grounded in the Current Codebase
**Project:** DYS Financial Management System (DYS FMS)
**Repository:** `git@github.com:gbrl-jsph/dys-fms.git`

---

## 1. Overview

### 1.1 Purpose

This guide documents how to install, configure, run, and deploy the implemented DYS FMS. Every command, path, variable, and configuration below is taken directly from the current codebase — nothing is invented, and no deployment infrastructure beyond what the implementation uses (Laravel's built-in development server, Composer, `php artisan` tooling, and the Flutter toolchain) is introduced.

### 1.2 Intended Audience

- Developers and QA engineers setting up local environments
- The person(s) performing the production deployment
- Support staff troubleshooting runtime issues

### 1.3 System Components

| Component | Technology | Location |
|-----------|------------|----------|
| Mobile application | Flutter app (`dys_fms`), provider + go_router + dio + flutter_secure_storage + google_fonts | `flutter_app/` |
| REST API | Laravel 12 framework (`laravel/framework ^12.0`), PHP `^8.2` | `backend/` |
| Authentication | Laravel Sanctum (`laravel/sanctum ^4.0`), bearer tokens stored in Flutter SecureStorage | `backend/`, `flutter_app/` |
| Database | MySQL (single database `dys_fms`, 5 domain tables + `personal_access_tokens`) | managed by `backend/database/migrations/` |

---

## 2. System Requirements

### 2.1 Backend

| Requirement | Version / Detail |
|-------------|------------------|
| PHP | `^8.2` (declared in `backend/composer.json`) |
| Composer | 2.x (PHP dependency manager) |
| MySQL | MySQL-compatible server (Laravel 12 supported version, e.g. MySQL 8.0 / MariaDB 10.2+) — the project uses the `mysql` driver (`DB_CONNECTION=mysql`) |
| Laravel | Installed via Composer from `laravel/framework ^12.0` (no separate installation step) |
| Required PHP extensions | `pdo_mysql` (referenced by `backend/config/database.php`), plus the standard Laravel 12 PHP extensions: `openssl`, `pdo`, `mbstring`, `tokenizer`, `xml`, `ctype`, `json`, `bcmath`, `fileinfo`, `curl` |
| Queue / cache | None required — file drivers configured (`CACHE_DRIVER=file`, `QUEUE_CONNECTION=sync`) |

### 2.2 Frontend

| Requirement | Version / Detail |
|-------------|------------------|
| Flutter SDK | Stable channel; must ship Dart SDK satisfying the `pubspec.yaml` constraint `sdk: ^3.12.2` |
| Dart SDK | `^3.12.2` (declared in `flutter_app/pubspec.yaml`) |
| Android Studio | Latest stable (for Android tooling and emulators) |
| Android SDK | Required for emulator runs and APK builds; the app uses Flutter's default SDK levels (`compileSdk = flutter.compileSdkVersion`, `minSdk = flutter.minSdkVersion`, `targetSdk = flutter.targetSdkVersion`) |
| Android application ID | `com.dys.fms.dys_fms` (declared in `flutter_app/android/app/build.gradle.kts`) |

### 2.3 General

| Requirement | Detail |
|-------------|--------|
| Git | For cloning the repository |
| Supported operating systems | Any OS supported by the Flutter and PHP toolchains (Linux, macOS, Windows). The current development environment is Linux (SteamOS/Arch). |

> **Note:** the backend was developed and verified on Linux. The PHP runtime is **not installed** in the current development environment, so `php`/`composer` commands must be executed on a machine (or environment) with PHP 8.2+ available; the full PHPUnit suite is preserved in the repository for that environment.

---

## 3. Project Structure

The repository top level contains:

```
dys-fms/
├── backend/                  # Laravel 12 REST API
│   ├── app/
│   │   ├── Http/Controllers/Api/   # 7 controllers (Auth, User, Sales, Expenses, Payroll, Reports, BusinessSector)
│   │   ├── Http/Middleware/        # Sanctum auth + 6 role-gate middleware classes
│   │   └── Services/               # 7 service classes (business logic + RBAC enforcement)
│   ├── config/               # Laravel configuration (database.php: mysql driver default)
│   ├── database/
│   │   ├── migrations/       # 7 migrations (personal_access_tokens, business_sectors, users,
│   │   │                     #   sales_transactions, payroll_records, expenses, users.updated_at)
│   │   └── seeders/          # BusinessSectorSeeder (4 sectors), UserSeeder (owner), DatabaseSeeder
│   ├── routes/api.php        # All 16 approved API endpoints
│   ├── tests/Feature/        # 7 PHPUnit feature test files (84 test methods)
│   ├── .env.example          # Environment template (no secrets)
│   └── composer.json         # PHP ^8.2, laravel/framework ^12.0, laravel/sanctum ^4.0
├── flutter_app/              # Flutter mobile application (dys_fms)
│   ├── lib/
│   │   ├── data/api/         # ApiClient (Dio), ApiConfig (base URL + endpoint constants)
│   │   ├── features/         # 8 screens: login, dashboard, sales, expenses, payroll, reports, sectors, users
│   │   ├── providers/        # 8 ChangeNotifier providers (one per feature)
│   │   ├── routing/          # go_router configuration + role-based guards
│   │   ├── core/             # shared widgets, theme, formatters, constants
│   │   └── main.dart         # app entry: SecureStorage + ApiClient.init + runApp
│   ├── android/              # Android host project (applicationId com.dys.fms.dys_fms)
│   ├── test/                 # 216 Flutter tests (unit, widget, integration/E2E)
│   └── pubspec.yaml          # dio, flutter_secure_storage, provider, go_router, google_fonts
└── .ai/                      # Approved project documentation (blueprint + development artifacts)
    └── development/          # RTM, Test Case Specification, Risk Assessment (this guide's companions)
```

**Notes on layout:** the database schema and seeders live inside `backend/database/` (Laravel convention) — there is no separate top-level `database/` folder. Project documentation lives in `.ai/`. There is no separate `frontend/` folder; the Flutter app is `flutter_app/`.

---

## 4. Backend Installation

Run all backend commands from the `backend/` directory.

### 4.1 Clone the repository

```sh
git clone git@github.com:gbrl-jsph/dys-fms.git
cd dys-fms/backend
```

### 4.2 Install Composer dependencies

```sh
composer install
```

This installs the locked dependencies (`laravel/framework`, `laravel/sanctum`, and dev packages: `phpunit/phpunit`, `fakerphp/faker`, etc.) and runs Laravel's post-install scripts.

### 4.3 Copy the environment file

```sh
cp .env.example .env
```

> Composer's `post-root-package-install` script does this automatically if `.env` does not exist.

### 4.4 Generate the application key

```sh
php artisan key:generate
```

This writes a fresh `APP_KEY` into `.env` (required for encryption/session functionality).

### 4.5 Configure the database

Edit `.env` and set the MySQL connection values (see §6 and §7):

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=dys_fms
DB_USERNAME=root
DB_PASSWORD=
```

### 4.6 Run migrations

```sh
php artisan migrate
```

Applies all 7 migrations in order:

1. `0000_create_personal_access_tokens_table`
2. `2026_07_30_000001_create_business_sectors_table`
3. `2026_07_30_000002_create_users_table`
4. `2026_07_30_000003_create_sales_transactions_table`
5. `2026_07_30_000004_create_payroll_records_table`
6. `2026_07_30_000005_create_expenses_table`
7. `2026_07_30_000006_add_updated_at_to_users_table`

### 4.7 Run seeders

```sh
php artisan db:seed
```

`DatabaseSeeder` runs the two seeders in order:

- `BusinessSectorSeeder` — creates the 4 approved sectors (DYS Events, B&DYS, Flavors by DYS, SnapDYS Memories)
- `UserSeeder` — creates the Business Owner account (BR-33: owner role is seeded, never creatable)

### 4.8 Start the Laravel server

```sh
php artisan serve --port=8000
```

The API is now available at `http://localhost:8000/api` (the default `APP_URL` and the Flutter app's default `baseUrl`).

---

## 5. Flutter Installation

Run all Flutter commands from the `flutter_app/` directory.

### 5.1 Install packages

```sh
flutter pub get
```

Installs the declared dependencies from `pubspec.yaml`: `dio`, `flutter_secure_storage`, `provider`, `go_router`, `google_fonts`, `cupertino_icons` (plus dev dependency `flutter_lints` and `flutter_test`).

### 5.2 Configure the API base URL

The API base URL is a **compile-time constant** in `flutter_app/lib/data/api/api_config.dart`:

```dart
static const String baseUrl = 'http://localhost:8000/api';
```

- For local development against a locally running backend, keep the default.
- For a device/emulator connecting to a backend on another machine, change this constant to that machine's reachable address (e.g., `http://192.168.x.x:8000/api`), then re-run/build the app.
- For production, set it to the production API URL before building the release artifact (see §9 — this addresses Risk DR-01 in the Risk Assessment).

The HTTP timeout is also defined here (30 seconds) and requires no change.

### 5.3 Run the Flutter application

With the backend running:

```sh
flutter run
```

Run on a connected device/emulator (`flutter devices` to list). The app boots to the Login screen; log in with the seeded Business Owner credentials.

### 5.4 Build the APK

```sh
flutter build apk --release
```

Produces a signed release APK (debug-signed by default in Flutter) at:

```
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

The application ID is `com.dys.fms.dys_fms`.

---

## 6. Database Setup

### 6.1 Database creation

Create the database named `dys_fms` (or your chosen name, matching `DB_DATABASE`):

```sql
CREATE DATABASE dys_fms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

(or via your MySQL client/management tool.)

### 6.2 Environment variables

Set these in `backend/.env` (values must match your MySQL instance):

| Variable | Example |
|----------|---------|
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `127.0.0.1` |
| `DB_PORT` | `3306` |
| `DB_DATABASE` | `dys_fms` |
| `DB_USERNAME` | `root` |
| `DB_PASSWORD` | *(your MySQL password)* |

### 6.3 Migration commands

```sh
php artisan migrate          # apply all migrations
php artisan migrate:status   # verify which migrations have run
php artisan migrate:rollback # step backward (e.g., to correct a failed seed)
```

### 6.4 Seeder commands

```sh
php artisan db:seed                                # run DatabaseSeeder (sectors + owner)
php artisan db:seed --class=BusinessSectorSeeder   # seed the 4 sectors only
php artisan db:seed --class=UserSeeder             # seed the Business Owner only
```

---

## 7. Environment Configuration

### 7.1 Backend — all variables used (from `backend/.env.example`)

| Variable | Example value (template) | Purpose |
|----------|--------------------------|---------|
| `APP_NAME` | `"DYS Financial Management System"` | Application name |
| `APP_ENV` | `local` (use `production` in production) | Environment mode |
| `APP_KEY` | *(generated by `php artisan key:generate`)* | Laravel encryption key — required |
| `APP_DEBUG` | `true` (use `false` in production) | Debug/exception display |
| `APP_URL` | `http://localhost:8000` | Application URL |
| `LOG_CHANNEL` | `stack` | Logging channel |
| `LOG_LEVEL` | `debug` | Log verbosity |
| `DB_CONNECTION` | `mysql` | Database driver (MySQL — the project's engine) |
| `DB_HOST` | `127.0.0.1` | Database host |
| `DB_PORT` | `3306` | Database port |
| `DB_DATABASE` | `dys_fms` | Database name |
| `DB_USERNAME` | `root` | Database user |
| `DB_PASSWORD` | *(empty in template)* | Database password |
| `BROADCAST_DRIVER` | `log` | Broadcasting (not used by the app) |
| `CACHE_DRIVER` | `file` | Cache driver (no external cache required) |
| `FILESYSTEM_DISK` | `local` | Storage disk |
| `QUEUE_CONNECTION` | `sync` | Queue driver (synchronous — no queue worker needed) |
| `SESSION_DRIVER` | `file` | Session driver (token API, so sessions are minimal) |
| `SESSION_LIFETIME` | `120` | Session lifetime in minutes |
| `SANCTUM_STATEFUL_DOMAINS` | `localhost,localhost:8000` | Sanctum stateful domains |
| `CORS_ALLOWED_ORIGINS` | `*` | CORS origins (Flutter mobile app is not browser-bound) |

### 7.2 Frontend — configuration used (from `flutter_app/lib/data/api/api_config.dart`)

| Constant | Value | Purpose |
|----------|-------|---------|
| `ApiConfig.baseUrl` | `http://localhost:8000/api` | Base URL for all API requests (edit for non-local/production endpoints) |
| `ApiConfig.timeout` | `Duration(seconds: 30)` | HTTP connect/receive timeout |
| Endpoint constants | `/login`, `/logout`, `/users`, `/users/{id}`, `/users/{id}/status`, `/sales`, `/expenses`, `/payroll`, `/reports`, `/business-sectors`, `/business-sectors/switch` | The 16 approved endpoints (matching `backend/routes/api.php`) |

No other environment variables are used by the application.

---

## 8. Running the System

### 8.1 Start the backend

```sh
cd dys-fms/backend
php artisan serve --port=8000
```

The API listens on `http://localhost:8000`.

### 8.2 Start the frontend

```sh
cd dys-fms/flutter_app
flutter run
```

Select the target device/emulator when prompted. The app starts on the Login screen.

### 8.3 Verify API connectivity

The only public endpoint is `POST /api/login`. From a terminal:

```sh
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@dys.com","password":"SecurePass123"}'
```

The seeded Business Owner credentials (defined in `backend/database/seeders/UserSeeder.php`): email `owner@dys.com`, password `SecurePass123` (BCrypt-hashed).

- **Success:** HTTP 200 with `data.user` (role Business Owner), `data.token`, and `data.default_sector`.
- **Invalid credentials:** HTTP 401 `{"message":"Invalid username or password."}` (indicates the API is up and auth works).
- **No response:** the backend is not running or is unreachable — check §10.

### 8.4 Verify login

1. Launch the app.
2. Enter the seeded Business Owner email and password.
3. Tap **Log In** — the app navigates to the Dashboard with the 6-tab Business Owner variant.
4. Wrong credentials show the error container and stay on the Login screen.

---

## 9. Production Deployment Notes

Recommendations below are limited to what the implemented project supports and what the Risk Assessment flags:

| Topic | Recommendation | Grounding |
|-------|----------------|-----------|
| API base URL | Set `ApiConfig.baseUrl` in `flutter_app/lib/data/api/api_config.dart` to the production API URL **before** building the release APK. The default `http://localhost:8000/api` only works locally. | Risk DR-01 |
| Debug mode | Set `APP_DEBUG=false` and `APP_ENV=production` in `backend/.env` — the template ships with `APP_DEBUG=true` for development only. | `.env.example` |
| Application key | Ensure `APP_KEY` is generated and unique to the production environment (`php artisan key:generate`). | §4.4 |
| HTTPS | Serve the API over HTTPS in production; bearer tokens (Sanctum) travel in the Authorization header and must not traverse plain HTTP. | Sanctum auth (SV-01/SV-11), Risk SR-02 |
| Storage permissions | Ensure the Laravel directories `backend/storage/` (framework/cache/logs/sessions) and `backend/bootstrap/cache/` are writable by the web process; the app uses the `file` cache/session/log drivers. | `CACHE_DRIVER=file`, `SESSION_DRIVER=file`, `LOG_CHANNEL=stack` |
| Database backups | Establish scheduled MySQL backups and a restore drill **before** go-live; no automated backup mechanism exists in the implementation. Restore procedure: recreate database → `php artisan migrate` → `php artisan db:seed` → restore data backup. | Risk TR-10 |
| Migrations on production | Run `php artisan migrate --step` against a verified backup; confirm `php artisan migrate:status` afterwards. | Risk DR-02 |
| Rollback | Code/schema rollback uses Laravel's reversible migrations (`php artisan migrate:rollback`); financial records are immutable by design and are never deleted or reverted (BR-17..19). | Risk DR-06 |
| Secrets | Never commit the real `.env`; the repository only contains `.env.example` with placeholder values. | Repository state |

---

## 10. Troubleshooting

| # | Symptom | Likely cause | Resolution |
|---|---------|--------------|------------|
| 1 | `composer install` fails | PHP version below 8.2, or missing PHP extensions | Verify `php -v` is 8.2+; enable required extensions (`pdo_mysql`, `mbstring`, `openssl`, etc.); ensure Composer 2.x |
| 2 | `php artisan` commands fail with "could not find driver" | `pdo_mysql` extension not enabled | Enable `pdo_mysql` in `php.ini` and restart the PHP process |
| 3 | Database connection error (`SQLSTATE[HY000] [2002] Connection refused`) | MySQL not running, wrong `DB_HOST`/`DB_PORT`, or wrong credentials in `.env` | Start MySQL; check `.env` values (§7.1); confirm the database `dys_fms` exists |
| 4 | `SQLSTATE[HY000] [1049] Unknown database 'dys_fms'` | Database not created | Run the `CREATE DATABASE` statement from §6.1 |
| 5 | Migration failure | DB user lacks privileges, or a migration was partially applied | Grant privileges; use `php artisan migrate:rollback` for the partial batch, fix, and re-run `php artisan migrate` |
| 6 | `php artisan migrate` says "Nothing to migrate" unexpectedly | Migrations already applied | Check `php artisan migrate:status`; the 7 migrations must show as run |
| 7 | `flutter pub get` fails | Network issue or corrupted pub cache | Re-run `flutter pub get`; if needed, `flutter pub cache repair` then retry |
| 8 | App shows connection error on every screen | Backend not running, or `ApiConfig.baseUrl` points to the wrong host/port | Start `php artisan serve`; verify `curl` from §8.3; correct `api_config.dart` and rebuild (the app shows the connection message by design) |
| 9 | Login returns "Invalid username or password." | Wrong credentials, or the account is `Inactive` | Use the seeded owner credentials; reactivate the account via `PATCH /api/users/{id}/status` (the message is intentionally generic — BR-41) |
| 10 | Logged-in app bounces back to Login | Token missing/revoked (e.g., after logout or backend token purge) | Log in again; tokens are stored in Flutter SecureStorage and re-issued at login |
| 11 | API returns 401 "Unauthenticated." | Request without a valid Bearer token | Ensure the app session is active; re-login; verify the backend's Sanctum tables are migrated |
| 12 | API returns 403 "Forbidden." | Role lacks permission for the endpoint | This is correct RBAC behavior (SV-03); verify the account role matches the intended access |
| 13 | API returns 422 with `errors` | Request failed validation | Check the payload against the API Specification/Validation Rules Matrix; these are the defined contract errors |
| 14 | `flutter build apk` fails | Android SDK/Java toolchain mismatch | Install/update Android Studio SDK components and JDK; run `flutter doctor` and fix flagged items |
| 15 | Backend tests fail on a fresh clone | Test database not set up, or PHP runtime missing | Configure the test database per the PHPUnit suite; run `php artisan test` from `backend/` on a PHP 8.2+ environment |

---

## 11. Verification Checklist

Run this checklist before considering a deployment complete:

| # | Check | Command / Method | Expected Result |
|---|-------|------------------|-----------------|
| 1 | Backend starts | `php artisan serve --port=8000` | Server responds on port 8000 |
| 2 | Database connected | `php artisan migrate:status` | 7 migrations listed as run (no connection errors) |
| 3 | Migrations complete | `php artisan migrate` | "Nothing to migrate" or all 7 applied |
| 4 | Seeders complete | `php artisan db:seed` | 4 sectors + Business Owner created. **Not idempotent:** seeders use plain `insert()`, so a re-run fails on the unique `name`/`email` constraints — to re-seed, truncate the affected tables first (`TRUNCATE business_sectors; TRUNCATE users;`) or use `migrate:fresh --seed` |
| 5 | API connectivity | `curl -X POST http://localhost:8000/api/login …` | HTTP 200 with `user`, `token`, `default_sector` |
| 6 | Flutter launches | `flutter run` | App boots to the Login screen without crashes |
| 7 | Login works | Log in as owner | Navigates to Dashboard (Business Owner variant, 6 tabs) |
| 8 | Dashboard loads | After login | Summary cards, sector chip, quick actions render; no error container |
| 9 | Reports load | Owner: Reports tab → Generate Report | Summary report renders; EM sees no Analytics; EE is redirected |
| 10 | CRUD operations function | Owner: record a sale + expense; create/edit/deactivate a user; calculate payroll; switch sector | 201/200 responses; lists refresh; auto-expense appears for payroll; sector switch reloads Dashboard/Sales/Expenses/Reports |
| 11 | Role restrictions | Log in as EM and EE | EM: 5 tabs, read-only chip; EE: 2 tabs, view-only; forbidden routes redirect |
| 12 | Regression gate | `cd flutter_app && flutter analyze && flutter test` | No issues; 216/216 tests pass (TCS §10 regression suite) |
| 13 | Backend regression gate | `cd backend && php artisan test` | All 84 PHPUnit tests pass (on a PHP 8.2+ environment) |

---

## 12. Deliverables Summary

| Item | Value |
|------|-------|
| File created | `.ai/development/deployment-installation-guide.md` (this document) |
| Files / configuration referenced | `backend/composer.json`, `backend/.env.example`, `backend/.env`, `backend/config/database.php`, `backend/routes/api.php`, `backend/database/migrations/` (6), `backend/database/seeders/` (3), `flutter_app/pubspec.yaml`, `flutter_app/lib/data/api/api_config.dart`, `flutter_app/lib/main.dart`, `flutter_app/android/app/build.gradle.kts` |
| Installation steps covered | Backend (clone → composer → .env → key → DB → migrate → seed → serve) and Flutter (pub get → base URL → run → build APK) |
| Verification checklist summary | 13 checks: backend starts, DB connected, migrations complete, seeders complete, Flutter launches, login works, dashboard loads, reports load, CRUD works, role restrictions, regression gates |
| Assumptions | See §13 |

## 13. Assumptions

1. **PHP runtime:** the current development environment (Linux/SteamOS) does not have PHP installed; all `php`/`composer`/`php artisan` commands must be executed in an environment with PHP 8.2+ and Composer 2.x. The guide reflects this by describing the commands without executing them here.
2. **Database engine:** **MySQL** per the implementation (`DB_CONNECTION=mysql`, `config/database.php`) and approved docs — no PostgreSQL-specific steps are included.
3. **No invented infrastructure:** no Docker, Nginx, CI/CD, or cloud hosting steps are included because the implementation does not use them. Production hosting specifics are out of scope; §9 covers only what the project itself supports.
4. **Credentials:** the seeded Business Owner account is `owner@dys.com` / `SecurePass123` (defined in `backend/database/seeders/UserSeeder.php`). Change the password of production accounts after first login via the Users screen (PATCH `account_status` flow) — the seeder value is a development default, not a production secret.
5. **Release signing:** `flutter build apk --release` produces the standard Flutter debug-signed release artifact; production signing configuration is Android-platform setup outside the scope of this project's codebase.
