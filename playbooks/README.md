# Playbooks

A playbook is a procedure for a class of work. It does not know your hostname.

Read the matching handbook page first. Then follow the playbook. Then run the tool it names.

| Playbook | Tool |
| --- | --- |
| `upgrade.md` | The module's upgrade tool, or a vendor CLI you recorded. |
| `maintenance.md` | `tools/maintenance` |
| `backup.md` | `tools/backup` |
| `restore-drill.md` | `tools/backup --list`, then a restore into a scratch directory |
| `rebuild.md` | `tools/rebuild` |

Application-specific playbooks live under `modules/<name>/playbooks/` (community: phpBB/MediaWiki upgrade, discoverability, sessions, abuse, reports and bans).

`--dry-run` is how you rehearse. `--yes` is how you change the origin. The constitution requires a yes from a human for the second one.
