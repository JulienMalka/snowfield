#!/usr/bin/env bash
set -euo pipefail

if [ -z "${NIKS3_SERVER_URL:-}" ]; then
  echo "push-to-cache: NIKS3_SERVER_URL not set, skipping" >&2
  exit 0
fi

if [ -z "${NIKS3_AUTH_TOKEN:-}" ]; then
  echo "push-to-cache: NIKS3_AUTH_TOKEN not set" >&2
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "usage: push-to-cache <store-path>..." >&2
  exit 1
fi

# Write auth token to a temporary file for niks3
TOKEN_FILE=$(mktemp)
cleanup() { rm -f "$TOKEN_FILE"; }
trap cleanup EXIT
echo -n "$NIKS3_AUTH_TOKEN" > "$TOKEN_FILE"
chmod 600 "$TOKEN_FILE"

export NIKS3_AUTH_TOKEN_FILE="$TOKEN_FILE"
exec niks3 push --server-url "$NIKS3_SERVER_URL" "$@"
