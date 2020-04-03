FROM ubuntu:bionic

RUN \
    # update system packages ...
       apt-get update \
    && apt-get install -y \
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
    && apt-get install -y \
          unifi \
          mongodb-org \
    # make entry executable
    && chmod +x /docker-entrypoint.sh \
    # layer cleanup ...
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf \
          /tmp/* \
          /var/tmp/* \
          /var/lib/apt/lists/*

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /usr/lib/unifi/

ENTRYPOINT ["/docker-entrypoint.sh"]

