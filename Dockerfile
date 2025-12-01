# Use a production-grade base image with PHP-FPM and Nginx
FROM serversideup/php:8.3-fpm-nginx

# Enable PHP OpCache for production optimization
ENV PHP_OPCACHE_ENABLE=1

# Switch to root user to install system dependencies
USER root

# Install Node.js and npm (if your Laravel project requires frontend asset compilation)
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy your application code into the image
COPY --chown=www-data:www-data . /var/www/html

# Switch back to the www-data user for security
USER www-data

# Install Node.js dependencies and build frontend assets (if applicable)
RUN npm install \
    && npm run build

# Install Composer dependencies, optimizing autoloader for production
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Expose the Nginx port (default is 80)
EXPOSE 80

# Define the default command to start the web server
CMD ["php-fpm", "-F"]