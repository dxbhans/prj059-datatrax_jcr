SELECT
    DATE(s.created_at) AS sr_date,
    s.created_at AS sr_created_at,
    gr.id AS gr_id,
    gr.map_id AS gr_map_id,
    gr.status AS gr_status,
    gr.type AS gr_type,
    gr.complete AS gr_complete,
    gr.clerk_name AS gr_clerk_name,
    gr.official_going AS gr_official_going,
    gr.race_date AS gr_race_date,
    t.name AS tr_track_name,
    m.label AS ma_label,
    c.name AS course,
    s.going_report_id AS sr_going_report_id,
    s.way_point AS sr_waypoint,
    s.index AS sr_index,
    s.penetrate AS sr_penetration,
    s.shear AS sr_shear
FROM tthub.stick_readings AS s
JOIN tthub.going_reports AS gr ON gr.id = s.going_report_id
JOIN tthub.tracks AS t ON t.map_id = gr.map_id
JOIN tthub.maps AS m ON m.id = t.map_id
JOIN tthub.courses AS c ON c.id = m.course_id
WHERE s.created_at >= '2021-01-01'
  AND s.created_at < '2027-01-01'
  AND c.id = 2;
