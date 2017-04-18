WITH  related_cases AS (
  SELECT
      ARRAY(  SELECT
        ROW(case__related_cases.related_case_id,
        case__localized_texts.title)::object_reference
      FROM
        case__related_cases,
        case__localized_texts
      WHERE
        case__related_cases.case_id = ${caseId} AND
        case__related_cases.related_case_id = case__localized_texts.case_id AND
        case__localized_texts.language = ${lang}
      )
    ),

 related_methods  AS (
   SELECT
      ARRAY(  SELECT
        ROW(case__related_methods.related_method_id,
        method__localized_texts.title)::object_reference
      FROM
        case__related_methods,
        method__localized_texts
      WHERE
        case__related_methods.case_id = ${caseId} AND
        case__related_methods.related_method_id = method__localized_texts.method_id AND
        method__localized_texts.language = ${lang}
      )
    ),
related_organizations AS (
  SELECT
      ARRAY(  SELECT
        ROW(case__related_organizations.related_organization_id,
        organization__localized_texts.title)::object_reference
      FROM
        case__related_organizations,
        organization__localized_texts
      WHERE
        case__related_organizations.case_id = ${caseId} AND
        case__related_organizations.related_organization_id = organization__localized_texts.organization_id AND
        organization__localized_texts.language = ${lang}
      )
    )


SELECT
    cases.id,
    'case' as type,
    cases.original_language,
    cases.issue,
    cases.communication_mode,
    cases.communication_with_audience,
    cases.content_country,
    cases.decision_method,
    cases.end_date,
    cases.facetoface_online_or_both,
    cases.facilitated,
    cases.voting,
    cases.number_of_meeting_days,
    cases.ongoing,
    cases.post_date,
    cases.published,
    cases.start_date,
    cases.total_number_of_participants,
    cases.updated_date,
    cases.targeted_participant_demographic,
    cases.kind_of_influence,
    cases.targeted_participants_public_role,
    cases.targeted_audience,
    cases.participant_selection,
    cases.specific_topic,
    cases.staff_type,
    cases.type_of_funding_entity,
    cases.typical_implementing_entity,
    cases.typical_sponsoring_entity,
    cases.who_else_supported_the_initiative,
    cases.who_was_primarily_responsible_for_organizing_the_initiative,
    to_json(
    	COALESCE(
    		cases.location,
    		('', '', '', '', '', '', '', '', '')::geolocation
    	)
    ) AS location,
    to_json(cases.lead_image) AS lead_image,
    to_json(COALESCE(cases.other_images, '{}')) AS other_images,
    to_json(COALESCE(cases.files, '{}')) AS files,
    to_json(COALESCE(cases.videos, '{}')) AS videos,
    to_json(COALESCE(cases.tags, '{}')) AS tags,
    case__localized_texts.*,
    to_json(author_list.authors) authors,
    to_json(related_cases.array) related_cases,
    to_json(related_methods.array) related_methods,
    to_json(related_organizations.array) related_organizations
FROM
    cases,
    case__localized_texts,
    (
        SELECT
            array_agg((
                case__authors.user_id,
                case__authors.timestamp,
                users.name
            )::author) authors,
            case__authors.case_id
        FROM
            case__authors,
            users
        WHERE
            case__authors.user_id = users.id
        GROUP BY
            case__authors.case_id
    ) AS author_list,
    related_cases,
    related_methods,
    related_organizations
WHERE
    cases.id = case__localized_texts.case_id AND
    case__localized_texts.language = ${lang} AND
    author_list.case_id = cases.id AND
    cases.id = ${caseId}
;
