# Backups

If you cannot restore, you do not have a backup. You have a compacting job.

restic writes to S3-compatible storage (`RESTIC_REPOSITORY`). The password and the S3 keys live in `<VAULT_NAME>`, as the item names in `site/site.env`.

## What a snapshot contains

1. A logical dump of the primary database, if `DB_NAME` is set.
2. A logical dump of each extra database in `EXTRA_DBS`.
3. `WEB_ROOT` and every path in `BACKUP_PATHS`.
4. The live `site/site.env` and `site/pins.env` copies from the origin (still no secrets; those stay in the vault).

`tools/backup` builds a work directory, dumps, and runs `restic backup`. It does not invent a second format.

## Rhythm

- Automatic: at least daily.
- Oldest snapshot we will still call "current" during a weekday glance: `RESTIC_MAX_AGE_HOURS` (36 hours in the example contract).
- Forget policy: keep daily snapshots for 14 days, weekly for 8 weeks, monthly for 12 months. Adjust here if you change it, and change the restic `forget` flags in the same pull request.

## Restore drill

`playbooks/restore-drill.md` is mandatory. Run it on a scratch host or a scratch directory on the origin, not over the live docroot.

A drill that only lists snapshots is not a drill. A drill that restores a dump and opens one real page is a drill.

Write the date of the last good drill here:

- Last good drill: `<YYYY-MM-DD>`.
- Snapshot ID: `<RESTIC_SNAPSHOT_ID>`.
- What we opened to verify: `<URL_OR_TITLE>`.

## What the agent may not do without a yes

1. `restic forget` with `--prune` beyond the policy above.
2. Restore over the live docroot or the live database.
3. Change `RESTIC_REPOSITORY`.
