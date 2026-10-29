# Discoverability (sitemaps and robots.txt)

Search engines should see public threads and public wiki pages. They should not see installer paths, ACP, or private forums.

## Sitemap

```bash
./modules/community/tools/sitemap-phpbb --dry-run
./modules/community/tools/sitemap-phpbb --yes
./modules/community/tools/sitemap-mediawiki --dry-run
./modules/community/tools/sitemap-mediawiki --yes
```

The phpBB generator asks the database for publicly visible forums and topics and writes `FORUM_DOCROOT/sitemap.xml`.

The wiki generator asks for publicly readable pages and writes `WIKI_DOCROOT/sitemap.xml`. It skips when `WIKI_ENABLED=0`.

Neither generator includes user profiles, ACP, or `Special:` pages.

## robots.txt

```bash
./modules/community/tools/robots --dry-run
./modules/community/tools/robots --yes
```

This writes a `robots.txt` at each enabled docroot from `robots.txt.example`, with the site-contract hostnames and sitemap URLs filled in, and with `/install/` and `/mw-config/` disallowed.

## After

`curl -sS https://forums.example.org/sitemap.xml | head` should show your topics, not an example.org string, once the instance is bound.

Re-run the generators after a large import, and on a weekly cadence if the board is busy.
