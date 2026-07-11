#!/bin/sh
# automated smoke test for the stagit container
# builds the image, then creates a throwaway git repo INSIDE the container,
# runs stagit/stagit-index against it and asserts real HTML was generated.
set -eu

IMAGE=stagit-test
NAME=stagit-test-run

FAILED=0
fail() {
  echo "FAIL: $*" >&2
  FAILED=1
}

cleanup() {
  echo ">> cleanup: removing container $NAME"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo ">> building image $IMAGE"
docker build -t "$IMAGE" .

echo ">> starting container $NAME"
docker rm -f "$NAME" >/dev/null 2>&1 || true
# override the default generate.sh CMD and just keep the container alive so we
# can drive it via docker exec
docker run -d --name "$NAME" "$IMAGE" sleep 600

echo ">> assert: stagit binaries present on PATH"
if docker exec "$NAME" sh -c 'command -v stagit && command -v stagit-index' >/dev/null; then
  echo "ok - stagit + stagit-index present"
else
  fail "stagit binaries missing"
fi

# everything below needs the binaries; bail out early if they are gone
if [ "$FAILED" -eq 0 ]; then

  echo ">> creating throwaway git repo inside the container"
  docker exec "$NAME" sh -c '
    set -e
    git config --global user.email "test@example.com"
    git config --global user.name  "Tester"
    rm -rf /tmp/work /tmp/demo.git /tmp/out
    mkdir -p /tmp/work && cd /tmp/work
    git init -q
    echo "hello stagit" > README.md
    git add README.md
    git commit -q -m "initial commit for stagit smoke test"
    echo "second line" >> README.md
    git commit -q -am "second commit tweak"
    # stagit reads a bare repo; clone the working repo into one
    git clone -q --bare /tmp/work /tmp/demo.git
    echo "demo repository" > /tmp/demo.git/description
  '

  echo ">> running stagit + stagit-index against the repo"
  docker exec "$NAME" sh -c '
    set -e
    mkdir -p /tmp/out && cd /tmp/out
    stagit /tmp/demo.git
    stagit-index /tmp/demo.git > index.html
  '

  echo ">> assert: log.html generated"
  if docker exec "$NAME" test -f /tmp/out/log.html; then
    echo "ok - log.html exists"
  else
    fail "log.html was not generated"
  fi

  echo ">> assert: files.html generated"
  if docker exec "$NAME" test -f /tmp/out/files.html; then
    echo "ok - files.html exists"
  else
    fail "files.html was not generated"
  fi

  echo ">> assert: index.html generated"
  if docker exec "$NAME" test -f /tmp/out/index.html; then
    echo "ok - index.html exists"
  else
    fail "index.html was not generated"
  fi

  echo ">> assert: log.html contains the commit message"
  if docker exec "$NAME" grep -q "initial commit for stagit smoke test" /tmp/out/log.html; then
    echo "ok - commit message present in log.html"
  else
    fail "commit message not found in log.html"
  fi

  echo ">> assert: files.html lists the committed file"
  if docker exec "$NAME" grep -q "README.md" /tmp/out/files.html; then
    echo "ok - README.md present in files.html"
  else
    fail "README.md not found in files.html"
  fi

  echo ">> assert: index.html lists the repository"
  if docker exec "$NAME" grep -q "demo" /tmp/out/index.html; then
    echo "ok - repo listed in index.html"
  else
    fail "repo not listed in index.html"
  fi

fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  exit 0
else
  echo "SOME TESTS FAILED"
  exit 1
fi
