SELECT
    c.name AS course,
    m.id AS map_id,
    m.label AS map_label,
    t.id AS track_id,
    t.name AS track_name,
    s.id AS section_id,
    s.area AS section_area,
    s.name AS section_name,
    s.way_points AS section_waypoints
FROM tthub.maps AS m
JOIN tthub.courses AS c ON c.id = m.course_id
LEFT JOIN tthub.tracks AS t ON t.map_id = m.id
LEFT JOIN tthub.sections AS s ON s.track_id = t.id
WHERE c.id = 2
ORDER BY c.name, m.id, t.id, s.id;
