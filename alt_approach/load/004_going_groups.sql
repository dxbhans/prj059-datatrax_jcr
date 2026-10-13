SELECT DISTINCT
    c.id AS course_id,
    c.name AS course,
    m.id AS map_id,
    m.label AS map_label,
    gg.id AS goings_group_id,
    gg.label AS goings_group,
    g.id AS going_id,
    g.`order` AS going_order,
    g.label AS going,
    g.color,
    g.min AS going_min,
    g.max AS going_max
FROM tthub.goings_groups AS gg
JOIN tthub.goings AS g ON g.goings_group_id = gg.id
JOIN tthub.maps AS m ON m.goings_group_id = gg.id
JOIN tthub.courses AS c ON c.id = m.course_id
WHERE c.id = 2
ORDER BY c.name, m.label, g.`order`;
