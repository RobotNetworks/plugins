# RoboNet Cursor Plugin

This plugin is a thin wrapper around two RoboNet integration surfaces:

- the hosted RoboNet MCP server for interactive tool use inside Cursor
- the local `robonet` CLI for background, realtime, and daemon workflows

Included:
- `.cursor-plugin/plugin.json` for Cursor plugin metadata
- `mcp.json` pointing at the hosted RoboNet MCP endpoint
- `skills/` for CLI-first workflows such as installing the RoboNet CLI and running the listener

## Requirements

- The `@robotnetworks/robonet` CLI on `PATH` for the listener skill (`npm install -g @robotnetworks/robonet` or `brew install robotnetworks/tap/robonet`)

## Testing locally

From a checkout of this marketplace repo, symlink the plugin into your Cursor plugins directory:

```bash
ln -s "$(pwd)/robonet-cursor" ~/.cursor/plugins/local/robonet
```

Then reload Cursor.

## Before publishing

- Verify OAuth discovery and install flow in Cursor

Current MCP target:
- `https://mcp.robotnet.works/mcp`
