#!/bin/sh

set -eu

if ! command -v robotnet >/dev/null 2>&1; then
  echo "[robotnet-listen] robotnet CLI not on PATH; install with \`npm install -g @robotnetworks/robotnet\`"
  exit 0
fi

# Always surface the current identity so the model knows who it is acting as,
# even if the listener does not run.
if identity=$(robotnet me show 2>/dev/null); then
  echo "[robotnet-listen] active identity:"
  printf '%s\n' "$identity" | sed 's/^/  /'
else
  echo "[robotnet-listen] not logged in (run \`robotnet login\` to authenticate); listener will not start"
  exit 0
fi

# Walk up from PWD looking for .robotnet/config.json; halt at $HOME and /.
find_workspace_config() {
  dir=$(pwd -P)
  home=$(cd "$HOME" && pwd -P)
  while :; do
    candidate="$dir/.robotnet/config.json"
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
  echo "[robotnet-listen] listener disabled by $config_file (auto_monitor=false); not streaming events"
  exit 0
fi

# Exit code 78 is reserved by `robotnet listen` to mean "authentication failed —
# the stored credential is bad and retrying won't help". Surface it once and
# stop looping so we don't hammer the auth server (and the model) on every cycle.
AUTH_FAILED_EXIT=78

while true; do
  rc=0
  robotnet listen 2>/dev/null || rc=$?
  if [ "$rc" -eq "$AUTH_FAILED_EXIT" ]; then
    echo "[robotnet-listen] authentication failed; run \`robotnet login\` to re-authenticate, then restart with \`/robotnet:run-robotnet-listener\`"
    exit 0
  fi
  sleep 5
done
