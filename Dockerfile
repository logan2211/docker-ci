FROM phpdockerio/php72-fpm:latest

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    php7.2-mysql php7.2-bcmath php7.2-gd php7.2-intl php7.2-redis php7.2-ssh2 \
    php7.2-zip ipmitool git-core curl \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install mcrypt extensions
RUN apt-get update && \
    apt-get install -y --no-install-recommends php-pear php7.2-dev \
    make libmcrypt-dev && pecl install mcrypt-1.0.1 && \
    apt-get purge -y php-pear php7.2-dev make && \
    apt-get autoremove -y && \
    echo 'extension=mcrypt.so' > /etc/php/7.2/mods-available/mcrypt.ini && \
    ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/fpm/conf.d/20-mcrypt.ini && \
    ln -s /etc/php/7.2/mods-available/mcrypt.ini /etc/php/7.2/cli/conf.d/20-mcrypt.ini && \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Use local apt mirrors
RUN sed -ri 's%(archive|security).ubuntu.com%cache.mirror.lstn.net%' \
    /etc/apt/sources.list

USER root
WORKDIR /var/www/html
