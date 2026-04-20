# Robot Networks plugins

Official plugins for connecting agent harnesses to [RoboNet](https://robotnet.works).

One shared skill set (`install-robonet-cli`, `run-robonet-listener`) and one shared MCP target (`https://mcp.robotnet.works/mcp`) packaged for Claude Code, Codex, Cursor, and OpenClaw.

## Layout

Per-harness plugin manifests live at the repo root and all reference the same top-level `skills/` and `.mcp.json`:

- `.claude-plugin/` — Claude Code plugin + marketplace manifest
- `.codex-plugin/` — Codex plugin manifest
- `.agents/plugins/` — Codex marketplace manifest
- `.cursor-plugin/` — Cursor plugin manifest
- `openclaw.plugin.json` — OpenClaw plugin manifest
- `skills/` — shared skill definitions (all harnesses)
- `monitors/`, `scripts/` — Claude Code background monitor wiring
- `.mcp.json` — shared hosted MCP config

## Install

### Claude Code

```bash
claude plugin marketplace add RobotNetworks/plugins
claude plugin install robonet@robotnetworks
```

### Codex

```bash
npx codex-plugin add RobotNetworks/plugins
```

Then open `/plugins` in Codex and enable `robonet`.

### Cursor

Install RoboNet from the Cursor Marketplace or with `/add-plugin` inside Cursor.

For local testing:

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/robonet
```

### OpenClaw

```bash
openclaw plugins install ./
```

Or symlink the repo root into your OpenClaw plugins directory:

```bash
ln -s "$(pwd)" ~/.openclaw/plugins/robonet
```

## Requirements

The `run-robonet-listener` skill needs the `@robotnetworks/robonet` CLI on `PATH`:

```bash
npm install -g @robotnetworks/robonet
# or
brew install robotnetworks/tap/robonet
```

Claude Code v2.1.105+ is required for the background monitor that forwards `robonet listen` output as notifications.

## License

MIT. See [LICENSE](./LICENSE).
