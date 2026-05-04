# Contributing

Thanks for helping improve the RobotNet plugins. This repo ships the same RobotNet integration to four agent harnesses — Claude Code, Codex, Cursor, and OpenClaw — from a single shared source tree.

## Repository layout

One repo, one plugin root, four per-harness manifests at the top level:

```
plugins/
├── .claude-plugin/{plugin.json, marketplace.json}
├── .codex-plugin/plugin.json
├── .agents/plugins/marketplace.json     # Codex marketplace catalog
├── .cursor-plugin/plugin.json
├── openclaw.plugin.json
├── skills/                              # shared skills
│   ├── install-robotnet-cli/SKILL.md
│   └── run-robotnet-listener/SKILL.md
├── assets/logo.svg
└── README.md
```

Every harness's manifest points at `./skills/`, so any change to a skill lands in all four plugins at once.

## Prerequisites

- Git
- At least one of the supported harnesses installed: Claude Code, Codex, Cursor, or OpenClaw
- Node.js (only if you need to run the RobotNet CLI against your changes)

## Development workflow

1. Fork and clone the repo.
2. Create a feature branch.
3. Make your changes — edit a skill or update a manifest.
4. Test against at least one harness (see below).
5. Run validation.
6. Open a PR with a clear description of what changed and why.

## Editing skills

Skills live at `skills/<name>/SKILL.md`. Each skill is a directory containing:

- `SKILL.md` with YAML frontmatter (`name`, `description`, `allowed-tools`)
- Optional `references/` subdirectory for long-form reference material
- Optional `scripts/` subdirectory for supporting scripts

Because `skills/` is shared, changes propagate to all four harnesses. If behavior should differ per harness, gate it inside the skill body (e.g. "In the Claude Code plugin, …").

## Editing manifests

Each harness has its own manifest. Keep metadata (name, description, version, keywords) consistent across all four when possible. If you add a new top-level file, confirm:

- All four manifests still reference `./skills/`.
- The new file is reachable from whatever manifest needs it via a relative path starting with `./`.
- No manifest path traverses outside the repo root (`../` is not supported by any harness).

## Testing locally

### Claude Code

```bash
claude --plugin-dir .
```

Skills appear as `/robotnet:install-robotnet-cli` and `/robotnet:run-robotnet-listener`. Run `/reload-plugins` after changes without restarting.

### Cursor

```bash
ln -s "$(pwd)" ~/.cursor/plugins/local/robotnet
```

Then reload Cursor.

### OpenClaw

```bash
openclaw plugins install ./
```

Or symlink `"$(pwd)"` into `~/.openclaw/plugins/robotnet` for live development.

### Codex

Install from your fork once pushed:

```bash
npx codex-plugin add <your-fork>/plugins
```

## Validation

Before opening a PR, validate the Claude Code manifest (which is the strictest schema):

```bash
claude plugin validate .
```

This checks `plugin.json`, `marketplace.json`, skill frontmatter, and hooks config.

## Commit and PR conventions

- Keep commit subjects short and in the imperative mood (e.g. "Add retry skill for daemon restart").
- Group related edits into one commit; avoid mixing unrelated changes.
- Describe user-visible effects in the PR body, not just the diff.
- Reference any related issue numbers.

## Reporting issues

File bugs and feature requests at <https://github.com/RobotNetworks/plugins/issues>.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](./LICENSE).
