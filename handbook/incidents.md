# Incidents

This page is the playbook and the log.

When something is on fire, you do not open a design discussion. You follow the steps, then you write down what happened.

## Severity

1. **The site is down or serving the wrong thing.** Restore service. Then write.
2. **The site is up and data is at risk.** Take it into maintenance. Then decide.
3. **The site is up and you are uneasy.** Stay read-only. Gather facts.

## First moves

1. Do not reboot the origin as a reflex.
2. Check Cloudflare: is the zone proxied, is the origin marked healthy, is there a challenge page you did not expect.
3. From your own network, `curl -I` the health URLs. Then curl the origin over SSH (`curl -I https://127.0.0.1/`) so you know which side is failing.
4. Disk, memory, and the systemd units in `handbook/host.md`.
5. The newest restic snapshot age. If you are about to do anything destructive, you need one you trust.

## Decision

If the origin is compromised (webshell, unknown admin user, unexpected installer path present, code that is not yours), do not "clean it in place." Take a snapshot for evidence, take the site down, restore to a new host from a snapshot *before* the compromise, rotate every secret in `<VAULT_NAME>` that the origin could see, and treat the old host as burned.

If the origin is sick but yours (disk full, runtime wedged, certificate expired), fix the cause, stay on this host, and record it.

If the edge is the problem (DNS, SSL mode, a bad cache rule), fix the edge and leave the origin alone.

## Known failure modes (do not rediscover these)

**Scrape flood.** Origin load spikes, PHP children pin, HTTPS accept queue fills, public TTFB goes multi-second. fail2ban stays at zero bans. Per-IP rate limits barely move the needle. Challenge the expensive paths at the CDN, or turn on Under Attack, then step down. See `handbook/edge.md`.

**Cached HTML leak.** A member sees another member's name, inbox badge, or notification chrome on a public page, but cannot act as them. Bypass cache for that path. Purge the zone. Do not "fix" it by caching harder.

**Silent session deaths.** Logins fail with "form invalid," or members drop while posting, especially behind a CDN. Check `form_token_sid_guests`, `ip_check`, `browser_check`, `server_name`, and whether the origin sees real client IPs. See `modules/community/playbooks/sessions-and-cookies.md`.

**Missed backup.** Status file says `FAIL`, or the newest snapshot is older than `RESTIC_MAX_AGE_HOURS`. That is an incident even if the site is up.

**Installer 200.** An overlay upgrade left `/install/` or `/mw-config/` reachable. 403 it now. Then write it down.

## Outward-facing

Do not post a public status note, mail the users, or email a vendor until a human says yes. Draft the text. Wait.

## Log

Write newest first. Scrub identifiers if this handbook might be published.

### Template

```
## <YYYY-MM-DD>  <one-line title>

- Severity: down | data | uneasy.
- What we saw:
- What we did:
- What we changed in the handbook:
- Follow-up:
```

### Entries

(none yet)
