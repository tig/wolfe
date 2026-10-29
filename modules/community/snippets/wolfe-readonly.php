<?php
/**
 * MediaWiki read-only snippet for Wolfe.
 *
 * In LocalSettings.php:
 *   require_once __DIR__ . '/wolfe-readonly.php';
 *
 * When WIKI_DOCROOT/maintenance.lock exists, the wiki is read-only.
 */
$wolfeLock = __DIR__ . '/maintenance.lock';
if (is_file($wolfeLock)) {
    $wgReadOnly = 'The wiki is in maintenance. Try again shortly.';
}
