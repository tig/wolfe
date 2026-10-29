# Backups

If you cannot restore, you do not have a backup. You have a compacting job.

restic writes to S3-compatible storage (`RESTIC_REPOSITORY`). The password and the S3 keys live in `<VAULT_NAME>`, as the item names in `site/site.env`.

## What a snapshot contains

1. A logical dump of the primary database, if `DB_NAME` is set (streamed, gzipped).
2. A logical dump of each extra database in `EXTRA_DBS`.
3. `WEB_ROOT` and every path in `BACKUP_PATHS`.
4. `/etc` when `BACKUP_INCLUDE_ETC=1`. It is small and encrypted. Config drift that never made it into git still survives a rebuild.
5. A rebuild manifest (manually installed packages, dpkg selections, web-server modules, public SSH keys). Public keys only.
6. The live `site/site.env` and `site/pins.env` copies from the origin (still no secrets; those stay in the vault).

Exclude application caches, `.git`, and any FUSE or object-storage mount that holds bulk media. Those mounts are a different backup problem. Following a photo symlink into object storage will make the snapshot huge and slow.

`tools/backup` builds a work directory, dumps, and runs `restic backup`. It does not invent a second format.

The restic password and the object-store keys must exist in the community vault, not only on the origin. A backup whose password dies with the VM is not a backup.

## Rhythm

- Automatic: at least daily, from a systemd timer on the origin. Editing the repo copy of the script does nothing until you install it.
- Oldest snapshot we will still call "current" during a weekday glance: `RESTIC_MAX_AGE_HOURS` (36 hours in the example contract).
- Forget policy (example): `--keep-daily 7 --keep-weekly 4 --keep-monthly 6 --keep-yearly 2`. Adjust here if you change it, and change the restic `forget` flags in the same pull request.
- After backup: `restic check --read-data-subset=5%`.

## Dead-man switch

A timer that fails quietly is how backups die.

`tools/backup` writes `${STATE_DIR}/backup-status` (`OK` or `FAIL`, plus a UTC stamp). If `HEALTHCHECK_URL` is set in the environment (from the vault, never from git), it pings that URL on success and `${HEALTHCHECK_URL}/fail` on failure.

The weekday glance reads the status file. The twice-weekly vulnerability watch does not. Missed backups are a health finding, not a CVE.

## Object storage and FUSE

If media lives on an S3-compatible bucket mounted with rclone or similar:

1. Pin the vendor build. Distro packages have shipped versions that cannot write to some providers (uploads sit in a VFS cache, look fine, and retry forever).
2. Hold that package so unattended-upgrades cannot silently replace it.
3. Put the VFS cache on a real disk path, not `/tmp`.
4. Do not `stat()` a huge flat directory on that mount from the request path. That is how a topic page becomes a twenty-second FUSE walk.
5. Watch Class A operation counts. A retry loop can turn a few thousand writes into millions.

Record the mount unit and the hold on this page if you use one.

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
