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

Before you apply a new allowlist, start a short dead-man timer that disables the firewall if you lock yourself out (for example `systemd-run --on-active=10m` calling `ufw disable`). Confirm SSH in a *new* session and confirm the site still loads through the CDN. Then cancel the timer.

Keep the web server's trusted-proxy list on the same ranges. If Apache or nginx trusts `CF-Connecting-IP` from the whole internet, clients can spoof. If it trusts none of them, every IP-based feature sees rotating edge addresses and session checks start lying.

If you must hit the origin yourself, do it over SSH, or from a path that already goes through Cloudflare. Emergency lockout recovery is the provider web console, then `ufw disable`.

Leaving SSH open to the world is an instance choice, not the default. Record it here if you do it, and say why.

## Installer paths

After install, a web installer is an attack surface.

Deny those paths in the web server, and delete or move the installer directory after the CLI updater has run. Record the paths in `INSTALLER_PATHS`. The community module uses `install/`, `install_/`, and `mw-config/`.

The deny must *and* with the vhost, not *or*. A vhost that says "allow all" will otherwise reopen the installer. `tools/installer-block` prints a snippet with that merge.

Verify from the origin with a `Host` header, not only from the public URL:

```bash
curl -sk -o /dev/null -w '%{http_code}\n' -H 'Host: example.org' https://127.0.0.1/install/
```

Expect 403 or 404. A 200 after an overlay upgrade is an incident.

`robots.txt` may also list those paths as `Disallow`. That is not access control. It is a courtesy to crawlers.

## Origin vs edge abuse

fail2ban on SSH is useful. fail2ban on a tiny error-log regex is not a request-rate shield. A distributed scrape of HTML will not trip it.

Block floods at the CDN first. An origin PHP pool cannot absorb tens of requests per second of 403s. Origin deny lists are defense in depth.

See `handbook/edge.md` and, for phpBB, `modules/community/playbooks/abuse.md`.

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
