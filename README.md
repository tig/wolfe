# Wolfe

You look after an online community resource you did not necessarily build and will not own forever. A forum. A wiki. A photo archive. The domains and the bills behind them.

You are one tired volunteer. The last admin's knowledge walked out with them. A scammer is in the reports queue. A patch is out. The card on the registrar expires this month. The next custodian cannot read your head.

Wolfe is the AI admin you talk to in plain language. This repository is the source of truth. Continuity comes first. The tenets in [`CONSTITUTION.md`](CONSTITUTION.md) keep the agent a custodian, not the owner.

The VPS is one part. The job is keeping the resource alive, safe, and handed off cleanly, across years and across custodians.

I named it after Winston Wolfe. He solves problems. He does not become the owner of the situation.

The jobs you actually do are in [`users-manual.md`](users-manual.md). Say the thing. The page tells you what the agent will do, what it will confirm with you, and how you check the result.

## Tenets

An agent reads these every session. The full text is in the constitution.

1. **Continuity first.** The resource outlives any admin, any agent, and any one server.
2. **The agent is a custodian, not the owner.** Humans set intent.
3. **The handbook is the source of truth. Reality wins.** If they disagree, stop and fix the handbook.
4. **Read-only by default.** Orient before you write.
5. **Confirm destructive or outward-facing work.** Recovery path first. Then an explicit yes.
6. **Operational change goes through pull requests.** Do not "just fix it on the server."

## Stack and modules

The worked default is one Linux origin behind Cloudflare, restic to S3-compatible storage, and a community-owned vault.

phpBB, with optional MediaWiki, is the first module (`modules/community/`). It is not the product. If the resource is something else, leave `MODULES` empty, or write the next module. You still use Wolfe for the host, the edge, the bills, and the handoff.

## What you get

A charter the agent has to read (`AGENTS.md`, `CONSTITUTION.md`).

A site contract with placeholders, not your hostnames (`site/`).

A handbook you fill from the live system (`handbook/`).

A users' manual for the custodian (`users-manual.md`).

Playbooks and parameterized tools (`playbooks/`, `tools/`). `--dry-run` is the default.

Plain-language cadence for a weekday glance, a weekly cost and pin check, and a twice-weekly vulnerability watch (`cadence/`).

A first module for a phpBB forum with an optional MediaWiki wiki (`modules/community/`).

A secret and identifier scan you run before every push (`integrity/`).

What you do not get: a second origin, a container platform, a mail product, or a monitoring SaaS. Instance facts stay in *your* `site/site.env` and *your* handbook.

## Layout

| Layer | Path | Job |
| --- | --- | --- |
| Charter | `CONSTITUTION.md`, `AGENTS.md` | Law, and the session entry. |
| Users' manual | `users-manual.md` | Task-oriented jobs for the custodian. |
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
6. First task for the agent: walk the live system and fill `handbook/` from reality. The example pages are a skeleton, not your system.
7. Second task: run the restore drill in `playbooks/restore-drill.md` before you need it.
8. Open `users-manual.md` and schedule the cadence prompts. They are deliberately boring.

You will need, on the host: a current Linux LTS, the web stack you actually run, a database if the app uses one, a firewall, restic, and an S3-compatible bucket. At the edge: DNS on Cloudflare, proxied, is the worked default. You will also need the registrar, the vault, and a community instrument that pays the bills.

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
