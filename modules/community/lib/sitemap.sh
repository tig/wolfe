# phpBB public-sitemap helpers.
# shellcheck shell=bash

# GUESTS and BOTS both need f_read. Do not hard-code private forum ids.
phpbb_acl_f_read() {
  local prefix="$1"
  local group_id="$2"
  cat <<SQL
EXISTS (
    SELECT 1 FROM ${prefix}acl_groups g
    JOIN ${prefix}acl_roles_data rd ON rd.role_id = g.auth_role_id
    JOIN ${prefix}acl_options o ON o.auth_option_id = rd.auth_option_id
    WHERE g.forum_id = f.forum_id AND g.group_id = ${group_id}
      AND o.auth_option = 'f_read' AND rd.auth_setting = 1
  )
SQL
}

phpbb_sitemap_sql() {
  local prefix="$1"
  local guest_id="$2"
  local bots_id="$3"
  local guests_acl bots_acl
  guests_acl="$(phpbb_acl_f_read "$prefix" "$guest_id")"
  bots_acl="$(phpbb_acl_f_read "$prefix" "$bots_id")"
  cat <<SQL
SELECT 'forum' AS kind, f.forum_id AS id, 0 AS extra, f.forum_last_post_time AS ts
FROM ${prefix}forums f
WHERE f.forum_type = 1
  AND f.forum_password = ''
  AND ${guests_acl}
  AND ${bots_acl}
UNION ALL
SELECT 'topic', t.topic_id, t.topic_posts_approved, t.topic_last_post_time
FROM ${prefix}topics t
JOIN ${prefix}forums f ON f.forum_id = t.forum_id
WHERE t.topic_visibility = 1
  AND t.topic_moved_id = 0
  AND f.forum_password = ''
  AND f.forum_type = 1
  AND ${guests_acl}
  AND ${bots_acl}
ORDER BY ts DESC;
SQL
}

phpbb_rows_to_urls() {
  local domain="$1"
  local ppp="${2:-30}"
  local kind id extra ts lastmod start
  while read -r kind id extra ts; do
    [[ -z "$kind" ]] && continue
    lastmod="$(date -u -d "@${ts:-0}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)"
    if [[ "$kind" == "forum" ]]; then
      printf 'https://%s/viewforum.php?f=%s\t%s\n' "$domain" "$id" "$lastmod"
    else
      printf 'https://%s/viewtopic.php?t=%s\t%s\n' "$domain" "$id" "$lastmod"
      if [[ "${extra:-0}" -gt "$ppp" ]]; then
        start="$ppp"
        while [[ "$start" -lt "$extra" ]]; do
          printf 'https://%s/viewtopic.php?t=%s&start=%s\t%s\n' "$domain" "$id" "$start" "$lastmod"
          start=$((start + ppp))
        done
      fi
    fi
  done
}

write_urlset() {
  local out="$1"
  local src="$2"
  local loc lastmod
  {
    printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
    printf '%s\n' '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    while IFS=$'\t' read -r loc lastmod; do
      [[ -z "$loc" ]] && continue
      printf '  <url><loc>%s</loc><lastmod>%s</lastmod></url>\n' "$(xml_escape "$loc")" "$(xml_escape "$lastmod")"
    done <"$src"
    printf '%s\n' '</urlset>'
  } >"$out"
}

write_sitemap_index() {
  local out="$1"
  local domain="$2"
  local shards="$3"
  local n=1
  {
    printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>'
    printf '%s\n' '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    while [[ "$n" -le "$shards" ]]; do
      printf '  <sitemap><loc>%s</loc></sitemap>\n' "$(xml_escape "https://${domain}/sitemap-${n}.xml")"
      n=$((n + 1))
    done
    printf '%s\n' '</sitemapindex>'
  } >"$out"
}
