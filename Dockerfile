FROM php:7.4.12-apache

ARG DEBIAN_FRONTEND=noninteractive
ARG RAINLOOP_URL=https://github.com/RainLoop/rainloop-webmail/releases/download/v1.14.0/rainloop-community-1.14.0.zip
ARG RAINLOOP_URL_ASC=https://github.com/RainLoop/rainloop-webmail/releases/download/v1.14.0/rainloop-community-1.14.0.zip.asc
ARG RAINLOOP_PGP_PUBLIC_KEY=https://www.rainloop.net/repository/RainLoop.asc 
ARG RAINLOOP_GPG_FINGERPRINT="3B79 7ECE 694F 3B7B 70F3  11A4 ED7C 49D9 87DA 4591"

ENV APACHE_DOCUMENT_ROOT /rainloop

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt update -qq \
    && apt install -q -y unzip wget gpg \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN cd /tmp \
    && wget -q ${RAINLOOP_PGP_PUBLIC_KEY} \
    && wget -q ${RAINLOOP_URL_ASC} \
    && wget -q ${RAINLOOP_URL} \
    && gpg --import RainLoop.asc \
    && FINGERPRINT="$(LANG=C gpg --verify rainloop-community-1.14.0.zip.asc rainloop-community-1.14.0.zip 2>&1 \
      | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
    && if [ -z "${FINGERPRINT}" ]; then echo "ERROR: Invalid GPG signature!" && exit 1; fi \
    && if [ "${FINGERPRINT}" != "${RAINLOOP_GPG_FINGERPRINT}" ]; then echo "ERROR: Wrong GPG fingerprint!" && exit 1; fi

RUN mkdir ${APACHE_DOCUMENT_ROOT} \
    && unzip -q /tmp/rainloop-community-1.14.0.zip -d ${APACHE_DOCUMENT_ROOT} \
    && find /rainloop -type d -exec chmod 755 {} \; \
    && find /rainloop -type f -exec chmod 644 {} \; \
    && chown -R www-data:www-data /rainloop

EXPOSE 80