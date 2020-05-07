#!/usr/bin/env sh

apk --no-cache add curl

# sleeping to avoid querying the server before it starts up completely
sleep 2
echo 'Slept for 2 seconds, querying now'
curl http://app:8080
echo 'Querying now with grep'
curl --silent --fail http://app:8080 | grep 'PHP 7.3'
echo $?
curl http://app:8080
echo 'Queried'
