# Design note

I built Wolfe as a framework for keeping a community resource alive across years and custodians, not as a cleaned-up copy of one community's repo.

The customer is a volunteer who looks after a forum, a wiki, a photo archive, the domains and the bills behind it. They did not necessarily build it. They will not own it forever. The VPS is one part of that job. It is not the headline.

A private proof of concept already showed that a non-technical custodian can run a real resource by talking to an agent: one origin, a web app and an optional wiki, Cloudflare at the edge, restic to S3-compatible storage, a community-owned vault. That instance is a living repo. Wolfe is the generic system any such instance can rebuild onto, including ones that are not a forum at all.

I used that proof of concept as evidence of requirements, lessons, and guardrails. I did not copy its folder layout, its document names, or its instance facts. I did not clone it, and I did not change it.

## What the proof of concept taught me

The repo has to be the brain. If a fact lives only in one admin's head, the site does not have it.

An `AGENTS.md` that is a real payload, not a pointer, is how an agent orients in one sitting.

A constitution with Continuity first is what lets a non-technical admin delegate. The useful constraints are specific: no irreversible unilateral action, a recovery path before a destructive step, verify before you act, read-only until the work requires a write.

A community-owned vault is the trust anchor. A personal vault, or secrets in the repo, collapses the model the first time an admin leaves.

The hands have to be scripts a new person can run: backup, restore, upgrade, rebuild. A prose runbook with no command is a wish.

The cheap stack is enough. One VPS, an edge in front, restic to S3-compatible storage. Adding a second service because it is fashionable is how you get a second thing that can die.

The origin should not be on the public internet. The firewall talks to the CDN. Installer paths are closed after install. The application runtime is locked down.

Upgrades are not "download latest." They are a pinned version and a checksum you verified on the vendor's site.

Docs drift. Reality wins, so noticing drift is the first job, not a cleanup pass.

Application-specific rescue tools (image proxies, scrapers, custom extensions) are instance problems. They are not framework services.

Handoff is a continuity problem. More than one admin must be able to get in. Break-glass material is split so no one person is both the bottleneck and the unilateral actor.

The pain is bigger than one application. The forum stack taught the shape. The shape is the whole resource: the site, the host, the edge, the bills, and the next custodian.

A later, scrubbed reading of that instance's runbooks added failure modes I would not have invented: a CDN cache rule that leaked one member's HTML chrome to the next visitor; phpBB sessions that die when `ip_check` sees rotating edge addresses; a scrape farm that wedges PHP while fail2ban stays at zero; installer paths that a vhost "allow all" reopens; restic that needs a dead-man ping or it fails quietly; object-storage FUSE mounts that turn a topic page into a twenty-second `stat()`; a distro rclone that cannot write and retries millions of times; DNS-01 still aimed at a nameserver that is no longer authoritative. Those lessons live in the handbook and the community module. They did not become a second `ops/` tree.

## The architecture

Wolfe has a generic core and optional modules. Each layer has one job. An agent should be able to name the layer it is in.

1. **Charter.** `CONSTITUTION.md` is law. `AGENTS.md` is the session entry. These stay at the repository root because that is the contract AI tools already look for.

2. **Site contract.** `site/site.env` is the only place an instance puts its name, hostnames, paths, and feature flags. The template ships placeholders (`example.org`, `<SERVER_IP>`, `<VAULT_NAME>`). `MODULES` lists overlays to load. Empty means no application overlay. The host, the edge, the bills, and the handoff still apply.

3. **Handbook.** `handbook/` is the living record of *this* deployment: architecture, host, edge, security, backups, upgrades, incidents, continuity. It is written in the present tense. If it is wrong, the handbook is wrong.

4. **Playbooks.** `playbooks/` are procedures for a *class* of work. They do not know your hostname. They tell the agent which tool to run and what "done" looks like.

5. **Tools.** `tools/` are parameterized scripts. They read the site contract. They default to `--dry-run`. They refuse to run if a placeholder is still in the environment. They do not provision a vendor account.

6. **Cadence, examples, and the users' manual.** `cadence/` is the plain-language prompts for recurring work. `examples/prompts.md` is how a human talks to the agent, and what the agent should do with each request. `users-manual.md` is the task-oriented menu for the custodian: what to say, what happens, what waits for a yes, and how to verify.

7. **Modules.** A module is a stack-specific overlay: extra contract keys, extra playbooks, extra tools. `modules/community/` is the first fully worked module (phpBB, optional MediaWiki). The core must still make sense if you delete `modules/`.

Integrity is a peer of those layers, not an afterthought. `integrity/` scans for secrets and instance identifiers. This repository is public. A leaked token in a "generic" template is still a leaked token.

```
charter        CONSTITUTION.md, AGENTS.md
     |         law and session entry
     v
site contract  site/site.env, MODULES=...
     |         the only instance-specific binding
     v
handbook       what is true about the live system
playbooks      how a class of work is done
tools          the commands the playbooks name
     |
     +-- modules/<name>   overlay for one stack
cadence        recurring prompts
examples       how humans ask
users-manual   task-oriented jobs for the custodian
integrity      keep the public tree clean
```

## How this differs from the proof-of-concept repo, and why

The proof of concept is a living instance. It mixes community lore, real host facts, vendor-shaped rebuild steps, and scripts under one operations bucket. That is the right shape for *one* community that already exists.

Wolfe is the thing you start from, and the thing an instance repo can later rebuild onto. A framework that mirrors an instance's folder names teaches the next agent to look for a vendor-specific rebuild and a firewall directory named after one tool. I will not do that.

Differences I chose on purpose:

1. **The product is a custodian for a community resource, not a forum installer.** The proof of concept is a board. Wolfe is the pain around keeping that kind of resource alive and handed off. The VPS is in the stack. The forum stack is module one.

2. **Handbook vs playbooks vs tools, not one operations bucket.** Truth, procedure, and code rot at different speeds. Mixing them is how a script and a paragraph disagree and nobody notices.

3. **A site contract instead of constants baked into docs.** The proof of concept can say the real hostname on every page. A public framework cannot. Every script loads `site/site.env`. Every doc uses placeholders.

4. **Modules instead of a parallel product.** Optional wiki, extra databases, and application CLIs load when `MODULES` says so. They do not fork the core.

5. **No vendor-shaped rebuild.** The proof of concept's rebuild was proven on one VPS product. `tools/rebuild` is a skeleton: install the stack you documented, restore restic, apply the edge allowlist, point DNS, verify. It does not call a cloud API.

6. **No extra services.** Image-rescue, scrapers, and custom extensions stay out of core. If an instance needs them, it adds them in *its* handbook, or in a module it owns.

7. **Break-glass is a continuity pattern, not a tool I invented.** The proof of concept split recovery secrets so no one person could act alone. I documented the pattern in `handbook/continuity.md`. I did not add a secret-sharing product.

8. **An integrity scan is part of v1.** The proof of concept is private and full of real identifiers. This repo is public. The scan is how I keep it that way. Run it before every push.

## What I left out

I did not add a control plane, a container platform, a second origin, a mail product, or a monitoring SaaS. Those are services.

I did not add a generic plugin marketplace or a theme kit. This is operations, not product.

I did not pretend the agent can buy a VPS or open a Cloudflare account. Humans do one-time account work. The agent takes it from a bound site contract.
