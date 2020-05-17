#!/bin/sh -e

if [ -z "$NGINX_DEFAULT_ROOT" ]
then
  NGINX_DEFAULT_ROOT="public_html"
fi

# escape slashes contained in root specification
path=$(echo "$NGINX_DEFAULT_ROOT" | sed 's/\//\\\//g')
# nginx does not support environemnt variables in its configuration therefore
# replacing it with sed
sed -i -- "s/ROOT_DIR/$path/g" /etc/nginx/conf.d/default.conf

# continue by running the command passed
exec "$@"
