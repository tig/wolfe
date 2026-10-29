# Wolfe

Winston Wolfe is the one you call at four in the morning. The car is a mess. He does not become your friend. He does not take the car home. He solves the problem and leaves you with a clean driveway.

I named this after that.

A Linux VPS becomes a pain the same way. PHP needs a bump. The certificate is five days from expiry. The domain sits on a card that already died. The one person who knew the passwords is gone. The site is still there. Nobody can touch it safely.

> **Wolfe** is the custodian you call when a self-hosted Linux VPS is a pain. You tell an AI agent what you want. The agent reads the handbook, proposes a plan, and makes the pain go away, without becoming the owner.

The human sets the goal. The agent orients and executes. The human approves anything destructive or outward-facing. A community-owned vault holds the secrets. The next admin can pick this repository up and continue.

This is not a hosting product. It is the brain, the hands, and the rules.

phpBB, with optional MediaWiki, is the first fully worked **module**. It is not the product. If your VPS runs something else, you still use Wolfe. You leave the community module off, or you write the next one.

## Philosophy

These are the tenets. The full text is in [`CONSTITUTION.md`](CONSTITUTION.md). An agent reads them every session.

1. **Continuity first.** The site outlives any admin, any agent, and any one server.
2. **The agent is a custodian, not the owner.** Humans set intent.
3. **The handbook is the source of truth. Reality wins.** If they disagree, stop and fix the handbook.
4. **Read-only by default.** Orient before you write.
5. **Confirm destructive or outward-facing work.** Recovery path first. Then an explicit yes.
6. **Operational change goes through pull requests.** Do not "just fix it on the server."

## What you get

A charter the agent has to read (`AGENTS.md`, `CONSTITUTION.md`).

A site contract with placeholders, not your hostnames (`site/`).

A handbook you fill from the live host (`handbook/`).

Playbooks and parameterized tools for the jobs every VPS actually has: health, maintenance, pinned upgrades, restic backup to S3-compatible storage, a restore drill, a rebuild skeleton, an edge allowlist (`playbooks/`, `tools/`).

Plain-language routines for a weekday health glance, a weekly dependency and cost check, and a twice-weekly vulnerability watch that stays silent unless something is serious (`cadence/`).

An examples file that shows what a human says and what the agent should do (`examples/prompts.md`).

A first module for a phpBB forum with an optional MediaWiki wiki (`modules/community/`).

A secret and identifier scan you run before every push (`integrity/`).

## What you do not get

A second origin, a container platform, a mail product, or a monitoring SaaS.

A copy of anyone's live site. Instance facts stay in *your* `site/site.env` and *your* handbook.

Application-specific rescue tools. Those belong in a module, or in your private instance fork, not in the Wolfe core.

## Layout

| Layer | Path | Job |
| --- | --- | --- |
| Charter | `CONSTITUTION.md`, `AGENTS.md` | Law, and the session entry. |
| Site contract | `site/` | The only instance binding. |
| Handbook | `handbook/` | What is true about the live system. |
| Playbooks | `playbooks/` | How a class of work is done. |
| Tools | `tools/` | Parameterized commands. `--dry-run` by default. |
| Cadence | `cadence/` | Recurring prompts. |
| Examples | `examples/` | How a human asks. |
| Modules | `modules/` | Stack-specific overlays. `community` is first. |
| Integrity | `integrity/` | Secret and identifier scan. |

The architecture, and how it differs from the private proof of concept that taught me these requirements, is in [`DESIGN.md`](DESIGN.md).

## Quick start

1. Copy this repository for your site. Keep that copy private until the handbook has only placeholders or facts you are willing to publish.
2. Copy `site/site.env.example` to `site/site.env` and `site/pins.env.example` to `site/pins.env`. Replace every placeholder.
3. If you run phpBB (and optionally MediaWiki), keep `MODULES='community'` and merge the fragment in `modules/community/site.env.example`. If you do not, set `MODULES=''`.
4. Put credentials in a **community-owned** password vault, not a personal one. Docs refer to `<VAULT_NAME>` and item names. Values never enter git.
5. Point an AI coding agent at the repository. The first thing it must read is `AGENTS.md` and `CONSTITUTION.md`.
6. First task for the agent: walk the live host and fill `handbook/` from reality. The example pages are a skeleton, not your system.
7. Second task: run the restore drill in `playbooks/restore-drill.md` before you need it.
8. Schedule the three cadence prompts. They are deliberately boring.

You will need, on the host: a current Linux LTS, the web stack you actually run, a database if the app uses one, a firewall, restic, and an S3-compatible bucket. At the edge: DNS on Cloudflare, proxied, is the worked default.

## Using the tools

Every tool reads `site/site.env`. Every mutating tool wants `--yes` and otherwise prints a dry run.

```bash
./tools/health
./tools/maintenance --on --dry-run
./tools/backup --dry-run
./tools/integrity-scan
```

Community-module tools live under `modules/community/tools/` and work the same way.

If a placeholder is still in the environment, the tool exits. That is the point.

## Integrity

This repository is public. Before every push:

```bash
./tools/integrity-scan
```

The scan fails on secrets, on real emails and IPs, and on identifiers from the private proof of concept. The last run is recorded in `integrity/SCAN-REPORT.md`. If the scan fails, you are not done. Do not push.

## License

MIT. Copyright Tig Kindel. See [`LICENSE`](LICENSE).
