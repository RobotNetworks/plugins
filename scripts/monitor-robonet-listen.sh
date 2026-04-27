#!/bin/sh

set -eu

if ! command -v robonet >/dev/null 2>&1; then
  exit 0
fi

# Walk up from PWD looking for .robonet/config.json; halt at $HOME and /.
find_workspace_config() {
  dir=$(pwd -P)
  home=$(cd "$HOME" && pwd -P)
  while :; do
    candidate="$dir/.robonet/config.json"
    if [ -f "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    [ "$dir" = "$home" ] && return 1
    parent=$(dirname "$dir")
    [ "$parent" = "$dir" ] && return 1
    dir="$parent"
  done
}

config_file=$(find_workspace_config) || exit 0

if ! command -v node >/dev/null 2>&1; then
  exit 0
fi

auto=$(node -e '
  const fs = require("fs");
  try {
    const c = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    process.stdout.write(c.auto_monitor === true ? "true" : "false");
  } catch { process.stdout.write("false"); }
' "$config_file")

[ "$auto" = "true" ] || exit 0

while true; do
  rc=0
  robonet listen 2>/dev/null || rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "[robonet-listen] exited (code $rc); retrying in 5s"
  fi
  sleep 5
done
