# Host

This page is the living record of the Linux server. Fill it from `uname`, the package manager, and the process list. If this page and the host disagree, the host wins.

## Identity

- Provider: `<VPS_PROVIDER>`.
- Region: `<REGION>`.
- Public IPv4: `<SERVER_IP>`.
- Hostname (internal): `<ORIGIN_HOSTNAME>`.
- OS: `<OS_PRETTY>` (example: Debian 12, Ubuntu 24.04).
- SSH: port `22`, user `admin`, allowed from `<ADMIN_CIDR>`.

Do not publish the IPv4 in a public fork. Keep this page in a private instance repo, or leave the placeholder.

## Stack

- Web server: `<apache2|nginx>` `<VERSION>`.
- Application runtime: `<php-fpm|other>` `<VERSION>`.
- Database: `<mariadb|mysql|none>` `<VERSION>`.
- Application: named in the loaded module, installed at `WEB_ROOT`.
- restic: `<RESTIC_VERSION>`.
- Firewall: `<ufw|nftables|iptables>`.

## Disk and services

Record the mount that holds the docroot and the database, and the systemd units that must be up for the site to serve traffic.

- Data mount: `<DATA_MOUNT>` with at least enough headroom that a database dump plus an archive extract cannot fill it.
- Must be running: `<web-unit>`, `<runtime-unit>`, `<db-unit-or-none>`.
- Backup timer: `<backup-timer>`. Confirm `systemctl list-timers` shows it, and that `${STATE_DIR}/backup-status` is `OK` and fresh.

If you switched from mod_php to PHP-FPM, the FPM pool has its own `upload_max_filesize` and `post_max_size`. The Apache `php.ini` no longer applies. Phone photos will fail instantly at the old 2M default.

A short `~/AGENTS.md` on each admin account that points at the on-box clone of this repo is enough for agents that only open the home directory. Do not invent a second copy of the handbook there.

## First-time bootstrap (shape only)

The rebuild skeleton in `playbooks/rebuild.md` does this. Do not invent a second stack.

1. Install the OS updates.
2. Install the web server, the runtime, and the database you actually use.
3. Create the docroot and the database users named in `site/site.env`.
4. Restore from restic, or install fresh and import.
5. Apply `handbook/security.md`.
6. Point DNS only after a local curl on the origin succeeds.
