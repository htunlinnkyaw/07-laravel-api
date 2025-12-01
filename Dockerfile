# ================================
# 1. Build Stage
# ================================
FROM php:8.2-fpm-alpine AS build

RUN apk add --no-cache git zip unzip libzip-dev oniguruma-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear


# ================================
# 2. Production Stage
# ================================
FROM nginx:alpine

WORKDIR /var/www/html

# Copy Laravel build
COPY --from=build /var/www/html /var/www/html

# Copy Nginx config
COPY ./deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
