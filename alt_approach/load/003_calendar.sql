SELECT
    ca.calendar_id AS calendar_id,
    ca.CourseId AS course_id,
    co.name AS course,
    co.altname AS course_altname,
    co.country,
    co.code AS course_code,
    ca.MeetingDate AS meeting_date,
    ca.Code AS meeting_code,
    ca.note,
    ca.created_at,
    ca.updated_at
FROM ttmaps.calendar AS ca
JOIN ttmaps.course AS co ON co.id = ca.CourseId
WHERE ca.MeetingDate >= '2021-01-01'
  AND ca.MeetingDate < '2027-01-01'
  AND co.id = 2;
