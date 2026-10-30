# Backup

The operator must take a snapshot before every upgrade, before every restore-over-live, and whenever the daily job failed. Restore-over-live is rare.

```bash
./tools/backup --dry-run
./tools/backup --yes
./tools/backup --list
```

The tool:

1. Resolves restic and S3 credentials from the environment or the vault CLI. It must not read them from git.
2. Dumps the primary database, and each extra database in `EXTRA_DBS`, gzipped, into `BACKUP_WORK_DIR`.
3. Writes a rebuild manifest (packages, public SSH keys).
4. Runs `restic backup` on the work directory, `WEB_ROOT`, `BACKUP_PATHS`, and `/etc` when `BACKUP_INCLUDE_ETC=1`. Honors `BACKUP_EXCLUDES`.
5. Forgets snapshots per the policy in `handbook/backups.md`, then runs `restic check --read-data-subset=5%`. A failed check must fail the job.
6. Writes `${STATE_DIR}/backup-status`. If `HEALTHCHECK_URL` is set, pings the dead-man switch. Failure writes `FAIL` and pings `${HEALTHCHECK_URL}/fail`.
7. Prints the new snapshot ID.

Editing the script in git does not change what the timer runs. The operator must install the deployed copy. The operator must diff the two before a claim that backup is fixed.

The operator must write that snapshot ID into the change about to be made, or into `handbook/backups.md` if this was the scheduled job.

A dump that is not in restic is not the backup.
