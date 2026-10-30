# Discoverability (sitemaps and robots.txt)

Search engines must see public threads and public wiki pages. Search engines must not see installer paths, ACP, or private forums.

## Sitemap

```bash
./modules/community/tools/sitemap-phpbb --dry-run
./modules/community/tools/sitemap-phpbb --yes
./modules/community/tools/sitemap-mediawiki --dry-run
./modules/community/tools/sitemap-mediawiki --yes
```

The phpBB generator includes public `viewforum` and `viewtopic` URLs, plus pagination (`start=N`) when a topic is longer than `PHPBB_POSTS_PER_PAGE`. A forum is public only when it is postable, has no password, and both GUESTS and BOTS have `f_read`. Do not hard-code private forum ids. Shard at 40000 URLs.

The wiki generator includes Main, File, and Category pages that are not redirects. It skips when `WIKI_ENABLED=0`.

Neither generator includes user profiles, ACP, or `Special:` pages. Generate them with a oneshot timer, not on-request PHP.

`robots.txt` must list the sitemap. `robots.txt` must not set `Crawl-delay` under `User-agent: *`.

## robots.txt

```bash
./modules/community/tools/robots --dry-run
./modules/community/tools/robots --yes
```

This writes a `robots.txt` at each enabled docroot from `robots.txt.example`. It fills in the site-contract hostnames and sitemap URLs. It disallows `/install/` and `/mw-config/`.

## After

`curl -sS https://forums.example.org/sitemap.xml | head` must show instance topics, not an example.org string, once the instance is bound.

Re-run the generators after a large import, and on a weekly cadence if the board is busy.
