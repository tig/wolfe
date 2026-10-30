# Cadence

These are prompts the custodian gives an agent on a schedule. The jobs behind them are in `users-manual.md`.

Paste the whole file. Do not add extra work.

| When | Prompt | Output |
| --- | --- | --- |
| Weekdays | `weekday-health.md` | A short report every time. |
| Weekly | `weekly-stewardship.md` | Report if dependencies or cost moved. Always record a one-line checked note. |
| Twice a week | `vulnerability-watch.md` | Silent unless something is serious. |
| Optional | `reports-watch.md` | Community module only. Polls new reports under the ban guard. |

Silent means the agent finishes with a single line that nothing serious showed up. The agent must not open a pull request. The agent must not ping anyone.

If a module is loaded, also check that module's pins and vendor advisories. Do not invent a second cadence.
