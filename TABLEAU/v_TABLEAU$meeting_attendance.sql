USE KIPP_NJ
GO

ALTER VIEW TABLEAU$meeting_attendance AS

WITH course_list AS (
  SELECT sectionid
        ,studentid
        ,academic_year
        ,dateenrolled
        ,dateleft
        ,period
        ,teacher_name
        ,course_name          
  FROM KIPP_NJ..PS$course_enrollments#static WITH(NOLOCK)
  WHERE schoolid = 73253
    AND course_number NOT IN ('HR','Adv')
    AND drop_flags = 0
 )

,dates AS (
  SELECT CONVERT(DATE,mem.date_value) AS date_value
        ,mem.academic_year
        ,dt.alt_name AS term
  FROM KIPP_NJ..PS$CALENDAR_DAY mem WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON mem.schoolid = dt.schoolid
   AND mem.date_value BETWEEN dt.start_date AND dt.end_date   
   AND dt.identifier = 'RT'
  WHERE mem.schoolid = 73253    
 )

--SELECT c.SECTIONID
SELECT co.STUDENTID      
      ,co.LASTFIRST
      ,co.GRADE_LEVEL
      ,co.year
      ,dt.term
      ,dt.date_value
      ,c.sectionid
      ,c.period      
      ,c.COURSE_NAME
      ,c.teacher_name
      ,m.att_code      
      ,CASE WHEN m.att_code IN ('A','AD','OSS','ISS','CS','CR','PLE','EV') THEN 1.0 ELSE 0.0 END AS is_absent
      ,CASE WHEN m.att_code IN ('T','T10') THEN 1.0 ELSE 0.0 END AS is_tardy      
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN dates dt WITH(NOLOCK)
  ON dt.date_value BETWEEN co.entrydate AND co.exitdate  
LEFT OUTER JOIN course_list c WITH(NOLOCK)
  ON co.studentid = c.studentid 
 AND dt.date_value BETWEEN c.dateenrolled AND c.dateleft
LEFT OUTER JOIN ATT_MEM$PS_ATTENDANCE_MEETING m WITH(NOLOCK)  
  ON co.studentid = m.studentid 
 AND dt.date_value = m.att_date
 AND c.sectionid = m.sectionid
WHERE co.schoolid = 73253
  AND co.rn = 1
  AND co.year >= (KIPP_NJ.dbo.fn_Global_Academic_Year() - 1)