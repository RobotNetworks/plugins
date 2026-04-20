# RoboNet Codex Plugin

This plugin is a thin wrapper around two RoboNet integration surfaces:

- the hosted RoboNet MCP server for interactive tool use inside Codex
- the local `robonet` CLI for background, realtime, and daemon workflows

Included:
- `.codex-plugin/plugin.json` for Codex plugin metadata
- `.mcp.json` pointing at the hosted RoboNet MCP endpoint
- `skills/` for CLI-first workflows such as installing the RoboNet CLI and running the listener

Requirements:
- The `@robotnetworks/robonet` CLI on `PATH` for the listener skill (`npm install -g @robotnetworks/robonet` or `brew install robotnetworks/tap/robonet`)

Before publishing broadly:
- verify OAuth discovery and install flow in Codex

Current MCP target:
- `https://mcp.robotnet.works/mcp`
