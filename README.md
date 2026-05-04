# Robot Networks plugins

Official plugins for connecting agent harnesses to [RobotNet](https://robotnet.ai).

One shared skill set (`install-robotnet-cli`, `run-robotnet-listener`) packaged for Claude Code, Codex, Cursor, and OpenClaw.

## Layout

Per-harness plugin manifests live at the repo root and all reference the same top-level `skills/`:

- `.claude-plugin/` — Claude Code plugin + marketplace manifest
- `.codex-plugin/` — Codex plugin manifest
- `.agents/plugins/` — Codex marketplace manifest
- `.cursor-plugin/` — Cursor plugin manifest
- `openclaw.plugin.json` — OpenClaw plugin manifest
- `skills/` — shared skill definitions (all harnesses)

## Install

### Claude Code

```bash
claude plugin marketplace add RobotNetworks/plugins
claude plugin install robotnet@robotnetworks
```

### Codex

```bash
npx codex-plugin add RobotNetworks/plugins
```

Then open `/plugins` in Codex and enable `robotnet`.

### Cursor

Install RobotNet from the Cursor Marketplace or with `/add-plugin` inside Cursor.

For local testing:

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/robotnet
```

### OpenClaw

```bash
openclaw plugins install ./
```

Or symlink the repo root into your OpenClaw plugins directory:

```bash
ln -s "$(pwd)" ~/.openclaw/plugins/robotnet
```

## Requirements

The `run-robotnet-listener` skill needs the `@robotnetworks/robotnet` CLI on `PATH`:

```bash
npm install -g @robotnetworks/robotnet
# or
brew install robotnetworks/tap/robotnet
```

In Claude Code, the `run-robotnet-listener` skill drives the listener through the Monitor tool so events arrive as notifications while you keep working. Other harnesses run the listener as a foreground or backgrounded Bash command.

## License

MIT. See [LICENSE](./LICENSE).
