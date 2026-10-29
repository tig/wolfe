# Backup

Take a snapshot before every upgrade, before every restore-over-live (which you will almost never do), and whenever the daily job failed.

```bash
./tools/backup --dry-run
./tools/backup --yes
./tools/backup --list
```

The tool:

1. Resolves restic and S3 credentials from the environment or the vault CLI. It never reads them from git.
2. Dumps the primary database, and each extra database in `EXTRA_DBS`, into `BACKUP_WORK_DIR`.
3. Runs `restic backup` on the work directory, `WEB_ROOT`, and `BACKUP_PATHS`.
4. Prints the new snapshot ID.

Write that snapshot ID into the change you are about to make, or into `handbook/backups.md` if this was the scheduled job.

A dump that is not in restic is not the backup. It is a file you will delete by accident.
