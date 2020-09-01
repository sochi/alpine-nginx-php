# Dockerize a PHP application

This repository is extending https://github.com/trafex/docker-php-nginx with 
minor changes to ease containerising a PHP application by using this image as
base.

For full description of the original repository please visit
https://github.com/trafex/docker-php-nginx directly. To provide a brief summary
here:
* based on Alpine Linux distribution
* running unprivileged Nginx and PHP-FPM from supervisord

The respective changes include installing of `pdo_mysql` extentsion instead of
MySQLi . And setting the default public directory differently to keep it closer
to other images, such as `composer`.

[![Docker pulls](https://img.shields.io/docker/pulls/soch1/alpine-nginx-php.svg)](https://hub.docker.com/r/soch1/alpine-nginx-php/)
[![Docker image layers](https://images.microbadger.com/badges/image/soch1/alpine-nginx-php.svg)](https://microbadger.com/images/soch1/alpine-nginx-php)


## Extending the server

The repository already contains a default server configuration that might be
sufficient in most cases. When necessary it can be extended (rather than
replaced completely) by providing one or more `.conf.add` files.

The default server only uses HTTP and listens on port 8080. This is done to ease
the configuration, and HTTPS can be terminated before the requests are proxied
to the service; for details see below.


## Expected usage

The image defined in this repository is primarily expected to be used as base
when defining other images.

```Dockerfile
FROM soch1/alpine-nginx-php
WORKDIR /app
COPY --chown=nginx <your_directory>/ /app

# append other configuration to the server if necessary
# for instance we can set expiration headers for cache, or to disable access
# logging on favicon.ico and robots.txt
COPY <your_configuration_file>.conf /etc/nginx/conf.d/default.conf.add
```


### Usage with composer

With dependencies managed with [Composer](https://getcomposer.org/) the build
definition could be changed to use a multi-stage build.

Note that only the downloaded dependencies should be copied over and not the
composer itself.

```Dockerfile
FROM composer AS composer

# copying the source directory and install the dependencies with composer
COPY <your_directory>/ /app
RUN composer install \
  --no-dev \
  --optimize-autoloader \
  --no-interaction \
  --no-progress

# continue stage build with the desired image and copy the source including the
# dependencies downloaded by composer
FROM soch1/alpine-nginx-php
COPY --chown=nginx --from=composer /app /app

# configure a directory with publicly available content
ENV NGINX_DEFAULT_ROOT www

# make logging and cache directories needed by the application,
# building using nginx user therefore ownership setup is unnecessary as the
# directories are created for current user
WORKDIR /app
RUN mkdir log temp

# append other configuration to the server if necessary
# for instance we can set expiration headers for cache, or to disable access
# logging on favicon.ico and robots.txt
COPY <your_configuration_file>.conf /etc/nginx/conf.d/default.conf.add
```


## Configure Nginx public root

The public root in Nginx is set to `/app/public_html` by default. However this
can be modified by providing a `NGINX_DEFAULT_ROOT` environment variable. The
path is then appended to the default `/app`.

```yaml
services:
  app:
    image: soch1/alpine-nginx-php
    environment:
      NGINX_DEFAULT_ROOT: your/public/dir
    volumes:
      - ./path/to/www:/app
```

The example above sets the public root to `/app/your/public/dir`.


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


## Availability

The image can be downloaded from [Docker Hub](https://hub.docker.com/r/soch1/alpine-nginx-php).


### Building locally

If necessary the respective image can be build locally, instead of downloading
it from the Docker Hub.

```bash
docker build -t alpine-nginx-php .
```
