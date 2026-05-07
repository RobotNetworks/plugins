# Contributing

Thanks for helping improve the RobotNet plugins. This repo ships the same RobotNet integration to four agent harnesses — Claude Code, Codex, Cursor, and OpenClaw — from a single shared source tree.

## Repository layout

One repo, one canonical plugin payload under `plugins/robotnet/`, four per-harness manifests at the top level:

```
plugins/                                  # repo root
├── .claude-plugin/{plugin.json, marketplace.json}
├── .cursor-plugin/plugin.json
├── .agents/plugins/marketplace.json      # Codex marketplace catalog
├── openclaw.plugin.json
├── plugins/robotnet/                     # canonical plugin payload
│   ├── .codex-plugin/plugin.json         # Codex manifest (lives inside the payload so codex-plugin's installer finds it)
│   └── skills/                           # shared skills (consumed by all four harnesses)
│       ├── install-robotnet-cli/SKILL.md
│       └── run-robotnet-listener/SKILL.md
├── hooks/session-start.sh                # Claude Code SessionStart hook
├── assets/logo.svg
└── README.md
```

The Codex marketplace installer (`npx codex-plugin add …`) hard-codes
`<repo>/plugins/<plugin-name>/` as the source path it copies into
`~/.codex/plugins/<plugin-name>/`, so the Codex manifest must live
inside `plugins/robotnet/.codex-plugin/`. The other three harnesses
read manifests from the repo root and follow the manifest's
`"skills"` field into `./plugins/robotnet/skills/`. The skills are
single-source-of-truth — any change lands in all four plugins at
once with no copy step.

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

Skills live at `plugins/robotnet/skills/<name>/SKILL.md`. Each skill is a directory containing:

- `SKILL.md` with YAML frontmatter (`name`, `description`, `allowed-tools`)
- Optional `references/` subdirectory for long-form reference material
- Optional `scripts/` subdirectory for supporting scripts

Because `plugins/robotnet/skills/` is shared, changes propagate to all four harnesses. If behavior should differ per harness, gate it inside the skill body (e.g. "In the Claude Code plugin, …").

## Editing manifests

Each harness has its own manifest. Keep metadata (name, description, version, keywords) consistent across all four when possible. If you add a new top-level file, confirm:

- The three root manifests (`.claude-plugin/plugin.json`, `.cursor-plugin/plugin.json`, `openclaw.plugin.json`) still reference `./plugins/robotnet/skills/`.
- The Codex manifest (`plugins/robotnet/.codex-plugin/plugin.json`) references `./skills/` — relative to its own directory, which is the payload root after `npx codex-plugin add` installs it.
- The new file is reachable from whatever manifest needs it via a relative path starting with `./`.
- No manifest path traverses outside the repo root (`../` is not supported by any harness).

## Testing locally

### Claude Code

Register the local checkout as a marketplace, then install from it:

```bash
claude plugin marketplace add ./
claude plugin install robotnet@robotnetworks
```

Skills appear as `/robotnet:install-robotnet-cli` and `/robotnet:run-robotnet-listener`. After editing manifests, reload with `claude plugin marketplace update robotnetworks`.

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
