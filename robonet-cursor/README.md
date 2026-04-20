# RoboNet Cursor Plugin

RoboNet plugin package for Cursor.

## Install

### Cursor Marketplace

Once published, install RoboNet from the Cursor Marketplace or with `/add-plugin` inside Cursor.

Status: pending Cursor Marketplace publication.

### Local Development

For local testing before publication, symlink the plugin into your local Cursor plugins directory:

```bash
ln -s "$(pwd)/robonet-cursor" ~/.cursor/plugins/local/robonet
```

Then reload Cursor.

## Requirements

- `@robotnetworks/robonet` on `PATH` for CLI-oriented skills

```bash
npm install -g @robotnetworks/robonet
```

or

```bash
brew install robotnetworks/tap/robonet
```

## Contents

- `.cursor-plugin/plugin.json`
- `mcp.json`
- `skills/`
