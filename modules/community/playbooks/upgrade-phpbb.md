# Upgrade phpBB

Use this when `MODULES` lists `community` and a human asked for a phpBB upgrade, or when a security release makes waiting the larger risk.

## Before

1. Stay read-only until the plan is approved.
2. Read the vendor notes for the exact version in `modules/community/pins.env` (or the bound copy).
3. Confirm `PHPBB_SHA256` is a hex digest copied from the vendor download page. The digest must not be a placeholder.
4. Confirm a restic snapshot newer than `RESTIC_MAX_AGE_HOURS`, or take one.
5. Name the rollback: restore that snapshot. Keep the old `FORUM_DOCROOT` aside until the custodian says the board is good.

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
7. Does not overlay `ext/` or custom styles.

`db:migrate` can clobber CDN-safe session settings. Re-apply the list in `sessions-and-cookies.md` after every migrate.

Confirm installer paths return 403:

```bash
./tools/installer-block
curl -sk -o /dev/null -w '%{http_code}\n' -H 'Host: forums.example.org' https://127.0.0.1/install/
```

Some phpBB trains add an "AI Crawlers" group and hide the board from those bots. If the edge is set to allow well-behaved assistant crawlers, give that group the same forum view rights as Bots.

## After

1. Open a logged-out forum index and one topic.
2. Log in. If the form is invalid, read `sessions-and-cookies.md`.
3. Post a test message. Upload one file if the board accepts uploads.
4. Open ACP and confirm the version matches the pin.
5. Update `handbook/upgrades.md` with the live version.
6. Commit the pin and the handbook change on the same branch.

If the CLI updater fails, leave maintenance on, restore the snapshot, and write an incident.
