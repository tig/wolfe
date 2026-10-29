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

load_site() {
  if ! _source_if "$SITE_ENV"; then
    if _source_if "$ROOT/site/site.env.example"; then
      err "site/site.env is missing; loading the example (dry-run only)."
    else
      die "no site contract found."
    fi
  fi
  _source_if "$PINS_ENV" || _source_if "$ROOT/site/pins.env.example" || true

  local m
  for m in ${MODULES:-}; do
    _source_if "$ROOT/modules/$m/site.env" \
      || _source_if "$ROOT/modules/$m/site.env.example" \
      || true
    _source_if "$ROOT/modules/$m/pins.env" \
      || _source_if "$ROOT/modules/$m/pins.env.example" \
      || true
  done
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
    mariadb-dump -u "$user" -p"$password" --single-transaction --quick "$name" >"$dest"
  else
    mysqldump -u "$user" -p"$password" --single-transaction --quick "$name" >"$dest"
  fi
}

curl_head() {
  local url="$1"
  curl -sS -o /dev/null -w '%{http_code} %{time_total}\n' --max-time 20 -I "$url" || true
}
