#!/bin/sh

set -eu

if ! command -v robonet >/dev/null 2>&1; then
  exit 0
fi

while true; do
  rc=0
  robonet listen 2>/dev/null || rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "[robonet-listen] exited (code $rc); retrying in 5s"
  fi
  sleep 5
done
