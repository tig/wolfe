# Community maintenance

Core `tools/maintenance` writes `WEB_ROOT/maintenance.on`. This module's hook flips the applications.

## Forum

phpBB's board-disable flag is the switch. The hook sets it through `bin/phpbbcli.php config:set board_disable 1` (and back to `0`).

When the CLI is not available, the hook prints the SQL to run on `FORUM_TABLE_PREFIX + config` for `board_disable`. Prefer the CLI.

## Wiki

When `WIKI_ENABLED=1`, the hook writes `WIKI_DOCROOT/maintenance.lock`. If `LocalSettings.php` requires `wolfe-readonly.php`, MediaWiki becomes read-only. The snippet ships in `modules/community/snippets/wolfe-readonly.php`.

## Use

Set `MAINTENANCE_HOOK` to this module's `tools/maintenance`, then:

```bash
./tools/maintenance --on --yes
```

Or call the hook directly:

```bash
./modules/community/tools/maintenance --on --dry-run
```
