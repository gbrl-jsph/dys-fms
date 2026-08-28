#!/bin/bash
set -e

# Render/Koyeb/Fly set PORT (e.g. 10000). Apache listens 80, so rewrite if needed.
if [ -n "$PORT" ] && [ "$PORT" != "80" ]; then
  echo "Listening on PORT=$PORT (mapping Apache 80 -> $PORT)"
  sed -i "s/*:80/*:$PORT/" /etc/apache2/sites-available/000-default.conf
  sed -i "s/Listen 80/Listen $PORT/" /etc/apache2/ports.conf || echo "Listen $PORT" >> /etc/apache2/ports.conf
fi

# Wait for MySQL if DB_HOST is set (max 30s)
if [ -n "$DB_HOST" ]; then
  echo "Waiting for DB $DB_HOST:$DB_PORT ..."
  for i in 1 2 3 4 5 6; do
    if php -r "try{\$p=new PDO('mysql:host='.getenv('DB_HOST').';port='.getenv('DB_PORT'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); exit(0);}catch(Exception \$e){exit(1);}" 2>/dev/null; then
      echo "DB reachable"
      break
    fi
    echo "DB not ready, retry $i..."
    sleep 5
  done
fi

# Laravel prod setup
echo "Running Laravel production setup..."
php artisan config:clear || true
php artisan storage:link || true

# Migrations — safe with --force, never seeds automatically
if [ "$RUN_MIGRATIONS" = "true" ]; then
  echo "Running migrations --force"
  php artisan migrate --force
fi

# Optional seed only if explicitly requested (QA demo data)
if [ "$RUN_SEEDERS" = "true" ]; then
  echo "Running seeders"
  php artisan db:seed --force
fi

php artisan config:cache || true
php artisan route:cache || true
# view:cache removed — API-only backend has no Blade views (causes "View path not found" 500 on /up)

# Permissions again (volume mounts may reset)
chown -R www-data:www-data storage bootstrap/cache || true
chmod -R 775 storage bootstrap/cache || true

echo "Starting Apache..."
exec apache2-foreground
