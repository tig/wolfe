# Users' manual

The custodian talks to Wolfe in plain language. This page lists the jobs.

Each section names the prompt, the procedure, the confirmation, and the verification.

The agent starts read-only. Destructive or outward-facing work waits for an explicit yes. Continuity comes first. The tenets are in `CONSTITUTION.md`.

The custodian must not paste secrets into chat. The custodian must open the vault item the agent names, or export it on the host.

Placeholders in this file (`example.org`, `<VAULT_NAME>`, `<ITEM_NAME>`) must stay placeholders.

## Morning health check

### Prompt

"Is the site up?" or "Don't change anything. Just tell me if we are OK."

### Procedure

1. The agent must stay read-only.
2. The agent must run `./tools/health` if it can reach the origin.
3. The agent must follow `cadence/weekday-health.md`.
4. The agent must report URL status, disk, load, snapshot age versus `RESTIC_MAX_AGE_HOURS`, and installer-path status.
5. The report must be 12 lines or fewer.

### Confirmation

None. This is a glance.

### Verification

The first line is a finding if a URL failed, the newest snapshot is stale, or an installer path returned 200. Otherwise the report is a short OK. The custodian must not ask the agent to restart anything to be sure.

## Security check and patching

### Prompt

"Anything we need to patch?" or "Upgrade the forum this weekend." Name the window if one exists.

### Procedure

1. The agent must stay read-only for the watch in `cadence/vulnerability-watch.md`.
2. The agent must check OS notices, PHP and web-stack packages, and the application pins.
3. If `MODULES` lists `community`, the pins include phpBB and MediaWiki when the wiki is on.
4. If the custodian asked for an upgrade, the agent must follow `playbooks/upgrade.md` and the module playbook.
5. The agent must check the pin and the vendor checksum.
6. The agent must confirm or take a restic snapshot.
7. The agent must dry-run maintenance and the upgrade, then wait.

### Confirmation

The custodian must confirm the patch or upgrade. Maintenance on, the overlay, and maintenance off each wait for a yes. The agent must not download "latest." The agent must not skip the snapshot.

### Verification

After the yes, a public page must load logged out. The live version must match the pin. Installer paths must return 403. `handbook/upgrades.md` must name the version that is now live. If the updater fails, maintenance stays on and the agent restores the snapshot.

## Emergency offline

### Prompt

"Take the site down now." or "We got hacked. Take it offline."

### Procedure

1. The agent must follow `handbook/incidents.md` and `playbooks/maintenance.md`.
2. The agent must put the origin in maintenance with `tools/maintenance --on`.
3. If the edge is the problem, the agent must prepare a Cloudflare challenge or Under Attack change and wait.
4. If compromise looks real, the agent must propose a snapshot for evidence, a restore to a new host from a snapshot before the break, and a vault rotation.
5. The agent must not clean a burned host in place.

### Confirmation

The custodian must confirm maintenance on, any edge mode change, any public status note, a restore or rebuild, and any mail.

### Verification

The public URL must serve the maintenance page or the requested challenge. `tools/maintenance --status` must agree. The incident log must have a dated entry with no secrets.

## Backups and restore drills

### Prompt

"Take a backup before the weekend." or "When did we last prove a restore?" or "Run the restore drill."

### Procedure

1. For a backup, the agent must follow `playbooks/backup.md`.
2. The agent must dry-run, then run `./tools/backup --yes` after a yes.
3. For a restore drill, the agent must follow `playbooks/restore-drill.md`.
4. The agent must restore into a scratch directory.
5. The agent must not restore over `WEB_ROOT` or the live database.
6. A list of snapshots is not a drill.

### Confirmation

The custodian must confirm the live backup and the restore into the scratch target. The tool must refuse a restore that points at the live docroot.

### Verification

Backup: a new snapshot id exists, `${STATE_DIR}/backup-status` says `OK`, and `tools/health` does not call the snapshot stale. Drill: the custodian opened a real page or a known title from the restored copy, the scratch data was deleted, and `handbook/backups.md` has the date and the snapshot id.

## User reports and banning a scammer

Use this when `MODULES` lists `community`. The playbook is `modules/community/playbooks/reports-and-bans.md`.

### Prompt

"A member reported a scammer in thread N." or "Check the new reports." or "Ban this account, it is a new-account payment scam."

### Procedure

1. The agent must investigate read-only first.
2. The agent must record account age, post count, other posts and PMs, copy-paste templates, off-site contact addresses, payment requests, and IP overlap with already-banned accounts.
3. The agent must classify the report.
4. For a clear scammer on a new account, the agent must propose the action list and wait for a yes.
5. After a yes, the CLI must ban permanently through the forum's own ban path, the same code the moderator control panel uses.
6. The ban must include an internal reason and a reason shown to the user.
7. The CLI must delete the spam posts.
8. The CLI must close the reports.
9. The CLI must post a short `Banned!` reply in each affected public thread. The reply must tell members not to answer that person's PMs.
10. The CLI must take an explicit acting-user flag.
11. The CLI must verify that the acting user can ban, delete, and close reports.
12. The CLI must exit nonzero if the check fails.
13. Every step must dry-run first.
14. The guard must refuse established members, founders, and admins.
15. Anything ambiguous must stop and return to the custodian.

A ban the custodian asked for must log under `<FORUM_ADMIN_USERNAME>`. Automated monitor actions must log under `<FORUM_BOT_USER>`. The moderator log must show which actions were automated so a human can audit and reverse them. The monitor must not fall back to the human account. If the bot cannot act, the monitor must stop and notify the custodian.

An optional scheduled monitor (`cadence/reports-watch.md`) polls for new reports and runs the same path as the bot. After the custodian enables it, clear new-account scammers under the guard run without a per-event yes. Everything else is a notification to the custodian.

### Confirmation

The custodian must confirm the classification, the ban, the deletions, the public `Banned!` posts, the acting user, and enabling the monitor. A one-time yes to the monitor covers later clear new-account scammers, logged as the bot. Tests must not run against the live board. The bot account password must live only in `<VAULT_NAME>/forum-bot`.

### Verification

The account is banned in the moderator control panel. A ban the custodian asked for shows that human as the actor. A monitor ban shows the bot. The spam posts are gone. The reports are closed. Each public thread has the `Banned!` reply. Established, founder, and admin accounts are untouched.

## Spam floods, scrapers, and the WAF

### Prompt

"The site is crawling." or "We're getting hammered on viewtopic." or "Turn on the challenge."

### Procedure

1. The agent must stay read-only long enough to see origin rate, PHP children, and the HTTPS accept queue.
2. The agent must follow `handbook/edge.md`.
3. If `MODULES` lists `community`, the agent must also follow `modules/community/playbooks/abuse.md`.
4. The agent must prefer a managed challenge on expensive paths for requests with no `Cookie` header.
5. Under Attack is the next step if the challenge is not enough.
6. Origin deny lists are defense in depth.
7. The agent must not reboot.
8. The agent must not force-cache HTML.

### Confirmation

The custodian must confirm any WAF rule, challenge, Under Attack toggle, or origin firewall change. A public "we are under attack" banner must change in the same step as the edge mode.

### Verification

Origin request rate falls. PHP children are no longer pinned. Returning members with a cookie skip the interstitial if that was requested. The banner matches the edge mode. The agent must step back when the farm is quiet.

## Search and SEO

### Prompt

"Search engines aren't seeing the forum." or "Rebuild the sitemaps." or "Check robots.txt."

### Procedure

1. The agent must follow `modules/community/playbooks/discoverability.md`.
2. The agent must dry-run the phpBB and MediaWiki sitemap tools and `robots`.
3. The sitemap must include only public forums: postable, no password, GUESTS and BOTS both have `f_read`.
4. Topics must inherit that filter.
5. Paginated locs must be XML-escaped.
6. Installer paths must stay disallowed.

### Confirmation

The custodian must confirm writing `sitemap.xml`, shards, or `robots.txt` into a docroot.

### Verification

`curl -sS https://forums.example.org/sitemap.xml` must show public topics, not `example.org`, once the instance is bound. `robots.txt` must list the sitemap. `robots.txt` must not set `Crawl-delay` under `User-agent: *`. Private forums and installer paths must be absent. A parser must accept the XML.

## Broken wiki links and files

Use this when `WIKI_ENABLED=1`.

### Prompt

"These wiki links are dead." or "The file on page X is missing." Paste the titles or URLs. Do not paste a database dump.

### Procedure

1. The agent must stay read-only.
2. The agent must check whether the page or file exists.
3. The agent must check whether it was renamed.
4. The agent must check whether an object-storage or FUSE mount is the cause.
5. A missing file on a slow mount is not a wiki-edit problem.
6. The agent must propose the smallest edit: a redirect, a corrected link, or a restored file from restic.

### Confirmation

The custodian must confirm any wiki edit, file restore, or mount change. The agent must not rewrite a page to tidy it.

### Verification

The link resolves for a logged-out reader. The file renders. If a restore was used, the scratch copy matched before it was copied into the live tree.

## Billing and payment-card changes

### Prompt

"The card on the VPS is expiring." or "Move hosting off my personal card." or "What are we paying for?"

### Procedure

1. The agent must stay read-only.
2. The agent must follow `handbook/continuity.md` and the cost half of `cadence/weekly-stewardship.md`.
3. The agent must list the community instruments for the VPS, the domain, the vault, and object storage.
4. The agent must name the vendor screens the custodian must open.
5. The agent must not log into a billing account it has not been given.
6. The agent must not enter a card number.

### Confirmation

The agent must not confirm anything on the vendor side. The custodian clicks. After the custodian says it is done, the agent updates the handbook payer lines.

### Verification

The next invoice lands on the community instrument. `handbook/continuity.md` matches. A personal card that still sits on a vendor account is a continuity failure.

## Domain renewals

### Prompt

"When does example.org expire?" or "Renew the domain." or "The registrar mail bounced."

### Procedure

1. The agent must stay read-only first.
2. The agent must find the registrar item in `<VAULT_NAME>`.
3. The agent must find the expiry if it can see it.
4. The agent must check whether the recovery mailbox still works without `@example.org` mail.
5. The agent must prepare the renewal or the nameserver check.
6. The agent must not transfer a domain.

### Confirmation

The custodian clicks the registrar. After the custodian says it is done, the agent updates `handbook/edge.md` and the continuity page. An autorenew that already exists is a note.

### Verification

The registrar shows a new expiry. DNS still answers through Cloudflare. The out-of-band mailbox can still open the registrar if the domain dies.

## Adding a co-admin and handing off

### Prompt

"Add another admin." or "I am leaving. Hand this off." Name the person in chat if required. Do not put their email in a public handbook page.

### Procedure

1. The agent must follow `handbook/continuity.md`.
2. The agent must propose vault access at the least role that still passes the continuity test.
3. The agent must propose SSH or break-glass, git write, and a restore-drill walkthrough.
4. When someone leaves, the agent must remove vault access the same day.
5. The agent must remove SSH keys and tokens.
6. The agent must rotate what that person could have copied.

### Confirmation

The custodian must confirm each account add or remove, each rotation, and any name or email published into git.

### Verification

Two people can, this week, without the departing custodian: SSH, open `<VAULT_NAME>`, restore the newest snapshot to a scratch directory, and merge a pull request. The continuity page lists roles, not personal inboxes.

## Rotating credentials

### Prompt

"Rotate the database password." or "I think this vault item leaked." or "Rotate everything the origin can see."

### Procedure

1. The agent must name the item (`<VAULT_NAME>/<ITEM_NAME>`), the consumers, and the order.
2. Consumers include origin, restic, CDN token, and registrar.
3. The agent must dry-run the origin-side change.
4. The agent must wait.
5. After a yes, the human or a vault CLI on the host writes the new secret.
6. The agent must update the consumer and the handbook.
7. The agent must not put the new value in git or in chat.

### Confirmation

The custodian must confirm each rotation. A full "everything the origin can see" rotation is an incident move. A recovery path must exist first: a snapshot, and a way back into the vault that does not depend on the secret being replaced.

### Verification

The old secret fails. The new secret works on the named consumer. `handbook/incidents.md` has a dated line if this was a leak. The integrity scan is clean.

## Decommissioning old infrastructure

### Prompt

"The old VPS can die." or "Remove the leftover DNS for the last host." or "We moved. Burn the previous origin."

### Procedure

1. The agent must stay read-only until it can name what still depends on the old thing.
2. Dependencies include DNS, restic, vault items, SSH keys, registrar glue, and CDN origin records.
3. The new path must already be proven: health URLs, a restore drill, and mail to the community instrument.
4. The agent must then propose a teardown order.

### Confirmation

The custodian must confirm each destroy: host, disk, DNS record, firewall exception, old vault item, and old key. The agent must not decommission the only working path.

### Verification

The public names still serve on the new origin. The old IP does not answer for the site. The vault no longer holds standing access to the burned host. The handbook no longer lists the old host as live.

## Filing issues

### Prompt

"File a Wolfe issue for this." or "Open an issue on our instance repo: the weekday glance missed a stale snapshot."

### Procedure

1. The agent must draft a short issue: what was seen, what was expected, and the playbook or tool involved.
2. The draft must use placeholders.
3. The draft must strip secrets, emails, hostnames the owner would not publish, and vault item values.

### Confirmation

The custodian must confirm posting the issue. A public tracker is outward-facing.

### Verification

The issue is on the named repo. It contains no secret and no real identifier. If the work needs a patch, that is a pull request, not a second issue.
