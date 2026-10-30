# Users' manual

You look after a community resource. You talk to Wolfe in plain language. This page is the menu.

Each section is a job. It tells you what to say, what the agent does, what it will wait for you to confirm, and how you know it worked.

The agent starts read-only. Destructive or outward-facing work waits for an explicit yes. Continuity comes first. The tenets are in `CONSTITUTION.md`.

Do not paste secrets into chat. Open the vault item the agent names, or export it on the host.

Placeholders in this file (`example.org`, `<VAULT_NAME>`, `<ITEM_NAME>`) stay placeholders.

## Morning health check

**Say.** "Is the site up?" or "Don't change anything. Just tell me if we are OK."

**Does.** Runs `./tools/health`. Reports URL status, disk, load, snapshot age versus `RESTIC_MAX_AGE_HOURS`, and whether installer paths are closed. Twelve lines or fewer. Follows `cadence/weekday-health.md`.

**Confirms.** Nothing. This is a glance.

**Verify.** The first line is a finding if a URL failed, the newest snapshot is stale, or an installer path returned 200. Otherwise you get a short OK. Do not ask the agent to restart anything "to be sure."

## Security check and patching

**Say.** "Anything we need to patch?" or "Upgrade the forum this weekend." Name the window if you have one.

**Does.** Stays read-only for the watch (`cadence/vulnerability-watch.md`): OS notices, PHP and web-stack packages, and the application pins (phpBB and MediaWiki when the community module is on). If you asked for an upgrade, it follows `playbooks/upgrade.md` and the module playbook. It checks the pin and the vendor checksum, takes or confirms a restic snapshot, dry-runs maintenance and the upgrade, then waits.

**Confirms.** The patch or upgrade itself. Maintenance on, the overlay, and maintenance off each wait for a yes. It will not download "latest." It will not skip the snapshot.

**Verify.** After the yes: a public page loads logged out, the live version matches the pin, installer paths 403, and `handbook/upgrades.md` names the version that is now live. If the updater fails, maintenance stays on and the agent restores the snapshot.

## Emergency offline

**Say.** "Take the site down now." or "We got hacked. Take it offline."

**Does.** Follows `handbook/incidents.md` and `playbooks/maintenance.md`. Puts the origin in maintenance (`tools/maintenance --on`). If the edge is the problem, it prepares a Cloudflare challenge or Under Attack change and waits. If compromise looks real, it proposes a snapshot for evidence, a restore to a new host from a snapshot before the break, and a vault rotation. It does not clean a burned host in place.

**Confirms.** Maintenance on. Any edge mode change. Any public status note. A restore or rebuild. Mailing anyone.

**Verify.** The public URL serves the maintenance page or the challenge you asked for. `tools/maintenance --status` agrees. The incident log has a dated entry with no secrets.

## Backups and restore drills

**Say.** "Take a backup before the weekend." or "When did we last prove a restore?" or "Run the restore drill."

**Does.** Backup: `playbooks/backup.md`, dry-run, then `./tools/backup --yes`. Restore drill: `playbooks/restore-drill.md`. It restores into a scratch directory, never over `WEB_ROOT` or the live database. A list of snapshots is not a drill.

**Confirms.** The live backup. The restore into the scratch target. It will refuse a restore that points at the live docroot.

**Verify.** Backup: a new snapshot id, `${STATE_DIR}/backup-status` says `OK`, and `tools/health` does not call the snapshot stale. Drill: you opened a real page or a known title from the restored copy, then the scratch data was deleted, and `handbook/backups.md` has the date and the snapshot id.

## User reports and banning a scammer

Use this when `MODULES` lists `community`. The playbook is `modules/community/playbooks/reports-and-bans.md`.

**Say.** "A member reported a scammer in thread N." or "Check the new reports." or "Ban this account, it is a new-account payment scam."

**Does.** Investigates read-only first: account age, post count, other posts and PMs, copy-paste templates, off-site contact addresses, payment requests, and IP overlap with already-banned accounts. It classifies the report.

For a clear scammer on a new account it proposes, then after a yes:

1. A permanent ban through the forum's own ban path, the same code the moderator control panel uses.
2. An internal reason and a reason shown to the user.
3. Deletion of the spam posts.
4. Closing of the reports.
5. A short `Banned!` reply in each affected public thread, telling members not to answer that person's PMs.

The CLI takes an explicit acting-user flag and checks that this user can ban, delete, and close reports. It exits nonzero if the check fails.

A ban you asked for is logged under you (`<FORUM_ADMIN_USERNAME>`). Automated monitor actions are logged under the dedicated bot moderator (`<FORUM_BOT_USER>`). The moderator log should show at a glance which actions were automated, so you can audit and reverse them. The monitor never falls back to your account. If the bot cannot act, it stops and notifies you.

Every step dry-runs first. A guard refuses established members, founders, and admins. Anything ambiguous stops and comes back to you.

An optional scheduled monitor (`cadence/reports-watch.md`) polls for new reports and runs the same path as the bot. Once you enable it, clear new-account scammers under the guard are handled without a per-event yes. Everything else is a notification to you.

**Confirms.** The classification, the ban, the deletions, the public `Banned!` posts, the acting user, and enabling the monitor. A one-time yes to the monitor covers later clear new-account scammers, logged as the bot. Tests never run against the live board. The bot account password lives only in `<VAULT_NAME>/forum-bot`.

**Verify.** The account is banned in the moderator control panel. A ban you asked for shows you as the actor. A monitor ban shows the bot. The spam posts are gone. The reports are closed. Each public thread has the `Banned!` reply. Established, founder, and admin accounts are untouched.

## Spam floods, scrapers, and the WAF

**Say.** "The site is crawling." or "We're getting hammered on viewtopic." or "Turn on the challenge."

**Does.** Stays read-only long enough to see origin rate, PHP children, and the HTTPS accept queue. Follows `handbook/edge.md` and, for phpBB, `modules/community/playbooks/abuse.md`. Prefers a managed challenge on expensive paths for requests with no `Cookie` header. Under Attack is the next step. Origin deny lists are depth, not the plan. It does not reboot. It does not force-cache HTML.

**Confirms.** Any WAF rule, challenge, Under Attack toggle, or origin firewall change. A public "we are under attack" banner, in the same step as the edge mode.

**Verify.** Origin request rate falls. PHP children are no longer pinned. Returning members with a cookie skip the interstitial if you asked for that. The banner matches the edge mode. Step back when the farm is quiet.

## Search and SEO

**Say.** "Search engines aren't seeing the forum." or "Rebuild the sitemaps." or "Check robots.txt."

**Does.** Follows `modules/community/playbooks/discoverability.md`. Dry-runs the phpBB and MediaWiki sitemap tools and `robots`. Public forums only: postable, no password, GUESTS and BOTS both have `f_read`. Topics inherit that filter. Paginated locs are XML-escaped. Installer paths stay disallowed.

**Confirms.** Writing `sitemap.xml`, shards, or `robots.txt` into a docroot.

**Verify.** `curl -sS https://forums.example.org/sitemap.xml` shows your public topics, not `example.org`, once the instance is bound. `robots.txt` lists the sitemap and does not set `Crawl-delay` under `User-agent: *`. Private forums and installer paths are absent. A parser accepts the XML.

## Broken wiki links and files

Use this when the wiki is on (`WIKI_ENABLED=1`).

**Say.** "These wiki links are dead." or "The file on page X is missing." Paste the titles or URLs, not a dump of the database.

**Does.** Stays read-only. Checks whether the page or file exists, whether it was renamed, and whether the object-storage or FUSE mount is the real cause (a missing file on a slow mount is not a wiki-edit problem). Proposes the smallest edit: a redirect, a corrected link, or a restored file from restic.

**Confirms.** Any wiki edit, file restore, or mount change. It will not rewrite a page to "tidy" it.

**Verify.** The link resolves for a logged-out reader. The file renders. If a restore was used, the scratch copy matched before it was copied into the live tree.

## Billing and payment-card changes

**Say.** "The card on the VPS is expiring." or "Move hosting off my personal card." or "What are we paying for?"

**Does.** Read-only. Follows `handbook/continuity.md` and the cost half of `cadence/weekly-stewardship.md`. Lists the community instruments for the VPS, the domain, the vault, and object storage. Names the vendor screens you must open. It does not log into a billing account you have not given it, and it does not enter a card number.

**Confirms.** Nothing on the vendor side. You click. After you say it is done, it updates the handbook payer lines.

**Verify.** The next invoice lands on the community instrument, not a personal card. `handbook/continuity.md` matches. A personal card that still sits on a vendor account is a continuity bug.

## Domain renewals

**Say.** "When does example.org expire?" or "Renew the domain." or "The registrar mail bounced."

**Does.** Read-only first. Finds the registrar item in `<VAULT_NAME>`, the expiry if it can see it, and whether the recovery mailbox still works without `@example.org` mail. Prepares the renewal or the nameserver check. It does not transfer a domain.

**Confirms.** You click the registrar. After you say it is done, it updates `handbook/edge.md` and the continuity page. An autorenew that already exists is a note, not a change.

**Verify.** The registrar shows a new expiry. DNS still answers through Cloudflare. The out-of-band mailbox can still open the registrar if the domain dies.

## Adding a co-admin and handing off

**Say.** "Add another admin." or "I am leaving. Hand this off." Name the person in chat if you must. Do not put their email in a public handbook page.

**Does.** Follows `handbook/continuity.md`. Proposes vault access at the least role that still passes the continuity test, SSH or break-glass, git write, and a restore-drill walkthrough. When someone leaves: remove vault access the same day, remove SSH keys and tokens, rotate what they could have copied.

**Confirms.** Each account add or remove. Each rotation. Publishing a name or email into git.

**Verify.** Two people can, this week, without you: SSH, open `<VAULT_NAME>`, restore the newest snapshot to a scratch directory, and merge a pull request. The continuity page lists roles, not personal inboxes.

## Rotating credentials

**Say.** "Rotate the database password." or "I think this vault item leaked." or "Rotate everything the origin can see."

**Does.** Names the item (`<VAULT_NAME>/<ITEM_NAME>`), the consumers (origin, restic, CDN token, registrar), and the order. Dry-runs the origin-side change. Waits. After a yes, the human (or a vault CLI on the host) writes the new secret. The agent updates the consumer and the handbook. It does not put the new value in git or in chat.

**Confirms.** Each rotation. A full "everything the origin can see" rotation is an incident move. Have a recovery path first: a snapshot, and a way back into the vault that does not depend on the secret you are killing.

**Verify.** The old secret fails. The new secret works on the consumer you named. `handbook/incidents.md` has a dated line if this was a leak. The integrity scan is still clean.

## Decommissioning old infrastructure

**Say.** "The old VPS can die." or "Remove the leftover DNS for the last host." or "We moved. Burn the previous origin."

**Does.** Stays read-only until it can name what still depends on the old thing: DNS, restic, vault items, SSH keys, registrar glue, CDN origin records. The new path must already be proven (health URLs, a restore drill, mail to the community instrument). Then it proposes a teardown order.

**Confirms.** Each destroy: host, disk, DNS record, firewall exception, old vault item, old key. It will not decommission the only working path.

**Verify.** The public names still serve on the new origin. The old IP does not answer for the site. The vault no longer holds standing access to the burned host. The handbook no longer lists the old host as live.

## Filing issues

**Say.** "File a Wolfe issue for this." or "Open an issue on our instance repo: the weekday glance missed a stale snapshot."

**Does.** Drafts a short issue: what you saw, what you expected, the playbook or tool involved. Uses placeholders. Strips secrets, emails, hostnames you would not publish, and vault item values.

**Confirms.** Posting the issue. A public tracker is outward-facing.

**Verify.** The issue is on the repo you named. It contains no secret and no real identifier. If the work needs a patch, that is a pull request, not a second issue.
