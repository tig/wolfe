# Sessions and cookies (phpBB behind a CDN)

These settings are how a board behind Cloudflare stops lying to itself. Re-apply them after every `db:migrate`. A stock default will clobber them.

Record the live values here once you have set them.

## CDN-safe set

| Config | Value | Why |
| --- | --- | --- |
| `form_token_sid_guests` | `0` | Guest login tokens bound to a session id fail when the GET and the POST see different sessions (edge cache, or a slow POST). "The form is invalid" is this, not a bad password. |
| `server_name` | the public forum hostname | A mismatch on every POST invalidates the session. |
| `force_server_vars` | `1` | Do not let the origin guess the name from the Host header Cloudflare sent. |
| `server_port` | `443` | The public hop is HTTPS. |
| `ip_check` | `0` | Behind a CDN the origin sees rotating edge IPs unless real-IP is perfect on every request. IP pinning logs people out while they post. |
| `browser_check` | `0` | Same, for User-Agent. Privacy browsers and in-app browsers change it. |
| `session_length` | `604800` (7 days) | A two-hour session plus remember-me key rotation races when the browser restores several tabs. The losing response can `Set-Cookie` a key that was never stored and wipe persistent login. |
| `max_autologin_time` | `90` (days) | Remember-me lifetime. |

```bash
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set form_token_sid_guests 0
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set server_name forums.example.org
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set force_server_vars 1
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set server_port 443
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set ip_check 0
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set browser_check 0
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" config:set session_length 604800
sudo -u www-data php "$FORUM_DOCROOT/bin/phpbbcli.php" cache:purge
```

Session binding is the `Secure; HttpOnly` cookie, not the client IP.

## Real client IP

The web server must set the remote address from `CF-Connecting-IP`, and only for Cloudflare's published ranges. Without that, phpBB, the logs, and fail2ban all see edge addresses, and `ip_check` (if you ever turn it back on) becomes a logout machine.

Keep that trusted-proxy list in sync with `tools/edge-allowlist`.

## Cookies and cache

phpBB sets a cookie on the first HTML page for guests and members. Do not force-cache `viewtopic.php` (or any page with that chrome). A URL-only cache key will leak one visitor's header to the next. See `handbook/edge.md`.

A curl test of a login form needs a cookie jar and a few seconds between GET and POST. phpBB rejects a token that is too old or from a different session.

## Object-storage media

If `images/` or `files/` is a symlink onto a FUSE or rclone mount, do not `file_exists()` walk that directory from the request path. Look the object up in the database. A missing symlink also silently disables image rewrite: the listener thinks nothing is cached and falls back to dead hotlinks.

Pin the mount binary. A distro downgrade can accept writes into a local VFS cache, fail the remote PUT, and retry forever.
