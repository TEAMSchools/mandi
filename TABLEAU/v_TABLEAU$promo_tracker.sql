USE KIPP_NJ
GO

ALTER VIEW TABLEAU$promo_tracker AS 

WITH roster AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.year
        ,co.schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor         
        ,co.HOME_PHONE
        ,co.MOTHER_CELL
        ,co.FATHER_CELL   
        ,co.spedlep

        ,dt.alt_name AS term
        ,dt.time_per_name AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..AUTOLOAD$GDOCS_REP_reporting_dates dt WITH(NOLOCK)
    ON co.year = dt.academic_year
   AND co.schoolid = dt.schoolid
   AND dt.identifier = 'RT'
   AND dt.alt_name != 'Summer School'
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1
    AND co.enroll_status = 0
    AND co.grade_level != 99    
  
  UNION ALL

  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.year
        ,co.schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor         
        ,co.HOME_PHONE
        ,co.MOTHER_CELL
        ,co.FATHER_CELL   
        ,co.spedlep

        ,'Y1' AS term
        ,dt.time_per_name AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..AUTOLOAD$GDOCS_REP_reporting_dates dt WITH(NOLOCK)
    ON co.year = dt.academic_year   
   AND dt.identifier = 'SY'   
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1
    AND co.enroll_status = 0
    AND co.grade_level != 99    
 )

,grades AS (
  /* term grades */
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,gr.academic_year            
        ,gr.rt AS reporting_term
        ,LEFT(gr.term,1) AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,gr.term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  UNION ALL
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,gr.academic_year      
        ,'Y1' AS reporting_term
        ,'Y' AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND gr.rn_curterm = 1

  UNION ALL
  
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'CATEGORY' AS subdomain
        ,gr.academic_year            
        ,'Y1' AS reporting_term
        ,gr.grade_category AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,ROUND(AVG(gr.grade_category_pct),0) AS term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$category_grades_long#static gr WITH(NOLOCK)
  WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY gr.student_number
          ,gr.academic_year
          ,gr.grade_category
          ,gr.credittype
          ,gr.course_name
  
  UNION ALL

  /* HS exams */
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'EXAMS' AS subdomain
        ,gr.academic_year
        ,gr.rt AS reporting_term
        ,'E' AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,COALESCE(gr.e1, gr.e2) AS term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)   
  WHERE gr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND gr.schoolid = 73253
    AND (gr.e1 IS NOT NULL OR gr.e2 IS NOT NULL)
 )

,attendance AS (
  SELECT studentid
        ,'ATTENDANCE' AS domain
        ,CASE
          WHEN field = 'presentpct_term' THEN 'ABSENT'
          WHEN field = 'ontimepct_term' THEN 'TARDY'
          WHEN field IN ('attpts_term', 'attptspct_term') THEN 'PROMO'
          WHEN field LIKE 'A%' THEN 'ABSENT'
          WHEN field LIKE 'T%' THEN 'TARDY'
          WHEN field LIKE '%SS%' THEN 'SUSPENSION'
         END AS subdomain
        ,academic_year
        ,reporting_term
        ,LEFT(field, CHARINDEX('_', field) - 1) AS att_code
        ,value AS att_counts
  FROM 
      (
       SELECT att.studentid
             ,att.academic_year
             ,att.rt AS reporting_term           
             ,att.A_counts_term
             ,att.AD_counts_term
             ,att.AE_counts_term
             ,att.ISS_counts_term
             ,att.OSS_counts_term
             ,att.T_counts_term
             ,att.T10_counts_term
             ,att.TE_counts_term           
             ,att.ABS_all_counts_term
             ,att.TDY_all_counts_term

             ,ROUND(((att.MEM_counts_term - att.ABS_all_counts_term) / att.MEM_counts_term) * 100,0) AS presentpct_term
             ,ROUND(((att.MEM_counts_term - att.ABS_all_counts_term - att.TDY_all_counts_term) / (att.MEM_counts_term - att.ABS_all_counts_term)) * 100,0) AS ontimepct_term

             ,att.ABS_all_counts_term + ROUND((att.TDY_all_counts_term / 3),1,1) AS attpts_term
             ,ROUND(((att.MEM_counts_term - (att.ABS_all_counts_term + ROUND((att.TDY_all_counts_term / 3),1,1))) / att.MEM_counts_term) * 100,0) AS attptspct_term
       FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static att WITH(NOLOCK)
       WHERE att.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND att.MEM_counts_term > 0
         AND att.MEM_counts_term != att.ABS_all_counts_term

       UNION ALL

       SELECT att.studentid
             ,att.academic_year
             ,'Y1' AS reporting_term
             ,att.A_counts_yr
             ,att.AD_counts_yr
             ,att.AE_counts_yr
             ,att.ISS_counts_yr
             ,att.OSS_counts_yr
             ,att.T_counts_yr
             ,att.T10_counts_yr
             ,att.TE_counts_yr           
             ,att.ABS_all_counts_yr
             ,att.TDY_all_counts_yr

             ,ROUND(((att.MEM_counts_yr - att.ABS_all_counts_yr) / att.MEM_counts_yr) * 100,0) AS presentpct_yr
             ,ROUND(((att.MEM_counts_yr - att.ABS_all_counts_yr - att.TDY_all_counts_yr) / (att.MEM_counts_yr - att.ABS_all_counts_yr)) * 100,0) AS ontimepct_yr

             ,att.ABS_all_counts_yr + ROUND((att.TDY_all_counts_yr / 3),1,1) AS attpts_yr
             ,ROUND(((att.MEM_counts_yr - (att.ABS_all_counts_yr + ROUND((att.TDY_all_counts_yr / 3),1,1))) / att.MEM_counts_yr) * 100,0) AS attptspct_yr
       FROM KIPP_NJ..ATT_MEM$attendance_counts_long#static att WITH(NOLOCK)
       WHERE att.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND att.MEM_counts_term > 0
         AND att.MEM_counts_yr != att.ABS_all_counts_yr
         AND att.rn_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (A_counts_term       
                 ,AD_counts_term
                 ,AE_counts_term
                 ,ABS_all_counts_term               
                 ,T_counts_term
                 ,T10_counts_term
                 ,TE_counts_term     
                 ,TDY_all_counts_term
                 ,ISS_counts_term
                 ,OSS_counts_term
                 ,presentpct_term
                 ,ontimepct_term
                 ,attpts_term
                 ,attptspct_term)
   ) u
 )

,modules AS (
  SELECT a.subject_area        
        ,a.title
        ,a.administered_at      
        ,a.scope            
        ,a.academic_year        
        ,res.local_student_id AS student_number
        ,res.percent_correct        
        ,'MODULES' AS domain
        ,NULL AS subdomain
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id
  WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,gpa AS (
  SELECT student_number
        ,'GPA' AS domain
        ,'GPA Y1 - TERM' AS subdomain
        ,academic_year      
        ,rt AS reporting_term
        ,schoolid
        ,GPA_Y1 AS GPA
  FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)    

  UNION ALL

  SELECT student_number
        ,'GPA' AS domain
        ,'GPA Y1' AS subdomain
        ,academic_year      
        ,'Y1' AS reporting_term
        ,schoolid
        ,GPA_Y1 AS GPA
  FROM
      (
       SELECT student_number
             ,academic_year
             ,schoolid           
             ,GPA_Y1
             ,ROW_NUMBER() OVER(
                PARTITION BY student_number, academic_year
                  ORDER BY rt DESC) AS rn
       FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)
      ) sub
  WHERE rn = 1

  UNION ALL

  SELECT s.STUDENT_NUMBER
        ,'GPA' AS domain
        ,'GPA CUMULATIVE' AS subdomain
        ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
        ,'Y1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.cumulative_Y1_gpa AS GPA
  FROM KIPP_NJ..GRADES$GPA_cumulative#static gpa WITH(NOLOCK)
  JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
    ON gpa.studentid = s.ID

  UNION ALL

  SELECT s.STUDENT_NUMBER
        ,'GPA' AS domain
        ,'CREDITS EARNED' AS subdomain
        ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
        ,'Y1' AS reporting_Term
        ,gpa.schoolid           
        ,gpa.earned_credits_cum AS GPA
  FROM KIPP_NJ..GRADES$GPA_cumulative#static gpa WITH(NOLOCK)
  JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
    ON gpa.studentid = s.ID
  WHERE gpa.schoolid = 73253
 )

,lit AS (
  SELECT student_number
        ,'LIT' AS domain
        ,'ACHIEVED' AS subdomain
        ,academic_year        
        ,test_round      
        ,read_lvl
        ,lvl_num        
  FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
  WHERE read_lvl IS NOT NULL
    AND goal_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())
  UNION ALL
  SELECT student_number
        ,'LIT' AS domain
        ,'GOAL' AS subdomain
        ,academic_year        
        ,test_round      
        ,goal_lvl
        ,goal_num
  FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
  WHERE read_lvl IS NOT NULL
    AND goal_lvl IS NOT NULL
    AND start_date <= CONVERT(DATE,GETDATE())
  
  UNION ALL

  SELECT student_number
        ,'LIT' AS domain
        ,'ACHIEVED' AS subdomain
        ,academic_year        
        ,term AS test_round        
        ,CONCAT(rittoreadingscore,'L') AS read_lvl
        ,CASE
          WHEN rittoreadingscore = 'BR' THEN -1
          WHEN rittoreadingscore BETWEEN 0 AND 100 THEN 1
          WHEN rittoreadingscore BETWEEN 100 AND 200 THEN 5
          WHEN rittoreadingscore BETWEEN 200 AND 300 THEN 10
          WHEN rittoreadingscore BETWEEN 300 AND 400 THEN 14
          WHEN rittoreadingscore BETWEEN 400 AND 500 THEN 17
          WHEN rittoreadingscore BETWEEN 500 AND 600 THEN 20
          WHEN rittoreadingscore BETWEEN 600 AND 700 THEN 22
          WHEN rittoreadingscore BETWEEN 700 AND 800 THEN 25
          WHEN rittoreadingscore BETWEEN 800 AND 900 THEN 27
          WHEN rittoreadingscore BETWEEN 900 AND 1000 THEN 28
          WHEN rittoreadingscore BETWEEN 1000 AND 1100 THEN 29
          WHEN rittoreadingscore BETWEEN 1100 AND 1200 THEN 30
          WHEN rittoreadingscore >= 1200 THEN 31
         END AS lvl_num        
  FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)
  WHERE measurementscale = 'Reading'
    AND schoolid = 73253    
    AND rn = 1
  UNION ALL
  SELECT student_number
        ,'LIT' AS domain
        ,'GOAL' AS subdomain
        ,academic_year        
        ,term AS test_round        
        ,CASE
          WHEN grade_level = 9 THEN '900L'
          WHEN grade_level = 10 THEN '1000L'
          WHEN grade_level = 11 THEN '1100L'
          WHEN grade_level = 12 THEN '1200L'
         END AS goal_lvl
        ,CASE
          WHEN grade_level = 9 THEN 28
          WHEN grade_level = 10 THEN 29
          WHEN grade_level = 11 THEN 30
          WHEN grade_level = 12 THEN 31
         END AS goal_num
  FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)
  WHERE measurementscale = 'Reading'
    AND schoolid = 73253    
    AND rn = 1
 )

,map AS (
  SELECT student_number
        ,'MAP' AS domain
        ,CONVERT(VARCHAR,academic_year) AS subdomain                
        ,term
        ,measurementscale
        ,testritscore
        ,testpercentile
  FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)
  WHERE rn = 1
 )

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,r.reporting_term      
      ,gr.domain
      ,gr.subdomain      
      ,gr.credittype AS subject
      ,gr.course_name
      ,gr.finalgradename AS measure_name
      ,gr.term_grade_percent_adjusted AS measure_value
FROM roster r
LEFT OUTER JOIN grades gr
  ON r.student_number = gr.student_number
 AND r.year = gr.academic_year
 AND r.reporting_term = gr.reporting_term

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,r.reporting_term      
      ,att.domain
      ,att.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,att.att_code AS measure_name
      ,att.att_counts AS measure_value
FROM roster r
LEFT OUTER JOIN attendance att
  ON r.studentid = att.studentid
 AND r.year = att.academic_year
 AND r.reporting_term = att.reporting_term

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,r.reporting_term      
      ,cma.domain
      ,cma.subdomain      
      ,cma.subject_area AS subject
      ,cma.title AS course_name
      ,cma.scope AS measure_name
      ,cma.percent_correct AS measure_value
FROM roster r
LEFT OUTER JOIN modules cma
  ON r.student_number = cma.student_number
 AND r.year = cma.academic_year
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,r.reporting_term      
      ,gpa.domain
      ,gpa.subdomain      
      ,NULL AS subject
      ,CONVERT(VARCHAR,gpa.schoolid) AS course_name
      ,CONVERT(VARCHAR,gpa.academic_year) AS measure_name
      ,gpa.GPA AS measure_value
FROM roster r
LEFT OUTER JOIN gpa
  ON r.student_number = gpa.student_number 
 AND r.schoolid = gpa.schoolid
 AND r.reporting_term = gpa.reporting_term

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,r.reporting_term      
      ,lit.domain
      ,lit.subdomain      
      ,CONVERT(VARCHAR,lit.academic_year) AS subject
      ,lit.test_round AS course_name
      ,lit.read_lvl AS measure_name
      ,lit.lvl_num AS measure_value
FROM roster r
LEFT OUTER JOIN lit
  ON r.student_number = lit.student_number
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,r.term
      ,map.term AS reporting_term      
      ,map.domain
      ,map.subdomain      
      ,map.measurementscale AS subject
      ,NULL AS course_name
      ,CONVERT(VARCHAR,map.testritscore) AS measure_name
      ,map.testpercentile AS measure_value
FROM roster r
LEFT OUTER JOIN map
  ON r.student_number = map.student_number
WHERE r.reporting_term = 'Y1' 