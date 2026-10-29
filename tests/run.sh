#!/usr/bin/env bash
# Wolfe unit tests. No network. No origin. Fail closed.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
notes=()

ok() {
  PASS=$((PASS + 1))
  notes+=("ok: $1")
}

bad() {
  FAIL=$((FAIL + 1))
  notes+=("FAIL: $1")
}

expect_eq() {
  local got="$1"
  local want="$2"
  local name="$3"
  if [[ "$got" == "$want" ]]; then
    ok "$name"
  else
    bad "$name (got '$got' want '$want')"
  fi
}

expect_ok() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    ok "$name"
  else
    bad "$name"
  fi
}

expect_fail() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    bad "$name (wanted failure)"
  else
    ok "$name"
  fi
}

# --- load_site: bound values survive module examples -------------------
tmp="$(mktemp -d)"
cat >"$tmp/site.env" <<'EOF'
SITE_NAME='Bound Site'
SITE_DOMAIN='bound.example.org'
MODULES='community'
WEB_ROOT='/bound'
DB_NAME='bounddb'
DB_USER='bounduser'
FORUM_DOMAIN='forums.bound.example.org'
HEALTH_URLS='https://bound.example.org/'
RESTIC_REPOSITORY='s3:https://example.org/bucket'
EOF
bound_out="$(
  export SITE_ENV="$tmp/site.env"
  export PINS_ENV="$tmp/pins.env"
  # shellcheck disable=SC1091
  source "$ROOT/tools/lib/common.sh"
  load_site
  printf '%s\n' "$FORUM_DOMAIN" "$WEB_ROOT" "$DB_NAME" "${FORUM_TABLE_PREFIX:-}" "${WIKI_ENABLED:-}"
)"
mapfile -t bound_vals <<<"$bound_out"
expect_eq "${bound_vals[0]}" "forums.bound.example.org" "bound FORUM_DOMAIN is not overwritten"
expect_eq "${bound_vals[1]}" "/bound" "bound WEB_ROOT is not overwritten"
expect_eq "${bound_vals[2]}" "bounddb" "bound DB_NAME is not overwritten"
expect_eq "${bound_vals[3]}" "phpbb_" "bound instance still fills missing FORUM_TABLE_PREFIX"
expect_eq "${bound_vals[4]}" "1" "bound instance still fills missing WIKI_ENABLED"

unbound_out="$(
  export SITE_ENV="$tmp/missing.env"
  export PINS_ENV="$tmp/missing.pins"
  # shellcheck disable=SC1091
  source "$ROOT/tools/lib/common.sh"
  load_site 2>/dev/null
  printf '%s\n' "$FORUM_DOMAIN" "$WEB_ROOT" "$DB_NAME"
)"
mapfile -t unbound_vals <<<"$unbound_out"
expect_eq "${unbound_vals[0]}" "forums.example.org" "unbound loads module example FORUM_DOMAIN"
expect_eq "${unbound_vals[1]}" "/var/www/forum" "unbound loads module example WEB_ROOT"
expect_eq "${unbound_vals[2]}" "phpbb" "unbound loads module example DB_NAME"

# --- snapshot age ------------------------------------------------------
# shellcheck disable=SC1091
source "$ROOT/tools/lib/common.sh"
expect_ok "age 10h is current vs 36h" snapshot_age_ok 10 36
expect_fail "age 40h is stale vs 36h" snapshot_age_ok 40 36
expect_fail "empty age is not ok" snapshot_age_ok "" 36
expect_eq "$(xml_escape 'https://forums.example.org/viewtopic.php?t=11&start=30')" \
  "https://forums.example.org/viewtopic.php?t=11&amp;start=30" \
  "xml_escape turns & into &amp;"

fresh="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
stale="$(date -u -d '48 hours ago' +%Y-%m-%dT%H:%M:%SZ)"
expect_ok "fresh snapshot is current" report_snapshot_age "$fresh" 36
expect_fail "48h snapshot is stale vs 36h" report_snapshot_age "$stale" 36
expect_fail "missing snapshot is a finding" report_snapshot_age "" 36

# --- sitemap ACL -------------------------------------------------------
# shellcheck disable=SC1091
source "$ROOT/modules/community/lib/sitemap.sh"
sql="$(phpbb_sitemap_sql phpbb_ 1 6)"
acl_count="$(printf '%s\n' "$sql" | grep -c "auth_option = 'f_read'" || true)"
if [[ "$acl_count" -ge 4 ]]; then
  ok "sitemap SQL applies f_read on both UNION halves"
else
  bad "sitemap SQL f_read count is $acl_count (want >= 4)"
fi

db="$tmp/phpbb.sqlite"
sqlite3 "$db" <"$ROOT/tests/fixtures/phpbb-acl.sql"
rows="$(sqlite3 -separator ' ' "$db" "$sql")"
if printf '%s\n' "$rows" | grep -qE '^forum 1 '; then
  ok "sitemap includes public forum 1"
else
  bad "sitemap missing public forum 1"
fi
if printf '%s\n' "$rows" | grep -qE '^topic 10 '; then
  ok "sitemap includes public topic 10"
else
  bad "sitemap missing public topic 10"
fi
if printf '%s\n' "$rows" | grep -qE '^topic 11 '; then
  ok "sitemap includes public topic 11"
else
  bad "sitemap missing public topic 11"
fi
if printf '%s\n' "$rows" | grep -qE 'forum 2|topic 20'; then
  bad "sitemap leaked private forum 2 or topic 20"
else
  ok "sitemap omits private forum 2 and its topics"
fi
if printf '%s\n' "$rows" | grep -qE 'forum 3|topic 30'; then
  bad "sitemap leaked passworded forum 3 or topic 30"
else
  ok "sitemap omits passworded forum 3 and its topics"
fi

# --- sitemap XML escape + parser --------------------------------------
urls="$tmp/urls.tsv"
phpbb_rows_to_urls "forums.example.org" 30 <<<"$rows" >"$urls"
if grep -q 'viewtopic.php?t=11&start=30' "$urls"; then
  ok "paginated topic URL includes start="
else
  bad "paginated topic URL missing"
fi
xml="$tmp/sitemap.xml"
write_urlset "$xml" "$urls"
if grep -q '&amp;start=30' "$xml"; then
  ok "paginated loc is XML-escaped"
else
  bad "paginated loc is not XML-escaped"
fi
if grep -E '<loc>[^<]*&start=' "$xml" >/dev/null; then
  bad "raw & remains inside a loc"
else
  ok "no raw & inside loc"
fi
if python3 -c "import xml.etree.ElementTree as ET; ET.parse('$xml')" 2>/dev/null; then
  ok "python xml parser accepts sitemap"
else
  bad "python xml parser rejected sitemap"
fi
if xmllint --noout "$xml" 2>/dev/null; then
  ok "xmllint accepts sitemap"
else
  bad "xmllint rejected sitemap"
fi

# --- backup check must fail the job -----------------------------------
check_line="$(grep -E '^restic check' "$ROOT/tools/backup" || true)"
if [[ "$check_line" == "restic check --read-data-subset=5%" ]]; then
  ok "restic check is not swallowed with ||"
else
  bad "restic check line is: $check_line"
fi
if grep -n 'restic check' "$ROOT/tools/backup" | grep -q '||'; then
  bad "restic check still has || on its line"
else
  ok "no || on a restic check line"
fi

# --- health exits non-zero when snapshot is stale ---------------------
mkdir -p "$tmp/bin" "$tmp/www"
cat >"$tmp/site.env.health" <<EOF
SITE_NAME='Health Test'
SITE_DOMAIN='bound.example.org'
MODULES=''
WEB_ROOT='$tmp/www'
HEALTH_URLS=''
SYSTEMD_UNITS='unused-unit'
RESTIC_REPOSITORY='s3:https://example.org/bucket'
RESTIC_MAX_AGE_HOURS=36
STATE_DIR='$tmp/state'
EOF
cat >"$tmp/bin/restic" <<'EOF'
#!/bin/sh
printf '%s\n' "[{\"time\":\"${MOCK_SNAPSHOT_TIME}\"}]"
EOF
chmod +x "$tmp/bin/restic"
health_env=(
  env
  "PATH=$tmp/bin:/usr/bin:/bin"
  "SITE_ENV=$tmp/site.env.health"
  "PINS_ENV=$tmp/missing.pins"
  "RESTIC_PASSWORD=dummy"
)
if MOCK_SNAPSHOT_TIME="$(date -u -d '72 hours ago' +%Y-%m-%dT%H:%M:%SZ)" \
  "${health_env[@]}" "$ROOT/tools/health" >"$tmp/health-stale.txt" 2>&1; then
  bad "health exited 0 for a stale snapshot"
else
  ok "health exits non-zero for a stale snapshot"
fi
if grep -q 'stale' "$tmp/health-stale.txt"; then
  ok "health names the stale snapshot"
else
  bad "health stale output missing 'stale'"
fi
if MOCK_SNAPSHOT_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "${health_env[@]}" "$ROOT/tools/health" >"$tmp/health-fresh.txt" 2>&1; then
  ok "health exits 0 for a fresh snapshot"
else
  bad "health exited non-zero for a fresh snapshot"
fi

# --- scan.sh covers git history ---------------------------------------
if grep -q 'gitleaks_hist_args=(detect' "$ROOT/integrity/scan.sh"; then
  ok "scan.sh runs gitleaks on git history"
else
  bad "scan.sh missing gitleaks history invocation"
fi
if grep -q -- 'log --all -S' "$ROOT/integrity/scan.sh"; then
  ok "scan.sh pickaxes git history for custom needles"
else
  bad "scan.sh missing git log -S pickaxe"
fi
if grep -q -- '--no-git' "$ROOT/integrity/scan.sh"; then
  ok "scan.sh still scans the working tree"
else
  bad "scan.sh dropped the working-tree gitleaks scan"
fi

hist="$tmp/histrepo"
mkdir -p "$hist"
git -C "$hist" init -q
git -C "$hist" config user.email "$(printf '%s@%s' dev example.org)"
git -C "$hist" config user.name 'Wolfe Tests'
# Assemble a PEM header at runtime so this test file never contains one.
_begin='-----BEGIN'
_kind='RSA PRIVATE KEY-----'
printf '%s %s\n' "$_begin" "$_kind" >"$hist/leak.txt"
git -C "$hist" add leak.txt
git -C "$hist" commit -q -m 'add leak'
git -C "$hist" rm -q leak.txt
git -C "$hist" commit -q -m 'delete leak'
if gitleaks detect --source "$hist" --config "$ROOT/integrity/gitleaks.toml" --no-git --redact >/tmp/wolfe-test-gitleaks-tree.log 2>&1; then
  ok "gitleaks --no-git misses a deleted committed secret (the bug)"
else
  bad "gitleaks --no-git flagged a working tree that has no secret"
fi
if gitleaks detect --source "$hist" --config "$ROOT/integrity/gitleaks.toml" --log-opts '--all' --redact >/tmp/wolfe-test-gitleaks-git.log 2>&1; then
  bad "gitleaks history scan missed a deleted committed secret"
else
  ok "gitleaks history scan finds a deleted committed secret"
fi

rm -rf "$tmp"

printf '%s\n' "${notes[@]}"
echo
echo "passed: $PASS  failed: $FAIL"
if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
exit 0
