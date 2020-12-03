![GitHub Workflow Status](https://img.shields.io/github/workflow/status/wernerfred/docker-rainloop/Docker%20Image%20CI?label=Docker%20Build)
![Docker Pulls](https://img.shields.io/docker/pulls/wernerfred/docker-rainloop?label=Docker%20Pulls)
![GitHub](https://img.shields.io/github/license/wernerfred/docker-rainloop?label=License)
![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/wernerfred/docker-rainloop?label=Image%20Size)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/wernerfred/docker-rainloop?label=Latest%20Release)
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/wernerfred/docker-rainloop?label=Latest%20Image)
![GitHub Release Date](https://img.shields.io/github/release-date/wernerfred/docker-rainloop?label=Release%20Date)

# Host your own rainloop instance using docker

This project allows you to host your own instance of [rainloop ](https://github.com/RainLoop/rainloop-webmail) (licensed under [GNU AGPL v3](https://choosealicense.com/licenses/agpl-3.0/)) using docker.

## Installation

### Build from source

To build this project from source make sure to clone the repository from github and change your working directroy into that newly created directory. Then simly issue the ```docker build``` like shown:

```
docker build -t wernerfred/docker-rainloop .
```

### Pull from DockerHub

Another possibility is pulling the image directly from the [DockerHub repository](https://hub.docker.com/r/wernerfred/rainloop). Every release on this project automatically triggers a new build based on the master branch.

```
docker pull wernerfred/docker-rianloop
``` 

### Run container

To run the container user ```docker run```. You might adjust the following command according to your neeeds:

```
docker run -d \
           -p 80:80 \
           wernerfred/docker-rainloop
``` 
