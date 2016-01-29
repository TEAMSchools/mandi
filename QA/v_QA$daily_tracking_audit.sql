USE KIPP_NJ
GO

ALTER VIEW QA$daily_tracking_audit AS

WITH dailytracking AS (
  SELECT studentid
        ,att_date
        ,field
        ,CASE WHEN value = '' THEN NULL ELSE value END AS value      
  FROM
      (
       SELECT dt.studentid
             ,dt.att_date
             ,ISNULL(dt.hw,'') AS hw
             ,ISNULL(dt.uniform,'') AS uniform
             ,ISNULL(dt.color_day,'') AS color_day
             ,ISNULL(dt.color_am,'') AS color_am
             ,ISNULL(dt.color_mid,'') AS color_mid
             ,ISNULL(dt.color_pm,'') AS color_pm
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
      
      ,cal.CALENDARDATE AS date_value
      --,cal.attendancevalue AS presence_status
      
      ,dt.alt_name AS term
      ,CONCAT('Week ', rep.alt_name) AS reporting_week            
      
      ,enr.sectionid
      ,enr.sectionsDCID      
      
      ,u.tracking_field
      ,CASE WHEN cal.ATTENDANCEVALUE = 0 THEN 'Absent' ELSE ISNULL(t.value,'MISSING') END AS tracking_value
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..ATT_MEM$MEMBERSHIP cal WITH(NOLOCK)
  ON co.studentid = cal.studentid
 AND co.schoolid = cal.schoolid
 AND co.year = cal.academic_year
 AND cal.CALENDARDATE BETWEEN co.entrydate AND CONVERT(DATE,GETDATE())
 AND cal.MEMBERSHIPVALUE = 1
JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND cal.CALENDARDATE BETWEEN dt.start_date AND dt.end_date
 AND dt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rep WITH(NOLOCK)
  ON co.schoolid = rep.schoolid
 AND cal.CALENDARDATE BETWEEN rep.start_date AND DATEADD(DAY, 2, rep.end_date) /* includes end of week in case of Saturday school */
 AND rep.identifier = 'REP'
JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND enr.drop_flags = 0
--LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
--  ON co.studentid = att.STUDENTID
-- AND co.year = att.academic_year
-- AND cal.CALENDARDATE = att.ATT_DATE
-- AND att.PRESENCE_STATUS_CD = 'Absent' 
CROSS JOIN ( 
            SELECT 'hw' UNION ALL
            SELECT 'uniform' UNION ALL
            SELECT 'color_day' UNION ALL
            SELECT 'color_am' UNION ALL
            SELECT 'color_mid' UNION ALL
            SELECT 'color_pm'
           ) u (tracking_field)
LEFT OUTER JOIN dailytracking t
  ON co.studentid = t.studentid
 AND cal.CALENDARDATE = t.att_date
 AND u.tracking_field = t.field
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()  
  AND (co.grade_level <= 4 AND co.schoolid != 73252)
  AND co.enroll_status = 0