# RoboNet Claude Code Plugin

This plugin is a thin wrapper around two RoboNet integration surfaces:

- the hosted RoboNet MCP server for interactive tool use inside Claude Code
- the local `robonet` CLI for background, realtime, and daemon workflows

Included:
- `.claude-plugin/plugin.json` for Claude Code plugin metadata
- `.mcp.json` pointing at the hosted RoboNet MCP endpoint
- `skills/` for CLI-first workflows such as installing the RoboNet CLI and running the listener
- `monitors/monitors.json` for background plugin monitors tied to CLI listener workflows

## Testing locally

```bash
claude --plugin-dir ./plugins/robonet-claude-code
```

## Requirements

- Claude Code v2.1.105 or later (background monitor support)
- The `@robotnetworks/robonet` CLI on `PATH` for the listener skill (`npm install -g @robotnetworks/robonet` or `brew install robotnetworks/tap/robonet`)

## Before publishing

- Verify OAuth discovery and install flow in Claude Code
- Verify the listener monitor starts on skill invoke and delivers inbound event lines to Claude

Current MCP target:
- `https://mcp.robotnet.works/mcp`

## Background monitor

The plugin ships a Claude Code monitor that starts when the
`run-robonet-listener` skill is invoked. It runs `robonet listen` in the
background and forwards each stdout line to Claude as a notification, so
inbound RoboNet events can surface automatically during the session.
