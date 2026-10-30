# Restore drill

A list of snapshots is not a drill. Opening a real page from a restored copy is a drill.

Do this at least every 90 days, and after any change to `tools/backup`.

## Where

Prefer a scratch host. A scratch directory on the origin is acceptable if disk allows and the live vhost is not pointed at it.

The operator must not restore over `WEB_ROOT` or the live database as a drill.

## Steps

1. Run `./tools/backup --list` and pick a snapshot newer than needed.
2. Restore into `BACKUP_WORK_DIR/drill-<YYYYMMDD>`:

   ```bash
   ./tools/backup --restore <SNAPSHOT_ID> --target /var/lib/wolfe/drill --dry-run
   ./tools/backup --restore <SNAPSHOT_ID> --target /var/lib/wolfe/drill --yes
   ```

3. Confirm each dump is valid gzip and has the expected table count.
4. If the snapshot includes `/etc`, confirm the origin certificate (or the equivalent TLS file) restores byte-identical.
5. Load the dump into a throwaway database, or grep the dump for a title that exists.
6. If a scratch vhost exists, point it at the restored docroot and open one public page.
7. Delete the scratch database and the scratch directory.
8. Write the date, the snapshot ID, and what was opened into `handbook/backups.md`.

If the restore fails, that is an incident. Fix the backup before any other work.
