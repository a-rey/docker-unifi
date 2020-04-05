#!/bin/bash

echo "[docker-entrypoint.sh] starting ..."
# set default UID/GID if not specified
if [[ -z $APP_UID || -z $APP_GID ]]; then
  echo "[docker-entrypoint.sh] using default UID/GID since none provided ..."
  APP_UID=1234
  APP_GID=5678
fi
# create user if needed
if [[ ! $(id -u app >/dev/null 2>&1) ]]; then
  echo "[docker-entrypoint.sh] creating app user ${APP_UID}:${APP_GID} ..."
  groupadd -g $APP_GID app
  useradd --no-log-init -r -u $APP_UID -g $APP_GID app
fi 
echo "[docker-entrypoint.sh] app user: $(id $APP_UID)"
# make expected volume folders
echo "[docker-entrypoint.sh] making volume mounts ..."
mkdir -p /usr/lib/unifi/{data,logs,run}
# set permissions on application data
echo "[docker-entrypoint.sh] setting app ownership to ${APP_UID}:${APP_GID} ..."
chown -R ${APP_UID}:${APP_GID} /usr/lib/unifi/
# format command with user arguments
APP_CMD="java $JAVA_OPTS -jar /usr/lib/unifi/lib/ace.jar start"
# start server as container user
echo "[docker-entrypoint.sh] running app: $APP_CMD"
exec sudo -u app /bin/bash -c "$APP_CMD"

