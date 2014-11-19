USE Khan
GO

ALTER VIEW REPORTING$khan_world_of_math_totals AS
SELECT s.id AS studentid
      ,sch.abbreviation AS school
      ,s.grade_level
      ,s.first_name + ' ' + s.last_name AS name
      ,s.lastfirst
      ,r.nickname
      ,st.username
      ,CASE WHEN r.studentid IS NULL THEN 'Not Linked' ELSE 'Valid' END AS khan_valid
      ,st.points
      ,st.total_seconds_watched
      ,SUM(r.mastered_dummy) AS num_mastered
      ,SUM(r.struggling_dummy) AS num_struggling
      ,SUM(r.total_correct) AS num_correct
      ,SUM(r.total_done) AS num_done
FROM KIPP_NJ..STUDENTS s WITH (NOLOCK)
JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
  ON s.schoolid = sch.school_number
 AND s.enroll_status = 0
 AND s.grade_level >= 5
 --AND s.grade_level <= 8
 AND s.grade_level <= 12
LEFT OUTER JOIN Khan..REPORTING$khan_world_of_math#long#static r
  ON s.id = r.studentid
LEFT OUTER JOIN Khan..stu_detail#identifiers st
  ON s.id = st.studentid
GROUP BY s.id
        ,sch.abbreviation
        ,s.grade_level
        ,s.first_name + ' ' + s.last_name
        ,s.lastfirst
        ,r.nickname
        ,st.username
        ,st.points
        ,st.total_seconds_watched
        ,r.studentid
