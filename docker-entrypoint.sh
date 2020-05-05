#!/bin/bash

echo "[docker-entrypoint.sh] starting ..."
echo "[docker-entrypoint.sh] user: $(id)"
java $JAVA_OPTS -jar /usr/lib/unifi/lib/ace.jar start
