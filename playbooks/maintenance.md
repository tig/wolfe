# Maintenance mode

Maintenance is how you stop writers without lying to readers about a silent failure.

`tools/maintenance` writes or removes `WEB_ROOT/maintenance.on`. If `MAINTENANCE_HOOK` is set and executable, the tool calls it with `--on` or `--off`.

The community module sets that hook so phpBB's `board_disable` flips, and so a wiki lock file is written.

If you have no hook, put a web-server rule in front of `WEB_ROOT` that serves a static 503 when `maintenance.on` exists, and record that rule here.

## Use

```bash
./tools/maintenance --on --dry-run
./tools/maintenance --on --yes
./tools/maintenance --status
./tools/maintenance --off --yes
```

Do not leave maintenance on overnight unless the incident log says why.
