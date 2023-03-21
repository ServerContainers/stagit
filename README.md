Stagit recursive Git-Site Generator (ghcr.io/servercontainers/stagit) [x86 + arm]
=================================================================================

Dockerized Version of `stagit` (https://git.codemadness.org/stagit/) - with script to recursively generate an overview over several git projects.

It's based on the [_/alpine](https://registry.hub.docker.com/_/alpine/) Image

View in GitHub Registry [ghcr.io/servercontainers/stagit](https://ghcr.io/servercontainers/stagit)

View in GitHub [ServerContainers/stagit](https://github.com/ServerContainers/stagit)

_currently tested on: x86_64, arm64, arm_

## IMPORTANT!

In March 2023 - Docker informed me that they are going to remove my 
organizations `servercontainers` and `desktopcontainers` unless 
I'm upgrading to a pro plan.

I'm not going to do that. It's more of a professionally done hobby then a
professional job I'm earning money with.

In order to avoid bad actors taking over my org. names and publishing potenial
backdoored containers, I'd recommend to switch over to my new github registry: `ghcr.io/servercontainers`.

## Build & Versions

You can specify `DOCKER_REGISTRY` environment variable (for example `my.registry.tld`)
and use the build script to build the main container and it's variants for _x86_64, arm64 and arm_

You'll find all images tagged like `a3.15.0-sMonFeb2219063620210100` which means `a<alpine version>-s<stagit-latest-commit-date>`.
This way you can pin your installation/configuration to a certian version. or easily roll back if you experience any problems
(don't forget to open a issue in that case ;D).

To build a `latest` tag run `./build.sh release`

## Changelogs

* 2023-03-20
    * github action to build container
    * implemented ghcr.io as new registry
* 2023-03-19
    * switched from docker hub to a build-yourself container
    * added build script and renamend generator script `generator.sh`
    * new way of multiarch build
* 2021-08-03
    * improved performance - only run stagit, if latest change in git is newer than latest generated html
    * serveral bug fixes
* 2020-11-05
    * multiarch build

## Usage

Build the container using `docker-compose build` and run the following command:

```
docker run --rm -v "$PWD/html:/html" -v "$PWD/repositories:/repositories" ghcr.io/servercontainers/stagit
```

## Serve generated files

`docker-compose.yml`

```
version: '3.3'

services:

  webserver:
    image: servercontainers/nginx # build: https://github.com/ServerContainers/nginx
    restart: always
    environment:
      NGINX_RAW_CONFIG_webserver: server {listen 80; listen [::]:80; server_name webserver; location / { root /data; autoindex on; }}
    volumes:
      - '/path/to/html:/data'
```
