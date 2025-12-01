FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev \
    libzip-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring zip exif pcntl

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# RUN php artisan migrate:fresh --seed

EXPOSE 8000

CMD ["php","artisan","serve","--host=0.0.0.0","--port=8000"]