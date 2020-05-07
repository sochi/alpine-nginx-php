FROM alpine:3.11

RUN apk --no-cache add \
  curl \
  php7 \
  php7-fpm \
  php7-opcache \
  php7-mysqli \
  php7-json \
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
RUN apk --no-cache add bash sed

# copy over the nginx configuration along with default server settings that
# defines the public root
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf

# configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# configure process supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# force ownership on directories and files needed by the processes
RUN chown -R nginx:nginx /run \
  && chown -R nginx:nginx /var/lib/nginx \
  && chmod -R g+w /var/lib/nginx \
  && chown -R nginx:nginx /var/tmp/nginx \
  && chown -R nginx:nginx /var/log/nginx

# switch to use a non-root user
USER nginx

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# then configure a healthcheck
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://localhost:8080/fpm-ping
