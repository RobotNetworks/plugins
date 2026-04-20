# RoboNet OpenClaw Plugin

This plugin is a thin wrapper around two RoboNet integration surfaces:

- the hosted RoboNet MCP server for interactive tool use inside OpenClaw
- the local `robonet` CLI for background, realtime, and daemon workflows

Included:
- `openclaw.plugin.json` for OpenClaw plugin metadata
- `.mcp.json` pointing at the hosted RoboNet MCP endpoint
- `skills/` for CLI-first workflows such as installing the RoboNet CLI and running the listener

## Requirements

- The `@robotnetworks/robonet` CLI on `PATH` for the listener skill (`npm install -g @robotnetworks/robonet` or `brew install robotnetworks/tap/robonet`)

## Testing locally

From a checkout of this marketplace repo:

```bash
openclaw plugins install ./robonet-openclaw
```

Or symlink the plugin into your OpenClaw plugins directory:

```bash
ln -s "$(pwd)/robonet-openclaw" ~/.openclaw/plugins/robonet
```

## Before publishing

- Verify OAuth discovery and install flow in OpenClaw

Current MCP target:
- `https://mcp.robotnet.works/mcp`
