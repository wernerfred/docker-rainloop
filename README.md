![GitHub Workflow Status](https://img.shields.io/github/workflow/status/wernerfred/docker-rainloop/Docker%20Image%20CI?label=Docker%20Build)
![Docker Pulls](https://img.shields.io/docker/pulls/wernerfred/docker-rainloop?label=Docker%20Pulls)
![GitHub](https://img.shields.io/github/license/wernerfred/docker-rainloop?label=License)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/wernerfred/docker-rainloop?label=Image%20Size)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/wernerfred/docker-rainloop?label=Latest%20Release)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/wernerfred/docker-rainloop?label=Latest%20Image)
![GitHub Release Date](https://img.shields.io/github/release-date/wernerfred/docker-rainloop?label=Release%20Date)

# Host your own rainloop instance using docker

This project allows you to host your own instance of [rainloop ](https://github.com/RainLoop/rainloop-webmail) community edition (licensed under [GNU AGPL v3](https://choosealicense.com/licenses/agpl-3.0/)) using docker.

## Installation

### Build from source

To build this project from source make sure to clone the repository from github and change your working directroy into that newly created directory. Then simly issue the ```docker build``` like shown:

```
docker build -t wernerfred/docker-rainloop .
```

### Pull from DockerHub

Another possibility is pulling the image directly from the [DockerHub repository](https://hub.docker.com/r/wernerfred/rainloop). Every release on this project automatically triggers a new build based on the master branch.

```
docker pull wernerfred/docker-rainloop
``` 

### Run container

To run the container user ```docker run```. You might adjust the following command according to your neeeds:

```
docker run -d \
           -p 80:80 \
           wernerfred/docker-rainloop
``` 

## Persisting data

There are several ways to persists the data inside the container. The Dockerfile defines a unnamed volume so if you do not specify anything docker creates a unnamed volume by default and makes your data accessible to the host there (find and inspect it with ```docker volume``` commands). The other two options are using a named volume or a bind mount which can be configured as follows (docker-compose using bind mount):

```
version: '3'

services:
  rainloop:
    image: wernerfred/docker-rainloop:latest
    container_name: docker-rainloop
    restart: always
    ports:
      - 80:80
    volumes:
      - /opt/docker-rainloop/data:/rainloop/data
```

## Configuration

To configure rainloop use the admin panel which can be accessed by: ```http://YOUR-IP/?admin```
The default login credentials are: ```admin``` and ```12345```.
The configuration is saved to: ```/rainloop/data/_data_/_default_/configs/application.ini```.
For further configuration options see the [official documentation](https://www.rainloop.net/docs/configuration/).

## Container structure and versions

The container uses the official [php-apache](https://hub.docker.com/_/php) base image. Rainloop is installed in the community edition to ```/rainloop```. The data lives in ```/rainloop/data```. Apache uses port 80.
You can define the image version by specifying a version tag behind the image. The project aims to provides the same version number as the used rainloop installation starting from ```1.14.0```. So ```wernerfred/docker-rainloop:1.14.0``` will use [rainloop-community-1.14.0](https://github.com/RainLoop/rainloop-webmail/releases/tag/v1.14.0) in the container.

## Reverse proxy

To secure the installation you should access the container through a reversy proxy which preferable will also handle SSL encryption for the connection.

### Nginx

If using ```nginx``` as a local reverse proxy you could use the following configuration (```docker-rainloop``` exposed on port ```8080``` and Let's Encrypt certs via ```certbot```):

```
server {
    listen       80;
    server_name  <mail.domain.tld>;
    return       301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name <mail.domain.tld>;
    root /dev/null;

    access_log /var/log/nginx/<mail.domain.tld>.access.log combined;
    error_log /var/log/nginx/<mail.domain.tld>.error.log warn;

    location / {
      proxy_pass http://localhost:8080;
      proxy_set_header X-Forwarded-Host $host:$server_port;
      proxy_set_header X-Forwarded-Server $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    ssl_certificate /etc/letsencrypt/live/<mail.domain.tld>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<mail.domain.tld>/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/<mail.domain.tld>/chain.pem;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
}
```

### Traefik

If you are using a reverse proxy like ```traefik``` you could use a configuration like this (```traefik``` located in the same ```proxy``` network:

```
version: '3'

services:
  rainloop:
    image: wernerfred/docker-rainloop:latest
    container_name: docker-rainloop
    restart: always
    volumes:
      - /opt/docker-rainloop/data:/rainloop/data
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.middlewares.rainloop-https.redirectscheme.scheme=https"
      - "traefik.http.routers.rainloop-http.entrypoints=web"
      - "traefik.http.routers.rainloop-http.rule=Host(`<mail.domain.tld>`)"
      - "traefik.http.routers.rainloop-http.middlewares=rainloop-https@docker"
      - "traefik.http.routers.rainloop-https.entrypoints=websecure"
      - "traefik.http.routers.rainloop-https.rule=Host(`<mail.domain.tld>`)"
      - "traefik.http.routers.rainloop-https.tls=true"
      - "traefik.http.routers.rainloop-https.tls.certresolver=letsencrypt"
      - "traefik.http.routers.rainloop-https.tls.domains[0].main=<mail.domain.tld>"
```
