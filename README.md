Stagit recursive Git-Site Generator
=====================================

Dockerized Version of `stagit` (https://git.codemadness.org/stagit/) - with script to recursively generate an overview over several git projects.

## Usage

```
docker run --rm -v "$PWD/html:/html" -v "$PWD/repositories:/repositories" servercontainers/stagit
```
