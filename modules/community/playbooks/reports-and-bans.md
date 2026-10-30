# Reports and bans

A member reports a post or a PM. The agent investigates read-only. The agent classifies it. The agent acts only when the classification is clear and the guard agrees.

This playbook is for `MODULES=community`. Tests must not touch a live board. Tests must use fixtures.

## Guard

Refuse, and hand the report to the human, when any of these is true:

1. The account is a founder, an administrator, or a global moderator.
2. The account is established: older than `SCAM_MAX_AGE_DAYS` or with more than `SCAM_MAX_POSTS` approved posts. The defaults in the module example are conservative. A bound `site/site.env` may tighten them. It must not loosen them without a handbook note.
3. The classification is not "clear scammer." Copy-paste templates, off-site contact addresses, and payment requests on a new account are the usual yes. A heated regular is not.
4. Anything is ambiguous. Age, post count, IP overlap, or the text could go either way.

The agent must not invent a private-forum exception. The agent must not mass-ban.

## Investigate, read-only

Look at, and report as counts and yes/no. Do not dump people's data:

1. Account age and registration date.
2. Approved post count.
3. Other posts and PMs from the same account (template reuse, payment asks, off-site contact addresses).
4. IP overlap with accounts already on the ban list. Do not publish the addresses.
5. Open reports that point at the same account.

Do not paste message bodies into a public handbook page. Do not paste emails.

## Classify

- **Clear scammer, new account.** The guard passed. Propose the action list below.
- **Needs a human.** Established, staff, or unclear. Stop. Say why.
- **Not a scam.** Close the loop with the human. Do not ban.

## Acting user

Every write must take an explicit acting-user flag. The CLI must verify that this user holds ban, delete, and report permissions on the forum. The CLI must exit nonzero if the user is missing, unresolved, or lacks those permissions. A permission failure is not a successful dry-run.

- **Manual.** The human asked for the action. Acting user is `<FORUM_ADMIN_USERNAME>`.
- **Automated.** The reports monitor, or any scheduled run of this path. Acting user is `<FORUM_BOT_USER>`.

The moderator log must show which actions were automated so a human can audit and reverse them. The CLI must not impersonate a human on an automated run. The CLI must not fall back from the bot to the human. If the bot cannot act, stop and notify.

The bot account password must live only in `<VAULT_NAME>/forum-bot`. It must not be in git, in `site/site.env`, or in a test fixture.

## Act (dry-run first, then `--yes`)

Use the forum's own ban path, the same code the moderator control panel uses. The ban must appear in the MCP log as the acting user. Do not `DELETE` from user tables. Do not write `phpbb_banlist` by hand.

After a yes (manual) or under the enabled monitor (automated):

1. Permanent ban. Internal reason (for other moderators) plus the reason shown to the user. Actor: the acting user.
2. Delete the spam posts named in the reports. Actor: the acting user.
3. Close those reports. Actor: the acting user.
4. Post a short `Banned!` reply in each affected public thread. Tell members not to answer that person's PMs. Do not post in a private forum. Actor: the acting user.

If a CLI implements this path, it must exit nonzero when it cannot bootstrap: missing site contract, missing vault item, database unreachable, missing `--acting-user`, or the acting user unresolved or under-permissioned. A bootstrap failure is not a successful dry-run.

## Optional monitor

`cadence/reports-watch.md` polls for new open reports and runs this playbook with `--acting-user` set to `<FORUM_BOT_USER>`.

Enabling the monitor is the human's yes for later clear new-account scammers that pass the guard. Everything else is a notification. The monitor must not loosen the guard. If the bot is missing or lacks ban, delete, or report permission, the monitor must stop and notify. It must not fall back to `<FORUM_ADMIN_USERNAME>`.

## After

The MCP ban list shows the account. The log actor is the intended acting user: the human for a requested ban, the bot for a monitor ban. Established, founder, and admin accounts are untouched. Write a one-line incident note if the volume was unusual. Scrub identifiers.
