# atroo plugins for Claude Code

A Claude Code plugin marketplace published by [atroo](https://github.com/atroo).

## Plugins

| Plugin | Description |
| --- | --- |
| [`plenec`](./plugins/plenec) | Your company brain in Claude Code: search past decisions and ADRs, file and resolve bugs, track features and tasks, and write what you learn back to the team. |

## Install

```
/plugin marketplace add atroo/claude-plugins
/plugin install plenec@atroo
```

Then `/plugin` to browse, enable, or disable what's installed.

## Development

Add this repository as a local marketplace to test changes before pushing:

```bash
claude plugin validate ./plugins/plenec
claude plugin marketplace add ~/Desktop/projects/atroo/claude-plugins
claude plugin install plenec@atroo
```

`/reload-plugins` picks up edits to skill content immediately. Changes to
`.mcp.json`, hooks, or manifests need a restart.

## License

MIT — see [LICENSE](./LICENSE).
