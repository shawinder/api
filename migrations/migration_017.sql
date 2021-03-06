-- Take a localization table and return a table of key/value pairs
-- Probably better as a view or materialized view?
CREATE OR REPLACE FUNCTION rotate_case_view_localized(language text) RETURNS table(key text, value text)
  LANGUAGE sql STABLE
  AS $_$
WITH localized as
  (SELECT to_json(case_view_localized.*) as lookup FROM case_view_localized WHERE language = language)
select key,value from (select (json_each_text(lookup)).* from localized) as a;
$_$;

-- Take a localization table and return a table of key/value pairs
-- Probably better as a view or materialized view?
CREATE OR REPLACE FUNCTION rotate_case_edit_localized(language text) RETURNS table(key text, value text)
  LANGUAGE sql STABLE
  AS $_$
WITH localized as
  (SELECT to_json(case_edit_localized.*) as lookup FROM case_edit_localized WHERE language = language)
select key,value from (select (json_each_text(lookup)).* from localized) as a;
$_$;

-- Take a localization table and return a table of key/value pairs
-- Probably better as a view or materialized view?
CREATE OR REPLACE FUNCTION rotate_tags_localized(language text) RETURNS table(key text, value text)
  LANGUAGE sql STABLE
  AS $_$
WITH localized as
  (SELECT to_json(tags_localized.*) as lookup FROM tags_localized WHERE language = language)
select key,value from (select (json_each_text(lookup)).* from localized) as a;
$_$;

-- Take a localization table and return a table of key/value pairs
-- Probably better as a view or materialized view?
CREATE OR REPLACE FUNCTION rotate_layout_localized(language text) RETURNS table(key text, value text)
  LANGUAGE sql STABLE
  AS $_$
WITH localized as
  (SELECT to_json(layout_localized.*) as lookup FROM layout_localized WHERE language = language)
select key,value from (select (json_each_text(lookup)).* from localized) as a;
$_$;
