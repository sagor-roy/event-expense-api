#!/bin/bash

# Wait for MySQL
echo "Waiting for MySQL..."
while ! nc -z mysql 3306; do
  sleep 1
done
echo "MySQL is ready."

# Install dependencies
composer install --no-dev --optimize-autoloader

# Setup .env
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Cache config and routes
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
chmod -R 777 storage bootstrap/cache

# Start PHP-FPM
php-fpm
