#!/bin/bash
export IMG=$(docker build -q --pull --no-cache -t 'get-version' .)

export STAGIT_VERSION=$(docker run --rm -t get-version cat /version | sed 's/Date://g' | sed 's/[^A-Za-z0-9]//g')
export ALPINE_VERSION=$(docker run --rm -t get-version cat /etc/alpine-release | tail -n1 | tr -d '\r')
[ -z "$ALPINE_VERSION" ] && exit 1

export IMGTAG=$(echo "$1""a$ALPINE_VERSION-s$STAGIT_VERSION")
export IMAGE_EXISTS=$(docker pull "$IMGTAG" 2>/dev/null >/dev/null; echo $?)

# return latest, if container is already available :)
if [ "$IMAGE_EXISTS" -eq 0 ]; then
  echo "$1""latest"
else
  echo "$IMGTAG"
fi