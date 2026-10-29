# Upgrade

Do this when a human asked for an upgrade, or when a security release makes waiting the larger risk.

The core does not know your application. A module does. If `MODULES` lists `community`, use `modules/community/playbooks/upgrade-phpbb.md` and, when the wiki is on, `upgrade-mediawiki.md`. If `MODULES` is empty, write the vendor steps on this page for *this* host, then run them with a pin and a checksum.

## Before

1. Stay read-only until the plan is approved.
2. Read the vendor notes for the exact version in the pin file.
3. Confirm the SHA-256 is a real hex digest copied from the vendor download page, not a placeholder. Do not pin a release the vendor has withdrawn.
4. Confirm a restic snapshot newer than `RESTIC_MAX_AGE_HOURS`, or take one (`playbooks/backup.md`). Keep a local tarball of the trees you will overlay.
5. Name the rollback: restore that snapshot or the tarball, keep the old `WEB_ROOT` aside until you say the site is good.

## Run

```bash
./tools/maintenance --on --dry-run
# then the module or vendor upgrade tool --dry-run
```

Show the dry run to the human. After a yes:

```bash
./tools/maintenance --on --yes
# upgrade tool --yes
./tools/health
./tools/maintenance --off --yes
```

## After

1. Open one public page logged out.
2. Confirm the live version matches the pin.
3. Update `handbook/upgrades.md`.
4. Commit the pin and the handbook change on the same branch.

If the updater fails, leave maintenance on, restore the snapshot, and write an incident.
