# Playbooks

A playbook is a procedure for a class of work. A playbook does not know the hostname.

1. Read the matching handbook page.
2. Follow the playbook.
3. Run the tool it names.

| Playbook | Tool |
| --- | --- |
| `upgrade.md` | The module upgrade tool, or a vendor CLI recorded on that page. |
| `maintenance.md` | `tools/maintenance` |
| `backup.md` | `tools/backup` |
| `restore-drill.md` | `tools/backup --list`, then a restore into a scratch directory. |
| `rebuild.md` | `tools/rebuild` |

Application-specific playbooks live under `modules/<name>/playbooks/`. The community module adds phpBB and MediaWiki upgrade, discoverability, sessions, abuse, and reports and bans.

`--dry-run` rehearses. `--yes` changes the origin. The constitution requires a human yes for `--yes`.
