FROM phpdockerio/php:8.4-fpm

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    php8.4-mysql php8.4-bcmath php8.4-gd php8.4-gmp php8.4-intl php8.4-redis php8.4-ssh2 \
    php8.4-zip ipmitool git-core curl \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Use local apt mirrors
RUN sed -ri 's%(archive|security).ubuntu.com%cache.mirror.lstn.net%' \
    /etc/apt/sources.list

USER root
WORKDIR /var/www/html
