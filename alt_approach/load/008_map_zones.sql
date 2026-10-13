SELECT
    c.name AS course,
    m.id AS map_id,
    m.label AS map_label,
    z.id AS zone_id,
    z.name AS zone_name,
    z.way_points AS zone_waypoints
FROM tthub.maps AS m
JOIN tthub.courses AS c ON c.id = m.course_id
LEFT JOIN tthub.zones AS z ON z.map_id = m.id
WHERE c.id = 2
ORDER BY c.name, m.id, z.id;
