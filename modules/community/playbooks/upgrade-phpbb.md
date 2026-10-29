# Upgrade phpBB

Use this when `MODULES` lists `community` and a human asked for a phpBB upgrade, or when a security release makes waiting the larger risk.

## Before

1. Stay read-only until the plan is approved.
2. Read the vendor notes for the exact version in `modules/community/pins.env` (or the bound copy).
3. Confirm `PHPBB_SHA256` is a real hex digest copied from the vendor download page, not a placeholder.
4. Confirm a restic snapshot newer than `RESTIC_MAX_AGE_HOURS`, or take one.
5. Name the rollback: restore that snapshot, keep the old `FORUM_DOCROOT` aside until you say the board is good.

## Run

```bash
./tools/maintenance --on --dry-run
./modules/community/tools/phpbb-upgrade --dry-run
```

Show the dry run to the human. After a yes:

```bash
./tools/maintenance --on --yes
./modules/community/tools/phpbb-upgrade --yes
./tools/health
./tools/maintenance --off --yes
```

The upgrade tool:

1. Downloads `PHPBB_ARCHIVE_URL`.
2. Verifies `sha256sum` against `PHPBB_SHA256`.
3. Refuses to continue on a mismatch.
4. Extracts over the board while keeping `config.php`, `files/`, `images/`, `store/`, and `ext/`.
5. Runs the phpBB CLI updater (`bin/phpbbcli.php db:migrate`).
6. Removes `install/` from the docroot.

## After

1. Open a logged-out forum index and one topic.
2. Open ACP and confirm the version matches the pin.
3. Update `handbook/upgrades.md` with the live version.
4. Commit the pin and the handbook change on the same branch.

If the CLI updater fails, leave maintenance on, restore the snapshot, and write an incident.
