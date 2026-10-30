# Community module prompts

Use these when `MODULES` lists `community`. The generic Wolfe prompts stay in `examples/prompts.md`.

## "Upgrade phpBB."

Read `playbooks/upgrade-phpbb.md` in this module and `handbook/upgrades.md`. Check the pin. Dry-run the upgrade. Wait for a yes. Do not download "latest."

## "The wiki looks stuck on an old version."

If `WIKI_ENABLED=0`, say so and stop. Otherwise treat it as a MediaWiki upgrade request and follow that playbook, including the wait for a yes.

## "A member reported a scammer."

`playbooks/reports-and-bans.md`. Investigate read-only. Classify. The guard refuses established members, founders, and admins. Dry-run the ban, the deletions, and the `Banned!` posts. A ban the human asked for logs as that human. The monitor logs as the bot and must not fall back. Anything ambiguous goes to the human.

## "We're getting a lot of spam."

Read-only. Look at phpBB's ACP settings and recent registrations in the database (counts and dates, not people's emails). Propose turning on the built-in captcha or moderation. Do not install a new extension. Do not mass-delete users without a yes.

## "Search engines aren't seeing the wiki."

If the wiki is disabled, say so. Otherwise run the discoverability playbook in dry-run, check `robots.txt` and `sitemap.xml` on the public hostnames, and check that Cloudflare is not caching an empty sitemap. Wait before writing files.

## "People keep getting logged out."

`playbooks/sessions-and-cookies.md`. Stay read-only until you have the live config values.

## "We're getting hammered on viewtopic."

`playbooks/abuse.md`. Edge first. Origin deny is depth, not the plan.
