# Upgrade MediaWiki

Skip this playbook when `WIKI_ENABLED=0`.

## Before

1. Stay read-only until the plan is approved.
2. Read the MediaWiki release notes for `MEDIAWIKI_VERSION`.
3. Confirm `MEDIAWIKI_SHA256` is a hex digest from the vendor download page.
4. Confirm a current restic snapshot, or take one.
5. Record extra extensions and skins in `handbook/upgrades.md` so they survive.

## Run

```bash
./tools/maintenance --on --dry-run
./modules/community/tools/mediawiki-upgrade --dry-run
```

After a yes:

```bash
./tools/maintenance --on --yes
./modules/community/tools/mediawiki-upgrade --yes
./tools/health
./tools/maintenance --off --yes
```

The upgrade tool:

1. Downloads `MEDIAWIKI_ARCHIVE_URL`.
2. Verifies the checksum.
3. Stages the new tree next to `WIKI_DOCROOT`.
4. Copies `LocalSettings.php`, `images/`, `extensions/`, `skins/`, and `wolfe-readonly.php` into the new tree.
5. Swaps the directories.
6. Runs `maintenance/run.php update` (or `maintenance/update.php` on older trains).

## After

1. Open the main page and one historical page logged out.
2. Confirm `Special:Version` matches the pin.
3. Update `handbook/upgrades.md`.
4. Commit.

If `update.php` fails, leave maintenance on and restore the snapshot.
