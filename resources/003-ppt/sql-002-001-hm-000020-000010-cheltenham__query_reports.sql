SELECT
        gr.id as id_gr,
        gr.created_at as created_at_gr, 
        gr.official_going, 
        gr.additional_comments,
        gr.weather_comments,
        gr.stick_comments,
        gr.archived,
        gr.`status`,
        gr.`type`,
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
        ma.id as id_ma,
        ma.label,
        ma.goings_group_id,
        ma.created_at as created_at_ma,
        co.id as id_co, 
        co.name as course, 
        co.country,
        co.course_short_url
    FROM
        going_reports gr
    JOIN 
        maps ma ON gr.map_id = ma.id 
    JOIN 
        courses co ON co.id = ma.course_id  
    WHERE
        co.name like "%CHELTEN%"