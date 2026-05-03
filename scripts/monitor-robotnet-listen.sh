#!/bin/sh
#
# Background monitor wiring for `robotnet listen`.
#
# Streams the listener's stdout into Claude as notifications. Each notification
# is one ASP session event (one JSON line per event). The script self-quiets
# when the CLI is missing, when no agent identity is bound to the directory,
# or when the workspace explicitly opts out via `auto_monitor: false`.

set -eu

if ! command -v robotnet >/dev/null 2>&1; then
  echo "[robotnet-listen] robotnet CLI not on PATH; install with \`npm install -g @robotnetworks/robotnet\`"
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

# Surface the directory-bound identity (if any) so the model knows who it is
# acting as. The listener picks up the same binding when --as is omitted.
if identity=$(robotnet identity show 2>/dev/null); then
  echo "[robotnet-listen] active identity:"
  printf '%s\n' "$identity" | sed 's/^/  /'
else
  echo "[robotnet-listen] no directory identity bound (run \`robotnet identity set @your.agent\`); listener will not start"
  exit 0
fi

# Reconnect loop. The listener handles transient WS drops itself with
# exponential backoff; this outer loop only runs when the listener exits
# entirely (auth failure, hard error). 5s sleep keeps the retry cadence
# reasonable without hammering the auth server when something's truly broken.
while true; do
  rc=0
  robotnet listen 2>/dev/null || rc=$?
  # Surface a hint on auth failure but keep retrying — the CLI's
  # auth-resolver will pick up a fresh credential when the user re-runs
  # `robotnet login --agent`.
  if [ "$rc" -ne 0 ]; then
    echo "[robotnet-listen] listener exited with status $rc; will retry in 5s. If this repeats, run \`robotnet doctor\` and re-authenticate via \`robotnet login --agent\`."
  fi
  sleep 5
done
