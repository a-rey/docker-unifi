# Ubuntu Docker Unifi Network Controller

Docker image for the [Unifi Network Controller](https://unifi-network.ui.com/#unifi) software on Ubuntu 18.04 LTS.

![Unifi Logo](https://unifi-network.ui.com/logo192.png)

## Install:

- [Ubuntu amd64 ISO download](https://ubuntu.com/download/server/thank-you?version=18.04.4&architecture=amd64)
- [Docker CE Install](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Docker Compose Install](https://docs.docker.com/compose/install/)

## Build:

Building the docker image:

```bash
sudo docker build --tag unifi:latest .
```

Create an `/etc/systemd/system/unifi.service` file with the following content:

- **NOTE:** replace `<path to your docker-compose.yml>` below with your system's path

```
[Unit]
Description=Unifi Docker Compose App Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/docker-compose -f <path to your docker-compose.yml> up -d
ExecStop=/usr/local/bin/docker-compose -f <path to your docker-compose.yml> down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Install the service:

```bash
sudo systemctl enable unifi
```

## Settings:

In `docker-compose.yml` there are 3 environmental variables you can customize:

- `APP_UID`: User ID for the container runtime of the Unifi Java application. Default is `1234`. 
- `APP_GID`: Group ID for the container runtime of the Unifi Java application. Default is `5678`.
- `JAVA_OPTS`: Extra command line flags to pass to the Java runtime when the Unifi application is started. For example, `"JAVA_OPTS=-Xmx1024M"` would set the runtime Java heap limit to 1024MB.

In `docker-compose.yml` there are 3 volumes you can map out of the container to your docker host since the Unifi application is **not** running as `root`:

| Container Directory   | Default Host Mountpoint in `docker-compose.yml` |
| --------------------- | ----------------------------------------------- |
| `/usr/lib/unifi/data` | `/docker/unifi/data`                            |
| `/usr/lib/unifi/logs` | `/docker/unifi/logs`                            |
| `/usr/lib/unifi/run`  | `/docker/unifi/run`                             |

## Run:

Make required container volume directories and change ownership to the `APP_UID` and `APP_GID` values from your `docker-compose.yml` file (using `APP_UID` and `APP_GID` defaults below):

```bash
sudo mkdir -vp /docker/unifi/{data,logs,run}
sudo chown -R 1234:5678 /docker/unifi/
```

Start the service and browse to `https://<host-ip>`:

```
sudo systemctl start unifi
```

## Development Notes:

Unifi Network Controller installation steps taken from these sources:

- https://stoffelconsulting.com/install-unifi-5-8-x-on-ubuntu-18-04-lts/
- https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-and-Update-via-APT-on-Debian-or-Ubuntu

Helpful Docker debugging commands:

```bash
# stop all running containers
sudo docker stop $(sudo docker ps -aq)
# delete all containers
sudo docker rm $(sudo docker ps -aq)
# delete unifi docker image
sudo docker rmi unifi:latest
# delete all docker images
sudo docker rmi $(sudo docker images -aq)
# start a bash shell in the unifi image
sudo docker run -it --entrypoint /bin/sh unifi:latest -s
# delete all unmapped docker volumes
sudo docker volume rm $(sudo docker volume ls -q)
# view logs from unifi-controller container
sudo docker logs unifi-controller
# reload changes to /etc/systemd/system/unifi.service
sudo systemctl daemon-reload
```

For image development, the following script is helpful:

```bash
#!/bin/bash
# delete old container logs
sudo rm -rvf /docker/unifi/
# stop service
sudo systemctl stop unifi
# stop and remove active containers
sudo docker stop $(sudo docker ps -aq)
sudo docker rm $(sudo docker ps -aq)
# delete image
sudo docker rmi unifi:latest
# goto location of repo with Dockerfile and rebuild image
cd ~/docker_unifi/
sudo docker build --tag unifi:latest .
# create new container directories with ownership
sudo mkdir -vp /docker/unifi/{data,logs,run}
sudo chown -R 6969:6969 /docker/unifi/
# start service and look at container logs
sudo systemctl start unifi &
watch -n 0.5 sudo docker logs unifi-controller
```



