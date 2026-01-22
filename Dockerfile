# Imagen base: PHP 8.2 en modo CLI (línea de comandos)
# Ideal para scripts, composer, jobs, etc. No es Apache ni FPM.
FROM php:8.2-cli as base

# Directorio de trabajo dentro del contenedor
# Todo lo que hagas a partir de ahora ocurre en /app
WORKDIR /app

# Actualiza repositorios e instala dependencias del sistema
# - unzip: necesario para Composer
# - git: para dependencias desde repositorios
# - libzip-dev: requerido para la extensión zip de PHP
# Luego instala la extensión zip de PHP
RUN apt update && apt install -y unzip git libzip-dev && \
    docker-php-ext-install zip

# Copia el binario de Composer desde la imagen oficial de Composer
# Así no tienes que instalarlo a mano (menos dolor)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copia el archivo composer.json al contenedor
# Se hace antes del código para aprovechar la cache de Docker
COPY composer.json ./

# Instala las dependencias PHP
# --no-dev = no instala dependencias de desarrollo (producción clean)
RUN composer install --no-dev

FROM base AS dev

RUN pecl install xdebug && docker-php-ext-enable xdebug

COPY ./docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

COPY . .

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]


FROM base as test

RUN composer require --dev phpunit/phpunit

COPY . .

CMD [ "./vendor/bin/phpunit", "--testdox", "tests"]

FROM base AS prod

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN rm -rf tests .env.development .env.test docker/

EXPOSE 80

CMD ["php", "-S", "0.0.0.0:80", "-t", "public"] 