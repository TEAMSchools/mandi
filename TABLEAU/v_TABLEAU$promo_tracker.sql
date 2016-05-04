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
        ,'Term' AS finalgradename
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
        ,'Y1' AS finalgradename
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
        ,'Exam' AS finalgradename
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

,module_standards AS (
  SELECT a.assessment_id
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(std.custom_code,CHAR(10)) AS standards
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$assessment_standards#static ast WITH(NOLOCK)
    ON a.assessment_id = ast.assessment_id
  JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
    ON ast.standard_id = std.standard_id
  WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
  GROUP BY a.assessment_id
 )

,modules AS (
  SELECT a.subject_area        
        ,a.title        
        ,a.academic_year        
        ,res.local_student_id AS student_number
        ,res.percent_correct        
        ,a.assessment_id
        ,'MODULES' AS domain
        ,'OVERALL' AS subdomain
        ,a.scope
        ,m.standards
        ,res.date_taken AS measure_date
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id
  LEFT OUTER JOIN module_standards m
    ON a.assessment_id = m.assessment_id
  WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

  UNION ALL

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
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard res WITH(NOLOCK)
    ON a.assessment_id = res.assessment_id  
  JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
    ON res.standard_id = std.standard_id
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
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_year()

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
        ,NULL AS subdomain                        
        ,test_year
        ,term
        ,measurementscale
        ,testritscore
        ,testpercentile
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

  UNION ALL
  --*/

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
 )

,collegeapps AS (
  SELECT *
  FROM
      (
       SELECT app.hs_student_id AS student_number
             ,app.collegename              
             ,app.level       
             ,CASE WHEN app.result_code IN ('unknown') OR app.result_code IS NULL THEN app.stage ELSE app.result_code END AS result_code
             ,app.inst_control        
             ,app.attending      
             ,app.initial_transcript_sent
             ,app.midyear_transcript_sent
             ,app.final_transcript_sent
             ,app.comments
        
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
      ) sub
  UNPIVOT(
    value
    FOR field IN (inst_control        
                 ,attending      
                 ,initial_transcript_sent
                 ,midyear_transcript_sent
                 ,final_transcript_sent
                 ,comments)
   ) u
 )

,disc_logs AS (
  SELECT studentid
        ,RT AS reporting_term
        ,'BEHAVIOR - DISC LOG' AS domain
        ,logtype
        ,subtype
        ,CASE WHEN subtype = 'Perfect Week' THEN COUNT(studentid) * 3 ELSE COUNT(studentid) END AS n_counts
  FROM KIPP_NJ..DISC$log#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND logtype IS NOT NULL
    AND subtype IS NOT NULL
  GROUP BY studentid
          ,rt
          ,logtype
          ,subtype
 )

,daily_tracking AS (
  SELECT studentid
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
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY studentid
          ,term
          ,field

  UNION ALL

  SELECT studentid
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
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  GROUP BY studentid
          ,term
          ,field
 )

,promo_status AS (
  SELECT student_number
        ,'PROMO STATUS' AS domain
        ,field AS subdomain
        ,CASE WHEN field LIKE '%status%' THEN value ELSE NULL END AS text_value
        ,CASE WHEN field LIKE '%status%' THEN NULL ELSE CONVERT(FLOAT,value) END AS numeric_value
  FROM
      (
       SELECT student_number
             ,schoolid
             ,CONVERT(VARCHAR,days_to_90) AS days_to_90
             ,CONVERT(VARCHAR,days_to_90_abs_only) AS days_to_90_abs_only
             ,CASE
               WHEN schoolid = 73253 THEN CONVERT(VARCHAR,N_below_70)
               ELSE CONVERT(VARCHAR,N_below_65)
              END AS n_failing
             ,CASE
               WHEN schoolid IN (73252,179902,73253) THEN CONVERT(VARCHAR,promo_overall_rise)
               WHEN schoolid = 133570965 THEN CONVERT(VARCHAR,promo_overall_team)
              END AS promo_status_overall
             ,CASE
               WHEN schoolid IN (73252, 179902,73253) THEN CONVERT(VARCHAR,promo_grades_gpa_rise)
               WHEN schoolid = 133570965 THEN CONVERT(VARCHAR,promo_grades_team)
              END AS promo_status_grades
             ,CASE
               WHEN schoolid IN (73252, 179902,73253) THEN CONVERT(VARCHAR,promo_att_rise)
               WHEN schoolid = 133570965 THEN CONVERT(VARCHAR,promo_att_team)
              END AS promo_status_att
             ,CASE
               WHEN schoolid IN (73252, 179902,73253) THEN CONVERT(VARCHAR,promo_hw_rise)
               WHEN schoolid = 133570965 THEN CONVERT(VARCHAR,promo_hw_team)
              END AS promo_status_hw      
       FROM KIPP_NJ..REPORTING$promo_status#MS WITH(NOLOCK)
       WHERE rn_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (days_to_90
                 ,days_to_90_abs_only
                 ,n_failing
                 ,promo_status_overall
                 ,promo_status_grades
                 ,promo_status_att
                 ,promo_status_hw)
   ) u

  UNION ALL

  SELECT STUDENT_NUMBER
        ,'PROMO STATUS' AS domain
        ,field AS subdomain
        ,CASE WHEN field LIKE '%status%' THEN value ELSE NULL END AS text_value
        ,CASE WHEN field LIKE '%status%' THEN NULL ELSE CONVERT(FLOAT,value) END AS numeric_value
  FROM
      (
       SELECT STUDENT_NUMBER                        
             ,CONVERT(VARCHAR,days_to_90) AS days_to_90
             ,CONVERT(VARCHAR,days_to_90_abs_only) AS days_to_90_abs_only
             ,CONVERT(VARCHAR,lit_ARFR_status) AS lit_ARFR_status      
             ,CONVERT(VARCHAR,att_ARFR_status) AS att_ARFR_status
             ,CONVERT(VARCHAR,CASE 
               WHEN CONCAT(att_ARFR_status,lit_ARFR_status) LIKE '%See Teacher%' THEN 'See Teacher'
               WHEN CONCAT(att_ARFR_status,lit_ARFR_status) LIKE '%ARFR%' THEN 'At Risk for Retention' 
               WHEN CONCAT(att_ARFR_status,lit_ARFR_status) LIKE '%Off Track%' THEN 'Off Track' 
               ELSE 'On Track' 
              END) AS overall_arfr_status
       FROM KIPP_NJ..PROMO$promo_status#ES WITH(NOLOCK)
       WHERE is_curterm = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (days_to_90
                 ,days_to_90_abs_only
                 ,lit_ARFR_status      
                 ,att_ARFR_status
                 ,overall_arfr_status)
   ) u
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
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
      ,cma.scope AS term
      ,r.reporting_term      
      ,cma.domain
      ,cma.subdomain      
      ,cma.subject_area AS subject
      ,cma.title AS course_name
      ,cma.standards AS measure_name
      ,cma.percent_correct AS measure_value
      ,cma.measure_date
      ,NULL AS performance_level
      ,CONVERT(VARCHAR,cma.assessment_id) AS performance_level_label
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
 AND r.reporting_term = gpa.reporting_term

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,lit.academic_year AS year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
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
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,map.test_year AS year
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team
      ,r.advisor
      ,r.HOME_PHONE
      ,r.MOTHER_CELL
      ,r.FATHER_CELL
      ,r.spedlep
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
WHERE r.reporting_term = 'Y1' 

UNION ALL

SELECT r.studentid
      ,r.student_number
      ,r.lastfirst
      ,std.academic_year AS year
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
      ,'COLLEGE APPS' AS domain
      ,apps.level AS subdomain
      ,apps.result_code AS subject
      ,apps.collegename AS course_name
      ,apps.field AS measure_name
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
 AND r.reporting_term = logs.reporting_term
WHERE r.term != 'Y1'

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
 AND r.term = daily.term
WHERE r.term != 'Y1'

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
WHERE r.term = 'Y1'

UNION ALL

SELECT NULL AS studentid
      ,NULL AS student_number
      ,'None' AS lastfirst
      ,NULL AS year
      ,0 AS schoolid
      ,NULL AS grade_level
      ,NULL AS cohort
      ,NULL AS team
      ,NULL AS advisor
      ,NULL AS HOME_PHONE
      ,NULL AS MOTHER_CELL
      ,NULL AS FATHER_CELL
      ,NULL AS spedlep
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