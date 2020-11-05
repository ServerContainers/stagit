Stagit recursive Git-Site Generator
=====================================

Dockerized Version of `stagit` (https://git.codemadness.org/stagit/) - with script to recursively generate an overview over several git projects.


## Changelogs

* 2020-11-05
    * multiarch build


## Usage

```
docker run --rm -v "$PWD/html:/html" -v "$PWD/repositories:/repositories" servercontainers/stagit
```


## Serve generated files

`docker-compose.yml`

```
version: '3.3'

services:

  webserver:
    image: servercontainers/nginx
    restart: always
    environment:
      NGINX_RAW_CONFIG_webserver: server {listen 80; listen [::]:80; server_name webserver; location / { root /data; autoindex on; }}
    volumes:
      - '/path/to/html:/data'
```
