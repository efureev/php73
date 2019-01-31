# PHP-Production
#
# VERSION               0.0.5

FROM php:7.3

MAINTAINER efureev <fureev@gmail.com>
LABEL Description="Production PHP 7.3"

ENV PHP_REDIS_VERSION 4.2.0
ENV COMPOSER_VERSION 1.8.3

COPY ./configs/php-fpm.d/www.conf /etc/php7/php-fpm.d/www.conf
COPY ./configs/php-fpm.conf /etc/php7/php-fpm.conf
COPY ./configs/php.ini /etc/php7/php.ini

RUN echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list

RUN cat /etc/apt/sources.list

RUN mkdir /www

RUN adduser -h /www -s /bin/sh -D www-data && chown -R www-data:www-data /www

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
    git openssh-client bash nano

RUN apt-get install -y \
    # for intl extension
    libicu-dev \
    # for postgres
    libpostgresql-dev \
    # for soap
    libxml2-dev \
    # for GD
    freetype \
    libpng \
    libjpeg-turbo \
    # for bz2 extension
    bzip2-dev \
    # for intl extension
    libintl gettext-dev libxslt

RUN set -xe \
    && ln -s /usr/lib /usr/local/lib64 \
    && apt-get install -y \
        $PHPIZE_DEPS \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure mysqli --with-mysqli \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure pdo_pgsql --with-pgsql \
    && docker-php-ext-configure soap --enable-soap

RUN docker-php-ext-install \
        gd \
        bcmath \
        intl \
        pcntl \
        mysqli \
        pdo_mysql \
        pdo_pgsql \
        soap \
        bz2 \
        calendar \
        exif \
        gettext \
        shmop \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        wddx \
        xsl \
        zip

# Redis
RUN git clone --branch ${PHP_REDIS_VERSION} https://github.com/phpredis/phpredis /tmp/phpredis \
        && cd /tmp/phpredis \
        && phpize  \
        && ./configure  \
        && make  \
        && make install \
        && make test \
        && echo 'extension=redis.so' > /usr/local/etc/php/conf.d/redis.ini \
    && apt-get purge -y --auto-remove \
    && rm -rf /tmp/* \
    && rm -f /usr/local/etc/php-fpm.d/*

RUN set -xe \
  && php -v \
  && php -m

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp

RUN set -xe && \
  mkdir -p "$COMPOSER_HOME" && \
  php -r "copy('http://getcomposer.org/installer', 'composer-setup.php');" && \
  php composer-setup.php --install-dir=/usr/bin --filename=composer --version=$COMPOSER_VERSION && \
  php -r "unlink('composer-setup.php');" && \
  composer --ansi --version --no-interaction && \
  composer --no-interaction global require 'hirak/prestissimo' && \
  composer clear-cache

COPY ./dockerentrypoint.sh /tmp/dockerentrypoint.sh
RUN chmod 0755 /tmp/dockerentrypoint.sh

#CMD ["/tmp/dockerentrypoint.sh"]

#CMD ["php-fpm7", "-F","-O"]

WORKDIR /www

ENTRYPOINT ["php-fpm7","-F","-O"]
