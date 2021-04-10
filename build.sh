#!/bin/sh
# shellcheck shell=dash

set -eux

mkdir -p repository
docker build --build-arg ENABLED_MODULES -f "$1.Dockerfile" -t "$1-build" .
docker cp "$(docker create "$1-build"):/packages" "repository/$1"
cd repository
dpkg-scanpackages "$1" /dev/null | gzip -c9 > "$1/Packages.gz"
