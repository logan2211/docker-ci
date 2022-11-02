FROM phpdockerio/php:8.1-fpm

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    php8.1-mysql php8.1-bcmath php8.1-gd php8.1-gmp php8.1-intl php8.1-redis php8.1-ssh2 \
    php8.1-zip ipmitool git-core curl \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install mcrypt extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends php-pear php8.1-dev \
    make libmcrypt-dev && pecl install mcrypt-1.0.3 && \
    apt-get purge -y php-pear php8.1-dev make && \
    apt-get autoremove -y && \
    echo 'extension=mcrypt.so' > /etc/php/8.1/mods-available/mcrypt.ini && \
    ln -s /etc/php/8.1/mods-available/mcrypt.ini /etc/php/8.1/fpm/conf.d/20-mcrypt.ini && \
    ln -s /etc/php/8.1/mods-available/mcrypt.ini /etc/php/8.1/cli/conf.d/20-mcrypt.ini && \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Use local apt mirrors
RUN sed -ri 's%(archive|security).ubuntu.com%cache.mirror.lstn.net%' \
    /etc/apt/sources.list

USER root
WORKDIR /var/www/html
