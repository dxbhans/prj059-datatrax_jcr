SELECT
    gr.id AS gr_id,
    gr.user_id,
    u.user AS stick_user,
    gr.created_at AS created_at_gr,
    gr.official_going,
    gr.additional_comments,
    gr.weather_comments,
    gr.stick_comments,
    gr.archived,
    gr.status,
    gr.type,
    gr.complete,
    gr.clerk_name,
    gr.race_date,
    gr.make_date,
    gr.map_id,
    gr.track,
    gr.zone_map,
    gr.abandoned,
    gr.watering,
    gr.rails,
    gr.stalls,
    gr.version,
    gr.pdf_path,
    gr.meeting_description,
    m.id AS ma_id,
    m.label AS ma_label,
    m.goings_group_id,
    m.created_at AS created_at_ma,
    c.id AS co_id,
    c.name AS course,
    c.country,
    c.course_short_url
FROM tthub.going_reports AS gr
JOIN tthub.maps AS m ON m.id = gr.map_id
JOIN tthub.courses AS c ON c.id = m.course_id
LEFT JOIN tthub.users AS u ON u.id = gr.user_id
WHERE gr.created_at >= '2021-01-01'
  AND gr.created_at < '2027-01-01'
  AND c.id = 2;
