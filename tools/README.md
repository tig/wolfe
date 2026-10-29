# Tools

These commands are the hands. They read `site/site.env`. They do not know a hostname of their own.

`--dry-run` is the default. `--yes` is the only way a tool changes the origin.

If a value still looks like `<PLACEHOLDER>`, the tool exits.

| Command | Job |
| --- | --- |
| `health` | Read-only glance: URLs, disk, snapshot age, installer paths. |
| `maintenance` | Write `WEB_ROOT/maintenance.on`, then call `MAINTENANCE_HOOK`. |
| `backup` | Dump, restic backup, list, restore to a target. |
| `rebuild` | Origin rebuild skeleton. Does not call a cloud API. |
| `edge-allowlist` | Cloudflare IP ranges into firewall rules. |
| `installer-block` | Print an Apache or nginx deny for installer paths. |
| `integrity-scan` | Secret and identifier scan. |

Application upgrades and sitemaps live in the module that owns the application.

Secrets come from the environment or a vault CLI on the host. The scripts print the item name they need. They never read a password out of git.
