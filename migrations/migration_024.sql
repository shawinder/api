-- Drop unused functions that still return id,ttile without type
DROP FUNCTION IF EXISTS get_methods(thing cases, language text);
DROP FUNCTION IF EXISTS get_organizations(thing cases, language text);

--
-- Name: get_case_by_id(integer, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

DROP FUNCTION IF EXISTS get_case_by_id(id integer, language text, userid integer);

CREATE OR REPLACE FUNCTION get_case_by_id(id integer, language text, userid integer, lookup json) RETURNS full_case
    LANGUAGE sql STABLE
    AS $_$
SELECT
  id,
  type,
  title,
  get_case_localized_list('general_issues', general_issues, lookup) as general_issues,
  get_case_localized_list('specific_topics', specific_topics, lookup) as specific_topics,
  description,
  body,
  get_localized_tags($2, tags) as tags,
  location_name,
  address1,
  address2,
  city,
  province,
  postal_code,
  country,
  latitude,
  longitude,
  get_case_localized_value('scope', scope_of_influence, lookup) as scope_of_influence,
  get_components($1, language) as has_components,
  get_object_title(is_component_of, language) as is_component_of,
  full_files as files,
  full_links as links,
  photos,
  full_videos as videos,
  audio,
  start_date,
  end_date,
  ongoing,
  get_case_localized_value('time_limited', time_limited, lookup) as time_limited,
  get_case_localized_list('purposes', purposes, lookup) as purposes,
  get_case_localized_list('approaches', approaches, lookup) as approaches,
  get_case_localized_value('public_spectrum', public_spectrum, lookup) as public_spectrum,
  number_of_participants,
  get_case_localized_value('open_limited', open_limited, lookup) as open_limited,
  get_case_localized_value('recruitment_method', recruitment_method, lookup) as recruitement_method,
  get_case_localized_list('targeted_participants', targeted_participants, lookup) as targeted_participants,
  get_case_localized_list('method_types', method_types, lookup) as method_types,
  get_case_localized_list('tools_techniques_types', tools_techniques_types, lookup) as tools_techniques_types,
  get_object_title_list(specific_methods_tools_techniques, language),
  get_case_localized_value('legality', legality, lookup) as legality,
  get_case_localized_value('facilitators', facilitators, lookup) as facilitators,
  get_case_localized_value('facilitator_training', facilitator_training, lookup) as facilitator_training,
  get_case_localized_value('facetoface_online_or_both', facetoface_online_or_both, lookup) as facetoface_online_or_both,
  get_case_localized_list('participants_interactions', participants_interactions, lookup)  as participants_interactions,
  get_case_localized_list('learning_resources', learning_resources, lookup) as learning_resources,
  get_case_localized_list('decision_methods', decision_methods, lookup) as decision_methods,
  get_case_localized_list('if_voting', if_voting, lookup) as if_voting,
  get_case_localized_list('insights_outcomes', insights_outcomes, lookup) as insights_outcomes,
  get_object_title(primary_organizer, language) as primary_organizer,
  get_case_localized_list('organizer_types', organizer_types, lookup) as organizer_types,
  funder,
  get_case_localized_list('funder_types', funder_types, lookup) as funder_types,
  staff,
  volunteers,
  impact_evidence,
  get_case_localized_list('change_types', change_types, lookup) as change_types,
  get_case_localized_list('implementers_of_change', implementers_of_change, lookup) as implementers_of_change,
  formal_evaluation,
  evaluation_reports,
  evaluation_links,
  bookmarked('case', $1, $3),
  first_author($1) AS creator,
  last_author($1) AS last_updated_by,

  original_language,
  post_date,
  published,
  updated_date,
  featured,
  hidden
FROM
  cases,
  get_localized_texts($1, $2) as localized_texts
WHERE
  cases.id = $1
;
$_$;


CREATE OR REPLACE FUNCTION get_case_view_by_id(id integer, language text, userid integer) RETURNS full_case
    LANGUAGE sql STABLE
    AS $_$
  WITH localized AS (
    SELECT to_json(case_view_localized.*) as lookup FROM case_view_localized WHERE language = $2
  )
  SELECT thecase.*
  FROM localized, get_case_by_id(id, language, userid, localized.lookup) as thecase;
$_$;

CREATE OR REPLACE FUNCTION get_case_edit_by_id(id integer, language text, userid integer) RETURNS full_case
    LANGUAGE sql STABLE
    AS $_$
  WITH localized AS (
    SELECT to_json(case_edit_localized.*) as lookup FROM case_edit_localized WHERE language = $2
  )
  SELECT thecase.*
  FROM localized, get_case_by_id(id, language, userid, localized.lookup) as thecase;
$_$;

CREATE OR REPLACE FUNCTION get_case_edit_localized_values(field text, language text) RETURNS localized_value[]
  LANGUAGE sql STABLE
  AS $_$
SELECT array_agg((replace(key, field || '_value_', ''), key, value)::localized_value)
FROM (
  SELECT key, value
  FROM rotate_case_edit_localized(language)
  WHERE key LIKE field || '_value_%'
  ORDER BY key
) as values
;
$_$
