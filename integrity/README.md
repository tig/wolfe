# Integrity

This repository is public. Every branch is visible.

`scan.sh` (also `tools/integrity-scan`) looks for secrets, for private-instance identifiers, and for leftovers from the scrubbed export used to teach Wolfe. Run it before every push. The export needles are assembled in the script so this file does not list them.

```bash
./tools/integrity-scan
```

The last run writes `SCAN-REPORT.md`. A failing scan means you are not done. Do not push. If a finding already landed on the remote, stop and report it. Do not force-push as a cleanup.
