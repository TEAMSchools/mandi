USE KIPP_NJ
GO

ALTER VIEW TABLEAU$710_dashboard AS
 
WITH enrollments AS (
  SELECT SCHOOLID
        ,STUDENTID
        ,TERMID
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,course_name
        ,SECTION_NUMBER
        ,SECTIONID
        ,teacher_name
        ,period AS nca_period
  FROM KIPP_NJ..PS$course_enrollments#static WITH(NOLOCK)  
  WHERE TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()    
    AND grade_level >= 5
    AND grade_level <= 12
    AND CREDITTYPE IS NOT NULL
    AND CREDITTYPE NOT IN ('LOG')
 )

,reporting_weeks AS (
  SELECT rw.reporting_hash
        ,rw.week
        ,CONVERT(DATE,rw.weekday_start) AS week_of
        ,dt.alt_name
        ,dt.termid
        ,dt.schoolid
  FROM KIPP_NJ..UTIL$reporting_weeks_days#static rw WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) >= ((DATEPART(YEAR,dt.start_date) * 100) + DATEPART(WEEK,dt.start_date))
   AND ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) <= ((DATEPART(YEAR,dt.end_date) * 100) + DATEPART(WEEK,dt.end_date))
   AND rw.academic_year = dt.academic_year
   AND dt.identifier = 'RT'
   AND dt.school_level != 'ES'
  WHERE rw.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND rw.weekday_start <= CONVERT(DATE,GETDATE())
 )

,course_scaffold AS (
  SELECT DISTINCT 
         rw.schoolid
        ,rw.week        
        ,rw.week_of
        ,rw.reporting_hash
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,SECTIONID
        ,SECTION_NUMBER
        ,CASE 
          WHEN enr.schoolid = 73253 THEN enr.nca_period 
          WHEN enr.schoolid = 73252 AND LEN(enr.SECTION_NUMBER) <= 5 THEN UPPER(SUBSTRING(enr.SECTION_NUMBER, 2, 10))
          WHEN enr.schoolid = 73252 AND LEN(enr.SECTION_NUMBER) > 5 THEN UPPER(SUBSTRING(enr.SECTION_NUMBER, 2, 1)) + SUBSTRING(enr.SECTION_NUMBER, 3, 10)
          WHEN enr.schoolid = 133570965 AND LEN(enr.SECTION_NUMBER) <= 6 THEN UPPER(SUBSTRING(enr.SECTION_NUMBER, 3, 10))
          WHEN enr.schoolid = 133570965 AND LEN(enr.SECTION_NUMBER) > 6 THEN UPPER(SUBSTRING(enr.SECTION_NUMBER, 3, 1)) + SUBSTRING(enr.SECTION_NUMBER, 4, 10)
         END AS section        
        ,teacher_name        
        ,rw.alt_name AS term
  FROM enrollments enr WITH(NOLOCK)
  JOIN reporting_weeks rw WITH(NOLOCK)
    ON enr.SCHOOLID = rw.schoolid
 )

,finalgrades_long AS ( 
  SELECT sectionid
        ,term
        ,ROUND(AVG(CONVERT(FLOAT,term_pct)),0) AS termgrade
  FROM KIPP_NJ..GRADES$detail_long#static WITH(NOLOCK)
  GROUP BY sectionid
          ,term
  
  UNION ALL
  
  SELECT sectionid
        ,'Y1' AS term
        ,ROUND(AVG(CONVERT(FLOAT,y1_pct)),0) AS termgrade
  FROM KIPP_NJ..GRADES$detail_long#static WITH(NOLOCK)
  GROUP BY sectionid
 )

,attendance_weekly AS (
  SELECT sectionid
        ,week
        ,SUM(is_absent) AS n_absent
  FROM
      (
       SELECT studentid
             ,sectionid
             ,DATEPART(WEEK,att_date) AS week
             ,att_code
             ,CASE WHEN att_code IS NULL OR att_code IN ('T','T10','TE') THEN 0.0 ELSE 1.0 END AS is_absent
       FROM ATT_MEM$PS_ATTENDANCE_MEETING WITH(NOLOCK)
       WHERE schoolid = 73253
      ) sub
  GROUP BY sectionid
          ,week
 )

,membership_weekly AS (
  SELECT sectionid
        ,week
        ,SUM(MEMBERSHIPVALUE) AS n_mem
  FROM
      (
       SELECT mem.STUDENTID                   
             ,ABS(cc.SECTIONID) AS sectionid
             ,DATEPART(WEEK,mem.CALENDARDATE) AS week
             ,CONVERT(FLOAT,mem.MEMBERSHIPVALUE) AS membershipvalue
       FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
       JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
         ON mem.STUDENTID = cc.STUDENTID
        AND (mem.CALENDARDATE BETWEEN cc.DATEENROLLED AND cc.DATELEFT)
       WHERE mem.academic_year >= KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND mem.SCHOOLID = 73253
      ) sub
  GROUP BY sectionid
          ,week
 )

,butts_in_seats AS (
  SELECT mem.sectionid
        ,NULL AS section_number
        ,mem.week
        ,mem.n_mem
        ,ISNULL(att.n_absent,0) AS n_absent
        ,ROUND(((mem.n_mem - ISNULL(att.n_absent,0)) / mem.n_mem) * 100,0) AS butts_in_seats_pct
  FROM membership_weekly mem
  LEFT OUTER JOIN attendance_weekly att
    ON mem.sectionid = att.sectionid
   AND mem.week = att.week

  UNION ALL

  SELECT NULL AS sectionid
        ,cc.SECTION_NUMBER
        ,DATEPART(WEEK,mem.CALENDARDATE) AS week
        ,NULL AS n_mem
        ,NULL AS n_absent
        ,ROUND(SUM(CONVERT(FLOAT,mem.attendancevalue)) / SUM(CONVERT(FLOAT,mem.membershipvalue)) * 100,0) AS butts_in_seats_pct
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  JOIN PS$CC#static cc WITH(NOLOCK)
    ON mem.STUDENTID = cc.STUDENTID
   AND cc.COURSE_NUMBER = 'HR' 
   AND cc.TERMID >= dbo.fn_Global_Term_Id()
   AND cc.DATELEFT >= GETDATE()
   AND cc.SECTIONID > 0
  WHERE mem.SCHOOLID IN (73252, 133570965)
    AND mem.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY cc.SECTION_NUMBER
          ,DATEPART(WEEK,mem.CALENDARDATE)
 )

SELECT schoolid
      ,week
      ,week_of
      ,reporting_hash
      ,CREDITTYPE
      ,COURSE_NUMBER
      ,COURSE_NAME
      ,sectionid
      ,SECTION_NUMBER
      ,SECTION      
      ,teacher_name
      ,term
      ,finalgrade
      ,category
      ,ROUND(AVG(pct),0) AS pct
      ,ISNULL(COUNT(DISTINCT assign_name),0) AS n_assign
FROM
    (
     SELECT enr.schoolid
           ,enr.week
           ,enr.week_of
           ,enr.reporting_hash
           ,enr.CREDITTYPE
           ,enr.COURSE_NUMBER
           ,enr.COURSE_NAME
           ,enr.SECTIONID
           ,enr.SECTION_NUMBER
           ,enr.section
           ,enr.teacher_name
           ,enr.term
           ,gr.ASSIGNMENTID
           ,gr.assign_name
           ,gr.finalgrade
           ,gr.category
           ,gr.pct      
           --,gr.student_number      
           --,s.lastfirst
           --,s.grade_level
           --,s.team
           --,s.gender
           --,cs.advisor
           --,cs.spedlep
           --,co.year_in_network
     FROM course_scaffold enr WITH(NOLOCK)
     JOIN KIPP_NJ..GRADES$asmt_scores_category_long#static gr WITH(NOLOCK)
       ON enr.SECTIONID = gr.sectionid
      AND enr.week = gr.week
     --JOIN STUDENTS s WITH(NOLOCK)
     --  ON gr.student_number = s.student_number
     --JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
     --  ON s.id = cs.studentid
     --JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
     --  ON s.id = co.studentid
     -- AND co.year = dbo.fn_Global_Academic_Year()
     -- AND co.rn = 1
    ) sub
GROUP BY schoolid
        ,week
        ,week_of
        ,reporting_hash
        ,CREDITTYPE
        ,COURSE_NUMBER
        ,COURSE_NAME
        ,SECTIONID
        ,SECTION_NUMBER
        ,SECTION
        ,teacher_name
        ,term
        ,finalgrade
        ,category

UNION ALL

SELECT enr.schoolid
      ,enr.week
      ,enr.week_of
      ,enr.reporting_hash
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.SECTIONID
      ,enr.SECTION_NUMBER
      ,enr.section
      ,enr.teacher_name
      ,enr.term
      --,NULL AS ASSIGNMENTID
      --,'Term Grade' AS assign_name
      ,'Term Grade' AS finalgrade
      ,'Term Grade' AS category
      ,fg.termgrade AS pct
      ,NULL AS n_assign
      --,fg.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN finalgrades_long fg WITH(NOLOCK)
  ON enr.sectionid = fg.sectionid
 AND enr.term = fg.term
--JOIN STUDENTS s WITH(NOLOCK)
--  ON fg.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1

UNION ALL

SELECT enr.schoolid
      ,enr.week
      ,enr.week_of
      ,enr.reporting_hash
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.SECTIONID
      ,enr.SECTION_NUMBER
      ,enr.section
      ,enr.teacher_name
      ,enr.term
      --,NULL AS ASSIGNMENTID
      --,'Term Grade' AS assign_name
      ,fg.term AS finalgrade
      ,'Final Grade' AS category
      ,fg.termgrade AS pct
      ,NULL AS n_assign
      --,fg.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN finalgrades_long fg WITH(NOLOCK)
  ON enr.sectionid = fg.sectionid
 AND fg.term = 'Y1'
--JOIN STUDENTS s WITH(NOLOCK)
--  ON fg.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1

UNION ALL

SELECT enr.schoolid
      ,enr.week
      ,enr.week_of
      ,enr.reporting_hash
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.SECTIONID
      ,enr.SECTION_NUMBER
      ,enr.section
      ,enr.teacher_name
      ,enr.term
      --,NULL AS ASSIGNMENTID
      --,'Attendance %' AS assign_name
      ,'Att %' AS finalgrade
      ,'Butts in Seats' AS category
      ,bis.butts_in_seats_pct AS pct
      ,NULL AS n_assign
      --,bis.student_number      
      --,s.lastfirst
      --,s.grade_level
      --,s.team
      --,s.gender
      --,cs.advisor
      --,cs.spedlep
      --,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN butts_in_seats bis WITH(NOLOCK)
  ON ((enr.schoolid = 73253 AND enr.SECTIONID = bis.sectionid) OR enr.section_number = bis.section_number)
 AND enr.week = bis.week
--JOIN STUDENTS s WITH(NOLOCK)
--  ON bis.student_number = s.student_number
--JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
--  ON s.id = cs.studentid
--JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
--  ON s.id = co.studentid
-- AND co.year = dbo.fn_Global_Academic_Year()
-- AND co.rn = 1
