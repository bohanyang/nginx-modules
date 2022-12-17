#!/usr/bin/env sh
# shellcheck shell=dash

set -eux

arch=$(uname -m)

for module in $ENABLED_MODULES; do
  for file in "nginx-module-${module}-${NGINX_VERSION}."*.apk; do
    name=${file%.*}-${arch}.apk
    curl -f -X POST -D - \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      -H 'Accept: application/vnd.github.v3+json' \
      -H 'Content-Type: application/octet-stream' \
      --data-binary "@${file}" \
      "${UPLOAD_URL}?name=${name}"
  done
done
