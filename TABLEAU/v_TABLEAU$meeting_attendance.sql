USE KIPP_NJ
GO

ALTER VIEW TABLEAU$meeting_attendance AS

WITH meeting_att AS (
  SELECT studentid
        ,sectionid
        ,att_date
        ,att_code        
        ,CASE WHEN att_code IN ('A','AD','OSS','ISS','CS','CR','PLE','EV') THEN 1.0 ELSE 0.0 END AS is_absent
        ,CASE WHEN att_code IN ('T','T10') THEN 1.0 ELSE 0.0 END AS is_tardy
  FROM ATT_MEM$meeting_attendance#static WITH(NOLOCK)  
 )

,course_list AS (
  SELECT cc.SECTIONID
        ,cc.STUDENTID
        ,cc.DATEENROLLED
        ,cc.DATELEFT
        ,s.LASTFIRST
        ,s.GRADE_LEVEL
        ,CASE        
          WHEN cc.expression = '1(A)' THEN 'HR'
          WHEN cc.expression = '2(A)' THEN '1'
          WHEN cc.expression = '3(A)' THEN '2'
          WHEN cc.expression = '4(A)' THEN '3'
          WHEN cc.expression = '5(A)' THEN '4A'
          WHEN cc.expression = '6(A)' THEN '4B'
          WHEN cc.expression = '7(A)' THEN '4C'
          WHEN cc.expression = '8(A)' THEN '4D'
          WHEN cc.expression = '9(A)' THEN '5A'
          WHEN cc.expression = '10(A)' THEN '5B'
          WHEN cc.expression = '11(A)' THEN '5C'
          WHEN cc.expression = '12(A)' THEN '5D'
          WHEN cc.expression = '13(A)' THEN '6'
          WHEN cc.expression = '14(A)' THEN '7'
          ELSE NULL
         END AS period
        ,t.LAST_NAME AS teacher
        ,cou.COURSE_NAME
  FROM PS$CC#static cc WITH(NOLOCK)
  JOIN PS$TEACHERS#static t WITH(NOLOCK)
    ON cc.TEACHERID = t.ID
  JOIN PS$COURSES#static cou WITH(NOLOCK)
    ON cc.course_number = cou.COURSE_NUMBER
  JOIN PS$STUDENTS#static s WITH(NOLOCK)
    ON cc.studentid = s.id
   AND s.ENROLL_STATUS = 0
  WHERE cc.SCHOOLID = 73253
    AND cc.TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()
    AND cc.COURSE_NUMBER != 'HR'
 )

,dates AS (
  SELECT DISTINCT 
         CONVERT(DATE,mem.CALENDARDATE) AS calendardate
        ,dt.alt_name
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON mem.schoolid = dt.schoolid
   AND mem.CALENDARDATE BETWEEN dt.start_date AND dt.end_date
   AND dt.academic_year = dbo.fn_Global_Academic_Year()   
   AND dt.identifier = 'RT'
  WHERE mem.schoolid = 73253
    AND mem.CALENDARDATE >= CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01')
 )

SELECT c.SECTIONID
      ,c.STUDENTID
      ,c.LASTFIRST
      ,c.GRADE_LEVEL
      ,c.period
      ,c.teacher
      ,c.COURSE_NAME      
      ,dt.alt_name AS term
      ,dt.CALENDARDATE
      ,m.att_code     
      ,ISNULL(m.is_absent,0.0) AS is_absent
      ,ISNULL(m.is_tardy,0.0) AS is_tardy
FROM course_list c WITH(NOLOCK)
JOIN dates dt WITH(NOLOCK)
  ON c.DATEENROLLED <= dt.CALENDARDATE
 AND c.DATELEFT >= dt.CALENDARDATE
LEFT OUTER JOIN meeting_att m WITH(NOLOCK)
  ON c.studentid = m.studentid
 AND c.sectionid = m.sectionid
 AND dt.calendardate = m.att_date