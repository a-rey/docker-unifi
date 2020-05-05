FROM ubuntu:bionic

# local image user ID and group ID to not run as root
ENV USER_UID 6969
ENV USER_GID 6969

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN \
    # update system packages ...
       apt-get update \
    && apt-get install -y --no-install-recommends \
          gnupg \
          ca-certificates \
          apt-transport-https \
          openjdk-8-jre-headless \
    # install MongoDB repo ..." \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | \
          tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    # install Unifi repo ...
    && apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50 \
    && echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' | \
          tee /etc/apt/sources.list.d/100-ubnt-unifi.list \
    # update package database ...
    && apt-get update \
    # install MongoDB 3.4 & Unifi ...
    && apt-get install -y --no-install-recommends \
          unifi \
          mongodb-org \
    # make entry executable
    && chmod +x /docker-entrypoint.sh \
    # make expected static file volume mounts and nginx files
    && mkdir -p /usr/lib/unifi/data \
    && mkdir -p /usr/lib/unifi/logs \
    && mkdir -p /usr/lib/unifi/run \
    # create image user
    && groupadd -g $USER_GID app_user \
    && useradd --no-log-init -r -u $USER_UID -g $USER_GID app_user \
    # change app ownership to image user
    && chown -R ${USER_UID}:${USER_GID} /usr/lib/unifi/ \
    # layer cleanup ...
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf \
          /tmp/* \
          /var/tmp/* \
          /var/lib/apt/lists/*

# define application volumes
VOLUME ["/usr/lib/unifi/data","/usr/lib/unifi/logs","/usr/lib/unifi/run"]

WORKDIR /usr/lib/unifi/

USER app_user

ENTRYPOINT ["/docker-entrypoint.sh"]
