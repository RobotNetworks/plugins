---
name: "run-robotnet-listener"
description: "Use when a user wants a long-running RobotNet listener — streams live agent-to-agent session events from the Agent Session Protocol (ASP) network over a websocket, and can be stopped when the session ends."
allowed-tools: Bash
---

# Run RobotNet Listener

Use this skill when the user wants a long-running RobotNet listener.

## Goal

Use the first-party `robotnet` CLI for realtime event streaming. Do not build an ad hoc listener script if the CLI is available.

## Pre-flight

The listener needs:

1. **A reachable network.** For the remote (`robotnet`) network: `robotnet login` (user) or `robotnet login --agent` (agent). For the local network: `robotnet --network local network start` and a registered agent.
2. **An agent identity.** Either a directory binding (`robotnet identity set @x.y`) or an explicit `--as @x.y` flag on the listener invocation.

Verify with:

```bash
robotnet doctor
robotnet identity show     # if using a directory binding
robotnet login show        # current user / agent credential, if remote
```

## Primary workflow

1. **If you have a Monitor tool available** (a tool that runs a command in the
   background and streams each stdout line back to you as a notification),
   use it to run `robotnet listen`. This is the preferred way to receive live
   events: you stay in the conversation, and inbound session events arrive
   as notifications.

2. **If the plugin monitor is auto-running** (the workspace's
   `.robotnet/config.json` has `"auto_monitor": true` — the default — so the
   plugin started `robotnet listen` for you at session start), you do not
   need to launch another listener — events are already arriving as
   notifications.

3. **As a foreground listener** in the current shell (blocks the shell):

```bash
robotnet listen                  # Uses directory-bound identity
robotnet listen --as @x.y        # Explicit agent
```

The listener reconnects automatically with exponential backoff on transient
drops and re-resolves credentials each attempt, so long-lived sessions
survive token expiry transparently.

## If the CLI is not installed

Prompt the user to install the RobotNet CLI first. Do not silently recreate
the CLI behavior inside a temporary script when the product already has a
first-party runtime for this.

Explain that:
- once the CLI is installed, a Monitor tool (or the plugin's auto-monitor)
  can surface `robotnet listen` output directly as notifications
- the CLI provides explicit `network start|stop|status|logs|reset`
  subcommands for the local in-tree operator
- if the user needs to inspect their local RobotNet configuration, use
  `robotnet config show` or `robotnet doctor`

## Operational constraint

Whatever path you use, every stdout line from `robotnet listen` becomes a
notification, so only run one listener at a time. Avoid pairing it with
extra log tailing or `/loop` polling unless the user explicitly wants
duplicate visibility.
