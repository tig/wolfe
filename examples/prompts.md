# Example prompts

These are things a human custodian actually says. Each one names the stance the agent takes, the files it reads, and the first move.

The task-oriented menu, including what the agent confirms and how to verify, is `users-manual.md`. This file is the short index.

The agent does not invent extra work. The first block is generic Wolfe. The second block is the community module.

## Generic

### "Is the site up?"

Read-only. Run `tools/health`. Report status codes, snapshot age, and whether installer paths are closed. Do not restart the runtime to "be sure."

### "Don't change anything. Just tell me if we are OK."

Read-only. Same as the weekday glance. Twelve lines or fewer.

### "Take a backup before the weekend."

Read `playbooks/backup.md`. Dry-run, then wait. After a yes, run `tools/backup --yes` and write the snapshot ID back to the human.

### "When did we last prove a restore?"

Read-only. Open `handbook/backups.md`. If the last good drill is missing or older than 90 days, say the drill is overdue and offer `playbooks/restore-drill.md`. Do not restore anything.

### "Disk is filling up."

Read-only first. Find the mount, the largest trees, and whether old backup-work directories were left behind. Propose a deletion plan. Wait. Do not run `restic forget --prune` unless the human asked for that, and the policy in `handbook/backups.md` agrees.

### "I think we got hacked."

Incident. Read `handbook/incidents.md`. Do not clean in place. Check for unexpected admin users, unexpected uploaded code, and a reachable installer path. Report. If compromise looks real, propose: snapshot for evidence, maintenance on, restore to a new host from a snapshot before the break, rotate the vault items the origin could see.

### "Move us to a new server."

Rebuild. Read `playbooks/rebuild.md`. A human creates the empty host. The agent dry-runs the skeleton, waits, then walks install, security, restore, local verify. The agent does not point DNS until a human says the local verify is good.

### "Add another admin."

Continuity. Read `handbook/continuity.md`. Propose vault access, SSH, git, and a restore-drill walkthrough. Do not create accounts until the human names the person and the role. Do not put that person's email in a public handbook page.

### "The card on the VPS is expiring."

Read-only. `users-manual.md` (billing) and `handbook/continuity.md`. Name the vendor screens. The human clicks. Do not enter a card number.

### "How much are we spending?"

Read-only. Follow `cadence/weekly-stewardship.md` for the cost half. Use the community instruments on the continuity page. Do not open billing accounts the agent has not been given.

### "Put the site in maintenance for an hour."

Follow `playbooks/maintenance.md`. Dry-run, wait, then `--yes`. Set a reminder to take it off. Do not leave it on because the session ended.

### "Can you post an announcement that we'll be down?"

Outward-facing. Draft the text. Wait for a yes. Then post with the account the human named. The agent does not become the site's voice on its own.

### "While you're in there, start a newsletter."

No. The constitution says not to add services. Offer to write the refusal in one sentence and stop.

## Community module

Use these only when `MODULES` lists `community`. The longer versions live in `modules/community/examples/prompts.md`.

### "Upgrade phpBB."

Read the community upgrade playbook. Check the pin. Dry-run. Wait for a yes. Do not download "latest."

### "The wiki looks stuck on an old version."

If the wiki is off, say so and stop. Otherwise treat it as a MediaWiki upgrade request.

### "A member reported a scammer."

Community only. Read `users-manual.md` (user reports and banning) and `modules/community/playbooks/reports-and-bans.md`. Investigate read-only. The guard refuses established members, founders, and admins. Dry-run every write. A requested ban logs as the human. The monitor logs as the bot and must not fall back.

### "We're getting a lot of spam."

Read-only. Look at phpBB's built-in anti-spam settings and recent registration counts, not people's emails. Do not install a new extension.

### "These wiki links are dead."

If the wiki is off, say so and stop. Otherwise stay read-only, name the missing page or file, and wait before editing. See `users-manual.md`.

### "Search engines aren't seeing the wiki."

If the wiki is disabled, say so. Otherwise dry-run the community discoverability playbook.

### "People keep getting logged out while they post."

Read-only first. Open `modules/community/playbooks/sessions-and-cookies.md`. Check `ip_check`, `browser_check`, `form_token_sid_guests`, `server_name`, and whether the origin sees real client IPs. Do not turn on IP pinning behind a CDN.

### "A member saw someone else's name in the header."

Privacy incident. Read `handbook/edge.md` (cached HTML leak). Bypass cache for the application path. Purge the zone. Do not force-cache guest HTML as a fix.

### "The site is crawling. viewtopic is huge."

Flood. Read `modules/community/playbooks/abuse.md`. Look at origin rate and PHP children. Challenge at the CDN or use Under Attack. Do not reboot. Do not add a service.

### "Did last night's backup run?"

Read-only. `tools/health` and `${STATE_DIR}/backup-status`. If the stamp is old or `FAIL`, that is an incident even if the site is up.

### "Uploads from phones fail right after we moved to FPM."

Read-only. Check the *FPM* pool `upload_max_filesize`, not Apache's `php.ini`. The old 2M default fails instantly.
