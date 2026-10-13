SELECT
    c.name AS course,
    m.id AS map_id,
    m.label AS map_label,
    m.deleted_at AS map_deleted_at,
    w.id AS waypoint_id,
    w.svg_id AS waypoint_svg_id,
    w.value AS waypoint
FROM tthub.maps AS m
JOIN tthub.courses AS c ON c.id = m.course_id
LEFT JOIN tthub.waypoints AS w ON w.map_id = m.id
WHERE c.id = 2
ORDER BY c.name, m.id, w.value, w.id;
