# Architecture

One Linux server is the origin. Cloudflare is the only public door. An application serves people. A database holds their data if the app needs one. restic copies data to S3-compatible storage. A community-owned vault holds secrets. This repository holds the truth we are willing to write down.

```
people
   |
   |  HTTPS
   v
Cloudflare (DNS, TLS, cache, bot filter)
   |
   |  HTTPS from Cloudflare IP ranges only
   v
origin Linux host
   +-- web server + application runtime
   +-- application     WEB_ROOT
   +-- database        (if the app uses one)
   +-- restic cron     ->  S3-compatible bucket
```

If `MODULES` lists `community`, the application is phpBB at a forum hostname, and MediaWiki is optional at a wiki hostname. That overlay is described in `modules/community/README.md`. The diagram above stays true either way.

## Trust boundaries

The internet may reach Cloudflare. It may not reach the origin.

The origin accepts SSH from `<ADMIN_CIDR>` and HTTP(S) from Cloudflare's published IP ranges. Everything else inbound is denied.

The web server must recover the real client IP from `CF-Connecting-IP`, and only from those ranges. Without that, session binding, fail2ban, and application logs all see rotating edge addresses.

Media on a FUSE or rclone mount is not "just a directory." Page-path `stat()` of a huge flat bucket is an outage waiting to happen. Backups must not follow that mount unless you meant to.

Secrets cross the vault boundary, not the git boundary. Scripts receive a password at run time from a vault item, an environment variable the human exported, or a prompt. They do not read a secret out of this repository.

## What is in scope

The Linux host, the web stack, an optional database, the firewall, the Cloudflare zone, restic, the registrar, the vault, the instrument that pays the bills, this repository, and any module you loaded.

## What is out of scope

A second origin, a container platform, a mail-sending product, a monitoring SaaS, and application-specific rescue proxies. If an instance adds one of those, it records it in *its* handbook after it forks Wolfe. It does not send the addition upstream unless it is a new module with a real owner.

## Filled from the live host

- Public URL: `https://example.org/`.
- Origin role: single host, no failover.
- Vault: `<VAULT_NAME>`.
- Backup repository: `s3:https://<S3_ENDPOINT>/<BUCKET>`.
- Modules: `<empty | community>`.
