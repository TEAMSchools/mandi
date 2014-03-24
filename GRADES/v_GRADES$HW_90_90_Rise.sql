USE KIPP_NJ
GO

ALTER VIEW GRADES$HW_90_90#Rise AS
WITH roster AS
    (
     SELECT s.id AS studentid
           ,s.lastfirst
           ,s.first_name + ' ' + s.last_name AS stu_name
           ,s.grade_level
           ,cc.course_number
     FROM KIPP_NJ..STUDENTS s
     JOIN KIPP_NJ..CC cc
       ON s.id = cc.studentid
      AND cc.dateenrolled <= CAST(GETDATE() AS date)
      AND cc.dateleft >= CAST(GETDATE() AS date)
     WHERE s.schoolid = 73252
       AND s.enroll_status = 0)

SELECT sub.*
      ,CASE
         WHEN cur_q >= 90 AND cur_h >= 90 THEN 'Above'
         WHEN cur_q < 70 OR cur_h < 70 THEN 'Below'
         WHEN cur_q >= 70 AND cur_h >= 70 THEN 'Middle'
       END AS cur_ninety_ninety_status
      ,CASE
         WHEN yr_q >= 90 AND yr_h >= 90 THEN 'Above'
         WHEN yr_q < 70 OR yr_h < 70 THEN 'Below'
         WHEN yr_q >= 70 AND yr_h >= 70 THEN 'Middle'
       END AS yr_ninety_ninety_status
FROM
      (
       SELECT roster.studentid
             ,roster.lastfirst
             ,roster.stu_name
             ,roster.grade_level
             /*--UPDATE FOR CURRENT TERM--*/ 
             ,CAST(ROUND(AVG(q.grade_3), 0) AS FLOAT) AS cur_q
             ,CAST(ROUND(AVG(h.grade_3), 0) AS FLOAT) AS cur_h
             ,CAST(ROUND(AVG(q.simple_avg), 0) AS FLOAT) AS yr_q
             ,CAST(ROUND(AVG(h.simple_avg), 0) AS FLOAT) AS yr_h
             ,COUNT(*) AS n
       FROM roster
       JOIN KIPP_NJ..GRADES$elements q
         ON roster.studentid = q.studentid
        AND roster.course_number = q.course_number
        AND q.yearid = 23
        AND q.pgf_type = 'Q'

       JOIN KIPP_NJ..GRADES$elements h
         ON roster.studentid = h.studentid
        AND roster.course_number = h.course_number
        AND h.yearid = 23
        AND h.pgf_type = 'H'

       GROUP BY roster.studentid
               ,roster.lastfirst
               ,roster.stu_name
               ,roster.grade_level
       ) sub