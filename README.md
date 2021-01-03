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

Create a `/etc/systemd/system/unifi.service` file with the following content:

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

In `docker-compose.yml` you can customize the following environmental variables:

- `JAVA_OPTS`: Extra command line flags to pass to the Java runtime when the Unifi application is started. For example, `"JAVA_OPTS=-Xmx1024M"` would set the runtime Java heap limit to 1024MB.

In `docker-compose.yml` there are 3 volumes you can map out of the container to your docker host since the Unifi application is **not** running as `root`:

- By default, the user ID and group ID of the image user is `6969`. You can change this in the `Dockerfile` before building the image to suit your needs.

| Container Directory   | Default Docker Volume in `docker-compose.yml` |
| --------------------- | --------------------------------------------- |
| `/usr/lib/unifi/data` | `unifi_data`                                  |
| `/usr/lib/unifi/logs` | `unifi_logs`                                  |
| `/usr/lib/unifi/run`  | `unifi_run`                                   |

## Run:

Start the service and browse to `https://<host-ip>:8443`:

```bash
sudo systemctl start unifi
```

Your container data host location can be found by running the following docker commands:

```bash
sudo docker volume ls
sudo docker volume inspect <volume_name>
```

**NOTE:** If you are having trouble getting devices to be adopted by the unifi controller, you may need to set the controller hostname/IP manually under controller settings and check the box to override the controller hostname/IP. The controller hostname can be the FQDN for your controller on your network or the IP you statically assign the controller from your DNS server:

![](https://img.community.ui.com/12516be0-c60a-4f8e-b02c-70be91a0dfa6/answers/1e455b55-9a2b-4be1-ab28-b7a8d5b5337c/b8282b56-d454-4d6f-96ac-5fef69a48807)

_see this [Unifi forum discussion post](https://community.ui.com/questions/UniFi-is-stuck-at-Adopting/596ee99e-5828-4fa2-930d-e6d3b68deba6) for more info_

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
# delete all docker images
sudo docker rmi $(sudo docker images -aq)
# delete all unmapped docker volumes
sudo docker volume rm $(sudo docker volume ls -q)
# start a bash shell in the unifi image
sudo docker run -it --entrypoint /bin/bash unifi:latest -s
# view logs from unifi-controller container
sudo docker logs unifi-controller
# reload changes to /etc/systemd/system/unifi.service
sudo systemctl daemon-reload
```

For image development & updating, the following script is helpful:

```bash
#!/bin/bash
# stop service
echo '[!!!] stopping unifi service ...'
sudo systemctl stop unifi
# stop and remove active containers
echo '[!!!] stopping unifi containers ...'
sudo docker stop $(sudo docker ps -aq)
echo '[!!!] removing unifi containers ...'
sudo docker rm $(sudo docker ps -aq)
# delete old container volumes
# NOTE: this will delete any backups!
#echo '[!!!] deleting unifi volumes ...'
#sudo docker volume rm $(sudo docker volume ls -q)
# delete image
echo '[!!!] deleting unifi image ...'
sudo docker rmi unifi:latest
# goto location of repo with Dockerfile and rebuild image
# NOTE: assumes git repo in home directory of current user
echo '[!!!] re-building unifi image ...'
cd ~/docker_unifi/
sudo docker build --tag unifi:latest .
# start service and look at container logs
echo '[!!!] starting unifi service ...'
sudo systemctl start unifi &
watch -n 0.5 sudo docker logs unifi-controller
```

