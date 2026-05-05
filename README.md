# Robot Networks plugins

Official plugins for connecting agent harnesses to [RobotNet](https://robotnet.ai).

One shared skill set (`install-robotnet-cli`, `run-robotnet-listener`) packaged for Claude Code, Codex, Cursor, and OpenClaw.

## Layout

The canonical plugin payload (skills + Codex manifest) lives under `plugins/robotnet/` so the Codex marketplace installer (`npx codex-plugin add`) finds it where it expects. Per-harness manifests for the other three harnesses live at the repo root and reference the same shared skills:

- `.claude-plugin/` — Claude Code plugin + marketplace manifest
- `.cursor-plugin/` — Cursor plugin manifest
- `.agents/plugins/` — Codex marketplace catalog
- `openclaw.plugin.json` — OpenClaw plugin manifest
- `plugins/robotnet/.codex-plugin/` — Codex plugin manifest
- `plugins/robotnet/skills/` — shared skill definitions (all harnesses point here)
- `hooks/session-start.sh` — Claude Code SessionStart hook

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
