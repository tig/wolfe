# Design

Wolfe is a framework that keeps a community resource alive across years and custodians. Wolfe is not a cleaned-up copy of one community repository.

The operator is a volunteer who looks after a forum, a wiki, a photo archive, the domains, and the bills. The operator did not necessarily build the resource. The operator will not own it forever. The VPS is one part of the job.

A private proof of concept showed that a non-technical custodian can run a real resource by talking to an agent. That instance uses one origin, a web app and an optional wiki, Cloudflare at the edge, restic to S3-compatible storage, and a community-owned vault. That instance is a living repo. Wolfe is the generic system any such instance can rebuild onto, including instances that are not a forum.

The proof of concept is evidence of requirements, lessons, and guardrails. Wolfe must not copy its folder layout, document names, or instance facts. Wolfe must not clone it. Wolfe must not change it.

## Requirements from the proof of concept

1. The repository must hold the facts. A fact that lives only in one admin's head is not recorded.
2. `AGENTS.md` must be a real payload. An agent must be able to orient in one sitting.
3. The constitution must put continuity first. Constraints must be specific: no irreversible unilateral action, a recovery path before a destructive step, verify before act, read-only until a write is required.
4. A community-owned vault must hold secrets. A personal vault, or secrets in the repo, fails the first time an admin leaves.
5. The hands must be scripts a new person can run: backup, restore, upgrade, rebuild. A prose runbook with no command is incomplete.
6. The stack must stay small. One VPS, an edge in front, restic to S3-compatible storage. A second service is a second thing that can die.
7. The origin must not be on the public internet. The firewall must accept the CDN. Installer paths must close after install. The application runtime must be locked down.
8. An upgrade must use a pinned version and a checksum from the vendor site. An upgrade must not download "latest."
9. If the handbook and the host disagree, the host wins. Detecting drift is the first job.
10. Application-specific rescue tools (image proxies, scrapers, custom extensions) are instance problems. They are not framework services.
11. More than one admin must be able to get in. Break-glass material must be split so no one person is both the bottleneck and the unilateral actor.
12. The shape is the whole resource: the site, the host, the edge, the bills, and the next custodian.

A later scrubbed reading of that instance's runbooks added failure modes. A CDN cache rule leaked one member's HTML chrome to the next visitor. phpBB sessions die when `ip_check` sees rotating edge addresses. A scrape farm wedges PHP while fail2ban stays at zero. Installer paths reopen when a vhost says allow all. restic needs a dead-man ping or it fails quietly. Object-storage FUSE mounts turn a topic page into a 20 s `stat()`. A distro rclone can accept a write, fail the remote PUT, and retry without bound. DNS-01 can aim at a nameserver that is no longer authoritative. Those lessons live in the handbook and the community module. They must not become a second `ops/` tree.

## Architecture

Wolfe has a generic core and optional modules. Each layer has one job. An agent must be able to name the layer it is in.

1. **Charter.** `CONSTITUTION.md` is law. `AGENTS.md` is the session entry. These stay at the repository root because that is the contract AI tools already look for.
2. **Site contract.** `site/site.env` is the only place an instance puts its name, hostnames, paths, and feature flags. The template ships placeholders (`example.org`, `<SERVER_IP>`, `<VAULT_NAME>`). `MODULES` lists overlays to load. Empty means no application overlay. The host, the edge, the bills, and the handoff still apply.
3. **Handbook.** `handbook/` is the living record of this deployment: architecture, host, edge, security, backups, upgrades, incidents, continuity. It is written in the present tense. If it is wrong, the handbook is wrong.
4. **Playbooks.** `playbooks/` are procedures for a class of work. They do not know the hostname. They name the tool and the done condition.
5. **Tools.** `tools/` are parameterized scripts. They read the site contract. They default to `--dry-run`. They must refuse to run if a placeholder is still in the environment. They must not provision a vendor account.
6. **Cadence, examples, and the users' manual.** `cadence/` holds recurring prompts. `examples/prompts.md` maps a human request to the first move. `users-manual.md` lists custodian jobs: prompt, procedure, confirmation, and verification.
7. **Modules.** A module is a stack-specific overlay: extra contract keys, extra playbooks, extra tools. `modules/community/` is the first completed module (phpBB, optional MediaWiki). Automated moderation in that module must log under a dedicated bot account. A manual ban the human asked for must log under the human. The core must still work if `modules/` is deleted.

Integrity is a peer of those layers. `integrity/` scans for secrets and instance identifiers. This repository is public. A leaked token in a template is still a leaked token.

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

## Differences from the proof-of-concept repo

The proof of concept is a living instance. It mixes community lore, real host facts, vendor-shaped rebuild steps, and scripts under one operations bucket. That shape fits one community that already exists.

Wolfe is the start point. An instance repo can later rebuild onto Wolfe. A framework that mirrors an instance's folder names teaches the next agent to look for a vendor-specific rebuild and a firewall directory named after one tool. Wolfe must not do that.

1. **The product is a custodian for a community resource.** The proof of concept is a board. Wolfe covers keeping that kind of resource alive and handed off. The VPS is in the stack. The forum stack is module one.
2. **Handbook, playbooks, and tools are separate.** Truth, procedure, and code rot at different speeds. Mixing them lets a script and a paragraph disagree.
3. **A site contract holds instance constants.** The proof of concept can print the real hostname on every page. A public framework must not. Every script loads `site/site.env`. Every doc uses placeholders.
4. **Modules overlay the core.** Optional wiki, extra databases, and application CLIs load when `MODULES` says so. They must not fork the core.
5. **Rebuild is a skeleton.** The proof of concept rebuild was proven on one VPS product. `tools/rebuild` installs the documented stack, restores restic, applies the edge allowlist, waits for DNS, and verifies. It must not call a cloud API.
6. **No extra services in core.** Image-rescue, scrapers, and custom extensions stay out. An instance that needs them adds them in its handbook or in a module it owns.
7. **Break-glass is a continuity pattern.** The proof of concept split recovery secrets so no one person could act alone. The pattern is in `handbook/continuity.md`. Wolfe must not add a secret-sharing product.
8. **An integrity scan is part of v1.** The proof of concept is private and full of real identifiers. This repo is public. The operator must run the scan before every push.

## Out of scope

Wolfe must not add a control plane, a container platform, a second origin, a mail product, or a monitoring SaaS. Those are services.

Wolfe must not add a generic plugin marketplace or a theme kit. Wolfe is operations.

The agent must not buy a VPS or open a Cloudflare account. Humans do one-time account work. The agent starts from a bound site contract.
