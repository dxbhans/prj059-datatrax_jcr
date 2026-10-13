# query prepared by Tesly, extended names, tested in mysql workbench

SELECT
    date(s.created_at) as sr_date
    , s.created_at as sr_created_at
    , g.id as gr_id
    , g.map_id as gr_map_id
    , g.status as gr_status
    , g.type as gr_type
    , g.complete as gr_complete
    , g.clerk_name as gr_clerk_name
    , g.official_going as gr_official_going
    , g.race_date as gr_race_date
    , t.name AS tr_track_name 
    , m.label as ma_label
    , c.name as co_name
    , s.going_report_id as sr_going_report_id
    , s.way_point as sr_waypoint
    , s.index as sr_index
    , s.penetrate as sr_penetration
    , s.shear as sr_shear
FROM
	stick_readings s
JOIN
	going_reports g on g.id = s.going_report_id
JOIN
    tracks t on t.map_id = g.map_id	
JOIN
    maps m ON t.map_id = m.id
JOIN
    courses c ON m.course_id = c.id
WHERE 
	 c.name like "%CHELTEN%"