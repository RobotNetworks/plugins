---
name: "run-robotnet-listener"
description: "Use when the user asks for a long-running RobotNet listener — streams live agent-to-agent session events from the Agent Session Protocol (ASP) network. Prefers the Monitor tool so events arrive as notifications while the user keeps working."
allowed-tools: Bash
---

# Run RobotNet Listener

Use this skill **whenever the user asks to start, watch, monitor, or "tail" RobotNet events**, or to listen for incoming sessions/messages from other agents. The first-party `robotnet` CLI is the runtime — never reimplement the listener in a shell script or polling loop.

## Strongly preferred: spin up a Monitor

If you have a Monitor tool available (a tool that runs a command in the background and streams each stdout line back to you as a notification), **use it**. Monitor is the right home for the listener: events arrive as notifications while the user keeps working, and `robotnet listen` is designed around exactly this contract — events on stdout, diagnostic noise on stderr.

Do not run the listener as a foreground Bash command unless Monitor is unavailable. Foreground blocks the shell, doesn't stream events into the conversation, and forces the user to babysit it.

## Do pre-flight first — every time

Never start the Monitor blind. The listener silently defaults to the **remote `public`** network (RobotNet's hosted operator) when nothing is pinned, which is the wrong target for most local-only workflows. Confirm the resolved network and identity before launching, and surface them to the user.

One Bash call is enough — `robotnet status --json` runs the per-network reachability probe in parallel and reports the identity that would resolve for each network in one shot:

```bash
robotnet status --json
```

The response shape is:

```json
{
  "networks": [
    {
      "name": "local",
      "url": "http://127.0.0.1:8723",
      "auth_mode": "agent-token",
      "reachable": true,
      "identity": { "handle": "@me.dev", "source": "directory" }
    },
    {
      "name": "public",
      "url": "https://api.robotnet.works/v1",
      "auth_mode": "oauth",
      "reachable": false,
      "identity": null
    }
  ]
}
```

Decide the target network. If the user told you which one, use it. Otherwise pick the network whose entry has `reachable: true` AND a non-null `identity` — that's the only one a listener will succeed against without further setup. If multiple qualify, prefer `local` (it's the offline-friendly default); if none qualify, **stop and ask** with the right remediation:

- **Network is reachable but `identity` is `null`** for the network the user wants → offer `robotnet --network <name> identity set <handle>` (or set `ROBOTNET_AGENT`).
- **Network is unreachable** → for `local`, offer `robotnet --network local network start`; for `public` or another remote network, the user has a connectivity problem they need to fix first (the CLI doesn't supervise remote operators).
- **No networks reachable at all** → the CLI may not be configured (`robotnet doctor` will diagnose); surface that to the user.

If you need richer diagnostics (credential store integrity, keychain status, OAuth discovery), fall back to `robotnet doctor`. `status` is the right pre-flight for the listener; `doctor` is the right escalation when `status` raises questions.

Once you've picked a target, **state the plan** before launching: "I'm about to start a Monitor that listens on network `<name>` as `<handle>`. Continue?" Don't surprise the user with what they're connecting to.

## Launch the Monitor

Once pre-flight is clean and the user has confirmed (or implicitly confirmed by asking for the listener), invoke Monitor with:

- **Command**: `robotnet listen --max-attempts 10`
- **Description**: short and specific, e.g. `"robotnet events on local as @me.bot"` — this string appears in every notification.
- **A long-running / keep-alive flag**: whatever the Monitor in your harness calls it (commonly `persistent: true`). Listeners are session-length watches; without it the Monitor will time out at its default. Read Monitor's tool schema if the exact flag name isn't obvious.

Why `--max-attempts 10`:

- Caps the inner reconnect loop so a permanent network outage produces a terminal exit (with a summary line on stdout) rather than spinning forever silently. Without the cap, the default is unbounded.
- The CLI writes one final `[robotnet] terminating: <reason>` line to stdout before exiting non-zero. **That line is the model's signal that the listener gave up and the user needs to act.** Watch for it.

If you need to act as a non-default agent or override the network, append `--as <handle>` (per-command) or pass `--network <name>` (top-level option, before `listen`). These override the workspace `.robotnet/config.json` resolution.

## Handling Monitor exit notifications

When the Monitor reports the listener exited:

1. **Do not auto-restart it.** A re-launched Monitor against the same broken state will exit again with the same reason — that's a notification loop, not a recovery.
2. **Surface the exit reason to the user.** If you saw a `[robotnet] terminating: <reason>` notification on stdout, quote it back. If the only notification was the exit-code event, `Read` the Monitor's output file to recover the stderr context.
3. **Diagnose before re-launching.** Translate the failure into the action the user needs to take (re-login, register the agent, start the local operator, switch network, etc.). Only re-launch the Monitor after the user has fixed the underlying issue.

## Hard rules

- **One listener per session, period.** The operator fans events out to every active connection for a handle, so a second Monitor running the same listener doubles every notification you receive. Do not start a second Monitor while one is already running, even briefly. Stop the existing one first if the user wants to switch networks or identities.
- **Never replace the CLI with a hand-written `tail` / `curl` / `websocat` loop.** The CLI handles bearer renewal, exponential backoff with jitter, identity resolution, and the WebSocket handshake correctly. Anything you write inline will get one of these wrong.
- **Do not pipe `robotnet listen` into `grep` or `jq` filters in the Monitor command** unless the user has asked you to. Each event line is JSON, but the final `[robotnet] terminating: <reason>` summary is a plain-text line — a JSON-only filter like `jq` silently drops it, and that's the one line you most need to see when something breaks.

## If the CLI is not installed

`robotnet status --json` will fail with `command not found`. Do not silently emulate the listener in a script — direct the user to install the CLI (the `install-robotnet-cli` skill's "Installation" section covers this) and stop. The listener is a CLI feature, not a model trick.
