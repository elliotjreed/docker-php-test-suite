FROM php:alpine

LABEL Description="" Vendor="Elliot J. Reed" Version="1.0"

ENV PATH="/home/composer/.composer/vendor/bin:${PATH}"

RUN apk add --update icu yaml git openssh-client && \
    apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        bzip2-dev \
        sqlite-dev \
        icu-dev \
        yaml-dev && \
    docker-php-ext-install bcmath pdo_mysql opcache pdo_sqlite zip && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    pecl install yaml && \
    docker-php-ext-enable yaml && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apk del .build-deps && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } && \
    rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* && \
    addgroup -S composer && adduser -S -G composer composer && \
    mkdir /app && \
    chown -R composer:composer /app && \
    chmod -R 777 /app && \
    echo "export PATH=\${PATH}:/home/composer/.composer/vendor/bin" > /etc/profile.d/composer.sh

USER composer

RUN composer global require \
        phpunit/phpunit \
        codeception/codeception \
        behat/behat \
        phpmd/phpmd \
        phpstan/phpstan \
        squizlabs/php_codesniffer && \
    cd /home/composer/.composer/vendor && \
    find -type f -iname '*readme*'  -exec rm -vf {} + && \
    find -type f -iname '*changelog*'  -exec rm -vf {} + && \
    find -type f -iname '*license*' -exec rm -vf {} +

CMD ["php"]
