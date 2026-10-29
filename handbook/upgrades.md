# Upgrades

Versions move on purpose, with a pin and a checksum, or they do not move.

Runtime pins live in `site/pins.env`. Application pins live in the module that owns the application. Playbooks refuse to run an upgrade if a checksum is still a placeholder.

## Rules

1. Read the vendor's upgrade notes for the exact version you are moving to.
2. Copy the SHA-256 from the vendor's own download page into the pin file in a pull request *before* you run the tool.
3. Take a restic snapshot that you have seen listed.
4. Put the site in maintenance (`tools/maintenance --on --yes`).
5. Run the upgrade tool. It verifies the checksum, replaces code, preserves instance data, and runs the vendor updater.
6. Hit the health URLs.
7. Take the site out of maintenance.
8. Delete installer paths.
9. Update this page with the version that is now live.

## What we preserve

Record the files and directories an upgrade must not overwrite. The community module preserves phpBB's `config.php`, `files/`, `images/`, `store/`, and `ext/`, and MediaWiki's `LocalSettings.php`, `images/`, extensions, and skins.

- Keep on this host: `<LIST>`.

## Current pins (filled from the live host)

- OS live: `<OS_PRETTY>`.
- Runtime live: `<LIVE_RUNTIME_VERSION>`.
- Application live: `<LIVE_APP_VERSION_OR_MODULE>`.

The live numbers and the pins must match after a successful upgrade. If they do not, the upgrade is not done.
