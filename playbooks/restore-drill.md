# Restore drill

A list of snapshots is not a drill. Opening a real page from a restored copy is a drill.

Do this on a schedule you will keep (every 90 days is a minimum), and after any change to `tools/backup`.

## Where

Prefer a scratch host. A scratch directory on the origin is acceptable if disk allows and you do not point the live vhost at it.

Never restore over `WEB_ROOT` or the live database as a drill.

## Steps

1. `./tools/backup --list` and pick a snapshot newer than you think you need.
2. Restore into `BACKUP_WORK_DIR/drill-<YYYYMMDD>`:

   ```bash
   ./tools/backup --restore <SNAPSHOT_ID> --target /var/lib/wolfe/drill --dry-run
   ./tools/backup --restore <SNAPSHOT_ID> --target /var/lib/wolfe/drill --yes
   ```

3. Load the dump into a throwaway database, or grep the dump for a title you know exists.
4. If you have a scratch vhost, point it at the restored docroot and open one public page.
5. Delete the scratch database and the scratch directory.
6. Write the date, the snapshot ID, and what you opened into `handbook/backups.md`.

If the restore fails, that is an incident. Fix the backup before you do anything else.
