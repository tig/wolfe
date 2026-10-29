# Cadence

These are prompts you give an agent on a schedule. They are deliberately boring.

Paste the whole file. Do not add "and while you're at it."

| When | Prompt | Noise |
| --- | --- | --- |
| Weekdays | `weekday-health.md` | A short report every time. |
| Weekly | `weekly-stewardship.md` | Report if dependencies or cost moved. Always record a one-line "checked" in the session. |
| Twice a week | `vulnerability-watch.md` | Silent unless something is serious. |

"Silent" means the agent finishes with a single line that nothing serious showed up. It does not open a pull request, and it does not ping anyone.

If a module is loaded, also check that module's pins and vendor advisories. Do not invent a second cadence.
