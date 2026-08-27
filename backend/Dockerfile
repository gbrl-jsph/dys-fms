# DYS FMS Backend — Production Dockerfile
# Minimal deployment config for Render / Koyeb / Fly.io / any Docker host.
# Preserves Laravel 12 + PHP 8.2 + MySQL + Sanctum. No arch changes.
FROM php:8.2-apache AS base

# System deps + Apache
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libzip-dev libonig-dev libxml2-dev libcurl4-openssl-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql mbstring zip bcmath gd \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install deps first (cache)
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-scripts --prefer-dist --optimize-autoloader \
    || composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Copy app
COPY . .

# Apache vhost: serve public/ + allow HTAccess
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Permissions (Laravel requires storage + bootstrap/cache writable)
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache \
    && mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs \
    && chown -R www-data:www-data storage \
    # Optimize for production (config/route/view cache runs at boot via env)
    && php artisan package:discover --ansi || true

# Apache port; Render/Koyeb inject PORT env (default 80 -> 10000). We listen 80.
EXPOSE 80

# Entrypoint: wait for DB, migrate --force, cache, start apache
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
