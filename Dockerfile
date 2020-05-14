FROM alpine:3.11

RUN apk --no-cache add \
  curl \
  php7 \
  php7-fpm \
  php7-opcache \
  php7-pdo_mysql \
  php7-json \
  php7-tokenizer \
  php7-openssl \
  php7-curl \
  php7-zlib \
  php7-xml \
  php7-phar \
  php7-intl \
  php7-dom \
  php7-xmlreader \
  php7-ctype \
  php7-session \
  php7-mbstring \
  php7-gd \
  nginx \
  supervisor

# reduce log rotation to keep last 2 weeks
RUN sed -ie -- "/rotate/s/[0-9]\+/14/g" /etc/logrotate.d/nginx

# copy over the nginx configuration along with default server configuration to
# define the public root
COPY config/nginx.conf /etc/nginx/nginx.conf
# override the existing nginx default
COPY config/default_server.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /usr/local/bin/
# copy PHP-FPM configuration
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini
# configure process supervisor
COPY config/supervisord.conf /etc/

# force ownership on directories and files needed by the processes
RUN chown -R nginx:nginx /run \
  && chown -R nginx:nginx /var/lib/nginx \
  && chmod -R g+w /var/lib/nginx \
  && chown -R nginx:nginx /var/log/nginx \
  && chown -R nginx:nginx /etc/nginx

# switch to use a non-root user
USER nginx

EXPOSE 8080

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisord.conf"]

# then configure a healthcheck
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://localhost:8080/fpm-ping
