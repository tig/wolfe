# Continuity and handoff

Continuity is the first tenet because volunteer sites die from missing people, not missing features.

This page is how the next admin gets in when you are in a hospital, on a beach, or done.

## The test

Name two people who can, this week, without you:

1. SSH to the origin.
2. Open `<VAULT_NAME>`.
3. Restore the newest restic snapshot onto a scratch directory.
4. Merge a pull request in this repository.

If you cannot name two, you do not have continuity. You have a hobby with a single point of failure.

## Vault

The vault is community-owned. A personal vault is a continuity bug.

Items the next admin must find by name, not by memory:

- SSH private key for `SSH_USER`.
- Database passwords (`DB_PASSWORD_ITEM`, plus any `EXTRA_DBS` items).
- restic repository password and S3 keys.
- Cloudflare login, or an API token limited to the zone, if you use one.
- Registrar login for `example.org`.
- The application's own founder or bureaucrat account.

Values never enter this repository. Names can, as `<VAULT_NAME>/<ITEM_NAME>`.

## Break-glass

Some recovery material is too powerful for one person to hold alone (the registrar transfer PIN, the vault recovery kit, the SSH CA, if you have one).

Split that material so that `k` of `n` admins are needed to reconstruct it. Two-of-three is enough for a three-admin site. Write the scheme here, not the shares.

- Scheme: `<none | 2-of-3 | other>`.
- Holders: `<ROLE_A>`, `<ROLE_B>`, `<ROLE_C>`.
- Last tested: `<YYYY-MM-DD>`.

The point is two-sided. No single person is the bottleneck. No single person can act alone on the nuclear options.

## Git

At least two people have write access to the instance repository, and at least two people can approve a pull request. The agent uses a branch and a pull request. It does not push to the default branch.

## Hosting and money

The VPS, the domain, the vault seats, and the S3-compatible bucket are paid by a community instrument, not a personal card that expires when one member moves house.

Record where the invoices land (a vault item, a shared inbox you are willing to name as a role, not a person's address). The weekly stewardship cadence looks at those invoices.

- VPS payer: `<COMMUNITY_INSTRUMENT>`.
- Domain payer: `<COMMUNITY_INSTRUMENT>`.
- Vault payer: `<COMMUNITY_INSTRUMENT>`.
- Object storage payer: `<COMMUNITY_INSTRUMENT>`.

## Handoff checklist

When an admin joins:

1. Add them to the vault with the least role that still lets them pass the test above.
2. Add their SSH key, or give them the existing key through the vault, and tighten `<ADMIN_CIDR>` if their network is known.
3. Walk them through one restore drill and one weekday health glance.
4. Add them to the git repository.
5. Update this page.

When an admin leaves:

1. Remove their vault access the same day.
2. Remove their SSH key and any API tokens they issued.
3. Rotate any secret they could have copied.
4. Update this page.

## Worked example (scrubbed)

A three-admin site put every origin secret in a community vault, paid the VPS from a community instrument, and split the registrar recovery kit two-of-three. One admin left. The other two restored a snapshot the same week without waiting for a forwarded email. That is what this page is for.
