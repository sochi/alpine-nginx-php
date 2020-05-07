# Dockerize a PHP application

This repository is extending https://github.com/trafex/docker-php-nginx with 
minor changes to ease containerising a PHP application by using this image as
base.

For full description of the original repository please visit
https://github.com/trafex/docker-php-nginx directly. To provide a brief summary
here:
* based on Alpine Linux distribution
* running unprivileged Nginx and PHP-FPM from supervisord

[![Docker pulls](https://img.shields.io/docker/pulls/s0chi/alpine-nginx-php.svg)](https://hub.docker.com/r/s0chi/alpine-nginx-php/)
[![Docker image layers](https://images.microbadger.com/badges/image/s0chi/alpine-nginx-php.svg)](https://microbadger.com/images/s0chi/alpine-nginx-php)

## Extending the server

The repository already contains a default server configuration that might be
sufficient in most cases. When necessary it can be extended (rather than
replaced completely) by providing one or more `.conf.add` files.

The default server only uses HTTP and listens on port 8080. This is done to ease
the configuration, and HTTPS can be terminated before the requests are proxied
to the service; for details see below.

## Expected usage

```Dockerfile
# build an image from this repository as base image
FROM s0chi/alpine-nginx-php
WORKDIR /var/www
COPY --chown=nginx <your_directory>/ /var/www

# append other configuration to the server if necessary
# for instance we can set expiration headers for cache, or to disable access
# logging on favicon.ico and robots.txt
COPY <your_configuration_file>.conf /etc/nginx/conf.d/default.conf.add
```

## Running with HTTPS

A docker image containing both the PHP application and the HTTP server can be
then started as service using `docker-compose`.

```yaml
version: '3'

services:
  app:
    image: image-that-you-built-above
    restart: unless-stopped
```

In cases When HTTP is sufficient the server can be then exposed directly by
mapping the ports.

```yaml
    ports:
      - 80:8080
```

### Proxy the requests

With any advanced configuration needed, such as terminating HTTPS, a public HTTP
server can be started to terminate HTTPS, and to proxy the filtered requests to
the service.

```
location /api/ {
  proxy_pass http://<container_name>;
  proxy_set_header Host $http_host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_read_timeout 900;
}
```

## Adding composer

This section is kept from the original repository. Preferably this should be
rewritten using a multi-stage build definition.

```Dockerfile
# build the image locally or download it from the Docker Hub
FROM s0chi/alpine-nginx-php:latest

# install composer from the official image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# run composer install to install the dependencies
RUN composer install --optimize-autoloader --no-interaction --no-progress
```

## Building the image locally

```bash
docker build -t docker-php-nginx .
```
