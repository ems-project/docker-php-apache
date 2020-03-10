ARG VERSION_ARG=""

FROM docker.io/elasticms/base-php-dev:${VERSION_ARG}

ARG RELEASE_ARG=""
ARG BUILD_DATE_ARG=""
ARG VCS_REF_ARG=""

LABEL eu.elasticms.base-php-apache-dev.build-date=$BUILD_DATE_ARG \
      eu.elasticms.base-php-apache-dev.name="" \
      eu.elasticms.base-php-apache-dev.description="" \
      eu.elasticms.base-php-apache-dev.url="hhttps://hub.docker.com/repository/docker/elasticms/base-php-apache-dev" \
      eu.elasticms.base-php-apache-dev.vcs-ref=$VCS_REF_ARG \
      eu.elasticms.base-php-apache-dev.vcs-url="https://github.com/ems-project/docker-php-apache" \
      eu.elasticms.base-php-apache-dev.vendor="sebastian.molle@gmail.com" \
      eu.elasticms.base-php-apache-dev.version="$VERSION_ARG" \
      eu.elasticms.base-php-apache-dev.release="$RELEASE_ARG" \
      eu.elasticms.base-php-apache-dev.schema-version="1.0" 

USER root

ENV HOME=/home/default \
    PATH=/opt/bin:/usr/local/bin:/usr/bin:$PATH

COPY etc/apache2/ /etc/apache2/
COPY etc/supervisor/ /etc/supervisor/
COPY src/ /var/www/html/

RUN apk add --update --virtual .php-apache-rundeps apache2 apache2-utils apache2-proxy apache2-ssl supervisor \
    && touch /var/log/supervisord.log \
    && touch /var/run/supervisord.pid \
    && mkdir -p /run/apache2 /var/run/apache2 /var/log/apache2 \
    && rm -rf /var/cache/apk/* \
    && echo "Setup permissions on filesystem for non-privileged user ..." \
    && chown -Rf 1001:0 /etc/apache2 /run/apache2 /var/run/apache2 /var/log/apache2 /var/www/html \
                        /var/log/supervisord.log /etc/supervisord.conf /var/run/supervisord.pid \
    && chmod -R ug+rw /etc/apache2 /run/apache2 /var/run/apache2 /var/log/apache2 /var/lock /var/www/html \
                      /var/log/supervisord.log /etc/supervisord.conf /var/run/supervisord.pid \
    && find /run/apache2 -type d -exec chmod ug+x {} \; \
    && find /etc/apache2 -type d -exec chmod ug+x {} \; \
    && find /run/apache2 -type d -exec chmod ug+x {} \; \
    && find /var/run/apache2 -type d -exec chmod ug+x {} \; \
    && find /var/log/apache2 -type d -exec chmod ug+x {} \; 

USER 1001

ENTRYPOINT ["container-entrypoint"]

HEALTHCHECK --start-period=10s --interval=1m --timeout=5s --retries=5 \
        CMD curl --fail --header "Host: default.localhost" http://localhost:9000/index.php || exit 1

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
