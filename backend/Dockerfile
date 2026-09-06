# DYS FMS Backend — Production Dockerfile
# Minimal deployment config for Render / Koyeb / Fly.io / any Docker host.
# Preserves Laravel 12 + PHP 8.4 + MySQL + Sanctum. No arch changes.
FROM php:8.4-apache AS base

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

# Laravel requires writable runtime directories even from a clean Git checkout.
# Package discovery optimizes production dependencies during the image build.
RUN mkdir -p storage/app/public storage/framework/cache/data storage/framework/sessions \
    storage/framework/views storage/logs bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && find storage bootstrap/cache -type d -exec chmod 775 {} + \
    && php artisan package:discover --ansi || true

# Apache port; Render/Koyeb inject PORT env (default 80 -> 10000). We listen 80.
EXPOSE 80

# Entrypoint: wait for DB, migrate --force, cache, start apache
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

CMD ["/usr/local/bin/entrypoint.sh"]
