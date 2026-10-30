# Community module

This is the first fully worked Wolfe module: a phpBB forum, with an optional MediaWiki wiki, on the same origin.

It is an overlay. The tenets, the handbook shape, backups, the edge allowlist, and continuity stay in Wolfe core.

## What it adds

- Forum and wiki hostnames, docroots, and database pointers.
- Pinned phpBB and MediaWiki upgrades with checksums.
- Forum and wiki maintenance through the core `MAINTENANCE_HOOK`.
- Public sitemaps and `robots.txt`.
- Example prompts a forum admin actually says.
- Reports and bans: investigate read-only, guard established members, ban through the forum's own MCP path.
- Session, cookie, scrape-flood, and object-storage lessons that a generic VPS does not need.

## Bind it

Keep `MODULES='community'` in `site/site.env`. Copy keys from `site.env.example` in this directory into the bound contract. A bound `site/site.env` wins. The example only fills keys you left empty.

Set `WIKI_ENABLED=0` if you do not run a wiki.

Set `MAINTENANCE_HOOK` to `modules/community/tools/maintenance` (absolute path on the host) so `tools/maintenance` flips phpBB and the wiki lock.

## Tools

| Command | Job |
| --- | --- |
| `tools/phpbb-upgrade` | Pinned phpBB upgrade. |
| `tools/mediawiki-upgrade` | Pinned MediaWiki upgrade. Skips if the wiki is off. |
| `tools/maintenance` | phpBB `board_disable` and a wiki lock file. |
| `tools/sitemap-phpbb` | Public-topic sitemap. Topics use the same GUESTS and BOTS `f_read` filter as forums. |
| `tools/sitemap-mediawiki` | Public-page sitemap. |
| `tools/robots` | `robots.txt` into each enabled docroot. |

All of them take `--dry-run` (default) and `--yes`.
