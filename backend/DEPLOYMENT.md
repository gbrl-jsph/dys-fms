# DYS FMS — Permanent Cloud Deployment Guide

Preserves Laravel 12 + MySQL + Sanctum. Minimum changes: `Dockerfile`, `docker/apache/000-default.conf`, `docker/entrypoint.sh`, `.dockerignore`, `.env.production.example`, this doc. No schema/route/response changes.

## 1. Recommended hosting (free/low-cost for QA)

**Primary: Docker host (Render Free / Koyeb Free / Fly.io) + managed MySQL (Clever Cloud Free 256MB / Aiven Free 1GB / FreeSQLDatabase.com 5MB)**

- Supports PHP 8.2, HTTPS (auto Let's Encrypt), env vars, `php artisan migrate --force`, Sanctum, persistent DB not public.
- Alternative no-Docker: **AlwaysData Free** (100MB, PHP 8.3, MySQL 10MB, SSH, HTTPS) — tight for vendor but OK for QA.
- Quick QA tunnel already verified via Cloudflare — now replaced by permanent domain.

**Why not other:** InfinityFree (no SSH/composer), Railway (requires card $5), Heroku (no free), Vercel (not PHP-native). Docker + external MySQL avoids vendor lock and preserves MySQL architecture.

## Approved Production Deployment — v1

The approved production stack is **Render Docker Web Service** for `backend/`,
**Clever Cloud MySQL** for the database, and **Cloudflare Pages** for the
prebuilt `flutter_app/build/web/` PWA. Use sibling HTTPS subdomains of one
registrable parent domain: `https://app.<domain>` for the PWA and
`https://api.<domain>` for the API. Do not create DNS records or enter a real
domain until the owner approves it.

### Render service

1. Connect the approved Git repository in Render and create a Docker Web Service.
2. Set the service root directory to `backend`; Render discovers `Dockerfile` there.
3. Set health check path to `/up`. The entrypoint changes Apache from port 80 to Render's injected `PORT`.
4. Add the production variables in the next section. `RUN_MIGRATIONS=true` applies forward migrations with `--force`; `RUN_SEEDERS=false` is the steady-state value.

### Clever Cloud MySQL

Create a MySQL add-on and copy its connection values into Render exactly:

| Clever Cloud value | Render variable |
|---|---|
| host | `DB_HOST` |
| port | `DB_PORT` |
| database name | `DB_DATABASE` |
| username | `DB_USERNAME` |
| password | `DB_PASSWORD` |

Always set `DB_CONNECTION=mysql`. The approved mapping uses the `DB_*` variables; `DB_URL` is supported by the current Laravel configuration but is unnecessary when those values are supplied. If Clever Cloud's chosen connection mode requires a CA certificate, obtain its published CA material and configure it as a Render secret file, then set `MYSQL_ATTR_SSL_CA` to that file path. The Laravel connection already consumes this variable. Do not invent a certificate path or certificate value.

### Initial database and owner

1. Take/confirm an empty database backup point and set `RUN_MIGRATIONS=true`.
2. For the one deployment that creates initial reference data, set `RUN_SEEDERS=true` and set a newly generated, secret `OWNER_PASSWORD` in Render.
3. Deploy once, verify migrations and `owner@dys.com`, then immediately set `RUN_SEEDERS=false` and remove `OWNER_PASSWORD` from Render.

The seeders are safe to re-run: sectors are updated by their fixed IDs without truncation, and the Business Owner is inserted only when absent. They never overwrite an existing owner password. Never use `migrate:fresh` in production.

### Cloudflare Pages

Build the Web/PWA artifact outside Cloudflare Pages and upload `flutter_app/build/web/` directly. This avoids adding Flutter SDK setup or CI/CD to Cloudflare's build environment. Hash routing requires no SPA rewrite rule. The release build contains only the public API URL supplied through `API_BASE_URL`; it contains no backend or SMTP secret.

### Exact sibling-domain configuration

After both custom domains verify and HTTPS certificates are active, set:

```
APP_URL=https://api.<domain>
CORS_ALLOWED_ORIGINS=https://app.<domain>
SANCTUM_STATEFUL_DOMAINS=app.<domain>
SESSION_DOMAIN=.<domain>
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax
```

`CORS_ALLOWED_ORIGINS` is parsed as exact comma-separated origins and does not permit wildcard CORS. `SESSION_DOMAIN` is read directly as the shared cookie domain, and Sanctum reads the comma-separated stateful host list. DNS records are created in Cloudflare: attach `app.<domain>` to the Pages project and create the Render-required custom-domain verification/target record for `api.<domain>`. Render issues HTTPS after DNS verification; Cloudflare issues HTTPS for the Pages custom domain after it is active.

## 2. Secrets — READ FIRST

- `.env` is gitignored (`Vault/.gitignore:5`). Never commit `.env`, `*.backup*`, passwords, app keys.
- SMTP credentials must be configured only through environment variables. Never commit SMTP usernames, passwords, or app passwords. If any credential was committed, revoke or rotate it immediately with the provider, then configure the replacement through the hosting provider's secret or environment-variable system.

- Use provider secrets: Render Dashboard > Environment, Koyeb > Service > Environment, `fly secrets set APP_KEY=...`, AlwaysData > Admin > Environment.

## 3. Prepare production env

In your cloud dashboard, set from `.env.production.example`:

```
APP_ENV=production
APP_DEBUG=false
APP_KEY=<generated Laravel application key>
APP_URL=https://<your-domain>
DB_CONNECTION=mysql
DB_HOST=<managed-mysql-host>
DB_PORT=3306
DB_DATABASE=<name>
DB_USERNAME=<user>
DB_PASSWORD=<pass>
# Browser/PWA session configuration. Use the exact deployed PWA/API domains.
CORS_ALLOWED_ORIGINS=https://<pwa-origin>
SANCTUM_STATEFUL_DOMAINS=<pwa-host>
SESSION_DOMAIN=<shared-cookie-domain>
SESSION_SECURE_COOKIE=true
SESSION_SAME_SITE=lax
RUN_MIGRATIONS=true
RUN_SEEDERS=false
```

## 4. Deploy

### Render (recommended free)

1. Push repo to GitHub.
2. Render > New Web Service > Connect repo > Runtime Docker > Root `backend/` > Dockerfile `backend/Dockerfile` > Plan Free > Add env vars > Create.
3. Render auto builds: `composer install`, `php artisan migrate --force` (via entrypoint), health `/up`.
4. Add Clever Cloud MySQL: Clever Cloud > Create MySQL > 256MB free > copy host/user/pass/db > paste into Render env > Redeploy.
5. For a fresh database only, set a newly generated `OWNER_PASSWORD` and `RUN_SEEDERS=true` for one deployment. Verify the owner account, then set `RUN_SEEDERS=false` and remove `OWNER_PASSWORD`. The seeder never replaces an existing owner password or truncates sectors.

### Koyeb / Fly.io (same Dockerfile)

- Koyeb: `koyeb app init ... --docker backend/Dockerfile --env APP_ENV=production ...`
- Fly: `fly launch --dockerfile backend/Dockerfile --region sin --no-db` + `fly secrets set DB_* APP_KEY APP_URL` + `fly deploy` + `fly ssh console -C "php artisan migrate --force"`

### AlwaysData (no Docker)

- Create AlwaysData account > Site > PHP 8.2 > MySQL DB > SSH: `git clone`, `composer install --no-dev`, `cp .env.production.example .env`, `php artisan key:generate`, `php artisan migrate --force`, `php artisan storage:link`, ensure `storage/` `bootstrap/cache/` 775.

## 5. Verify API over HTTPS (before APK)

```bash
curl https://<your-domain>/up
curl -X POST https://<your-domain>/api/login -H "Content-Type: application/json" -d '{"email":"owner@dys.com","password":"SecurePass123"}'
# expect: {"data":{"user":{...},"token":"...","default_sector":{...}},"message":"Login successful."}
curl -H "Authorization: Bearer <token>" https://<your-domain>/api/business-sectors
curl -H "Authorization: Bearer <token>" https://<your-domain>/api/sales
curl -H "Authorization: Bearer <token>" https://<your-domain>/api/expenses
curl -H "Authorization: Bearer <token>" https://<your-domain>/api/payroll
curl -H "Authorization: Bearer <token>" "https://<your-domain>/api/reports?type=summary"
curl -X POST -H "Authorization: Bearer <token>" https://<your-domain>/api/business-sectors/switch -d '{"sector_id":1}'
curl -X POST -H "Authorization: Bearer <token>" https://<your-domain>/api/logout
curl https://<your-domain>/api/users # expect 401 without token
```

## 6. Client Builds

### Android native application

Android uses Sanctum personal-access Bearer tokens stored in Flutter Secure Storage. Build it against the HTTPS API:

```bash
export PATH="/home/deck/flutter/bin:$PATH"
flutter analyze # expect No issues found!
flutter test    # existing tests must pass
flutter build apk --release --dart-define=API_BASE_URL=https://<api-host>/api
strings build/app/outputs/flutter-apk/app-release.apk | grep -E "192\.168\.1\.34|localhost|127\.0\.0\.1|trycloudflare" # must be empty
```

### iPhone/iPad Flutter Web/PWA

iPhone and iPad are supported through the Flutter Web/PWA build installed in Safari with **Add to Home Screen**. This is not a native iOS application. It uses Sanctum session cookies and CSRF protection, so the five browser-session variables in §3 must match the deployed HTTPS PWA/API domain arrangement exactly.

```bash
flutter build web --release --dart-define=API_BASE_URL=https://<api-host>/api
```

Deploy `flutter_app/build/web/` to the HTTPS PWA origin. In Safari on iPhone/iPad, open the origin, choose **Share**, then **Add to Home Screen**. The application is online-only: it does not support offline financial transactions, local write queues, synchronization, or reconciliation.

## 7. Mobile-data QA (phone not on laptop Wi-Fi)

- Install APK: `adb install build/app/outputs/flutter-apk/app-release.apk` or transfer file.
- Phone > Mobile Data ON, Wi-Fi OFF.
- Test: login, logout, dashboard, sales view/record, expenses, payroll, reports (owner), sector switch, user mgmt (owner), staff restrictions (403), invalid token 401.

## 8. Security checklist

- [ ] HTTPS only
- [ ] APP_DEBUG=false
- [ ] .env not committed (`git ls-files | grep -E "^\.env|backend/\.env"`)
- [ ] secrets in provider env only
- [ ] DB not publicly exposed (Clever Cloud restricts to app IP, firewalled)
- [ ] Laravel debug pages don't leak (APP_DEBUG false)
- [ ] Sanctum bearer auth enforced, unauth 401, RBAC via Ensure* middleware
- [ ] Android native app uses Bearer tokens over HTTPS
- [ ] PWA CORS allows only the exact HTTPS PWA origin, never `*` with credentialed cookies
- [ ] `SANCTUM_STATEFUL_DOMAINS`, `SESSION_DOMAIN`, `SESSION_SECURE_COOKIE=true`, and `SESSION_SAME_SITE` match the PWA/API deployment
- [ ] iPhone/iPad PWA has been tested from Safari after Add to Home Screen
- [ ] No offline financial transactions are advertised or accepted

## 9. Git

```bash
git status
git diff --stat
git diff -- . ':!*.lock'
```

No auto commit/push. Review, then `git add backend/Dockerfile backend/.dockerignore backend/docker/ backend/.env.production.example backend/DEPLOYMENT.md flutter_app/lib/data/api/api_config.dart` after approval.

## 10. Local restore

Current local `backend/.env` uses `test_dys` anonymous MySQL hack for local dev. Keep backup `backend/.env.backup.20260827`. For normal dev revert:

```bash
cp backend/.env.backup.20260827 backend/.env
php artisan config:clear
php artisan migrate:fresh --seed
php artisan serve --host=127.0.0.1 --port=8000
```
