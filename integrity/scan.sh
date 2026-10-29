#!/usr/bin/env bash
# Secret and identifier scan. Fail closed. Run before every push.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REPORT="$ROOT/integrity/SCAN-REPORT.md"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FAIL=0
# Assemble the private-instance needle without storing it as one literal.
POC_A="mye"
POC_ID="${POC_A}28"

notes=()
fail() {
  FAIL=1
  notes+=("FAIL: $1")
}
ok() {
  notes+=("ok: $1")
}

# --- gitleaks (working tree) -------------------------------------------
# --no-git sees the files as they are now, including uncommitted edits.
gitleaks_out=""
gitleaks_git_out=""
if command -v gitleaks >/dev/null 2>&1; then
  if gitleaks detect --source "$ROOT" --config "$ROOT/integrity/gitleaks.toml" --no-git --redact --report-format json --report-path /tmp/wolfe-gitleaks.json >/tmp/wolfe-gitleaks.log 2>&1; then
    ok "gitleaks working tree clean"
    gitleaks_out="clean"
  else
    fail "gitleaks reported findings in the working tree (see /tmp/wolfe-gitleaks.log)"
    gitleaks_out="findings"
  fi
else
  notes+=("skip: gitleaks is not installed; custom greps still ran")
  gitleaks_out="not installed"
fi

# --- gitleaks (git history) --------------------------------------------
# --no-git misses secrets that were committed and later deleted.
# Scan the full log by default. Override with WOLFE_SCAN_GIT_LOG_OPTS
# (for example origin/main..HEAD) when you only want the push range.
if command -v gitleaks >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gitleaks_hist_args=(detect --source "$ROOT" --config "$ROOT/integrity/gitleaks.toml" --redact --report-format json --report-path /tmp/wolfe-gitleaks-git.json)
  gitleaks_hist_args+=(--log-opts "${WOLFE_SCAN_GIT_LOG_OPTS:---all}")
  if gitleaks "${gitleaks_hist_args[@]}" >/tmp/wolfe-gitleaks-git.log 2>&1; then
    ok "gitleaks git history clean"
    gitleaks_git_out="clean"
  else
    fail "gitleaks reported findings in git history (see /tmp/wolfe-gitleaks-git.log)"
    gitleaks_git_out="findings"
  fi
elif ! command -v gitleaks >/dev/null 2>&1; then
  gitleaks_git_out="not installed"
else
  notes+=("skip: not a git checkout; history scan not run")
  gitleaks_git_out="not a git checkout"
fi

# Files to scan: tracked-like tree, no .git
mapfile -t files < <(find "$ROOT" -type f \
  -not -path "$ROOT/.git/*" \
  -not -name 'SCAN-REPORT.md' \
  | sort)

# --- proof-of-concept identifier ---------------------------------------
poc_hits=0
poc_list=""
for f in "${files[@]}"; do
  rel="${f#"$ROOT"/}"
  if grep -F -i -n "$POC_ID" "$f" >/dev/null 2>&1; then
    poc_hits=$((poc_hits + 1))
    poc_list+="$rel "
  fi
done
if [[ "$poc_hits" -gt 0 ]]; then
  fail "proof-of-concept identifier present in: $poc_list"
else
  ok "proof-of-concept identifier absent"
fi

# Scrubbed-export leftovers. Assembled so this file does not contain the literals.
export_needles=()
_n="ac"; export_needles+=("${_n}me")
_n="Example"; export_needles+=("${_n}Community")
_n="<PER"; export_needles+=("${_n}SON_")
_n="onmicro"; export_needles+=("${_n}soft")
_n="chas"; export_needles+=("${_n}sis")
_n="Schalt"; export_needles+=("${_n}plan")
export_hits=""
for needle in "${export_needles[@]}"; do
  for f in "${files[@]}"; do
    rel="${f#"$ROOT"/}"
    [[ "$rel" == integrity/scan.sh ]] && continue
    if grep -F -i -n -- "$needle" "$f" >/dev/null 2>&1; then
      export_hits+="$rel:$needle "
    fi
  done
done
if [[ -n "$export_hits" ]]; then
  fail "scrubbed-export placeholder present in: $export_hits"
else
  ok "scrubbed-export placeholders absent"
fi

# --- git history pickaxe for custom needles ----------------------------
# gitleaks may not know our private-instance strings. git log -S finds
# them even after the commit that deleted the file.
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  history_hits=""
  for needle in "$POC_ID" "${export_needles[@]}"; do
    if [[ -n "$(git -C "$ROOT" log --all -S "$needle" --pretty=format:%h)" ]]; then
      history_hits+="$needle "
    fi
  done
  if [[ -n "$history_hits" ]]; then
    fail "git history still contains scrubbed identifiers: $history_hits"
  else
    ok "git history has no scrubbed identifiers"
  fi
fi

# --- emails ------------------------------------------------------------
# Allow none. example.org addresses would be the only exception we would add.
email_hits="$(grep -R -I -n -E --exclude-dir=.git --exclude=SCAN-REPORT.md \
  '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' . || true)"
if [[ -n "$email_hits" ]]; then
  fail "email address found"
  notes+=("$email_hits")
else
  ok "no email addresses"
fi

# --- IPv4 --------------------------------------------------------------
# Allow loopback and documentation ranges only (RFC 5737, RFC 1918 not needed).
ip_raw="$(grep -R -I -n -E --exclude-dir=.git --exclude=SCAN-REPORT.md \
  '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' . || true)"
ip_bad=""
if [[ -n "$ip_raw" ]]; then
  while IFS= read -r line; do
    ip="$(printf '%s\n' "$line" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1 || true)"
    [[ -z "$ip" ]] && continue
    case "$ip" in
      127.*|0.0.0.0|192.0.2.*|198.51.100.*|203.0.113.*)
        continue
        ;;
      *)
        ip_bad+="$line"$'\n'
        ;;
    esac
  done <<<"$ip_raw"
fi
if [[ -n "$ip_bad" ]]; then
  fail "non-documentation IPv4 address found"
  notes+=("$ip_bad")
else
  ok "no non-documentation IPv4 addresses"
fi

# --- PEM / key files ---------------------------------------------------
if grep -R -I -l --exclude-dir=.git --exclude=gitleaks.toml --exclude=scan.sh \
  --exclude=SCAN-REPORT.md '-----BEGIN .*PRIVATE KEY-----' . >/dev/null 2>&1; then
  fail "PEM private key material found"
else
  ok "no PEM private keys"
fi

# --- report ------------------------------------------------------------
{
  echo "# Integrity scan report"
  echo
  echo "Ran at ${STAMP} on the working tree."
  echo
  echo "gitleaks working tree: ${gitleaks_out}"
  echo "gitleaks git history: ${gitleaks_git_out}"
  echo
  echo "## Results"
  echo
  for n in "${notes[@]}"; do
    echo "- ${n}"
  done
  echo
  if [[ "$FAIL" -eq 0 ]]; then
    echo "Verdict: clean. Safe to commit and push."
  else
    echo "Verdict: dirty. Do not push."
  fi
} >"$REPORT"

printf '%s\n' "${notes[@]}"
if [[ "$FAIL" -ne 0 ]]; then
  echo "integrity scan failed; see integrity/SCAN-REPORT.md" >&2
  exit 1
fi
echo "integrity scan clean; see integrity/SCAN-REPORT.md"
exit 0
