# Community overlay

Read this after the core handbook pages when `MODULES` lists `community`.

## Architecture

Two public names, one origin: `forums.example.org` for phpBB, `wiki.example.org` for MediaWiki when `WIKI_ENABLED=1`. Both orange-clouded.

The wiki should authenticate through phpBB when you want one account. Overlay MediaWiki *without* `--delete` so non-bundled extensions (auth plugins) survive.

## Security

`INSTALLER_PATHS` includes `install/`, `install_/`, and `mw-config/`. After an overlay, those paths must 403 even if a vhost says allow all. Use `tools/installer-block`.

phpBB rsync excludes `install/`. Do not copy it onto the origin.

## Sessions

CDN-safe phpBB config lives in `playbooks/sessions-and-cookies.md`. Re-apply after every `db:migrate`.

## Upgrades

Preserve phpBB's `config.php`, `files/`, `images/`, `store/`, `ext/`, and custom styles. Preserve MediaWiki's `LocalSettings.php`, `images/`, extensions, and skins.

Skip a phpBB package the vendor has withdrawn. Hash-pin the first good release.

## Media and mounts

Bulk photos often live on object storage, not in restic. Exclude that mount from `tools/backup`. Do not `stat()` a huge flat directory on the mount from `viewtopic.php`.

If a symlink from `images/` onto the mount disappears, image-rewrite extensions fail closed and old hotlinks come back. Both the symlink and the public base URL must point at the live host, not at a decommissioned bucket.

## Abuse

`playbooks/abuse.md`. Challenge at the edge. fail2ban is not a scrape shield.

## Continuity

The vault also holds the phpBB founder account and, if the wiki is on, the MediaWiki bureaucrat account. Still as item names, never as values.
