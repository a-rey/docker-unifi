#!/bin/sh

# set default user if not specified
if [ -z ${USER} ]; then
  USER="unifi"
fi

# check if container user created
id -u "$USER" >/dev/null 2>&1
if [ $? ]; then
  # create user
  groupadd -r $USER
  useradd --no-log-init -r -g $USER $USER
  # make expected volume folders
  mkdir -p /usr/lib/unifi/{data,logs,run}
  # set permissions on them
  chown -R $USER:$USER /usr/lib/unifi/
fi

# start server as container user
CMD="java ${JAVA_OPTS} -jar /usr/lib/unifi/lib/ace.jar start"
exec sudo -u $USER $CMD

