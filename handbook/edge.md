# Edge (DNS and CDN)

Cloudflare is the public name of the site. The origin is a dumb HTTPS server that only Cloudflare can reach.

This page records the zone shape. It does not record a Cloudflare account ID or a zone ID. Those are identifiers. They live in the vault as `<VAULT_NAME>/cloudflare-api` if an API token exists at all.

## Zone

- Zone name: `example.org`.
- Apex or app record: `example.org` (or the name in `SITE_DOMAIN`) is a proxied `A` (or `CNAME`) to the origin.
- Extra hostnames: listed here when a module adds them (forum and wiki, or `www`).

Orange-cloud (proxied) is required for every name that serves people. Grey-cloud exposes the origin and fights the firewall.

## TLS

There are two hops. Visitors see the edge certificate. Cloudflare talks to the origin on a second certificate.

A valid padlock in the browser does **not** mean the origin certificate is alive. Flexible SSL hides a dead origin cert by talking HTTP to the origin. Full (no strict) hides an expired or self-signed origin cert. **Full (strict)** is the only mode that checks the origin. Use a Cloudflare Origin CA certificate (long-lived, trusted only by Cloudflare) so you do not need port 80 from the world for HTTP-01. Generate the private key on the origin. It never leaves the box.

If you still run a public CA, the DNS-01 authenticator must write to the DNS that is actually authoritative. A leftover authenticator aimed at a previous DNS host will fail forever, and the edge padlock will keep you from noticing.

## Cache

Most authenticated web apps are cookie-bound HTML. Do not cache `/` as if it were a brochure.

**Do not force-cache personalized HTML.** A cache rule that matches every GET to an application page, keyed only on the URL, will serve one member's chrome (name, inbox badge, notifications) to the next visitor. That is a privacy incident, not a session hijack. The origin `Cache-Control: private` is not enough if the rule overrides origin TTL.

Bypass cache for application HTML. Cache only what you have measured: public static assets, and a sitemap if it is not personalized.

If you ever cache guest HTML as scrape defense, the rule must exclude any request that has a `Cookie` header. Prefer not to. Scrape defense belongs in WAF and rate limits, not in cached member pages.

After a mistaken HTML cache, purge the whole zone from the dashboard if the API token cannot purge. Then leave the bypass rule in place.

## Abuse at the edge

A distributed scrape with rotating browser user-agents will not look like a bot. Per-IP rate limits and "definitely automated" challenges drop a little traffic and still wedge the origin.

What has actually worked, in order:

1. A managed challenge on the expensive paths (`viewtopic.php`, search, member lists), preferably limited to requests with no `Cookie` header so returning members skip it.
2. Cloudflare Under Attack mode when the farm is still winning. Origin request rate falls in about a minute. Do not leave it on as the steady state. Real members get an interstitial every visit.
3. Step back to a high security level once origin rate stays quiet for a couple of hours and the PHP pool is no longer pinned.

Toggle the public "we are under attack" banner in the same command as the edge mode. A dashboard-only flip leaves the banner stale.

Token scopes matter. A DNS token cannot edit firewall. Firewall Services cannot edit custom WAF rulesets. Account tokens (`cfat_`) fail `/user/tokens/verify`; test them on the zone list. User tokens (`cfut_`) verify on that endpoint.

Do not invent a fail2ban-to-Cloudflare ban path that is not wired. Check the jail config before you document it.

## What the agent may not do without a yes

1. Change nameservers or move the zone.
2. Flip proxy on or off.
3. Change SSL mode.
4. Create or delete records that point at `<SERVER_IP>`.
5. Purge the whole cache as a "just in case."

A single-file purge after a static deploy is ordinary work. Say so, then do it.

## Worked example (scrubbed)

A one-host site served an application on `example.org` and an optional second vhost on a subdomain, both orange-clouded to one origin. Full (strict) TLS. Cache bypassed on the login cookies. That shape is enough.
