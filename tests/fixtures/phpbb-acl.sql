-- Minimal phpBB ACL fixture for sitemap tests.
-- Forum 1 is public. Forum 2 is private (no guest/bot f_read, no password).
-- Forum 3 is passworded even though guests and bots have f_read.

CREATE TABLE phpbb_forums (
  forum_id INTEGER,
  forum_type INTEGER,
  forum_password TEXT,
  forum_last_post_time INTEGER
);

CREATE TABLE phpbb_topics (
  topic_id INTEGER,
  forum_id INTEGER,
  topic_visibility INTEGER,
  topic_moved_id INTEGER,
  topic_posts_approved INTEGER,
  topic_last_post_time INTEGER
);

CREATE TABLE phpbb_acl_groups (
  forum_id INTEGER,
  group_id INTEGER,
  auth_role_id INTEGER
);

CREATE TABLE phpbb_acl_roles_data (
  role_id INTEGER,
  auth_option_id INTEGER,
  auth_setting INTEGER
);

CREATE TABLE phpbb_acl_options (
  auth_option_id INTEGER,
  auth_option TEXT
);

INSERT INTO phpbb_acl_options VALUES (1, 'f_read');
INSERT INTO phpbb_acl_roles_data VALUES (1, 1, 1);

INSERT INTO phpbb_forums VALUES (1, 1, '', 1000);
INSERT INTO phpbb_acl_groups VALUES (1, 1, 1);
INSERT INTO phpbb_acl_groups VALUES (1, 6, 1);
INSERT INTO phpbb_topics VALUES (10, 1, 1, 0, 5, 1000);
INSERT INTO phpbb_topics VALUES (11, 1, 1, 0, 65, 1100);

INSERT INTO phpbb_forums VALUES (2, 1, '', 2000);
INSERT INTO phpbb_topics VALUES (20, 2, 1, 0, 3, 2000);

INSERT INTO phpbb_forums VALUES (3, 1, 'secret', 3000);
INSERT INTO phpbb_acl_groups VALUES (3, 1, 1);
INSERT INTO phpbb_acl_groups VALUES (3, 6, 1);
INSERT INTO phpbb_topics VALUES (30, 3, 1, 0, 3, 3000);
