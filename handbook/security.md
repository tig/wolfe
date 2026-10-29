# Security

The origin is not on the public internet. The CDN is.

If you take only one thing from this page, take that.

## Firewall

Default deny inbound.

Allow:

1. SSH on `SSH_PORT` from `<ADMIN_CIDR>` only.
2. TCP 80 and 443 from Cloudflare's published IPv4 and IPv6 ranges, and from nowhere else.
3. Outbound as the host needs (updates, restic, DNS).

Cloudflare publishes the ranges at `https://www.cloudflare.com/ips-v4` and `https://www.cloudflare.com/ips-v6`. `tools/edge-allowlist` fetches those lists and prints or applies the rules.

Re-fetch the lists when Cloudflare announces a change. Do not hard-code a range you copied a year ago.

If you must hit the origin yourself, do it over SSH, or from a path that already goes through Cloudflare.

## Installer paths

After install, a web installer is an attack surface.

Deny those paths in the web server, and delete or move the installer directory after the CLI updater has run. Record the paths in `INSTALLER_PATHS`. The community module uses `install/` and `mw-config/`.

`robots.txt` may also list those paths as `Disallow`. That is not access control. It is a courtesy to crawlers.

## Runtime hardening

These belong in the application pool, not a debate. PHP is the worked example because the community module uses it. Translate the same ideas if your runtime is different.

1. Do not advertise the runtime version (`expose_php = Off` for PHP).
2. Do not allow remote include.
3. Do not display errors on the origin.
4. Session cookies are HTTP-only, secure, and `SameSite=Lax`.
5. Constrain the process to the docroot, the session path, and the upload path (`open_basedir` or the equivalent).
6. Disable shell-out functions the application does not need. If a documented maintenance script needs one, name that script here instead of disabling nothing.

Reload the runtime after you change this. Then verify, and record the date on this page.

## Web server

1. Do not list directories.
2. Do not serve `config.php`, `LocalSettings.php`, `.env`, or `site.env`.
3. Deny `.git`.
4. Send `X-Content-Type-Options: nosniff` and a conservative `Referrer-Policy`.

## Accounts

The database users in `site/site.env` have only the grants they need on their own database. They are not `root`.

`root` SSH login is off. The admin user uses a key. The key's private half lives in the vault, not in this repository.

## Worked example (scrubbed)

A one-host site allowed SSH from a single admin CIDR and 80/443 from Cloudflare ranges only. After an application upgrade, an installer directory stayed on disk for a day. That was a finding, not a style note. The upgrade playbook now deletes it before it calls the job done.
