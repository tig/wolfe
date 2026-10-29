# Community overlay

Read this after the core handbook pages when `MODULES` lists `community`.

## Architecture

Two public names, one origin: `forums.example.org` for phpBB, `wiki.example.org` for MediaWiki when `WIKI_ENABLED=1`. Both orange-clouded.

## Security

`INSTALLER_PATHS` is `install/` and `mw-config/`. After a phpBB upgrade, `install/` must be gone. After MediaWiki is installed, `mw-config/` must not return 200.

## Upgrades

Preserve phpBB's `config.php`, `files/`, `images/`, `store/`, and `ext/`. Preserve MediaWiki's `LocalSettings.php`, `images/`, extensions, and skins.

## Continuity

The vault also holds the phpBB founder account and, if the wiki is on, the MediaWiki bureaucrat account. Still as item names, never as values.
