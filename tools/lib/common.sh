# shared helpers for Wolfe tools.
# shellcheck shell=bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SITE_ENV="${SITE_ENV:-$ROOT/site/site.env}"
PINS_ENV="${PINS_ENV:-$ROOT/site/pins.env}"
DRY_RUN=1
ASSUME_YES=0

log() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }
die() { err "$*"; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

is_placeholder() {
  local v="${1:-}"
  [[ -z "$v" ]] && return 0
  [[ "$v" == '<'*'>' ]] && return 0
  return 1
}

require_value() {
  local name="$1"
  local value="${2-}"
  if is_placeholder "$value"; then
    die "$name is unset or still a placeholder. Bind site/site.env."
  fi
}

wiki_enabled() {
  [[ "${WIKI_ENABLED:-0}" == "1" ]]
}

_source_if() {
  local file="$1"
  if [[ -f "$file" ]]; then
    # shellcheck disable=SC1090
    source "$file"
    return 0
  fi
  return 1
}

# Source KEY=value lines only when that key is unset or empty.
# Bound site.env must win over module examples.
_source_fill_missing() {
  local file="$1"
  local line key
  [[ -f "$file" ]] || return 1
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    key="${line%%=*}"
    key="${key//[[:space:]]/}"
    [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    if [[ -z "${!key:-}" ]]; then
      # shellcheck disable=SC2163,SC1090
      eval "$line"
    fi
  done <"$file"
  return 0
}

load_site() {
  local site_bound=0
  if _source_if "$SITE_ENV"; then
    site_bound=1
  elif _source_if "$ROOT/site/site.env.example"; then
    err "site/site.env is missing; loading the example (dry-run only)."
  else
    die "no site contract found."
  fi
  if [[ "$site_bound" == "1" ]]; then
    _source_if "$PINS_ENV" || _source_fill_missing "$ROOT/site/pins.env.example" || true
  else
    _source_if "$PINS_ENV" || _source_if "$ROOT/site/pins.env.example" || true
  fi

  local m
  for m in ${MODULES:-}; do
    if [[ -f "$ROOT/modules/$m/site.env" ]]; then
      _source_if "$ROOT/modules/$m/site.env"
    elif [[ "$site_bound" == "1" ]]; then
      _source_fill_missing "$ROOT/modules/$m/site.env.example" || true
    else
      _source_if "$ROOT/modules/$m/site.env.example" || true
    fi
    if [[ -f "$ROOT/modules/$m/pins.env" ]]; then
      _source_if "$ROOT/modules/$m/pins.env"
    elif [[ "$site_bound" == "1" ]]; then
      _source_fill_missing "$ROOT/modules/$m/pins.env.example" || true
    else
      _source_if "$ROOT/modules/$m/pins.env.example" || true
    fi
  done
}

# Hours between an ISO-8601 UTC timestamp and now. Empty/unparseable -> empty.
hours_since() {
  local ts="${1:-}"
  local then now
  [[ -n "$ts" ]] || return 1
  then="$(date -u -d "$ts" +%s 2>/dev/null)" || return 1
  now="$(date -u +%s)"
  printf '%s' "$(( (now - then) / 3600 ))"
}

# 0 if age_hours is a number <= max_hours.
snapshot_age_ok() {
  local age_hours="${1:-}"
  local max_hours="${2:-36}"
  [[ "$age_hours" =~ ^[0-9]+$ ]] || return 1
  [[ "$max_hours" =~ ^[0-9]+$ ]] || return 1
  [[ "$age_hours" -le "$max_hours" ]]
}

# Log latest snapshot age. Return 1 when the stamp is missing, unparseable, or stale.
report_snapshot_age() {
  local latest="${1:-}"
  local max_hours="${2:-${RESTIC_MAX_AGE_HOURS:-36}}"
  local age
  if [[ -z "$latest" ]]; then
    err "restic latest: unavailable. That is a finding."
    return 1
  fi
  age="$(hours_since "$latest")" || {
    err "restic latest timestamp is unparseable: $latest"
    return 1
  }
  log "restic latest: $latest (${age}h old, max ${max_hours}h)"
  if snapshot_age_ok "$age" "$max_hours"; then
    return 0
  fi
  err "restic snapshot is stale: ${age}h > ${max_hours}h. That is a finding."
  return 1
}

# Escape text for an XML text node. Ampersand first.
xml_escape() {
  local s="${1:-}"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  s="${s//\"/&quot;}"
  s="${s//\'/&apos;}"
  printf '%s' "$s"
}

parse_args() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=1 ;;
      --yes) DRY_RUN=0; ASSUME_YES=1 ;;
      --help|-h) usage; exit 0 ;;
    esac
  done
}

require_yes() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "dry-run: no changes. Re-run with --yes after a human confirms."
    return 0
  fi
  if [[ "$ASSUME_YES" != "1" ]]; then
    die "refusing to change the origin without --yes."
  fi
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "dry-run: $*"
    return 0
  fi
  log "+ $*"
  "$@"
}

# Resolve a secret. Prefer an already-exported variable. Then a vault CLI.
# Pointers look like "<VAULT_NAME>/item" and never belong in git as values.
resolve_secret() {
  local dest_var="$1"
  local pointer_var="$2"
  local pointer="${!pointer_var:-}"
  if [[ -n "${!dest_var:-}" ]]; then
    return 0
  fi
  if command -v op >/dev/null 2>&1 && [[ "$pointer" == op://* ]]; then
    local got
    got="$(op read "$pointer")"
    printf -v "$dest_var" '%s' "$got"
    return 0
  fi
  die "$dest_var is not set. Export it from vault item ${pointer:-<unknown>}, then re-run."
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

assert_sha256() {
  local file="$1"
  local expected="$2"
  require_value "checksum" "$expected"
  [[ "$expected" =~ ^[a-fA-F0-9]{64}$ ]] || die "checksum is not a 64-char hex digest."
  local got
  got="$(sha256_of "$file")"
  [[ "$got" == "$expected" ]] || die "checksum mismatch for $file (got $got)."
}

mysql_cmd() {
  local user="$1"
  local name="$2"
  local extra=()
  if [[ -n "${3:-}" ]]; then
    extra+=(-p"$3")
  fi
  if command -v mariadb >/dev/null 2>&1; then
    mariadb -N -B -u "$user" "${extra[@]}" "$name"
  else
    mysql -N -B -u "$user" "${extra[@]}" "$name"
  fi
}

dump_db() {
  local user="$1"
  local name="$2"
  local password="$3"
  local dest="$4"
  if command -v mariadb-dump >/dev/null 2>&1; then
    mariadb-dump -u "$user" -p"$password" --single-transaction --quick --no-tablespaces "$name" | gzip -1 >"$dest"
  else
    mysqldump -u "$user" -p"$password" --single-transaction --quick --no-tablespaces "$name" | gzip -1 >"$dest"
  fi
}

curl_head() {
  local url="$1"
  curl -sS -o /dev/null -w '%{http_code} %{time_total}\n' --max-time 20 -I "$url" || true
}
