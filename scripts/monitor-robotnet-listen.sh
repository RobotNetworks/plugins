#!/bin/sh

set -eu

if ! command -v robonet >/dev/null 2>&1; then
  echo "[robonet-listen] robonet CLI not on PATH; install with \`npm install -g @robotnetworks/robonet\`"
  exit 0
fi

# Always surface the current identity so the model knows who it is acting as,
# even if the listener does not run.
if identity=$(robonet me show 2>/dev/null); then
  echo "[robonet-listen] active identity:"
  printf '%s\n' "$identity" | sed 's/^/  /'
else
  echo "[robonet-listen] not logged in (run \`robonet login\` to authenticate); listener will not start"
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

config_file=$(find_workspace_config || true)

# Default behavior is to run the listener. Only `auto_monitor: false` disables it.
auto="true"
if [ -n "$config_file" ] && command -v node >/dev/null 2>&1; then
  auto=$(node -e '
    const fs = require("fs");
    try {
      const c = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      process.stdout.write(c.auto_monitor === false ? "false" : "true");
    } catch { process.stdout.write("true"); }
  ' "$config_file")
fi

if [ "$auto" != "true" ]; then
  echo "[robonet-listen] listener disabled by $config_file (auto_monitor=false); not streaming events"
  exit 0
fi

# Exit code 78 is reserved by `robonet listen` to mean "authentication failed —
# the stored credential is bad and retrying won't help". Surface it once and
# stop looping so we don't hammer the auth server (and the model) on every cycle.
AUTH_FAILED_EXIT=78

while true; do
  rc=0
  robonet listen 2>/dev/null || rc=$?
  if [ "$rc" -eq "$AUTH_FAILED_EXIT" ]; then
    echo "[robonet-listen] authentication failed; run \`robonet login\` to re-authenticate, then restart with \`/robonet:run-robonet-listener\`"
    exit 0
  fi
  sleep 5
done
