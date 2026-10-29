# Abuse and scrape floods

fail2ban will not save you. A farm of rotating browser user-agents hitting `viewtopic.php` does not match an SSH jail or a tiny error-log regex.

## What to do, in order

1. Stay read-only long enough to see origin request rate, PHP children, and the HTTPS accept queue. If children are pinned and TTFB is multi-second, you are in a flood.
2. At the CDN, challenge the expensive paths (`viewtopic.php`, `memberlist.php`, `search.php`). Prefer "no Cookie header" so returning members skip the interstitial.
3. If that is not enough, turn on Under Attack. Origin rate should fall within about a minute. Do not leave it on as the everyday default.
4. Step back to a high security level when origin rate stays quiet for a couple of hours and the pool is no longer pinned.
5. Toggle any public "we are under attack" banner in the same step as the edge mode.

Block known farm ranges at the CDN first (`/24` is what many plans allow). Origin deny lists are defense in depth. An origin PHP pool cannot absorb tens of 403s per second; those still cost a worker.

Do not force-cache HTML to "help" the farm. That is how you leak personalized chrome. See `handbook/edge.md`.

## What not to do

1. Do not reboot the origin as a reflex.
2. Do not add a new service.
3. Do not mass-ban members because a cookie-less challenge caught a deep link.
4. Do not publish a member's IP or a farm range in a public handbook page.
