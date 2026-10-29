# Discoverability (sitemaps and robots.txt)

Search engines should see public threads and public wiki pages. They should not see installer paths, ACP, or private forums.

## Sitemap

```bash
./modules/community/tools/sitemap-phpbb --dry-run
./modules/community/tools/sitemap-phpbb --yes
./modules/community/tools/sitemap-mediawiki --dry-run
./modules/community/tools/sitemap-mediawiki --yes
```

The phpBB generator includes public `viewforum` and `viewtopic` URLs, plus pagination (`start=N`) when a topic is longer than `PHPBB_POSTS_PER_PAGE`. A forum is public only when it is postable, has no password, and both GUESTS and BOTS have `f_read`. Do not hard-code private forum ids. Shard at 40,000 URLs.

The wiki generator includes Main, File, and Category pages that are not redirects. It skips when `WIKI_ENABLED=0`.

Neither generator includes user profiles, ACP, or `Special:` pages. Generate them with a oneshot timer, not on-request PHP.

`robots.txt` must list the sitemap and must not set `Crawl-delay` under `User-agent: *`.

## robots.txt

```bash
./modules/community/tools/robots --dry-run
./modules/community/tools/robots --yes
```

This writes a `robots.txt` at each enabled docroot from `robots.txt.example`, with the site-contract hostnames and sitemap URLs filled in, and with `/install/` and `/mw-config/` disallowed.

## After

`curl -sS https://forums.example.org/sitemap.xml | head` should show your topics, not an example.org string, once the instance is bound.

Re-run the generators after a large import, and on a weekly cadence if the board is busy.
