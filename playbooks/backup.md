# Backup

Take a snapshot before every upgrade, before every restore-over-live (which you will almost never do), and whenever the daily job failed.

```bash
./tools/backup --dry-run
./tools/backup --yes
./tools/backup --list
```

The tool:

1. Resolves restic and S3 credentials from the environment or the vault CLI. It never reads them from git.
2. Dumps the primary database, and each extra database in `EXTRA_DBS`, gzipped, into `BACKUP_WORK_DIR`.
3. Writes a rebuild manifest (packages, public SSH keys).
4. Runs `restic backup` on the work directory, `WEB_ROOT`, `BACKUP_PATHS`, and `/etc` when `BACKUP_INCLUDE_ETC=1`. Honors `BACKUP_EXCLUDES`.
5. Forgets snapshots per the policy in `handbook/backups.md`, then `restic check --read-data-subset=5%`. A failed check fails the job.
6. Writes `${STATE_DIR}/backup-status` and, if `HEALTHCHECK_URL` is set, pings the dead-man switch. Failure writes `FAIL` and pings `${HEALTHCHECK_URL}/fail`.
7. Prints the new snapshot ID.

Editing the script in git does not change what the timer runs. Install the deployed copy, or the change is silently inert. Diff the two before you trust a "we fixed backup."

Write that snapshot ID into the change you are about to make, or into `handbook/backups.md` if this was the scheduled job.

A dump that is not in restic is not the backup. It is a file you will delete by accident.
