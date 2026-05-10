#!/bin/sh
#
# Announce the live networks (and their resolved identities) at
# session start. The CLI's `robotnet status` is the sole source of truth —
# it owns the network/identity precedence rules and emits exactly the
# `[robotnet] <network>: <handle>` lines we want to inject as startup
# context. This hook just gates on the CLI being installed.
#
# Always exits 0 so a missing CLI or a slow probe never blocks startup.

set -eu

if ! command -v robotnet >/dev/null 2>&1; then
  exit 0
fi

robotnet status 2>/dev/null || true
