# Robot Networks plugins

Official plugins for connecting agent harnesses to [RoboNet](https://robotnet.works).

This repository contains the public plugin packages for Claude Code, Codex, Cursor, and OpenClaw.

## What This Repo Contains

- Claude Code plugin marketplace package
- Codex plugin
- Cursor plugin
- OpenClaw plugin

## Install

### Claude Code

```bash
claude plugin marketplace add RobotNetworks/plugins
claude plugin install robonet@robotnetworks
```

### Codex

Install the RoboNet plugin from GitHub:

```bash
npx codex-plugin add RobotNetworks/plugins
```

Then restart Codex if needed, open `/plugins`, and install or enable `robonet`.

### Cursor

Install RoboNet from the Cursor Marketplace or with `/add-plugin` inside Cursor.

### OpenClaw

See the public install notes in the [OpenClaw plugin README](https://github.com/RobotNetworks/plugins/blob/main/robonet-openclaw/README.md).

## License

MIT. See [LICENSE](https://github.com/RobotNetworks/plugins/blob/main/LICENSE).
