# Dockerfile for Frontend Microservice
FROM php:7.4-apache
COPY . /var/www/html
RUN docker-php-ext-install mysqli
CMD ["apache2-foreground"]
