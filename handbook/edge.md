# Edge (DNS and CDN)

Cloudflare is the public name of the site. The origin is a dumb HTTPS server that only Cloudflare can reach.

This page records the zone shape. It does not record a Cloudflare account ID or a zone ID. Those are identifiers. They live in the vault as `<VAULT_NAME>/cloudflare-api` if an API token exists at all.

## Zone

- Zone name: `example.org`.
- Apex or app record: `example.org` (or the name in `SITE_DOMAIN`) is a proxied `A` (or `CNAME`) to the origin.
- Extra hostnames: listed here when a module adds them (forum and wiki, or `www`).

Orange-cloud (proxied) is required for every name that serves people. Grey-cloud exposes the origin and fights the firewall.

## TLS

Cloudflare terminates public TLS. The origin has its own certificate (origin CA, or a public cert if you insist) so the hop from Cloudflare to origin is HTTPS.

Set the zone SSL mode to **Full (strict)** once the origin certificate is in place. Flexible SSL is a misconfiguration.

## Cache

Most authenticated web apps are cookie-bound HTML. Do not cache `/` as if it were a brochure.

Bypass cache for session cookies. Cache only what you have measured: public static assets, and a sitemap if it is not personalized.

## What the agent may not do without a yes

1. Change nameservers or move the zone.
2. Flip proxy on or off.
3. Change SSL mode.
4. Create or delete records that point at `<SERVER_IP>`.
5. Purge the whole cache as a "just in case."

A single-file purge after a static deploy is ordinary work. Say so, then do it.

## Worked example (scrubbed)

A one-host site served an application on `example.org` and an optional second vhost on a subdomain, both orange-clouded to one origin. Full (strict) TLS. Cache bypassed on the login cookies. That shape is enough.
