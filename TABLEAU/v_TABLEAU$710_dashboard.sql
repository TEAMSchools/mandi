USE KIPP_NJ
GO

ALTER VIEW TABLEAU$710_dashboard AS
 
WITH enrollments AS (
  SELECT cc.SCHOOLID
        ,cc.STUDENTID
        ,cc.TERMID
        ,cou.CREDITTYPE
        ,cc.COURSE_NUMBER
        ,cou.course_name
        ,cc.SECTION_NUMBER
        ,cc.SECTIONID
        ,t.last_name AS teacher_name
        ,CASE        
          WHEN cc.SCHOOLID != 73253 THEN cc.EXPRESSION
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
         END AS nca_period
  FROM CC WITH(NOLOCK)
  JOIN COURSES cou WITH(NOLOCK)
    ON cc.COURSE_NUMBER = cou.COURSE_NUMBER
   AND cou.CREDITTYPE IS NOT NULL
   AND cou.CREDITTYPE NOT IN ('LOG')
  JOIN TEACHERS t WITH(NOLOCK)
    ON cc.TEACHERID = t.ID
  WHERE cc.TERMID >= dbo.fn_Global_Term_Id()
    AND cc.STUDENTID IN (SELECT studentid FROM COHORT$comprehensive_long#static co WITH(NOLOCK) WHERE co.year = dbo.fn_Global_Academic_Year() AND co.grade_level >= 5 AND co.grade_level <= 12)
 )

,reporting_weeks AS (
  SELECT rw.reporting_hash
        ,rw.week
        ,CONVERT(DATE,rw.weekday_start) AS week_of
        ,dt.alt_name
        ,dt.termid
        ,dt.schoolid
  FROM UTIL$reporting_weeks_days rw WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) >= ((DATEPART(YEAR,dt.start_date) * 100) + DATEPART(WEEK,dt.start_date))
   AND ((DATEPART(YEAR,rw.weekday_start) * 100) + DATEPART(WEEK,rw.weekday_start)) <= ((DATEPART(YEAR,dt.end_date) * 100) + DATEPART(WEEK,dt.end_date))
   AND rw.academic_year = dt.academic_year
   AND dt.identifier = 'RT'
   AND dt.school_level != 'ES'
  WHERE rw.academic_year = dbo.fn_Global_Academic_Year()
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
        ,CASE WHEN enr.schoolid = 73253 THEN enr.nca_period ELSE enr.SECTION_NUMBER END AS section        
        ,teacher_name        
        ,rw.alt_name AS term
  FROM enrollments enr WITH(NOLOCK)
  JOIN reporting_weeks rw WITH(NOLOCK)
    ON enr.SCHOOLID = rw.schoolid
 )

,finalgrades_long AS ( 
  SELECT *
  FROM
      (
       SELECT DISTINCT 
              STUDENT_NUMBER             
             ,sectionid
             ,T1
             ,T2
             ,T3
             ,Q1
             ,Q2
             ,Q3
             ,Q4
             ,E1
             ,E2
             ,Y1
       FROM
           (
            SELECT STUDENT_NUMBER
                  ,T1
                  ,T2
                  ,T3             
                  ,NULL AS Q1
                  ,NULL AS Q2
                  ,NULL AS Q3
                  ,NULL AS Q4
                  ,NULL AS E1
                  ,NULL AS E2
                  ,Y1
                  ,T1_ENR_SECTIONID AS rt1_sectionid
                  ,T2_ENR_SECTIONID AS rt2_sectionid
                  ,T3_ENR_SECTIONID AS rt3_sectionid
                  ,NULL AS rt4_sectionid
            FROM GRADES$DETAIL#MS WITH(NOLOCK)

            UNION ALL

            SELECT STUDENT_NUMBER
                  ,NULL AS T1
                  ,NULL AS T2
                  ,NULL AS T3
                  ,q1
                  ,q2
                  ,q3
                  ,q4
                  ,e1
                  ,e2
                  ,Y1
                  ,q1_enr_sectionid AS rt1_sectionid
                  ,q2_enr_sectionid AS rt2_sectionid
                  ,q3_enr_sectionid AS rt3_sectionid
                  ,q4_enr_sectionid AS rt4_sectionid
            FROM GRADES$DETAIL#NCA WITH(NOLOCK)
           ) sub

       UNPIVOT (
         sectionid
         FOR term IN (rt1_sectionid, rt2_sectionid, rt3_sectionid, rt4_sectionid)
        ) u
      ) sub

  UNPIVOT (
    termgrade
    FOR term IN (T1
                ,T2
                ,T3
                ,Q1
                ,Q2
                ,Q3
                ,Q4)
   ) u2
 )

SELECT enr.*      
      ,fg.y1
      ,fg.e1
      ,fg.e2
      ,fg.termgrade
      ,gr.ASSIGNMENTID
      ,gr.assign_name
      ,gr.finalgrade
      ,gr.category
      ,gr.pct
      ,gr.student_number      
      ,s.lastfirst
      ,s.grade_level
      ,s.team
      ,s.gender
      ,cs.advisor
      ,cs.spedlep
      ,co.year_in_network
FROM course_scaffold enr WITH(NOLOCK)
JOIN GRADES$asmt_scores_category_long#static gr WITH(NOLOCK)
  ON enr.SECTIONID = gr.sectionid
 AND enr.week = gr.week
JOIN finalgrades_long fg WITH(NOLOCK)
  ON enr.sectionid = fg.sectionid
 AND enr.term = fg.term
 AND gr.student_number = fg.student_number
JOIN STUDENTS s WITH(NOLOCK)
  ON gr.student_number = s.student_number
JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON s.id = co.studentid
 AND co.year = dbo.fn_Global_Academic_Year()
 AND co.rn = 1