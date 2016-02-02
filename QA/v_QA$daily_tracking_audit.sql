USE KIPP_NJ
GO

ALTER VIEW QA$daily_tracking_audit AS

WITH u (tracking_field) AS (
  SELECT 'hw' UNION ALL
  SELECT 'uniform' UNION ALL
  SELECT 'color_day' UNION ALL
  SELECT 'color_am' UNION ALL
  SELECT 'color_mid' UNION ALL
  SELECT 'color_pm'
 )

,dailytracking AS (
  SELECT studentid
        ,att_date
        ,field
        ,value      
  FROM
      (
       SELECT dt.studentid
             ,dt.att_date
             ,dt.hw
             ,dt.uniform
             ,dt.color_day
             ,dt.color_am
             ,dt.color_mid
             ,dt.color_pm
       FROM KIPP_NJ..DAILY$tracking_long#ES#static dt WITH(NOLOCK)
       WHERE dt.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      ) sub
  UNPIVOT(
    value
    FOR field IN (hw
                 ,uniform
                 ,color_day
                 ,color_am
                 ,color_mid
                 ,color_pm)
   ) u
 )

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status            
      ,co.term

      ,cal.CALENDARDATE AS date_value           
      
      ,CONCAT('Week ', rep.alt_name) AS reporting_week            
      
      ,enr.sectionid
      ,enr.sectionsDCID      
      
      ,u.tracking_field
      ,CASE WHEN cal.ATTENDANCEVALUE = 0 THEN 'Absent' ELSE ISNULL(t.value,'MISSING') END AS tracking_value
FROM KIPP_NJ..COHORT$identifiers_scaffold#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP cal WITH(NOLOCK)
  ON co.studentid = cal.studentid
 AND co.schoolid = cal.schoolid
 AND co.year = cal.academic_year
 AND co.date = cal.CALENDARDATE
 AND cal.MEMBERSHIPVALUE = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rep WITH(NOLOCK)
  ON co.schoolid = rep.schoolid
 AND cal.CALENDARDATE BETWEEN rep.start_date AND DATEADD(DAY, 2, rep.end_date) /* includes end of week in case of Saturday school */
 AND rep.identifier = 'REP'
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND enr.drop_flags = 0
CROSS JOIN u
LEFT OUTER JOIN dailytracking t
  ON co.studentid = t.studentid
 AND cal.CALENDARDATE = t.att_date
 AND u.tracking_field = t.field
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND co.date BETWEEN co.entrydate AND co.exitdate
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.enroll_status = 0