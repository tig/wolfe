# Rebuild the origin

This is the "the host is gone" path. It is also the "the host is burned" path from `handbook/incidents.md`.

`tools/rebuild` is a skeleton. It does not call a cloud vendor. A human creates the empty Linux server and writes `<SERVER_IP>` into `site/site.env`.

## Before

1. You have a restic snapshot you have restored in a drill.
2. You have the vault.
3. You have SSH to a new host that is not yet serving public traffic.
4. DNS TTL is low enough that a cutover will finish while you are still at the keyboard.

## Shape of the work

```bash
./tools/rebuild --dry-run
```

The skeleton prints, and when `--yes` is given, walks:

1. `install-stack`: packages from `handbook/host.md` (web server, runtime, database, restic).
2. `apply-security`: installer-path denies, runtime hardening, edge allowlist (`tools/edge-allowlist --yes`).
3. `restore-data`: the restic snapshot into the new docroots and databases.
4. `verify-local`: curl the origin on localhost until the app is 200.
5. `cutover`: you point the Cloudflare records at the new `<SERVER_IP>`. The tool never does this itself.
6. `verify-public`: `tools/health` through the public URLs.
7. `record`: handbook updates for the new host identity.

## After

1. Keep the old origin off the public internet until you are sure.
2. Rotate any secret the old origin could still use, if the rebuild was a compromise.
3. Run a restore drill against the new host within a week.
4. Update `handbook/host.md` and `handbook/continuity.md`.
