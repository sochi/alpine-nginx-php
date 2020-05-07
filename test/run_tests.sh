#!/usr/bin/env sh

apk --no-cache add curl

# sleeping to avoid querying the server before it starts up completely
sleep 2
curl --silent --fail http://app:8080 | grep 'PHP 7.3'
