# Deployment & Testing Guide for Beginners — DYS Financial Management System (DYS FMS)

**Version:** 1.0
**Purpose:** Deploy the DYS FMS Laravel backend on a clean machine **for testing** (not production) and run a live SMTP (email) validation.
**Environment tested on:** Arch Linux (SteamOS) — PHP 8.4.10, Composer 2.8.10, MariaDB 11.8.2 — all steps below verified against the actual release candidate.

---

## 0. How to use this guide

Every section has two things: **what to run** and **why it matters**. If you are a beginner, read the "why" — it teaches you how the pieces fit together. The commands all run from a terminal.

- On **Windows**, install WSL2 first and run everything inside the WSL terminal (until you reach the "Start the server / API testing" sections, which can be done on Windows too).
- On **Linux / macOS**, use your normal terminal.

This guide uses the **MySQL/MariaDB** database and the **Laravel** framework. Always run Laravel commands from inside the `backend` folder (unless the guide says otherwise).

---

## 1. Prerequisites

Before anything else, install four tools. "Prerequisites" means: the tools the project needs to build, run, and connect.

### 1.1 PHP 8.2 or newer

PHP executes the Laravel code. Check what version is installed:

```sh
php -v
```

**Expect something like:** `PHP 8.4.10 (cli) ...`

If `php` is not found (or the version is below 8.2), install it:

- **Windows with WSL (Ubuntu):** `sudo apt update && sudo apt install -y php php-cli php-mbstring php-xml php-curl php-bcmath php-fileinfo php-mysql zip unzip`
- **Debian/Ubuntu:** same command as above.
- **Arch / SteamOS:** `sudo pacman -S php composer` (then edit `/etc/php/php.ini` to enable `extension=pdo_mysql`).

### 1.2 PHP extensions

Laravel needs several extensions loaded *inside PHP*. Verify them:

```sh
php -m
```

Look for these names in the list: `pdo_mysql`, `mbstring`, `openssl`, `curl`, `bcmath`, `fileinfo`, `tokenizer`, `xml`, `ctype`, `json`, `pdo`. They must be **uncommented** (no `;` in front) in your `php.ini` file. On Ubuntu/Arch the line looks like:

```ini
extension=pdo_mysql
extension=bcmath
```

If an extension is missing, uncomment the matching line and restart PHP (on WSL run `sudo systemctl restart apache2` or simply close/reopen the terminal).

### 1.3 Composer

Composer is PHP's package manager — it downloads the Laravel framework and all libraries the project uses. Verify:

```sh
composer --version
```

Should print something like `Composer version 2.8.10 ...`. Install via the official installer: `https://getcomposer.org/download/` (or `sudo apt install composer` on Ubuntu).

### 1.4 MySQL (or MariaDB)

The database where all records (users, sales, expenses, ...) are stored. Verify the server connects:

```sh
mysql --version
```

If not installed: `sudo apt install -y mysql-server` (Ubuntu) or `sudo pacman -S mariadb mariadb-client` (Arch/SteamOS, then `sudo systemctl start mariadb`). You also need a **database user** — either root, or a dedicated user like `dys_fms`. We will create the database itself in section 4.

### 1.5 Git

Downloads/clones the project and tracks changes.

```sh
git --version
```

Install with `sudo apt install git` / `winget install Git.Git` / `brew install git`.

### 1.6 Node.js — **not required**

This project has **no front-end build step** (the mobile app is Flutter, and it does not need Node). You can skip Node entirely. A common beginner mistake is to install it because Laravel "used to" need it — this project does not.

---

## 2. Clone the project

"Clone" means: download a copy of the code to your machine.

```sh
git clone git@github.com:gbrl-jsph/dys-fms.git
cd dys-fms/backend
```

- `git clone ...` — copies the whole repository (backend + Flutter app + docs) into a new folder `dys-fms`.
- `cd dys-fms/backend` — moves you into the Laravel backend, the part we are deploying.

Install the PHP dependencies with Composer:

```sh
composer install
```

**What it does:** reads `backend/composer.json` (the "shopping list" of libraries — Laravel framework, Sanctum auth, PHPUnit test runner, etc.), downloads them into `backend/vendor/`, and creates the `backend/vendor/autoload.php` that PHP uses to find classes at runtime. When it finishes you should see "Generating optimized autoload files".

> If at this point you see an error about a PHP extension missing (e.g. `zip`), go back to section 1.3.

---

## 3. Environment setup

Laravel keeps *configuration values* (database name, mail server, etc.) in a file called `.env`. Every project has a built-in **template** called `.env.example` that you must copy:

```sh
cp .env.example .env
```

(The copy is owned by you and is never committed to Git, which is why important secrets go here.)

Then generate the application encryption key. Laravel uses this key to encrypt tokens/cookies/passwords:

```sh
php artisan key:generate
```

It writes a line like `APP_KEY=base64:...` into your `.env`.

### The important variables in `.env`

Open `.env` with any text editor. Explanations:

| Variable | What it does | Typical value for local testing |
|----------|--------------|--------------------------------|
| `APP_NAME` | Display/app name (appears in emails and titles) | `"DYS Financial Management System"` |
| `APP_ENV` | Environment: `local`, `production`. Use `local` for testing | `local` |
| `APP_DEBUG` | `true` = verbose error pages (good while testing), `false` = hide internals | `true` for testing |
| `APP_URL` | The URL the API is served at | `http://localhost:8000` |
| `DB_CONNECTION` | Database kind | `mysql` |
| `DB_HOST` | Where MySQL lives. Same machine = `127.0.0.1` | `127.0.0.1` |
| `DB_PORT` | MySQL's port (default 3306) | `3306` |
| `DB_DATABASE` | Name of the database to use (create it in section 4) | `dys_fms` |
| `DB_USERNAME` / `DB_PASSWORD` | MySQL credentials with rights on that database | your MySQL user/password |
| `MAIL_MAILER` | Email transport; `smtp` talks to a real SMTP server | `smtp` |
| `MAIL_HOST` | SMTP server address | Mailtrap: `sandbox.smtp.mailtrap.io` |
| `MAIL_PORT` | SMTP port | `587` (STARTTLS) or `465` (SSL) |
| `MAIL_USERNAME` / `MAIL_PASSWORD` | SMTP login (a username/token and password/token) | Mailtrap credentials |
| `MAIL_SCHEME` | The SMTP transport type: `smtp` (plain, then STARTTLS) or `smtps` (implicit SSL/TLS from the start) | `smtp` for Mailtrap 587/2525; `smtps` for 465 |
| `MAIL_REQUIRE_TLS` | `true` = fail if the server does not offer STARTTLS (recommended for real senders) | `true` in production, `false` for local Mailpit |
| `MAIL_VERIFY_PEER` | `true` = verify the server TLS certificate | `true` in all cases |

> **`MAIL_SCHEME` is the transport type, not an encryption mode.** Symfony Mailer builds a transport directly from the scheme, so the only valid values are:
>
> - **STARTTLS (recommended):**
>   ```
>   MAIL_SCHEME=smtp
>   MAIL_PORT=587    # or 2525 if the provider supports it
>   MAIL_REQUIRE_TLS=true
>   ```
> - **Implicit SSL/TLS:**
>   ```
>   MAIL_SCHEME=smtps
>   MAIL_PORT=465
>   ```
> - **Do NOT use `MAIL_SCHEME=tls`** — that is not a transport scheme and must be rejected: `"The \"tls\" scheme is not supported"`. The handshake mode is expressed via `MAIL_REQUIRE_TLS` (for STARTTLS) or by choosing `smtps` (for implicit TLS), never via a `tls` scheme.

> **Use `MAIL_SCHEME` / `MAIL_REQUIRE_TLS` / `MAIL_VERIFY_PEER`, NOT `MAIL_ENCRYPTION`.** This Laravel 12 project builds its SMTP transport with Symfony's DSN options (`scheme`, `require_tls`, `verify_peer`). The old `MAIL_ENCRYPTION` variable is ignored by this stack — setting it does nothing.

You can leave the rest of the file (SANCTUM_, CACHE_, QUEUE_, SESSION_, CORS_) at their defaults for testing.

---

## 4. Database setup

Three short steps on the database.

### 1) Create the database

You create the DB inside MySQL itself. Log in with your MySQL user:

```sh
mysql -u dys_fms -p
```

(The command will prompt for your MySQL password.) Then run:

```sql
CREATE DATABASE dys_fms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
exit
```

`utf8mb4` = character set that supports all text (including emoji). The name must match the `DB_DATABASE` value in `.env`.

### 2) Run migrations

```sh
php artisan migrate
```

**What it does:** Laravel builds your database *tables* (users, sectors, sales, expenses, payroll, etc.) from migration files in `backend/database/migrations/` — it does not delete or touch tables you've created manually. When it finishes you should see "8 migrations run". Rerun-safe: `php artisan migrate` only applies what is new.

### 3) Run seeders

```sh
php artisan db:seed
```

Adds starter data: the 4 business sectors and the Business Owner login account. **Expected output:** two seeders run (`BusinessSectorSeeder`, `UserSeeder`).

> Seeders are **not idempotent** — if you run them twice on a non-empty DB you'll get a duplicate-key error. For a fresh environment run once; to start over use `php artisan migrate:fresh --seed`.

---

## 5. Storage setup

```sh
php artisan storage:link
```

Create the `public/storage` symlink → `storage/app/public`. **Does this project need it?** No. The DYS FMS backend has no file-uploads, avatars, or images — there is no `Storage::` usage in the code. You can run it anyway (it is harmless and one second), or skip it. If you skip, a leftover note: the app will still work.

---

## 6. Start the server

```sh
php artisan serve
```

Laravel starts a small built-in web server on `http://127.0.0.1:8000`. To choose a different port: `php artisan serve --port=8001`.

The API is then reachable at `http://127.0.0.1:8000/api`. To confirm it is up, hit the public (no token) endpoint in a browser or terminal:

```sh
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@dys.com","password":"SecurePass123"}'
```

Expect an early 200 response with the owner user, a `token`, and the default sector — the API is alive. (The seeded owner credentials are `owner@dys.com` / `SecurePass123`.)

---

## 7. API testing (Postman or Bruno)

Postman and Bruno are free "HTTP clients" you use to send requests to the API (JSON in, JSON out). Bruno is open-source and 100% local. Create one "Collection" named `DYS FMS`, then:

### 7.1 Login (returns the token)

- **Method:** POST — **URL:** `http://127.0.0.1:8000/api/login`
- **Body:** (set type to raw JSON):
  ```json
  {"email":"owner@dys.com","password":"SecurePass123"}
  ```
- Copy the `data.token` value from the response.

### 7.2 Authentication (using the token)

- Open the collection → **Authorization** tab → type **Bearer Token** → paste the token.
- Every request from now on uses that header automatically: `Authorization: Bearer <token>`.

> **Tip:** always add an `Accept: application/json` header. The API is 100% JSON and Laravel's auth middleware returns `401 Unauthorized` for it; without that header, unauthenticated browser-like requests get a **500** (Laravel tries to redirect to a non-existent named "login" route page instead).

### 7.3 Endpoints to try (all require the Bearer token)

| Purpose | Request | Body / notes |
|---------|---------|--------------|
| List users (owner only) | `GET /api/users` | none → `200` with the 4 seeded users |
| Create a user | `POST /api/users` | `{"name":"Maria Santos","email":"maria@dys.com","role":"Event Manager","sector_id":2}` → `201`, includes `temporary_password` |
| Record a sale | `POST /api/sales` | `{"amount":1500,"description":"Package","sector_id":1}` → `201` |
| List sales | `GET /api/sales` | → `200` |
| Record an expense | `POST /api/expenses` | `{"amount":320.50,"description":"Props","sector_id":1}` → `201` |
| Calculate payroll | `POST /api/payroll` | `{"user_id":2,"hours_worked":160,"hourly_rate":125,"pay_period":"2026-07-15"}` → `201`, auto-creates the payroll expense |
| Report summary | `GET /api/reports?type=summary` | → `200` with per-sector totals |
| Wrong password | `POST /api/login` with bad password | → `401 {"message":"Invalid username or password."}` |
| Missing token | `GET /api/users` (no Bearer) | → `401` |

Sectors seeded: `id 1` = DYS Events, `2` = B&DYS, `3` = Flavors by DYS, `4` = SnapDYS Memories (check with `GET /api/business-sectors`).

**What "success" looks like:** every 200/201 the expected payload and every error returns a clean JSON message — not a server HTML crash page.

---

## 8. Live SMTP validation with Mailtrap

Mailtrap is a "fake inbox" SMTP provider: it accepts your app's real emails so you can inspect them — perfect for safely testing the temporary-password email before using a real provider.

### 8.1 Create a Mailtrap account

1. Go to https://mailtrap.io and click **Sign up for Free** (email + password; free plan works).
2. Once inside, you land on the "Email Testing" page.

### 8.2 Find your SMTP credentials

1. Open **Email Testing → Inboxes** (it is often called "My Inbox").
2. Click the inbox, then click the **SMTP / Settings** tab (or "Integrate"). You'll see two values:
   - **Host:** `sandbox.smtp.mailtrap.io`
   - **Port:** `587`
   - **Username** and **Password** (the "token" strings) — copy both.

These go straight into `.env`.

### 8.3 Configure `.env`

Edit `backend/.env` to:

```env
MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=587
MAIL_USERNAME=<your Mailtrap username token>
MAIL_PASSWORD=<your Mailtrap password token>
MAIL_SCHEME=smtp
MAIL_REQUIRE_TLS=true
MAIL_VERIFY_PEER=true
MAIL_FROM_ADDRESS="no-reply@dys.test"
MAIL_FROM_NAME="DYS Financial Management System"
```

Rules: **no `MAIL_ENCRYPTION`**; `MAIL_SCHEME=smtp` (STARTTLS) with `MAIL_REQUIRE_TLS=true` and port 587 (or 2525 if the provider supports it). If your provider uses implicit SSL, set `MAIL_PORT=465` and `MAIL_SCHEME=smtps` instead. **Never set `MAIL_SCHEME=tls`** — Symfony only accepts `smtp`/`smtps`. And for local Mailpit use `MAIL_MAILER=smtp`, `MAIL_HOST=127.0.0.1`, `MAIL_PORT=1025`, `MAIL_SCHEME=`, `MAIL_REQUIRE_TLS=false`.

### 8.4 Send a real email (through the app)

Restart the server so the new mail settings take effect (Ctrl+C then `php artisan serve` again). Then trigger the app's actual email by creating a user:

```sh
curl -X POST http://127.0.0.1:8000/api/users \
  -H "Authorization: Bearer <owner token>" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"name":"Rosa","email":"you@example.com","role":"Employee/Staff","sector_id":1}'
```

Look for **`"password_sent": true`** in the response. That is the contract: `true` = the SMTP server accepted the message, `false` = delivery failed (account is still created — "fail-soft").

### 8.5 Verify delivery

Add the address from the request to the Mailtrap inbox's **Add real recipient** field, then within a few seconds the email appears in the inbox. It should look like:

- **From:** DYS Financial Management System <no-reply@dys.test>
- **Subject:** Your DYS Financial Management System Account
- **Body:** a greeting with the recipient's name, assigned role, business sector (if any), and the temporary password.

### 8.6 If the email does not arrive

1. Check the response for `"password_sent": false`.
2. Read the log — Laravel writes everything to `backend/storage/logs/laravel.log`. Search for `Temporary password email could not be sent.` — the log entry includes the `user_id`, the recipient `email`, the exception **message**, and the full **stack trace**, so you can see exactly why (wrong host, wrong username/password, port, TLS issue, ...).
3. Check that the Inbox is set to accept your recipient ("Real Recipients"), and that the token username/password were copied exactly.

---

## 9. Production checklist (what to verify before go-live)

| Check | Command | Success = |
|-------|---------|-----------|
| Migrations | `php artisan migrate:status` | All 8 migrations show **Ran** (no red errors) |
| Queues | (none — `QUEUE_CONNECTION=sync`, no queue worker needed) | Email and jobs finish immediately; no worker to run |
| Config cache | `php artisan config:cache` (only when going live) | "Configuration cached successfully" |
| Email | Create a test user & confirm `password_sent:true` + email in Mailtrap | Both true |
| Logs clean | `tail -f storage/logs/laravel.log` while making requests | No unexpected `ERROR`/`Exception` lines (only expected `Temporary password email could not be sent.` if mail is offline) |
| Backend tests | `php artisan test` | **Tests: 91 passed (496 assertions)** — all green |
| Storage | `php artisan storage:link` | "link has been connected" |

Which tests matter: the suite covers the entire API (auth, sectors, users, sales, expenses, payroll, reports, RBAC role gates, and the email fail-soft + duplicate-delivery regression tests added for the temporary-password feature).

---

## 10. Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `php` not found (or command not recognized) | PHP not on PATH | Install per §1.1; reopen the terminal |
| `composer install` fails with "missing extensions" | PHP extensions not installed / not enabled | Install the missing `php-*` package or uncommente the `extension=...` line in `php.ini`, then retry |
| Composer "InvalidArgumentException: Package not found"... | Composer too old | `composer self-update` |
| MySQL `SQLSTATE[HY000] [2002] Connection refused` | MySQL not running or wrong `DB_HOST`/`DB_PORT` | Start the service (`sudo systemctl start mysql` / `mariadb`); verify `.env` values; make sure `DB_PORT=3306` |
| `SQLSTATE[HY000] [1049] Unknown database` | The database does not exist | Run the `CREATE DATABASE` from §4 |
| `SQLSTATE[28000] Access denied for user` | Wrong MySQL user/password, or user has no rights on the DB | Fix `.env`; grant: `GRANT ALL PRIVILEGES ON dys_fms.* TO 'youruser'@'localhost'; FLUSH PRIVILEGES;` |
| SMTP auth failures (email not sent) | Wrong `MAIL_USERNAME`/`MAIL_PASSWORD`, wrong port, host | Compare with Mailtrap inbox settings (§8.2); use port 587; enable `MAIL_REQUIRE_TLS=true`; read the log stack trace (§8.6) |
| `APP_KEY` missing (`No application encryption key has been specified`) | Old/none `.env` | `php artisan key:generate` |
| "Configuration cache must be regenerated"... `class not found` after moving files | Stale config | `php artisan config:clear` + `php artisan cache:clear` |
| Migration failure mid-run | Partial batch, or migration constraint | `php artisan migrate:rollback --step=1`, fix, re-run `php artisan migrate`; never edit a run migration on live data |
| 500 HTML page on API endpoints | Client sent no `Accept: application/json` (Laravel went to the web redirect) | Send the header (all our services do); the proper API behavior from the client view is `401` |
| Tests fail on a fresh clone | Test database not configured, or missing DB user | See `backend/phpunit.xml` — it expects a `dys_fms_testing` database, user `dys_fms` with the password in that file. Create that DB/user in MySQL |
| Port already in use (8000) | Another server running | `php artisan serve --port=8001` |

---

## Appendix — What was verified on the Release Candidate for this document

| Item | Result |
|------|--------|
| Fresh database `dys_fms_deploy` (MariaDB 11.8.2) | 8/8 migrations applied cleanly |
| Seeders | 4 sectors + Business Owner |
| `php artisan storage:link` | Symlink created (not required by app) |
| `php artisan serve` + API | All 200/201/401 checks passed (login, users, create, sales, expenses, payroll, reports, auth guards) |
| `php artisan test` | **91 passed, 496 assertions** |
| Temporary-password email | `password_sent:false` when no SMTP (fail-soft works); with Mailtrap → `true` + delivered |

**Deliverable status:** backend deployed, endpoints verified, docs up to date. Pending: your Mailtrap credentials for the final live SMTP check, awaiting your approval.