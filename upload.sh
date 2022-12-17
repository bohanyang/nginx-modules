#!/usr/bin/env sh
# shellcheck shell=dash

set -eux

for file in *; do
  curl -f -X POST -D - \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H 'Accept: application/vnd.github.v3+json' \
    -H 'Content-Type: application/octet-stream' \
    --data-binary "@${file}" \
    "${UPLOAD_URL}?name=${file}"
done
