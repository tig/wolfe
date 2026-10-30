# Handbook

The handbook is what we believe about the live system.

Write it in the present tense. Fill every placeholder from the host in front of you. If a page and the host disagree, the host wins, and you update the page in the same pull request.

These pages are templates. They describe the *shape* of one Linux origin behind a CDN. They are not a description of any real site.

| Page | What it records |
| --- | --- |
| `architecture.md` | The moving parts and the trust boundaries. |
| `host.md` | The Linux server. |
| `edge.md` | DNS and the CDN. |
| `security.md` | Firewall, installer paths, runtime hardening. |
| `backups.md` | What restic holds, and how you know a restore works. |
| `upgrades.md` | How versions move, and where pins live. |
| `incidents.md` | The playbook, and the log of things that already happened. |
| `continuity.md` | Multi-admin handoff. Who can get in when you cannot. |

A module may add a short overlay under `modules/<name>/handbook/`. Read it after the core page it extends.

Do not put secrets, emails of people, account IDs, or origin IPs that you would not publish in a public repository. Use `<SERVER_IP>`, `<VAULT_NAME>`, and `example.org`.
