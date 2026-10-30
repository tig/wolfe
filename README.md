# Wolfe

Wolfe is an AI admin for a community resource. The resource is a forum, a wiki, a photo archive, or the domains and bills behind them. A volunteer custodian states a goal in plain language. The agent reads this repository and executes only what `CONSTITUTION.md` allows.

This repository is the source of truth. Continuity comes first. The VPS is one part of the resource. The job is to keep the resource alive, safe, and handed off across years and custodians.

The custodian jobs are in [`users-manual.md`](users-manual.md). Each section names the prompt, the procedure, the confirmation, and the verification.

## Tenets

The agent must read the tenets at the start of every session. The full text is in [`CONSTITUTION.md`](CONSTITUTION.md).

1. **Continuity first.** The resource outlives any admin, any agent, and any one server.
2. **The agent is a custodian, not the owner.** Humans set intent.
3. **The handbook is the source of truth. Reality wins.** If they disagree, stop and fix the handbook.
4. **Read-only by default.** Orient before you write.
5. **Confirm destructive or outward-facing work.** Recovery path first. Then an explicit yes.
6. **Operational change goes through pull requests.** Do not "just fix it on the server."

## Stack and modules

The default stack is one Linux origin behind Cloudflare, restic to S3-compatible storage, and a community-owned vault.

`modules/community/` is the first module. It adds phpBB and optional MediaWiki. It is not the product. If the resource is a different stack, set `MODULES=''` or add a module. Wolfe still covers the host, the edge, the bills, and the handoff.

## Contents

| Path | Role |
| --- | --- |
| `CONSTITUTION.md`, `AGENTS.md` | Law and session entry. |
| `users-manual.md` | Custodian jobs. |
| `site/` | Instance binding. Placeholders only in the template. |
| `handbook/` | Facts about the live system. |
| `playbooks/` | Procedures for a class of work. |
| `tools/` | Parameterized commands. Default is `--dry-run`. |
| `cadence/` | Recurring prompts. |
| `examples/` | Example prompts. |
| `modules/` | Stack overlays. `community` is first. |
| `integrity/` | Secret and identifier scan. |

Wolfe must not add a second origin, a container platform, a mail product, or a monitoring SaaS. Instance facts belong in the bound `site/site.env` and the instance handbook.

See [`DESIGN.md`](DESIGN.md) for the architecture and the differences from the private proof of concept.

## Quick start

1. Copy this repository for the instance.
2. Keep that copy private until the handbook has only placeholders or facts the owner will publish.
3. Copy `site/site.env.example` to `site/site.env`.
4. Copy `site/pins.env.example` to `site/pins.env`.
5. Replace every placeholder.
6. If the instance runs phpBB, keep `MODULES='community'` and merge `modules/community/site.env.example`.
7. If the instance does not run phpBB, set `MODULES=''`.
8. Store credentials in a community-owned vault. Docs use `<VAULT_NAME>` and item names. Values must not enter git.
9. Point an AI coding agent at the repository.
10. The agent must read `AGENTS.md` and `CONSTITUTION.md` first.
11. The first agent task is to walk the live system and fill `handbook/` from reality.
12. The second agent task is the restore drill in `playbooks/restore-drill.md`.
13. Open `users-manual.md` and schedule the cadence prompts.

The origin must have a current Linux LTS, the live web stack, a database if the app uses one, a firewall, restic, and an S3-compatible bucket. The edge default is DNS on Cloudflare, proxied. The instance also needs the registrar, the vault, and a community instrument that pays the bills.

## Tools

Every tool reads `site/site.env`. A mutating tool must receive `--yes`. Without `--yes` the tool prints a dry run.

```bash
./tools/health
./tools/maintenance --on --dry-run
./tools/backup --dry-run
./tools/integrity-scan
```

Community-module tools live under `modules/community/tools/` and use the same flags.

If a placeholder is still in the environment, the tool must exit nonzero.

## Integrity

This repository is public. The operator must run the scan before every push:

```bash
./tools/integrity-scan
```

The scan must fail on secrets, real emails, real IPs, and identifiers from the private proof of concept. The last run is in `integrity/SCAN-REPORT.md`. If the scan fails, the operator must not push.

## License

MIT. Copyright Tig Kindel. See [`LICENSE`](LICENSE).
