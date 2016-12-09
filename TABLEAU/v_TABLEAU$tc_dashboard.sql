USE KIPP_NJ
GO

ALTER VIEW TABLEAU$tc_dashboard AS

WITH assessment_avgs AS (
  SELECT student_number
        ,academic_year
        ,scope
        ,ROUND([Text Study],0) AS textstudy_avg_pct_correct
        ,CASE
          WHEN ROUND([Text Study],0) >= 70 THEN 1.0
          WHEN ROUND([Text Study],0) < 70 THEN 0.0
         END AS textstudy_is_target
        ,ROUND([Mathematics],0) AS mathematics_avg_pct_correct
        ,CASE
          WHEN ROUND([Mathematics],0) >= 70 THEN 1.0
          WHEN ROUND([Mathematics],0) < 70 THEN 0.0
         END  AS mathematics_is_target
  FROM
      (
       SELECT student_number
             ,academic_year
             ,scope
             ,subject_area
             ,ROUND(AVG(mod_percent_correct),0) AS mod_percent_correct
       FROM
           (
            SELECT student_number
                  ,academic_year
                  ,scope
                  ,subject_area
                  ,module_num
                  ,ROUND(AVG(CONVERT(FLOAT,
                     CASE
                      WHEN scope = 'CMA - End of Module' AND subject_area IN ('Text Study','Social Studies') AND mc_percent_correct IS NOT NULL
                             THEN (ovr_percent_correct * 0.6 * 2) /* weighted SR EOM */
                      WHEN scope = 'CMA - End of Module' AND subject_area IN ('Text Study','Social Studies') AND oer_percent_correct IS NOT NULL
                             THEN (ovr_percent_correct * 0.4 * 2) /* weighted OER EOM */
                      ELSE ovr_percent_correct
                     END)),0) AS mod_percent_correct
            FROM
                (
                 SELECT a.assessment_id
                       ,a.academic_year
                       ,a.scope
                       ,a.subject_area
                       ,a.title
                       ,CASE
                         WHEN PATINDEX('%M[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]/[0-9]%', a.title) + 1, 3)
                         WHEN PATINDEX('%M[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1)
                         WHEN PATINDEX('%U[0-9]/[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]/[0-9]%', a.title) + 1, 3)
                         WHEN PATINDEX('%U[0-9]%', a.title) > 0 THEN SUBSTRING(a.title, PATINDEX('%U[0-9]%', a.title) + 1, 1)
                        END AS module_num
                       ,ovr.local_student_id AS student_number
                       ,ovr.percent_correct AS ovr_percent_correct
                       ,mc.percent_correct AS mc_percent_correct
                       ,oer.percent_correct AS oer_percent_correct
                 FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
                 JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
                   ON a.assessment_id = ovr.assessment_id
                  AND ovr.answered > 0
                 LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static mc WITH(NOLOCK)
                   ON ovr.local_student_id = mc.local_student_id
                  AND a.assessment_id = mc.assessment_id
                  AND mc.reporting_group = 'Multiple Choice'
                 LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_group#static oer WITH(NOLOCK)
                   ON ovr.local_student_id = oer.local_student_id
                  AND a.assessment_id = oer.assessment_id
                  AND oer.reporting_group = 'Open-Ended Response'
                 WHERE a.scope IN ('CMA - End-of-Module')
                   AND a.subject_area IN ('Text Study','Mathematics')
                ) sub
            GROUP BY student_number
                    ,academic_year
                    ,scope
                    ,subject_area
                    ,module_num
           ) sub
       GROUP BY student_number
               ,academic_year
               ,scope
               ,subject_area
      ) sub
  PIVOT (
    MAX(mod_percent_correct)
    FOR subject_area IN ([Text Study],[Mathematics])
   ) p
 )

,parcc AS (
  SELECT student_number
        ,academic_year
        ,[ELA] AS ela_is_prof
        ,[Mathematics] AS math_is_prof
  FROM
      (
       SELECT localstudentidentifier AS student_number
             ,LEFT(assessmentyear,4) AS academic_year
             ,CASE
               WHEN subject = 'English Language Arts/Literacy' THEN 'ELA'
               ELSE 'Mathematics'
              END AS subject
             --,summativeperformancelevel
             ,CASE
               WHEN summativeperformancelevel >= 4 THEN 1.0
               WHEN summativeperformancelevel < 4 THEN 0.0
              END AS is_prof
       FROM KIPP_NJ..PARCC$district_summative_record_file parcc WITH(NOLOCK)
      ) sub
  PIVOT(
    MAX(is_prof)
    FOR subject IN ([ELA],[Mathematics])
   ) p
 )

,map AS (
  SELECT student_number
        ,academic_year
        ,COALESCE([Mathematics_Fall], LAG([Mathematics_Spring], 1) OVER(PARTITION BY student_number ORDER BY academic_year)) AS math_fall_is_top_quartile
        ,[Mathematics_Spring] AS math_spring_is_top_quartile
        ,COALESCE([Reading_Fall], LAG([Reading_Spring], 1) OVER(PARTITION BY student_number ORDER BY academic_year)) AS reading_fall_is_top_quartile
        ,[Reading_Spring] AS reading_spring_is_top_quartile
  FROM
      (
       SELECT map.student_number
             ,map.academic_year
             ,CONCAT(map.measurementscale,'_',map.term) AS pivot_field
             ,CASE
               WHEN map.percentile_2015_norms >= 75 THEN 1.0
               WHEN map.percentile_2015_norms < 75 THEN 0.0
              END AS is_top_quartile
       FROM KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
       WHERE map.measurementscale IN ('Mathematics','Reading')
         AND map.term IN ('Fall','Spring')
         AND map.grade_level <= 2
         AND map.rn = 1
      ) sub
  PIVOT(
    MAX(is_top_quartile)
    FOR pivot_field IN ([Mathematics_Fall],
                        [Mathematics_Spring],
                        [Reading_Fall],
                        [Reading_Spring])
   ) p
 )

,act_real AS (
  SELECT student_number
        ,composite
  FROM KIPP_NJ..NAVIANCE$ACT_clean WITH(NOLOCK)
  WHERE rn_highest = 1
 )

,act_interim AS (
  SELECT student_number
        ,academic_year
        ,COALESCE([ACT5],[ACT4],[ACT3],[ACT2]) - [ACT1] AS act_growth_from_pretest
  FROM
      (
       SELECT student_number
             ,academic_year
             ,CASE
               WHEN time_per_name = 'Pre-Test' THEN 'ACT1'
               WHEN time_per_name = 'Mid-Year' THEN 'ACT2'
               WHEN time_per_name = 'Post-Test' THEN 'ACT3'
               ELSE time_per_name
              END AS time_per_name      
             ,scale_score
       FROM KIPP_NJ..ACT$test_prep_scores WITH(NOLOCK)
       WHERE subject_area = 'Composite'
      ) sub
  PIVOT(
    MAX(scale_score)
    FOR time_per_name IN ([ACT1]
                         ,[ACT2]
                         ,[ACT3]
                         ,[ACT4]
                         ,[ACT5])
   ) p
 )

,attendance AS (
  SELECT mem.STUDENTID
        ,mem.academic_year
        ,SUM(CONVERT(FLOAT,mem.MEMBERSHIPVALUE)) AS total_membership_days
        ,SUM(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) AS total_attendance_days
        ,MAX(CASE WHEN att.ATT_CODE IS NOT NULL THEN 1.0 ELSE 0.0 END) AS is_oss
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE att WITH(NOLOCK)
    ON mem.STUDENTID = att.STUDENTID
   AND mem.CALENDARDATE = att.ATT_DATE
   AND att.ATT_CODE IN ('OSS','S','OS')
  WHERE mem.MEMBERSHIPVALUE = 1
  GROUP BY mem.STUDENTID
          ,mem.academic_year
 )

,attrition AS (
  SELECT student_number
        ,year AS academic_year      
        ,CONVERT(FLOAT,attr_flag) AS attr_flag
  FROM KIPP_NJ..DEVFIN$mobility_long#KIPP WITH(NOLOCK)
 )

,staff AS (
  SELECT CASE WHEN schoolid LIKE '1799%' THEN 1799 ELSE 7325 END AS schoolid
        ,academic_year
        ,SUM(is_teacher) AS N_teachers
        ,SUM(is_staff) AS N_staff
        ,SUM(is_staff_r9) AS N_staff_r9
        ,SUM(is_staff_retention_kipp) AS N_staff_retention_kipp
        ,SUM(is_staff_retention_kipp_baseline) AS N_staff_retention_kipp_baseline
        ,SUM(CASE WHEN is_teacher = 1 THEN is_staff_attrition_midyear END) AS N_staff_attrition_midyear
        ,SUM(CASE WHEN is_teacher = 1 THEN is_staff_attrition_midyear_baseline END) AS N_staff_attrition_midyear_baseline
  FROM
      (
       SELECT CASE
               WHEN location IN ('Lanning Square Primary','Whittier Elementary','Lanning Square MS','Whittier Middle') THEN 1799
               ELSE 7325
              END AS schoolid           
             ,r.n AS academic_year           
             ,CASE
               WHEN job_title IN ('Co-Teacher','Fellow','Lead Teacher','Relay Resident','Temporary Co Teacher') THEN 1
               WHEN job_title LIKE 'Teacher%' THEN 1
               ELSE 0
              END AS is_teacher
             ,CASE
               WHEN location IN ('KIPP NJ','TEAM Schools','Room 9') THEN 0
               WHEN job_title IN ('Co-Teacher','Fellow','Lead Teacher','Relay Resident','Temporary Co Teacher') THEN 0
               WHEN job_title LIKE 'Teacher%' THEN 0
               ELSE 1
              END AS is_staff      
             ,CASE
               WHEN location IN ('KIPP NJ','TEAM Schools','Room 9') THEN 1        
               ELSE 0
              END AS is_staff_r9
             ,CASE 
               WHEN position_start_date > CONVERT(DATE,CONCAT(r.n,'-10-01')) THEN NULL        
               WHEN termination_date < CONVERT(DATE,CONCAT(r.n,'-10-01')) THEN NULL        
               WHEN termination_date IS NULL THEN 1.0
               WHEN position_start_date <= CONVERT(DATE,CONCAT(r.n,'-10-01')) AND termination_date >= CONVERT(DATE,CONCAT((r.n + 1),'-10-01')) THEN 1.0
               ELSE 0.0
              END AS is_staff_retention_kipp
             ,CASE 
               WHEN position_start_date > CONVERT(DATE,CONCAT(r.n,'-10-01')) THEN 0.0
               WHEN termination_date < CONVERT(DATE,CONCAT(r.n,'-10-01')) THEN 0.0                
               ELSE 1.0
              END AS is_staff_retention_kipp_baseline
             ,CASE 
               WHEN position_start_date > CONVERT(DATE,CONCAT(r.n,'-07-15')) THEN NULL        
               WHEN termination_date < CONVERT(DATE,CONCAT(r.n,'-07-15')) THEN NULL        
               WHEN termination_date IS NULL THEN 0.0
               WHEN KIPP_NJ.dbo.fn_DateToSY(termination_date) = r.n AND termination_date >= CONVERT(DATE,CONCAT(r.n,'-07-15')) THEN 1.0
               ELSE 0.0
              END AS is_staff_attrition_midyear
             ,CASE 
               WHEN position_start_date > CONVERT(DATE,CONCAT(r.n,'-07-15')) THEN 0.0
               WHEN termination_date < CONVERT(DATE,CONCAT(r.n,'-07-15')) THEN 0.0
               ELSE 1.0
              END AS is_staff_attrition_midyear_baseline
             --,location
             --,associate_id
             --,preferred_first
             --,preferred_last
             --,job_title      
             --,position_status
             --,KIPP_NJ.dbo.fn_DateToSY(position_start_date) AS start_year
             --,KIPP_NJ.dbo.fn_DateToSY(termination_date) AS end_year
             --,position_start_date
             --,termination_date
       FROM KIPP_NJ..PEOPLE$ADP_detail adp WITH(NOLOCK)
       JOIN KIPP_NJ..UTIL$row_generator r WITH(NOLOCK)
         ON r.n BETWEEN KIPP_NJ.dbo.fn_DateToSY(position_start_date) AND ISNULL(KIPP_NJ.dbo.fn_DateToSY(termination_date), KIPP_NJ.dbo.fn_Global_Academic_Year())
        AND r.n BETWEEN 2002 AND KIPP_NJ.dbo.fn_Global_Academic_Year()
       WHERE adp.rn_curr = 1
      ) sub
  GROUP BY schoolid
          ,academic_year
 )

,engagement_survey AS (
  SELECT academic_year
        ,term
        ,schoolid        
        ,AVG(CONVERT(FLOAT,response_value)) AS avg_response_value
        ,COUNT(DISTINCT responder_name)  AS N_respondents
  FROM
      (
       SELECT academic_year
             ,responder_name
             ,CASE 
               WHEN term = 'Q2' THEN 'Winter'
               WHEN term = 'Q4' THEN 'Spring'
              END AS term
             ,CASE WHEN responder_reporting_location IN ('Lanning Square Primary','Whittier Elementary','Lanning Square MS','Whittier Middle','KCNA') THEN 1799 ELSE 7325 END AS schoolid
             ,response_value
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'R9'
         AND competency = 'Q12'         
      ) sub
  GROUP BY academic_year
          ,schoolid
          ,term
 )

,r9_survey AS (
  SELECT academic_year
        ,survey_round
        ,COUNT(DISTINCT competency) AS n_dept_total
        ,SUM(CASE WHEN pct_agree >= 90 THEN 1.0 ELSE 0.0 END) AS n_dept_90      
        --,ROUND(AVG(CASE WHEN pct_agree >= 90 THEN 1.0 ELSE 0.0 END) * 100,0) AS pct_dept_90
        ,AVG(pct_agree) AS avg_pct_agree
  FROM
      (
       SELECT academic_year
             ,CASE 
               WHEN term = 'Q2' THEN 'Winter'
               WHEN term = 'Q4' THEN 'Spring'
              END AS survey_round
             ,competency
             ,ROUND(AVG(CASE WHEN response_value >= 4 THEN 1.0 ELSE 0.0 END) * 100, 0) AS pct_agree
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'R9'
         AND competency NOT IN ('Q12','R9')
         AND is_open_ended = 0
         AND exclude_from_agg = 'N'
       GROUP BY academic_year
               ,CASE 
                 WHEN term = 'Q2' THEN 'Winter' 
                 WHEN term = 'Q4' THEN 'Spring' 
                END
               ,competency
      ) sub
  GROUP BY academic_year
          ,survey_round
 )

,tntp AS (
  SELECT schoolid
        ,academic_year
        ,SUM(ICI_MOY_is_7) AS N_ICI_7_MOY
        ,SUM(ICI_EOY_is_7) AS N_ICI_7_EOY
  FROM
      (
       SELECT CASE 
               WHEN schoolid LIKE '9%' THEN NULL
               WHEN schoolid LIKE '1799%' THEN 1799 
               ELSE 7325 
              END AS schoolid
             ,academic_year
             --,ROUND([MOY],0) AS ICI_MOY
             ,CASE WHEN ROUND([MOY],0) >= 7 THEN 1 ELSE 0 END AS ICI_MOY_is_7
             --,ROUND([EOY],0) AS ICI_EOY
             ,CASE WHEN ROUND([EOY],0) >= 7 THEN 1 ELSE 0 END AS ICI_EOY_is_7
       FROM KIPP_NJ..TNTP$insight_survey_data_long WITH(NOLOCK)
       PIVOT(
         MAX(value)
         FOR term IN ([MOY],[EOY])
        ) p
       WHERE field = 'Current Instructional Culture Index'
      ) sub
  GROUP BY schoolid
          ,academic_year
 )

,long_data AS (
  SELECT co.student_number
        ,co.lastfirst
        ,co.year AS academic_year
        ,CASE WHEN co.schoolid LIKE '1799%' THEN 'KCNA' ELSE 'TEAM' END AS region
        ,co.reporting_schoolid
        ,co.schoolid
        ,co.grade_level
        ,co.cohort
        ,CASE WHEN co.enroll_status = 0 THEN 1 ELSE 0 END AS is_enrolled_current
        ,CASE WHEN CONVERT(DATE,CONCAT(co.year,'-10-15')) BETWEEN co.entrydate AND co.exitdate THEN 1 ELSE 0 END AS is_enrolled_1015
        /* modules */        
        ,CASE WHEN co.school_level = 'ES' THEN asmt.textstudy_is_target END AS ES_textstudy_is_target
        ,CASE WHEN co.school_level = 'ES' THEN asmt.mathematics_is_target END AS ES_mathematics_is_target
        ,CASE WHEN co.school_level = 'MS' THEN asmt.textstudy_is_target END AS MS_textstudy_is_target
        ,CASE WHEN co.school_level = 'MS' THEN asmt.mathematics_is_target END AS MS_mathematics_is_target
        /* parcc results */
        ,CASE WHEN co.school_level = 'ES' THEN parcc.ela_is_prof END AS ES_parcc_ELA_prof
        ,CASE WHEN co.school_level = 'ES' THEN parcc.math_is_prof END AS ES_parcc_math_prof
        ,CASE WHEN co.school_level = 'MS' THEN parcc.ela_is_prof END AS MS_parcc_ELA_prof
        ,CASE WHEN co.school_level = 'MS' THEN parcc.math_is_prof END AS MS_parcc_math_prof
        /* MAP */
        ,map.math_fall_is_top_quartile
        ,map.math_spring_is_top_quartile
        ,map.reading_fall_is_top_quartile
        ,map.reading_spring_is_top_quartile
        /* ACT */
        ,CASE WHEN co.cohort = (KIPP_NJ.dbo.fn_Global_Academic_Year() + 2) THEN act_real.composite END AS highest_act_jrclass
        ,CASE
          WHEN act_interim.act_growth_from_pretest IS NULL THEN NULL
          WHEN co.cohort = (KIPP_NJ.dbo.fn_Global_Academic_Year() + 2) AND act_interim.act_growth_from_pretest >= 4 THEN 1.0 /* junior class */
          WHEN co.cohort = (KIPP_NJ.dbo.fn_Global_Academic_Year() + 3) AND act_interim.act_growth_from_pretest >= 3 THEN 1.0 /* sophomore class */
          WHEN co.cohort = (KIPP_NJ.dbo.fn_Global_Academic_Year() + 4) AND act_interim.act_growth_from_pretest >= 3 THEN 1.0 /* freshman class */
          ELSE 0.0
         END AS act_meeting_growth_target
        ,CASE
          WHEN act_interim.act_growth_from_pretest IS NULL THEN NULL        
          WHEN co.cohort != (KIPP_NJ.dbo.fn_Global_Academic_Year() + 2) AND act_interim.act_growth_from_pretest >= 3 THEN NULL
          WHEN act_interim.act_growth_from_pretest >= 3 THEN 1.0
          ELSE 0.0
         END AS act_meeting_growth_target_jrclass
        /* attendance */
        ,att.total_attendance_days
        ,att.total_membership_days
        ,att.is_oss
        /* student attrition */
        ,attr.attr_flag      
        /* regional data */
        ,NULL AS N_teachers
        ,NULL AS N_staff
        ,NULL AS N_staff_r9
        ,NULL AS N_staff_retention_kipp
        ,NULL AS N_staff_retention_kipp_baseline
        ,NULL AS N_staff_attrition_midyear
        ,NULL AS N_staff_attrition_midyear_baseline
        ,NULL AS engagement_winter_avg
        ,NULL AS engagement_winter_N
        ,NULL AS engagement_spring_avg
        ,NULL AS engagement_spring_N
        ,NULL AS r9winter_n_dept_total
        ,NULL AS r9winter_n_dept_90
        ,NULL AS r9winter_avg_pct_agree
        ,NULL AS r9spring_n_dept_total
        ,NULL AS r9spring_n_dept_90
        ,NULL AS r9spring_avg_pct_agree
        ,NULL AS N_ICI_7_MOY
        ,NULL AS N_ICI_7_EOY
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)  
  LEFT OUTER JOIN assessment_avgs asmt
    ON co.student_number = asmt.student_number
   AND co.year = asmt.academic_year
  LEFT OUTER JOIN parcc
    ON co.student_number = parcc.student_number
   AND co.year = parcc.academic_year
  LEFT OUTER JOIN map
    ON co.student_number = map.student_number
   AND co.year = map.academic_year
  LEFT OUTER JOIN act_real
    ON co.student_number = act_real.student_number
  LEFT OUTER JOIN act_interim
    ON co.student_number = act_interim.student_number
   AND co.year = act_interim.academic_year
  LEFT OUTER JOIN attendance att
    ON co.studentid = att.STUDENTID
   AND co.year = att.academic_year
  LEFT OUTER JOIN attrition attr
    ON co.student_number = attr.STUDENT_NUMBER
   AND co.year = attr.academic_year
  WHERE co.rn = 1
    AND co.year >= 2015
    AND co.schoolid != 999999

  UNION ALL

  /* Newark regional */
  SELECT 7325 AS student_number
        ,'TEAM' AS lastfirst
        ,r.n AS academic_year
        ,'TEAM' AS region
        ,7325 AS reporting_schoolid
        ,NULL AS schoolid
        ,NULL AS grade_level
        ,NULL AS cohort
        ,NULL AS is_enrolled_current
        ,NULL AS is_enrolled_1015
        /* student data */
        ,NULL AS ES_textstudy_is_target
        ,NULL AS ES_mathematics_is_target
        ,NULL AS MS_textstudy_is_target
        ,NULL AS MS_mathematics_is_target        
        ,NULL AS ES_parcc_ELA_prof
        ,NULL AS ES_parcc_math_prof
        ,NULL AS MS_parcc_ELA_prof
        ,NULL AS MS_parcc_math_prof
        ,NULL AS math_fall_is_top_quartile
        ,NULL AS math_spring_is_top_quartile
        ,NULL AS reading_fall_is_top_quartile
        ,NULL AS reading_spring_is_top_quartile
        ,NULL AS highest_act_jrclass
        ,NULL AS act_meeting_growth_target
        ,NULL AS act_meeting_growth_target_jrclass
        ,NULL AS total_attendance_days
        ,NULL AS total_membership_days
        ,NULL AS is_oss
        ,NULL AS attr_flag
        /* staffing data */
        ,staff.N_teachers
        ,staff.N_staff
        ,staff.N_staff_r9
        ,staff.N_staff_retention_kipp
        ,staff.N_staff_retention_kipp_baseline
        ,staff.N_staff_attrition_midyear
        ,staff.N_staff_attrition_midyear_baseline
        /* Staff Engagement Survey */
        ,es_wint.avg_response_value AS engagement_winter_avg
        ,es_wint.N_respondents AS engagement_winter_N
        ,es_spr.avg_response_value AS engagement_spring_avg
        ,es_spr.N_respondents AS engagement_spring_N
        /* R9 Survey */
        ,r9s_w.n_dept_total AS r9winter_n_dept_total
        ,r9s_w.n_dept_90 AS r9winter_n_dept_90      
        ,r9s_w.avg_pct_agree AS r9winter_avg_pct_agree
        ,r9s_s.n_dept_total AS r9spring_n_dept_total
        ,r9s_s.n_dept_90 AS r9spring_n_dept_90      
        ,r9s_s.avg_pct_agree AS r9spring_avg_pct_agree
        /* TNTP Insight survey */
        ,tntp.N_ICI_7_MOY
        ,tntp.N_ICI_7_EOY
  FROM KIPP_NJ..UTIL$row_generator r WITH(NOLOCK)
  LEFT OUTER JOIN staff
    ON r.n = staff.academic_year
   AND staff.schoolid = 7325
  LEFT OUTER JOIN engagement_survey es_wint
    ON r.n = es_wint.academic_year
   AND es_wint.schoolid = 7325
   AND es_wint.term = 'Winter'
  LEFT OUTER JOIN engagement_survey es_spr
    ON r.n = es_spr.academic_year
   AND es_spr.schoolid = 7325
   AND es_spr.term = 'Spring'
  LEFT OUTER JOIN r9_survey r9s_w
    ON r.n = r9s_w.academic_year
   AND r9s_w.survey_round = 'Winter'
  LEFT OUTER JOIN r9_survey r9s_s
    ON r.n = r9s_s.academic_year
   AND r9s_s.survey_round = 'Spring'
  LEFT OUTER JOIN tntp
    ON r.n = tntp.academic_year
   AND tntp.schoolid = 7325
  WHERE r.n BETWEEN 2015 AND KIPP_NJ.dbo.fn_Global_Academic_Year()

  UNION ALL

  /* Camden regional */
  SELECT 1799 AS student_number
        ,'KCNA' AS lastfirst
        ,r.n AS academic_year
        ,'KCNA' AS region
        ,1799 AS reporting_schoolid
        ,NULL AS schoolid
        ,NULL AS grade_level
        ,NULL AS cohort
        ,NULL AS is_enrolled_current
        ,NULL AS is_enrolled_1015
        /* student data */
        ,NULL AS ES_textstudy_is_target
        ,NULL AS ES_mathematics_is_target
        ,NULL AS MS_textstudy_is_target
        ,NULL AS MS_mathematics_is_target        
        ,NULL AS ES_parcc_ELA_prof
        ,NULL AS ES_parcc_math_prof
        ,NULL AS MS_parcc_ELA_prof
        ,NULL AS MS_parcc_math_prof
        ,NULL AS math_fall_is_top_quartile
        ,NULL AS math_spring_is_top_quartile
        ,NULL AS reading_fall_is_top_quartile
        ,NULL AS reading_spring_is_top_quartile
        ,NULL AS highest_act_jrclass
        ,NULL AS act_meeting_growth_target
        ,NULL AS act_meeting_growth_target_jrclass
        ,NULL AS total_attendance_days
        ,NULL AS total_membership_days
        ,NULL AS is_oss
        ,NULL AS attr_flag
        /* staffing data */
        ,staff.N_teachers
        ,staff.N_staff
        ,staff.N_staff_r9
        ,staff.N_staff_retention_kipp
        ,staff.N_staff_retention_kipp_baseline
        ,staff.N_staff_attrition_midyear
        ,staff.N_staff_attrition_midyear_baseline
        /* Staff Engagement Survey */
        ,es_wint.avg_response_value AS engagement_winter_avg
        ,es_wint.N_respondents AS engagement_winter_N
        ,es_spr.avg_response_value AS engagement_spring_avg
        ,es_spr.N_respondents AS engagement_spring_N
        /* R9 Survey */
        ,NULL AS r9winter_n_dept_total
        ,NULL AS r9winter_n_dept_90      
        ,NULL AS r9winter_avg_pct_agree
        ,NULL AS r9spring_n_dept_total
        ,NULL AS r9spring_n_dept_90      
        ,NULL AS r9spring_avg_pct_agree
        /* TNTP Insight survey */
        ,tntp.N_ICI_7_MOY
        ,tntp.N_ICI_7_EOY
  FROM KIPP_NJ..UTIL$row_generator r WITH(NOLOCK)
  LEFT OUTER JOIN staff
    ON r.n = staff.academic_year
   AND staff.schoolid = 1799
  LEFT OUTER JOIN engagement_survey es_wint
    ON r.n = es_wint.academic_year
   AND es_wint.schoolid = 1799
   AND es_wint.term = 'Winter'
  LEFT OUTER JOIN engagement_survey es_spr
    ON r.n = es_spr.academic_year
   AND es_spr.schoolid = 1799
   AND es_spr.term = 'Spring'
  --LEFT OUTER JOIN r9_survey r9s_w
  --  ON r.n = r9s_w.academic_year
  -- AND r9s_w.survey_round = 'Winter'
  --LEFT OUTER JOIN r9_survey r9s_s
  --  ON r.n = r9s_s.academic_year
  -- AND r9s_s.survey_round = 'Spring'
  LEFT OUTER JOIN tntp
    ON r.n = tntp.academic_year
   AND tntp.schoolid = 1799
  WHERE r.n BETWEEN 2015 AND KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,unpivoted AS (
  SELECT region
        ,academic_year
        ,metric
        ,value
  FROM
      (
       SELECT ISNULL(region,'KNJ') AS region
             ,academic_year
             /* academics */
             ,CONVERT(FLOAT,AVG(ES_textstudy_is_target) * 100) AS ES_textstudy_target_pct
             ,CONVERT(FLOAT,AVG(ES_mathematics_is_target) * 100) AS ES_math_target_pct
             ,CONVERT(FLOAT,AVG(MS_textstudy_is_target) * 100) AS MS_textstudy_target_pct
             ,CONVERT(FLOAT,AVG(MS_mathematics_is_target) * 100) AS MS_math_target_pct
             ,CONVERT(FLOAT,AVG(ES_parcc_ELA_prof) * 100) AS ES_parcc_ELA_prof
             ,CONVERT(FLOAT,AVG(ES_parcc_math_prof) * 100) AS ES_parcc_math_prof
             ,CONVERT(FLOAT,AVG(MS_parcc_ELA_prof) * 100) AS MS_parcc_ELA_prof
             ,CONVERT(FLOAT,AVG(MS_parcc_math_prof) * 100) AS MS_parcc_math_prof
             ,CONVERT(FLOAT,AVG(highest_act_jrclass)) AS avg_highest_act_jrclass
             ,CONVERT(FLOAT,AVG(act_meeting_growth_target) * 100) AS act_meeting_growth_target_pct
             ,CONVERT(FLOAT,AVG(act_meeting_growth_target_jrclass) * 100) AS act_meeting_growth_target_jrclass_pct
             ,CONVERT(FLOAT,AVG(reading_fall_is_top_quartile) * 100) AS reading_fall_top_quartile_pct
             ,CONVERT(FLOAT,AVG(reading_spring_is_top_quartile) * 100) AS reading_spring_top_quartile_pct
             ,CONVERT(FLOAT,AVG(math_fall_is_top_quartile) * 100) AS math_fall_top_quartile_pct
             ,CONVERT(FLOAT,AVG(math_spring_is_top_quartile) * 100) AS math_spring_top_quartile_pct
             ,CONVERT(FLOAT,(SUM(total_attendance_days) / SUM(total_membership_days)) * 100) AS ada      
             /* headline stats */
             ,CONVERT(FLOAT,SUM(is_enrolled_current)) AS N_enrolled_current      
             ,CONVERT(FLOAT,COUNT(DISTINCT schoolid)) AS N_schools
             ,CONVERT(FLOAT,AVG(attr_flag) * 100) AS student_attrition_pct_kipp
             ,CONVERT(FLOAT,AVG(is_oss) * 100) AS oss_pct
             ,CONVERT(FLOAT,SUM(N_teachers)) AS N_teachers
             ,CONVERT(FLOAT,SUM(N_staff)) AS N_staff
             ,CONVERT(FLOAT,SUM(N_staff_r9)) AS N_staff_r9
             /* people */
             ,CONVERT(FLOAT,(SUM(N_staff_retention_kipp) / SUM(N_staff_retention_kipp_baseline)) * 100) AS employee_retention_pct_kipp
             ,CONVERT(FLOAT,(SUM(N_staff_attrition_midyear) / SUM(N_staff_attrition_midyear_baseline)) * 100) AS teacher_attrition_pct_midyear
             ,CONVERT(FLOAT,SUM(engagement_spring_avg * engagement_spring_N) / SUM(engagement_spring_N)) AS engagement_avg_spring
             ,CONVERT(FLOAT,SUM(engagement_winter_avg * engagement_winter_N) / SUM(engagement_winter_N)) AS engagement_avg_winter
             ,CONVERT(FLOAT,SUM(N_ICI_7_MOY)) AS N_schools_ICI_target_MOY
             ,CONVERT(FLOAT,SUM(N_ICI_7_EOY)) AS N_schools_ICI_target_EOY
             ,CONVERT(FLOAT,AVG(r9spring_avg_pct_agree)) AS r9spring_avg_pct_agree
             ,CONVERT(FLOAT,(SUM(r9spring_n_dept_90) / SUM(r9spring_n_dept_total)) * 100) AS r9spring_pct_dept_90
             ,CONVERT(FLOAT,AVG(r9winter_avg_pct_agree)) AS r9winter_avg_pct_agree
             ,CONVERT(FLOAT,(SUM(r9winter_n_dept_90) / SUM(r9winter_n_dept_total)) * 100) AS r9winter_pct_dept_90
       FROM long_data
       GROUP BY CUBE(region)
               ,academic_year
      ) sub
  UNPIVOT(
    value
    FOR metric IN (ES_textstudy_target_pct
                  ,ES_math_target_pct
                  ,MS_textstudy_target_pct
                  ,MS_math_target_pct
                  ,ES_parcc_ELA_prof
                  ,ES_parcc_math_prof
                  ,MS_parcc_ELA_prof
                  ,MS_parcc_math_prof
                  ,avg_highest_act_jrclass
                  ,act_meeting_growth_target_pct
                  ,act_meeting_growth_target_jrclass_pct
                  ,reading_fall_top_quartile_pct
                  ,reading_spring_top_quartile_pct
                  ,math_fall_top_quartile_pct
                  ,math_spring_top_quartile_pct
                  ,ada
                  ,N_enrolled_current
                  ,N_schools
                  ,student_attrition_pct_kipp
                  ,oss_pct
                  ,N_teachers
                  ,N_staff
                  ,N_staff_r9
                  ,employee_retention_pct_kipp
                  ,teacher_attrition_pct_midyear
                  ,engagement_avg_spring
                  ,engagement_avg_winter
                  ,N_schools_ICI_target_MOY
                  ,N_schools_ICI_target_EOY
                  ,r9spring_avg_pct_agree
                  ,r9spring_pct_dept_90
                  ,r9winter_avg_pct_agree
                  ,r9winter_pct_dept_90)
   ) u
 )

SELECT tc.region
      ,tc.academic_year
      ,tc.domain
      ,tc.field_label
      ,tc.goal_name
      ,tc.field_type
      ,tc.goal_value
      ,tc.goal_format
      ,ROUND(u.value,1) AS value
      ,CASE 
        WHEN u.value >= tc.goal_value THEN 1
        WHEN u.value < tc.goal_value THEN -1
        ELSE 0
       END AS met_goal
FROM KIPP_NJ..AUTOLOAD$GDOCS_SPI_tc_dashboard_goals tc WITH(NOLOCK)
LEFT OUTER JOIN unpivoted u
  ON tc.region = u.region
 AND tc.academic_year = u.academic_year
 AND tc.field = u.metric