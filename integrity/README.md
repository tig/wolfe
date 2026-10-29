# Integrity

This repository is public. Every branch is visible.

`scan.sh` (also `tools/integrity-scan`) looks for secrets and for private-instance identifiers. Run it before every push.

```bash
./tools/integrity-scan
```

The last run writes `SCAN-REPORT.md`. A failing scan means you are not done. Do not push. If a finding already landed on the remote, stop and report it. Do not force-push as a cleanup.
