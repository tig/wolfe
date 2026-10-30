# Reports and bans

A member reports a post or a PM. You investigate read-only. You classify it. You act only when the classification is clear and the guard agrees.

This playbook is for `MODULES=community`. Tests never touch a live board. Use fixtures.

## Guard

Refuse, and hand the report to the human, when any of these is true:

1. The account is a founder, an administrator, or a global moderator.
2. The account is established: older than `SCAM_MAX_AGE_DAYS` or with more than `SCAM_MAX_POSTS` approved posts. The defaults in the module example are conservative. A bound `site/site.env` may tighten them. It may not loosen them without a handbook note.
3. The classification is not "clear scammer." Copy-paste templates, off-site contact addresses, and payment requests on a new account are the usual yes. A heated regular is not.
4. Anything is ambiguous. Age, post count, IP overlap, or the text could go either way.

The agent does not invent a private-forum exception. The agent does not mass-ban.

## Investigate, read-only

Look at, and report as counts and yes/no, not as a dump of people's data:

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

## Act (dry-run first, then `--yes`)

Use the forum's own ban path, the same code the moderator control panel uses. The ban must appear in the MCP log exactly as if the named human moderator clicked Ban. Do not `DELETE` from user tables. Do not write `phpbb_banlist` by hand.

After a yes:

1. Permanent ban. Internal reason (for other moderators) plus the reason shown to the user. Actor: `<FORUM_ADMIN_USERNAME>`.
2. Delete the spam posts named in the reports.
3. Close those reports.
4. From the dedicated bot moderator account, post a short `Banned!` reply in each affected *public* thread. Tell members not to answer that person's PMs. Do not post in a private forum. Do not post as the human admin.

The bot account password lives only in `<VAULT_NAME>/forum-bot`. It is not in git, not in `site/site.env`, and not in a test fixture.

If a CLI implements this path, it exits nonzero when it cannot bootstrap: missing site contract, missing vault item, database unreachable, or the bot user unresolved. A bootstrap failure is not a successful dry-run.

## Optional monitor

`cadence/reports-watch.md` polls for new open reports and runs this playbook.

Enabling the monitor is the human's yes for later *clear new-account scammers* that pass the guard. Everything else is a notification. The monitor does not loosen the guard. The monitor does not post from the human admin's account.

## After

The MCP ban list shows the account. The log actor is `<FORUM_ADMIN_USERNAME>`. The bot posted `Banned!` only in the public threads you named. Established, founder, and admin accounts are untouched. Write a one-line incident note if the volume was unusual. Scrub identifiers.
