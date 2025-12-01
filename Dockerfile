# -------------------------
# 1) PHP Stage
# -------------------------
FROM php:8.3-fpm AS php-stage

RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN php artisan config:cache && php artisan route:cache && php artisan view:cache


# -------------------------
# 2) Nginx Stage
# -------------------------
FROM nginx:alpine AS nginx-stage

COPY --from=php-stage /var/www /var/www
COPY ./docker/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
