SELECT
    c.id AS course_id,
    c.name AS course,
    m.id AS map_id,
    m.label AS map_label,
    m.path AS map_path,
    m.goings_group_id,
    m.created_at AS map_created_at,
    m.updated_at AS map_updated_at,
    m.deleted_at AS map_deleted_at
FROM tthub.maps AS m
JOIN tthub.courses AS c ON c.id = m.course_id
WHERE c.id = 2
ORDER BY c.name, m.id;
