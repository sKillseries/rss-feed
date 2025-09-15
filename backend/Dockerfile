FROM php:8.2-apache

# Installer dépendances système + extensions PHP
RUN apt-get update && apt-get install -y \
    git curl libpq-dev unzip libzip-dev nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql zip bcmath

# Activer mod_rewrite pour Laravel
RUN a2enmod rewrite

# Config Apache : DocumentRoot doit pointer sur /rss-backend/public
RUN sed -ri -e 's!/var/www/html!/var/www/html/rss-backend/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/var/www/html/rss-backend/public!g' /etc/apache2/apache2.conf \
    && sed -i '/<Directory \/var\/www\/html\/rss-backend\/public>/,/<\/Directory>/ s/AllowOverride[[:space:]]\+None/AllowOverride All/' /etc/apache2/apache2.conf

# Modifier le port d'écoute Apache de 80 -> 9080
RUN sed -i 's/Listen 80/Listen 9080/' /etc/apache2/ports.conf \
    && sed -i 's/:80/:9080/g' /etc/apache2/sites-available/000-default.conf

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copier les fichiers Laravel dans /var/www/html/rss-backend
WORKDIR /var/www/html/rss-backend
COPY rss-backend/ ./
RUN rm -rf .git
RUN rm .gitattributes
RUN rm .gitignore
RUN rm -rf tests
RUN mv .env.example .env

# Installer dépendances PHP et JS
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader \
    && npm install && npm run build

RUN php artisan key:generate
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan optimize

# Donner les droits à www-data
RUN chown -R www-data:www-data /var/www/html/rss-backend \
    && chmod -R 775 storage bootstrap/cache

# Configuration Apache2
RUN sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
RUN sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf

# Script d'entrée (migration auto au démarrage)
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9080

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
