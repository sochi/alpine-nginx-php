#!/usr/bin/env sh

apk --no-cache add curl

# sleeping to avoid querying the server before it starts up completely
sleep 2
echo 'Slept for 2 seconds, querying now'
curl http://app:8080 | head -n3
sleep 10
echo 'Slept for 10 seconds, querying now'
curl http://app:8080 | head -n3
echo 'Querying now with grep'
curl --silent --fail http://app:8080 | grep 'PHP 7.3'
echo
echo "RETURNED"
echo $?
echo
ping app -c5

sleep 20
echo 'Slept for 20 seconds, querying now'
curl http://app:8080 | head -n3
echo 'Queried'
