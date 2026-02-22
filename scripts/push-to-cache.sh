#!/usr/bin/env bash
set -euo pipefail

if [ -z "${STORE_ENDPOINT:-}" ] || [ -z "${STORE_USER:-}" ]; then
  echo "push-to-cache: STORE_ENDPOINT or STORE_USER not set, skipping" >&2
  exit 0
fi

if [ -z "${STORE_PASSWORD:-}" ]; then
  echo "push-to-cache: STORE_PASSWORD not set" >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "usage: push-to-cache <store-path>" >&2
  exit 1
fi

cleanup() { rm -f .netrc; }
trap cleanup EXIT

host=$(echo "$STORE_ENDPOINT" | sed 's|https\?://||;s|/.*||')
cat > .netrc <<EOF
machine $host
login $STORE_USER
password $STORE_PASSWORD
EOF
chmod 600 .netrc

nix copy \
  --extra-experimental-features nix-command \
  --to "${STORE_ENDPOINT}?compression=none" \
  --netrc-file .netrc \
  "$@"
