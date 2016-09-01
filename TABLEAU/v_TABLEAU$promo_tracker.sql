USE KIPP_NJ
GO

ALTER VIEW TABLEAU$promo_tracker AS 

WITH roster AS (
  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor         
        ,co.spedlep
        ,co.enroll_status

        ,dt.alt_name AS term
        ,dt.time_per_name AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
    ON co.year = dt.academic_year
   AND co.schoolid = dt.schoolid
   AND dt.identifier = 'RT'
   AND dt.alt_name != 'Summer School'
  WHERE co.year >= 2015
    AND co.rn = 1
    --AND co.enroll_status != 2
    AND co.grade_level != 99    
  
  UNION ALL

  SELECT co.studentid
        ,co.student_number
        ,co.lastfirst      
        ,co.year
        ,co.schoolid
        ,co.reporting_schoolid
        ,co.grade_level
        ,co.cohort
        ,co.team
        ,co.advisor                 
        ,co.spedlep
        ,co.enroll_status

        ,'Y1' AS term
        ,dt.time_per_name AS reporting_term
        ,CONVERT(DATE,dt.start_date) AS term_start_date
        ,CONVERT(DATE,dt.end_date) AS term_end_date
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..AUTOLOAD$GDOCS_REP_reporting_dates dt WITH(NOLOCK)
    ON co.year = dt.academic_year   
   AND dt.identifier = 'SY'   
  WHERE co.year >= 2015
    AND co.rn = 1
    --AND co.enroll_status != 2
    AND co.grade_level != 99    
 )

,contact AS (
  SELECT studentid
        ,'CONTACT' AS domain      
        ,LEFT(field, CHARINDEX('_',field) - 1) AS person
        ,RIGHT(field, LEN(field) - CHARINDEX('_',field)) AS type
        ,value      
  FROM
      (
       SELECT con.STUDENTID
             ,CONVERT(VARCHAR,'Home') AS HOME_NAME           
             ,CONVERT(VARCHAR,con.HOME_PHONE) AS HOME_PHONE
             ,CONVERT(VARCHAR,blob.GUARDIANEMAIL) AS HOME_EMAIL
             ,CONVERT(VARCHAR,con.MOTHER) AS PARENT1_NAME
             ,CASE WHEN CONCAT(con.mother_home, con.mother_cell, con.mother_day) != '' THEN CONVERT(VARCHAR,'Mother') END AS PARENT1_RELATION
             ,CONVERT(VARCHAR,con.MOTHER_HOME) AS PARENT1_HOME
             ,CONVERT(VARCHAR,con.MOTHER_CELL) AS PARENT1_CELL
             ,CONVERT(VARCHAR,con.MOTHER_DAY) AS PARENT1_DAY           
             ,CONVERT(VARCHAR,con.FATHER) AS PARENT2_NAME
             ,CASE WHEN CONCAT(con.FATHER_HOME, con.FATHER_CELL, con.FATHER_DAY) != '' THEN CONVERT(VARCHAR,'Father') END AS PARENT2_RELATION
             ,CONVERT(VARCHAR,con.FATHER_HOME) AS PARENT2_HOME
             ,CONVERT(VARCHAR,con.FATHER_CELL) AS PARENT2_CELL
             ,CONVERT(VARCHAR,con.FATHER_DAY) AS PARENT2_DAY
             ,CONVERT(VARCHAR,con.DOCTOR_NAME) AS DOCTOR_NAME
             ,CASE WHEN CONCAT(con.DOCTOR_NAME, con.DOCTOR_PHONE) != '' THEN CONVERT(VARCHAR,'Doctor') END AS DOCTOR_RELATION
             ,CONVERT(VARCHAR,con.DOCTOR_PHONE) AS DOCTOR_PHONE
             ,CONVERT(VARCHAR,con.EMERG_CONTACT_1) AS EMERG1_NAME
             ,CONVERT(VARCHAR,con.EMERG_1_REL) AS EMERG1_RELATION
             ,CONVERT(VARCHAR,con.EMERG_PHONE_1) AS EMERG1_PHONE
             ,CONVERT(VARCHAR,con.EMERG_CONTACT_2) AS EMERG2_NAME
             ,CONVERT(VARCHAR,con.EMERG_2_REL) AS EMERG2_RELATION
             ,CONVERT(VARCHAR,con.EMERG_PHONE_2) AS EMERG2_PHONE
             ,CONVERT(VARCHAR,con.EMERG_CONTACT_3) AS EMERG3_NAME
             ,CONVERT(VARCHAR,con.EMERG_3_REL) AS EMERG3_RELATION
             ,CONVERT(VARCHAR,con.EMERG_3_PHONE) AS EMERG3_PHONE
             ,CONVERT(VARCHAR,con.EMERG_4_NAME) AS EMERG4_NAME
             ,CONVERT(VARCHAR,con.EMERG_4_REL) AS EMERG4_RELATION
             ,CONVERT(VARCHAR,con.EMERG_4_PHONE) AS EMERG4_PHONE
             ,CONVERT(VARCHAR,con.EMERG_5_NAME) AS EMERG5_NAME
             ,CONVERT(VARCHAR,con.EMERG_5_REL) AS EMERG5_RELATION
             ,CONVERT(VARCHAR,con.EMERG_5_PHONE) AS EMERG5_PHONE
             ,CONVERT(VARCHAR,con.RELEASE_1_NAME) AS RELEASE1_NAME
             ,CONVERT(VARCHAR,con.RELEASE_1_RELATION) AS RELEASE1_RELATION
             ,CONVERT(VARCHAR,con.RELEASE_1_PHONE) AS RELEASE1_PHONE           
             ,CONVERT(VARCHAR,con.RELEASE_2_NAME) AS RELEASE2_NAME
             ,CONVERT(VARCHAR,con.RELEASE_2_RELATION) AS RELEASE2_RELATION
             ,CONVERT(VARCHAR,con.RELEASE_2_PHONE) AS RELEASE2_PHONE           
             ,CONVERT(VARCHAR,con.RELEASE_3_NAME) AS RELEASE3_NAME
             ,CONVERT(VARCHAR,con.RELEASE_3_RELATION) AS RELEASE3_RELATION
             ,CONVERT(VARCHAR,con.RELEASE_3_PHONE) AS RELEASE3_PHONE           
             ,CONVERT(VARCHAR,con.RELEASE_4_NAME) AS RELEASE4_NAME
             ,CONVERT(VARCHAR,con.RELEASE_4_RELATION) AS RELEASE4_RELATION
             ,CONVERT(VARCHAR,con.RELEASE_4_PHONE) AS RELEASE4_PHONE           
             ,CONVERT(VARCHAR,con.RELEASE_5_NAME) AS RELEASE5_NAME
             ,CONVERT(VARCHAR,con.RELEASE_5_RELATION) AS RELEASE5_RELATION
             ,CONVERT(VARCHAR,con.RELEASE_5_PHONE) AS RELEASE5_PHONE                      
       FROM KIPP_NJ..PS$STUDENTS_contact#static con WITH(NOLOCK)
       JOIN KIPP_NJ..PS$STUDENTS_BLObs#static blob WITH(NOLOCK)
         ON con.STUDENTID = blob.STUDENTID
      ) sub
  UNPIVOT(
    value
    FOR field IN (HOME_NAME
                 ,HOME_PHONE
                 ,HOME_EMAIL
                 ,PARENT1_NAME
                 ,PARENT1_RELATION
                 ,PARENT1_HOME
                 ,PARENT1_CELL
                 ,PARENT1_DAY
                 ,PARENT2_NAME
                 ,PARENT2_RELATION
                 ,PARENT2_HOME
                 ,PARENT2_CELL
                 ,PARENT2_DAY
                 ,DOCTOR_NAME
                 ,DOCTOR_PHONE
                 ,EMERG1_NAME
                 ,EMERG1_RELATION
                 ,EMERG1_PHONE
                 ,EMERG2_NAME
                 ,EMERG2_RELATION
                 ,EMERG2_PHONE
                 ,EMERG3_NAME
                 ,EMERG3_RELATION
                 ,EMERG3_PHONE
                 ,EMERG4_NAME
                 ,EMERG4_RELATION
                 ,EMERG4_PHONE
                 ,EMERG5_NAME
                 ,EMERG5_RELATION
                 ,EMERG5_PHONE
                 ,RELEASE1_NAME
                 ,RELEASE1_RELATION
                 ,RELEASE1_PHONE
                 ,RELEASE2_NAME
                 ,RELEASE2_RELATION
                 ,RELEASE2_PHONE
                 ,RELEASE3_NAME
                 ,RELEASE3_RELATION
                 ,RELEASE3_PHONE
                 ,RELEASE4_NAME
                 ,RELEASE4_RELATION
                 ,RELEASE4_PHONE
                 ,RELEASE5_NAME
                 ,RELEASE5_RELATION
                 ,RELEASE5_PHONE)
   ) u
 )

,grades AS (
  /* term grades */
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,gr.academic_year            
        ,gr.rt AS reporting_term
        ,'Term' AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,gr.term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  WHERE gr.academic_year >= 2015
    AND gr.excludefromgpa = 0
  UNION ALL
  SELECT gr.student_number
        ,'GRADES' AS domain
        ,'TERM' AS subdomain
        ,gr.academic_year      
        ,'Y1' AS reporting_term
        ,'Y1' AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,gr.y1_grade_percent_adjusted AS term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)
  WHERE gr.academic_year >= 2015
    AND gr.rn_curterm = 1
    AND gr.excludefromgpa = 0

  UNION ALL
  
  /* category grades */
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
  WHERE gr.academic_year >= 2015    
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
        ,'Exam' AS finalgradename
        ,gr.credittype
        ,gr.course_name
        ,COALESCE(gr.e1, gr.e2) AS term_grade_percent_adjusted
  FROM KIPP_NJ..GRADES$final_grades_long#static gr WITH(NOLOCK)   
  WHERE gr.academic_year >= 2015
    AND gr.schoolid = 73253
    AND (gr.e1 IS NOT NULL OR gr.e2 IS NOT NULL)
    AND gr.excludefromgpa = 0
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
       WHERE att.academic_year >= 2015
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
       WHERE att.academic_year >= 2015
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
  /* overall */
  SELECT a.subject_area        
        ,a.title        
        ,a.academic_year        
        ,res.local_student_id AS student_number
        ,res.percent_correct        
        ,a.assessment_id
        ,'MODULES' AS domain
        ,'OVERALL' AS subdomain
        ,a.scope
        ,NULL standards
        ,res.date_taken AS measure_date
        ,CASE
          WHEN res.percent_correct >= 85 THEN 'Exceeded'
          WHEN res.percent_correct >= 70 THEN 'Met'
          WHEN res.percent_correct >= 50 THEN 'Approached'
          WHEN res.percent_correct >= 35 THEN 'Partially Met'
          WHEN res.percent_correct < 35 THEN 'Did Not Yet Meet'
         END AS proficiency_label
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id
  WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')        
    AND a.academic_year >= 2015

  UNION ALL

  /* standards */
  SELECT a.subject_area        
        ,a.title        
        ,a.academic_year        
        ,res.local_student_id AS student_number
        ,res.percent_correct        
        ,a.assessment_id
        ,'MODULES' AS domain        
        ,'STANDARDS' AS subdomain
        ,a.scope
        ,std.custom_code AS standards
        ,res.updated_at AS measure_date
        ,NULL AS proficiency_label
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id  
  JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
    ON res.standard_id = std.standard_id
  WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
    AND a.subject_area != 'Writing'
    AND a.academic_year >= 2015

  UNION ALL

  /* writing */
  SELECT a.subject_area        
        ,a.title        
        ,a.academic_year        
        ,res.local_student_id AS student_number
        ,res.points AS percent_correct        
        ,a.assessment_id
        ,'MODULES' AS domain        
        ,'WRITING RUBRIC' AS subdomain
        ,a.scope
        ,std.description AS standards
        ,res.updated_at AS measure_date
        ,NULL AS proficiency_label
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id  
   AND res.answered > 0
  JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
    ON res.standard_id = std.standard_id
   AND std.custom_code LIKE 'T_S.W.%'
  WHERE a.scope = 'CMA - End-of-Module'
    AND a.subject_area = 'Writing'  
    AND a.academic_year >= 2015
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
  WHERE academic_year >= 2015

  UNION ALL

  SELECT student_number
        ,'GPA' AS domain
        ,'GPA Y1' AS subdomain
        ,academic_year      
        ,'Y1' AS reporting_term
        ,schoolid
        ,GPA_Y1 AS GPA
  FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)      
  WHERE academic_year >= 2015
    AND is_curterm = 1

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
  /* STEP/F&P */
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

  /* Lexile */
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
        ,NULL AS subdomain                        
        ,academic_year
        ,test_year
        ,term
        ,measurementscale
        ,testritscore
        ,percentile_2015_norms AS testpercentile
  FROM KIPP_NJ..MAP$CDF#identifiers#static WITH(NOLOCK)
  WHERE rn = 1
 )

,standardized_tests AS (
  /* PARCC */
  SELECT parcc.localstudentidentifier AS student_number
        ,parcc.BINI_ID
        ,LEFT(parcc.assessmentyear,4) AS academic_year
        ,NULL AS test_date
        ,'PARCC' AS test_name
        ,parcc.subject                 
        ,parcc.summativescalescore AS scale_score
        ,parcc.summativeperformancelevel AS performance_level
        ,CASE
          WHEN parcc.summativeperformancelevel = 5 THEN 'Exceeded'
          WHEN parcc.summativeperformancelevel = 4 THEN 'Met'
          WHEN parcc.summativeperformancelevel = 3 THEN 'Approached'
          WHEN parcc.summativeperformancelevel = 2 THEN 'Partially Met'
          WHEN parcc.summativeperformancelevel = 1 THEN 'Did Not Meet'
         END AS performance_level_label       
  FROM KIPP_NJ..AUTOLOAD$GDOCS_PARCC_district_summative_record_file parcc WITH(NOLOCK)

  UNION ALL

  /* NJASK & HSPA */
  SELECT nj.student_number
        ,nj.BINI_ID
        ,nj.academic_year
        ,NULL AS test_date
        ,nj.test_name
        ,nj.subject      
        ,nj.scale_score      
        ,CASE 
          WHEN nj.prof_level_numeric = 1 THEN 5 
          WHEN nj.prof_level_numeric = 2 THEN 4
          WHEN nj.prof_level_numeric = 3 THEN 2
         END AS performance_level
        ,nj.prof_level AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$GDOCS_STATE_njask_hspa_scores nj WITH(NOLOCK)
  WHERE nj.void_reason IS NULL

  UNION ALL

  /* ACT */
  SELECT student_number
        ,BINI_ID
        ,academic_year
        ,test_date
        ,test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM
      (
       SELECT hs_student_id AS student_number
             ,BINI_ID
             ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
             ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date
             ,REPLACE(test_type,' (Legacy)','') AS test_name
             ,CONVERT(INT,composite) AS composite
             ,CONVERT(INT,english) AS english
             ,CONVERT(INT,math) AS math
             ,CONVERT(INT,reading) AS reading
             ,CONVERT(INT,science) AS science
             --,CONVERT(INT,COALESCE(writing, writing_sub)) AS writing
       FROM KIPP_NJ..AUTOLOAD$NAVIANCE_3_act_scores WITH(NOLOCK)
      ) sub
  UNPIVOT(
    scale_score
    FOR subject IN (composite
                   ,english
                   ,math
                   ,reading
                   ,science)
   ) u

  UNION ALL

  /* ACT Prep */
  SELECT student_number
        ,NULL AS BINI_ID
        ,academic_year
        ,administered_at AS test_date
        ,'ACT Prep' AS test_name
        ,CASE WHEN subject_area = 'Mathematics' THEN 'Math' ELSE subject_area END AS subject
        ,scale_score
        ,overall_performance_band AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..ACT$test_prep_scores act WITH(NOLOCK)
  WHERE rn_dupe = 1

  UNION ALL
  
  /* SAT */
  SELECT hs_student_id AS student_number
        ,BINI_ID
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
        ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date      
        ,'SAT' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_2_sat_scores WITH(NOLOCK)
  UNPIVOT(
    scale_score
    FOR subject IN (total
                   ,math
                   ,verbal
                   ,writing)
   ) u

  UNION ALL

  /* SAT II */
  SELECT hs_student_id AS student_number
        ,BINI_ID
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
        ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date      
        ,'SAT II' AS test_name      
        ,test_name AS subject
        ,score AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_6_sat2_scores WITH(NOLOCK)

  UNION ALL  

  /* AP */
  SELECT hs_student_id AS student_number
        ,BINI_ID
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
        ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date      
        ,'AP' AS test_name      
        ,test_name AS subject
        ,score AS scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_7_ap_scores WITH(NOLOCK)

  UNION ALL

  /* EXPLORE */
  SELECT hs_student_id
        ,BINI_ID
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
        ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date      
        ,'EXPLORE' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_10_explore_scores WITH(NOLOCK)
  UNPIVOT(
    scale_score
    FOR subject IN (english	
                   ,math
                   ,reading
                   ,science
                   ,composite)
   ) u

  /* PSAT -- this data is garbage, we need to do some major cleanup of the student numbers */
  /*
  SELECT hs_student_id AS student_number
        ,BINI_ID
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END)) AS academic_year
        ,CONVERT(DATE,CASE WHEN test_date = '0000-00-00' THEN NULL ELSE REPLACE(test_date,'-00','-01') END) AS test_date      
        ,'PSAT' AS test_name
        ,subject
        ,scale_score
        ,NULL AS performance_level
        ,NULL AS performance_level_label
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_15_psat_scores WITH(NOLOCK)
  UNPIVOT(
    scale_score
    FOR subject IN (evidence_based_reading_writing
                   ,math
                   ,total)
   ) u
  WHERE ISNUMERIC(hs_student_id) = 1  
  --*/
 )

,collegeapps AS (
  SELECT app.hs_student_id AS student_number
        ,app.collegename              
        ,app.level       
        ,CASE WHEN app.result_code IN ('unknown') OR app.result_code IS NULL THEN app.stage ELSE app.result_code END AS result_code
        ,CONCAT('Type:', CHAR(9), REPLACE(app.inst_control,'p','P'), CHAR(10)
               ,'Attending?', CHAR(9), app.attending, CHAR(10)
               --,app.initial_transcript_sent
               --,app.midyear_transcript_sent
               --,app.final_transcript_sent
               ,app.comments) AS value
        
        ,ROW_NUMBER() OVER(                                
             ORDER BY CASE
                       WHEN Competitiveness_Ranking__c = 'Most Competitive+' THEN 7
                       WHEN Competitiveness_Ranking__c = 'Most Competitive' THEN 6
                       WHEN Competitiveness_Ranking__c = 'Highly Competitive' THEN 5
                       WHEN Competitiveness_Ranking__c = 'Very Competitive' THEN 4
                       WHEN Competitiveness_Ranking__c = 'Noncompetitive' THEN 1
                       WHEN Competitiveness_Ranking__c = 'Competitive' THEN 3
                       WHEN Competitiveness_Ranking__c = 'Less Competitive' THEN 2
                      END DESC, a.Competitiveness_Index__c DESC) AS Competitiveness_Index__c 
        /* potentially useful but not sure what they all mean */
        --,type
        --,waitlisted
        --,deferred      
        --,spec
        --,leg
        --,intv
        --,vis
        --,urg
  FROM KIPP_NJ..AUTOLOAD$NAVIANCE_1_college_applications app WITH(NOLOCK)
  LEFT OUTER JOIN AlumniMirror..Account a WITH(NOLOCK)
    ON app.ceeb_code = a.ceeb_code__C
   AND a.RecordTypeId = '01280000000BQEkAAO'
   AND a.Competitiveness_Index__c IS NOT NULL
  WHERE ISNUMERIC(app.ceeb_code) = 1
 )

,disc_logs AS (
  SELECT studentid
        ,academic_year
        ,RT AS reporting_term
        ,'BEHAVIOR - DISC LOG' AS domain
        ,logtype
        ,subtype
        ,CASE WHEN subtype = 'Perfect Week' THEN COUNT(studentid) * 3 ELSE COUNT(studentid) END AS n_counts
  FROM KIPP_NJ..DISC$log#static WITH(NOLOCK)
  WHERE academic_year >= 2015
    AND logtype IS NOT NULL
    AND subtype IS NOT NULL
  GROUP BY studentid
          ,academic_year
          ,rt
          ,logtype
          ,subtype
 )

,daily_tracking AS (
  SELECT studentid
        ,academic_year
        ,term
        ,'BEHVAIOR - DAILY TRACKING' AS domain
        ,CASE
          WHEN field LIKE 'am%' THEN 'AM'
          WHEN field LIKE 'mid%' THEN 'MID'
          WHEN field LIKE 'pm%' THEN 'PM'
          ELSE 'DAY'
         END AS time_of_day
        ,field
        ,SUM(value) AS n_counts
  FROM KIPP_NJ..DAILY$tracking_long#ES#static WITH(NOLOCK)
  UNPIVOT(
    value
    FOR field IN (purple_pink
                 ,green
                 ,yellow
                 ,orange
                 ,red
                 ,am_purple_pink
                 ,am_green
                 ,am_yellow
                 ,am_orange
                 ,am_red
                 ,mid_purple_pink
                 ,mid_green
                 ,mid_yellow
                 ,mid_orange
                 ,mid_red
                 ,pm_purple_pink
                 ,pm_green
                 ,pm_yellow
                 ,pm_orange
                 ,pm_red)
  ) u
  WHERE academic_year >= 2015
  GROUP BY studentid
          ,academic_year
          ,term
          ,field

  UNION ALL

  SELECT studentid
        ,academic_year
        ,term
        ,'BEHVAIOR - DAILY TRACKING' AS domain
        ,CASE
          WHEN field LIKE 'am%' THEN 'AM'
          WHEN field LIKE 'mid%' THEN 'MID'
          WHEN field LIKE 'pm%' THEN 'PM'
          ELSE 'DAY'
         END AS time_of_day
        ,field
        ,AVG(value) AS n_counts
  FROM KIPP_NJ..DAILY$tracking_long#ES#static WITH(NOLOCK)
  UNPIVOT(
    value
    FOR field IN (has_hw
                 ,has_uniform)
  ) u
  WHERE academic_year >= 2015
  GROUP BY studentid
          ,academic_year
          ,term
          ,field
 )

,promo_status AS (
  SELECT student_number
        ,academic_year
        ,'PROMO STATUS' AS domain
        ,field AS subdomain
        ,CASE WHEN field LIKE '%status%' THEN value ELSE NULL END AS text_value
        ,CASE WHEN field LIKE '%status%' THEN NULL ELSE CONVERT(FLOAT,value) END AS numeric_value
  FROM
      (
       SELECT student_number
             ,academic_year
             ,schoolid             

             /* overall */
             ,CONVERT(VARCHAR,promo_status_overall) AS promo_status_overall             
             
             /* attendance */
             ,CONVERT(VARCHAR,promo_status_attendance) AS promo_status_att
             ,CONVERT(VARCHAR,att_pts_pct) AS att_pts_pct
             ,CONVERT(VARCHAR,days_to_90) AS days_to_90
             ,CONVERT(VARCHAR,days_to_90_abs_only) AS days_to_90_abs_only
             
             /* lit */
             ,CONVERT(VARCHAR,promo_status_lit) AS lit_ARFR_status                   
             ,CONVERT(VARCHAR,cur_read_lvl) AS read_lvl_status
             ,CONVERT(VARCHAR,goal_lvl) AS goal_lvl_status      
             
             /* grades */
             ,CONVERT(VARCHAR,promo_status_grades) AS promo_status_grades /* # failing */                          
             ,CONVERT(VARCHAR,N_below_60) AS n_failing       
             ,CONVERT(VARCHAR,GPA_Y1) AS GPA_Y1_promo                   

             /* credits */
             ,CONVERT(VARCHAR,promo_status_credits) AS promo_status_credits
             ,CONVERT(VARCHAR,credits_enrolled) AS credits_enrolled
             ,CONVERT(VARCHAR,projected_credits_earned) AS projected_credits_earned
             ,CONVERT(VARCHAR,earned_credits_cum) AS earned_credits_cum
       FROM KIPP_NJ..PROMO$promo_status WITH(NOLOCK)
       WHERE academic_year >= 2015
         AND is_curterm = 1       
      ) sub
  UNPIVOT(
    value
    FOR field IN (days_to_90
                 ,days_to_90_abs_only
                 ,att_pts_pct
                 ,n_failing
                 ,promo_status_overall
                 ,promo_status_grades
                 ,promo_status_att
                 ,read_lvl_status
                 ,goal_lvl_status          
                 ,lit_ARFR_status
                 ,promo_status_credits
                 ,credits_enrolled
                 ,projected_credits_earned
                 ,earned_credits_cum
                 ,GPA_Y1_promo)
   ) u
 )

,blended AS (
  SELECT student_number
        ,academic_year
        ,CASE WHEN time_period_name = 'Year' THEN 'Y1' ELSE time_period_name END AS reporting_term
        ,'BLENDED LEARNING' AS domain
        ,'AR' AS subdomain      
        ,CASE WHEN schoolid = 73253 THEN points ELSE words END AS progress
        ,CASE WHEN schoolid = 73253 THEN points_goal ELSE words_goal END AS goal
        ,CASE WHEN schoolid = 73253 THEN stu_status_points ELSE stu_status_words END AS goal_status
  FROM KIPP_NJ..AR$progress_to_goals_long#static WITH(NOLOCK)
  WHERE academic_year >= 2015
 )

,wordwork AS (
  SELECT student_number
        ,academic_year
        ,'Word Work' AS domain
        ,subject_area AS subdomain
        ,listweek_num
        ,word
        ,score
  FROM KIPP_NJ..LIT$word_work_long#static WITH(NOLOCK)
 )

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,CASE WHEN gr.finalgradename = 'Exam' THEN REPLACE(r.term,'Q','X') ELSE r.term END AS term
      ,r.reporting_term      
      ,gr.domain
      ,gr.subdomain      
      ,gr.credittype AS subject
      ,gr.course_name
      ,gr.finalgradename AS measure_name
      ,gr.term_grade_percent_adjusted AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
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
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,att.domain
      ,att.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,att.att_code AS measure_name
      ,att.att_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
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
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,cma.scope AS term
      ,r.reporting_term      
      ,cma.domain
      ,cma.subdomain      
      ,cma.subject_area AS subject
      ,cma.title AS course_name
      ,cma.standards AS measure_name
      ,cma.percent_correct AS measure_value
      ,cma.measure_date
      ,cma.assessment_id AS performance_level
      ,cma.proficiency_label AS performance_level_label
FROM roster r
LEFT OUTER JOIN modules cma
  ON r.student_number = cma.student_number
 AND r.year = cma.academic_year
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,gpa.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,gpa.domain
      ,gpa.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,gpa.GPA AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN gpa
  ON r.student_number = gpa.student_number 
 AND r.schoolid = gpa.schoolid
 AND r.year >= gpa.academic_year
 AND r.reporting_term = gpa.reporting_term

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,lit.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,lit.test_round AS term
      ,r.reporting_term      
      ,lit.domain
      ,lit.subdomain      
      ,NULL AS subject
      ,NULL AS course_name
      ,lit.read_lvl AS measure_name
      ,lit.lvl_num AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN lit
  ON r.student_number = lit.student_number
 AND r.year >= lit.academic_year
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,map.test_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,map.term
      ,r.reporting_term      
      ,map.domain
      ,map.subdomain      
      ,map.measurementscale AS subject
      ,NULL AS course_name
      ,CONVERT(VARCHAR,map.testritscore) AS measure_name
      ,map.testpercentile AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN map
  ON r.student_number = map.student_number
 AND r.year >= map.academic_year
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,std.academic_year AS year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,'STANDARDIZED TESTS' AS domain
      ,std.test_name AS subdomain
      ,std.subject AS subject
      ,NULL AS course_name
      ,CONVERT(VARCHAR,std.BINI_ID) AS measure_name
      ,std.scale_score AS measure_value
      ,std.test_date AS measure_date
      ,std.performance_level
      ,std.performance_level_label
FROM roster r
LEFT OUTER JOIN standardized_tests std
  ON r.student_number = std.student_number
WHERE r.reporting_term = 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,'COLLEGE APPS' AS domain
      ,apps.level AS subdomain
      ,apps.result_code AS subject
      ,apps.collegename AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,apps.competitiveness_index__c AS performance_level
      ,apps.value AS performance_level_label
FROM roster r
LEFT OUTER JOIN collegeapps apps
  ON r.student_number = apps.student_number
WHERE r.reporting_term = 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,logs.domain
      ,logs.logtype AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,logs.subtype AS measure_name
      ,logs.n_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN disc_logs logs
  ON r.studentid = logs.studentid
 AND r.year = logs.academic_year
 AND r.reporting_term = logs.reporting_term
WHERE r.term != 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,daily.domain
      ,daily.field AS subdomain
      ,daily.time_of_day AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,daily.n_counts AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
LEFT OUTER JOIN daily_tracking daily
  ON r.studentid = daily.studentid
 AND r.year = daily.academic_year
 AND r.term = daily.term
WHERE r.term != 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,promo.domain
      ,promo.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,promo.numeric_value AS performance_level
      ,promo.text_value AS performance_level_label
FROM roster r
LEFT OUTER JOIN promo_status promo
  ON r.student_number = promo.student_number 
 AND r.year = promo.academic_year
WHERE r.term = 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,ss.term
      ,r.reporting_term      
      ,'SOCIAL SKILLS' AS domain
      ,NULL AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,ss.social_skill AS measure_name
      ,CONVERT(FLOAT,ss.score) AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN KIPP_NJ..REPORTING$social_skills#ES ss WITH(NOLOCK)
  ON r.student_number = ss.student_number 
 AND r.year = ss.academic_year
 AND r.term = ss.term
 AND ISNUMERIC(ss.score) = 1
WHERE r.term != 'Y1'
  AND r.year >= 2015

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,c.domain
      ,c.type AS subdomain
      ,c.person AS subject
      ,NULL AS course_name
      ,c.value AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN contact c
  ON r.STUDENTID = c.STUDENTID  
WHERE r.term = 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,CONVERT(VARCHAR,ww.listweek_num) AS term
      ,r.reporting_term      
      ,ww.domain
      ,ww.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,ww.word AS measure_name
      ,ww.score AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM roster r
JOIN wordwork ww
  ON r.student_number = ww.student_number
 AND r.year = ww.academic_year
WHERE r.term = 'Y1'

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.year
      ,r.reporting_schoolid AS schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor      
      ,r.spedlep
      ,r.enroll_status
      ,r.term
      ,r.reporting_term      
      ,b.domain
      ,b.subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,b.progress AS measure_value
      ,NULL AS measure_date
      ,b.goal AS performance_level
      ,b.goal_status AS performance_level_label
FROM roster r
JOIN blended b
  ON r.student_number = b.student_number
 AND r.year = b.academic_year
 AND r.reporting_term = b.reporting_term

/* blank row for default */
UNION ALL

SELECT DISTINCT 
       NULL AS studentid
      ,NULL AS student_number
      ,' Choose a student...' AS lastfirst
      ,year
      ,reporting_schoolid AS schoolid
      ,grade_level
      ,NULL AS cohort
      ,NULL AS team
      ,advisor      
      ,'No IEP' AS spedlep
      ,NULL AS enroll_status
      ,NULL AS term
      ,NULL AS reporting_term      
      ,NULL AS domain
      ,NULL AS subdomain
      ,NULL AS subject
      ,NULL AS course_name
      ,NULL AS measure_name
      ,NULL AS measure_value
      ,NULL AS measure_date
      ,NULL AS performance_level
      ,NULL AS performance_level_label
FROM KIPP_NJ..COHORT$identifiers_long#static WITH(NOLOCK)
WHERE year >= 2015
  AND schoolid != 999999