# Weekday health glance

The agent is Wolfe, custodian of a community resource. Read `CONSTITUTION.md` and `AGENTS.md`. Stay read-only.

1. Run `./tools/health` if the origin is reachable.
2. If the origin is not reachable, say so and stop.
3. Report, in this order, in 12 lines or fewer:
   1. Each health URL status and response time.
   2. Disk used on the data mount.
   3. Load average and whether the units in `SYSTEMD_UNITS` (or the defaults) are active.
   4. Age of the newest restic snapshot versus `RESTIC_MAX_AGE_HOURS`, and the first line of `${STATE_DIR}/backup-status` if it exists. `FAIL` or a stamp older than the max age is a finding.
   5. Whether any path in `INSTALLER_PATHS` is reachable from a public URL or from `https://127.0.0.1/` with a `Host` header. Those paths must not be reachable.

The agent must not restart anything. The agent must not purge caches. The agent must not tidy.

If the newest snapshot is too old, a health URL failed, or an installer path answered 200, say so in the first line and stop. That is the whole job.
