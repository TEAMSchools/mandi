USE KIPP_NJ
GO

ALTER VIEW TABLEAU$SPI_goals_long AS

WITH map_data AS (
  SELECT sub.*
        ,dts.start_date
        ,dts.end_date
        ,ROW_NUMBER() OVER(
           PARTITION BY sub.studentid, sub.year, sub.measurementscale
             ORDER BY dts.start_date DESC) AS rn
  FROM
      (
       SELECT base.studentid
             ,base.year
             ,base.measurementscale                         
             ,growth.end_term_string AS term                   
             ,growth.met_typical_growth_target
             ,growth.end_npr AS testpercentile
             --,growth.growth_percentile
             ,PERCENTILE_DISC(0.5)
                WITHIN GROUP (ORDER BY growth.growth_percentile)
                  OVER(PARTITION BY base.year, growth.end_term_string, base.schoolid, base.grade_level, base.measurementscale) AS median_SGP_gr
             ,PERCENTILE_DISC(0.5)
                WITHIN GROUP (ORDER BY growth.growth_percentile)
                  OVER(PARTITION BY base.year, growth.end_term_string, base.schoolid, base.measurementscale) AS median_SGP_school
       FROM KIPP_NJ..MAP$best_baseline base WITH(NOLOCK)       
       LEFT OUTER JOIN KIPP_NJ..MAP$growth_measures_long#static growth WITH(NOLOCK)
         ON base.studentid = growth.studentid
        AND base.year = growth.year
        AND base.measurementscale = growth.measurementscale
        AND base.termname = growth.start_term_verif
        AND growth.end_term_string != 'Fall'
       WHERE base.year >= 2013
         AND base.measurementscale IN ('Mathematics','Reading')
      ) sub
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
    ON sub.year = dts.academic_year
   AND sub.term = dts.alt_name
   AND dts.identifier = 'MAP'   
  WHERE sub.met_typical_growth_target IS NOT NULL
 )

,attendance AS (
  SELECT mem.STUDENTID
        ,mem.academic_year        
        ,SUM(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) AS n_present
        ,AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) * 100 AS pct_present
        ,CONVERT(FLOAT,CASE WHEN AVG(CONVERT(FLOAT,mem.ATTENDANCEVALUE)) < 0.895 THEN 1.0 ELSE 0.0 END) * 100 AS is_habitually_absent
        ,CONVERT(FLOAT,SUM(CASE 
                            WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NOT NULL THEN 0
                            WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NULL THEN 1
                           END)) AS n_ontime
        ,CONVERT(FLOAT,AVG(CASE 
                            WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NOT NULL THEN 0.0
                            WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NULL THEN 1.0
                           END)) * 100 AS pct_ontime
        ,CONVERT(FLOAT,CASE
                        WHEN AVG(CASE 
                                  WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NOT NULL THEN 0.0
                                  WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NULL THEN 1.0
                                 END) < 0.795 THEN 1 
                        ELSE 0
                       END) * 100 AS is_habitually_tardy
        ,CONVERT(FLOAT,COUNT(mem.calendardate)) AS n_attendance_days      
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)    
  LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE tdy WITH(NOLOCK)
    ON mem.studentid = tdy.STUDENTID
   AND mem.academic_year = tdy.academic_year
   AND mem.CALENDARDATE = tdy.ATT_DATE
   AND tdy.ATT_CODE IN ('T','T10')  
  WHERE mem.academic_year >= 2013
  GROUP BY mem.STUDENTID
          ,mem.academic_year          
 )

,offtrack_grades AS (
  SELECT academic_year
        ,student_number
        ,CASE
          WHEN SUM(CASE 
                    WHEN schoolid = 73253 AND y1_grade_letter LIKE 'F%' THEN 1
                    WHEN schoolid != 73253 AND y1_grade_letter LIKE 'F%' THEN 1
                    ELSE 0
                   END) > 0 THEN 1
          ELSE 0
         END AS is_offtrack_grades
  FROM KIPP_NJ..GRADES$final_grades_long#static WITH(NOLOCK)
  WHERE is_curterm = 1
    AND course_number NOT IN ('HR')
    AND credittype NOT IN ('LOG')
    AND y1_grade_percent_adjusted IS NOT NULL
  GROUP BY academic_year
          ,student_number
 )

,GPA AS (
  SELECT STUDENT_NUMBER
        ,academic_year
        ,CONVERT(FLOAT,GPA_is_above_30) AS GPA_is_above_30
        ,CONVERT(FLOAT,GPA_is_above_35) AS GPA_is_above_35
  FROM
      (
       SELECT student_number                      
             ,academic_year
             ,CASE WHEN ROUND(GPA_y1,1) >= 3.0 THEN 100.0 ELSE 0.0 END AS GPA_is_above_30
             ,CASE WHEN ROUND(GPA_y1,1) >= 3.5 THEN 100.0 ELSE 0.0 END AS GPA_is_above_35
       FROM KIPP_NJ..GRADES$GPA_detail_long#static WITH(NOLOCK)
       WHERE is_curterm = 1       
      ) sub
 )

,es_lit_growth AS (
  SELECT STUDENTID
        ,academic_year              
        ,CONVERT(FLOAT,met_goal * 100) AS met_goal        
  FROM KIPP_NJ..LIT$achieved_by_round#static WITH(NOLOCK)
  WHERE read_lvl IS NOT NULL
    AND is_curterm = 1
    AND start_date <= CONVERT(DATE,GETDATE())
    AND (GRADE_LEVEL <= 4 AND SCHOOLID != 73252)
 )

,module_avg AS (
  SELECT academic_year
        ,student_number
        ,subject_area        
        ,CONVERT(FLOAT,CASE WHEN ROUND(AVG(percent_correct),0) >= 50 THEN 100.0 ELSE 0.0 END) AS module_avg_above_65
        ,CONVERT(FLOAT,CASE WHEN ROUND(AVG(percent_correct),0) >= 70 THEN 100.0 ELSE 0.0 END) AS module_avg_above_80
  FROM
      (
       SELECT a.academic_year
             ,a.subject_area              
             ,ovr.local_student_id AS student_number
             ,ovr.percent_correct
       FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
       JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
         ON a.assessment_id = ovr.assessment_id
        AND ovr.answered > 0
       WHERE a.scope IN ('CMA - End-of-Module')
         AND a.subject_area IN ('Text Study', 'Mathematics')         
      ) sub
  GROUP BY academic_year
          ,student_number
          ,subject_area
 )

,hsr AS (
  SELECT academic_year
        ,schoolid
        ,[Parent] AS hsr_parent_pct_recommend
        ,[Student] AS hsr_student_pct_recommend
  FROM
      (
       SELECT academic_year
             ,schoolid
             ,survey_type      
             ,CONVERT(FLOAT,pct_top_box * 100) AS pct_top_box
       FROM KIPP_NJ..SURVEY$KIPP_HSR_survey_results WITH(NOLOCK)
       WHERE survey_type IN ('Parent','Student')
         AND question_id IN (471, 623) /* I would recommend KIPP... */
      ) sub
  PIVOT(
    MAX(pct_top_box)
    FOR survey_type IN ([Parent], [Student])
   ) p
)

,long_data AS (
  SELECT *
  FROM
      (
       SELECT co.year            
             ,co.schoolid
             ,co.reporting_schoolid
             ,co.grade_level
             ,co.team      
             ,co.student_number
             ,co.lastfirst
             ,co.advisor
             ,co.enroll_status                  
             ,CASE WHEN co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate >= CONVERT(DATE,CONCAT(co.year,'-10-15')) THEN 1 ELSE 0 END AS is_baseline_10_15

             /* demographics */      
             ,CONVERT(FLOAT,CASE WHEN co.LUNCHSTATUS IN ('F','R') THEN 100.0 ELSE 0.0 END) AS is_FR_lunch
             ,CONVERT(FLOAT,CASE WHEN co.SPEDLEP LIKE '%SPED%' THEN 100.0 ELSE 0.0 END) AS is_SPED      

             /* attrition */
             ,CASE
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate <= CONVERT(DATE,GETDATE()) THEN 100.0 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate > CONVERT(DATE,GETDATE()) THEN 0.0
               ELSE CONVERT(FLOAT,attr_kipp.attr_flag) * 100
              END AS attrition_flag_10_15           
             ,CASE
               WHEN co.GENDER != 'M' THEN NULL
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate <= CONVERT(DATE,GETDATE()) THEN 100.0 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate > CONVERT(DATE,GETDATE()) THEN 0.0
               ELSE CONVERT(FLOAT,attr_kipp.attr_flag) * 100
              END AS male_attrition_flag

             /* attendance */
             --,att.n_present
             ,att.pct_present
             ,att.is_habitually_absent      
             --,att.n_ontime
             ,att.pct_ontime
             ,att.is_habitually_tardy
             --,att.n_attendance_days

             /* MAP data -- n/a for dropped students */
             /* MAP goals */
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_read.testpercentile >= 75 THEN NULL
               ELSE CONVERT(FLOAT,map_read.met_typical_growth_target) 
              END * 100 AS map_reading_met_keepup
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_math.testpercentile >= 75 THEN NULL
               ELSE CONVERT(FLOAT,map_math.met_typical_growth_target) 
              END * 100 AS map_math_met_keepup

             /* MAP %ile distribution */
             ,CONVERT(FLOAT,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_read.testpercentile IS NULL THEN NULL
               WHEN map_read.testpercentile >= 75 THEN 1.0
               ELSE 0.0
              END * 100) AS map_reading_is_top_quartile
             ,CONVERT(FLOAT,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_read.testpercentile IS NULL THEN NULL
               WHEN map_read.testpercentile >= 50 THEN 1.0
               ELSE 0.0
              END * 100) AS map_reading_is_top_half
             ,CONVERT(FLOAT,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_math.testpercentile IS NULL THEN NULL               
               WHEN map_math.testpercentile >= 75 THEN 1.0
               ELSE 0.0
              END * 100) AS map_math_is_top_quartile
             ,CONVERT(FLOAT,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               WHEN map_math.testpercentile IS NULL THEN NULL
               WHEN map_math.testpercentile >= 50 THEN 1.0
               ELSE 0.0
              END * 100) AS map_math_is_top_half
             
             /* MAP SGP */
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               ELSE CONVERT(FLOAT,map_read.median_SGP_school) 
              END AS map_reading_SGP_school
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               ELSE CONVERT(FLOAT,map_read.median_SGP_gr) 
              END AS map_reading_SGP_gr             
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               ELSE CONVERT(FLOAT,map_math.median_SGP_school) 
              END AS map_math_SGP_school
             ,CASE 
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL 
               ELSE CONVERT(FLOAT,map_math.median_SGP_gr) 
              END AS map_math_SGP_gr

             /* grades off track */
             ,CONVERT(FLOAT,gr.is_offtrack_grades * 100) AS is_offtrack_grades

             /* TNTP Insight survey */
             ,(tntp.ici_pctile * 100) AS ici_pctile
             ,tntp.learning_environment_index
             ,tntp.observation_feedback_index
             ,tntp.peer_culture_index        
             
             /* manager survey */     
             ,mgr.pct_topbox AS mgr_survey_pct_topbox

             /* Q12 average */
             ,q12.avg_response_value AS q12_avg_response

             /* SPI walkthrough avgs -- some differences btw 2014 & 2015 naming conventions */
             ,wlk.classroom_engagement_overall
             ,wlk.culture_schoolculture_overall            
             ,COALESCE(wlk.classroom_instruction_overall, wlk.classroom_instructionaldelivery_overall) AS classroom_instruction_overall
             ,COALESCE(wlk.classroom_routinesrules_overall, wlk.classroom_management_overall) AS classroom_management_overall

             /* state test date -- 2013 and below = NJASK/HSPA, 2014 and beyond = PARCC */             
             ,nj.ELA03_diff_pct_proficient_weighted
             ,nj.ELA04_diff_pct_proficient_weighted
             ,nj.ELA05_diff_pct_proficient_weighted
             ,nj.ELA06_diff_pct_proficient_weighted
             ,nj.ELA07_diff_pct_proficient_weighted
             ,nj.ELA08_diff_pct_proficient_weighted
             ,nj.ELA09_diff_pct_proficient_weighted
             ,nj.ELA10_diff_pct_proficient_weighted
             ,nj.ELA11_diff_pct_proficient_weighted
             ,nj.MAT03_diff_pct_proficient_weighted
             ,nj.MAT04_diff_pct_proficient_weighted
             ,nj.MAT05_diff_pct_proficient_weighted
             ,nj.MAT06_diff_pct_proficient_weighted
             ,nj.MAT07_diff_pct_proficient_weighted
             ,nj.MAT08_diff_pct_proficient_weighted
             ,nj.ALG01_diff_pct_proficient_weighted
             ,nj.GEO01_diff_pct_proficient_weighted
             ,nj.ALG02_diff_pct_proficient_weighted
             
             ,nj.ELA_median_SGP
             ,nj.Math_median_SGP             

             /* GPA */
             ,gpa.GPA_is_above_30
             ,gpa.GPA_is_above_35

             /* ES lit growth */
             ,lit.met_goal AS met_lit_goal

             /* Module assessments */
             ,ela_mod.module_avg_above_65 AS ela_module_avg_above_65
             ,ela_mod.module_avg_above_80 AS ela_module_avg_above_80
             ,math_mod.module_avg_above_65 AS math_module_avg_above_65
             ,math_mod.module_avg_above_80 AS math_module_avg_above_80

             /* enrollment targets */
             ,enr.diff_from_target AS diff_from_target_enrollment
             ,enr.diff_from_target_fr AS diff_from_target_enrollment_fr
             ,enr.diff_from_target_sped AS diff_from_target_enrollment_sped

             /* teacher attrition */
             ,staff.pct_attrition
             ,staff.pct_unwanted_attrition
             ,staff.pct_wanted_attrition

             /* ACT prep */
             ,CONVERT(FLOAT,COALESCE(act_real.composite, act.composite)) AS act_composite
             ,CONVERT(FLOAT,COALESCE(act_real.is_22, act.is_22) * 100) AS act_pct_is_22
             ,CONVERT(FLOAT,COALESCE(act_real.is_25, act.is_25) * 100) AS act_pct_is_25

             /* HSR survey results */
             ,hsr.hsr_parent_pct_recommend
             ,hsr.hsr_student_pct_recommend
       FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..DEVFIN$mobility_long#KIPP attr_kipp WITH(NOLOCK)
         ON co.studentid = attr_kipp.d_studentid
        AND co.year = attr_kipp.year
       LEFT OUTER JOIN attendance att
         ON co.studentid = att.STUDENTID
        AND co.year = att.academic_year 
       LEFT OUTER JOIN map_data map_read
         ON co.studentid = map_read.studentid
        AND co.year = map_read.year 
        AND map_read.measurementscale = 'Reading'
        AND map_read.rn = 1
       LEFT OUTER JOIN map_data map_math
         ON co.studentid = map_math.studentid
        AND co.year = map_math.year 
        AND map_math.measurementscale = 'Mathematics'
        AND map_math.rn = 1
       LEFT OUTER JOIN offtrack_grades gr
         ON co.student_number = gr.student_number
        AND co.year = gr.academic_year        
       LEFT OUTER JOIN KIPP_NJ..TNTP$ici_scores_wide tntp WITH(NOLOCK)
         ON co.schoolid = tntp.schoolid
        AND co.year = tntp.academic_year
        AND tntp.rn = 1
       LEFT OUTER JOIN KIPP_NJ..SURVEY$manager_survey_averages mgr WITH(NOLOCK)
         ON co.schoolid = mgr.schoolid
        AND co.year = mgr.academic_year
       LEFT OUTER JOIN KIPP_NJ..SURVEY$Q12_averages q12 WITH(NOLOCK)
         ON co.schoolid = q12.schoolid
        AND co.year = q12.academic_year
       LEFT OUTER JOIN KIPP_NJ..SPI$walkthrough_avgs wlk WITH(NOLOCK)
         ON co.schoolid = wlk.schoolid
        AND co.year = wlk.academic_year
        AND wlk.rn = 1
       LEFT OUTER JOIN KIPP_NJ..SPI$state_test_scores nj WITH(NOLOCK)
         ON co.schoolid = nj.schoolid
        AND co.year = nj.academic_year
       LEFT OUTER JOIN GPA
         ON co.student_number = gpa.STUDENT_NUMBER
        AND co.year = gpa.academic_year
       LEFT OUTER JOIN es_lit_growth lit
         ON co.studentid = lit.STUDENTID
        AND co.year = lit.academic_year
       LEFT OUTER JOIN module_avg ela_mod
         ON co.student_number = ela_mod.student_number
        AND co.year = ela_mod.academic_year
        AND ela_mod.subject_area = 'Text Study'
        AND co.schoolid != 73253
       LEFT OUTER JOIN module_avg math_mod
         ON co.student_number = math_mod.student_number
        AND co.year = math_mod.academic_year
        AND math_mod.subject_area = 'Mathematics'
        AND co.schoolid != 73253
       LEFT OUTER JOIN KIPP_NJ..FINANCE$enrollment_targets enr WITH(NOLOCK)
         ON co.year = enr.academic_year
        AND co.schoolid = enr.schoolid
       LEFT OUTER JOIN KIPP_NJ..PEOPLE$staff_attrition_rates staff WITH(NOLOCK)
         ON co.reporting_schoolid = staff.reporting_schoolid
        AND co.year = staff.academic_year
       LEFT OUTER JOIN KIPP_NJ..ACT$test_prep_scores_wide act WITH(NOLOCK)
         ON co.student_number = act.student_number
        AND co.year = act.academic_year
        AND act.rn_curr = 1
       LEFT OUTER JOIN KIPP_NJ..ACT$test_scores act_real WITH(NOLOCK)
         ON co.student_number = act_real.student_number
        AND act_real.rn = 1
       LEFT OUTER JOIN hsr
         ON co.schoolid = hsr.schoolid
        AND co.year = hsr.academic_year
       WHERE co.year >= 2013
         AND co.schoolid != 999999
         AND co.grade_level != 99
         AND co.rn = 1
      ) sub
  UNPIVOT(
    value
    FOR field IN (is_FR_lunch
                 ,is_SPED
                 ,attrition_flag_10_15    
                 ,male_attrition_flag                            
                 ,pct_present
                 ,is_habitually_absent                 
                 ,pct_ontime
                 ,is_habitually_tardy                 
                 ,map_reading_met_keepup
                 ,map_reading_SGP_school
                 ,map_reading_SGP_gr
                 ,map_reading_is_top_quartile
                 ,map_reading_is_top_half
                 ,map_math_met_keepup	
                 ,map_math_SGP_school
                 ,map_math_SGP_gr
                 ,map_math_is_top_quartile
                 ,map_math_is_top_half
                 ,is_offtrack_grades
                 ,ici_pctile
                 ,learning_environment_index
                 ,observation_feedback_index
                 ,peer_culture_index
                 ,mgr_survey_pct_topbox
                 ,q12_avg_response
                 ,culture_schoolculture_overall
                 ,classroom_engagement_overall                 
                 ,classroom_instruction_overall
                 ,classroom_management_overall
                 ,ELA_median_SGP                 
                 ,Math_median_SGP
                 ,ELA03_diff_pct_proficient_weighted
                 ,ELA04_diff_pct_proficient_weighted
                 ,ELA05_diff_pct_proficient_weighted
                 ,ELA06_diff_pct_proficient_weighted
                 ,ELA07_diff_pct_proficient_weighted
                 ,ELA08_diff_pct_proficient_weighted
                 ,ELA09_diff_pct_proficient_weighted
                 ,ELA10_diff_pct_proficient_weighted
                 ,ELA11_diff_pct_proficient_weighted
                 ,MAT03_diff_pct_proficient_weighted
                 ,MAT04_diff_pct_proficient_weighted
                 ,MAT05_diff_pct_proficient_weighted
                 ,MAT06_diff_pct_proficient_weighted
                 ,MAT07_diff_pct_proficient_weighted
                 ,MAT08_diff_pct_proficient_weighted
                 ,ALG01_diff_pct_proficient_weighted
                 ,GEO01_diff_pct_proficient_weighted
                 ,ALG02_diff_pct_proficient_weighted
                 ,GPA_is_above_30
                 ,GPA_is_above_35
                 ,met_lit_goal
                 ,ela_module_avg_above_65
                 ,ela_module_avg_above_80
                 ,math_module_avg_above_65
                 ,math_module_avg_above_80
                 ,diff_from_target_enrollment
                 ,diff_from_target_enrollment_fr
                 ,diff_from_target_enrollment_sped
                 ,pct_attrition
                 ,pct_unwanted_attrition
                 ,pct_wanted_attrition
                 ,act_composite
                 ,act_pct_is_22
                 ,act_pct_is_25
                 ,hsr_parent_pct_recommend
                 ,hsr_student_pct_recommend)
   ) u
 )

SELECT sub.year
      ,sub.schoolid
      ,sub.reporting_schoolid
      ,ISNULL(CONVERT(VARCHAR,sub.grade_level),'All') AS grade_level
      ,sub.field
      ,CASE
        WHEN spi.type = 'pct' THEN ROUND(sub.value,0)
        WHEN spi.type = 'index' THEN ROUND(sub.value,2)
        ELSE sub.value
       END AS value
      ,scoring
      ,ISNULL(points,0) AS points
      ,network_above
      ,network_target
      ,network_low_bar      
      ,network_below
      ,CASE
        WHEN network_target IS NULL THEN NULL       
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_above THEN 'Above'
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_target THEN 'Target'
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_low_bar THEN 'Low Bar'
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_below THEN 'Below'
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_above THEN 'Above'
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_target THEN 'Target'
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_low_bar THEN 'Low Bar'
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_below THEN 'Below'
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_above THEN 'Above'
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_target THEN 'Target'
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_low_bar THEN 'Low Bar'
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_below THEN 'Below'
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_above THEN 'Above'
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_target THEN 'Target'
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_low_bar THEN 'Low Bar'
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_below THEN 'Below'        
        ELSE 'Far Below'
       END AS SPI_status_network
      ,CASE
        WHEN network_target IS NULL THEN NULL                       
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_above THEN points * above_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_target THEN points * target_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_low_bar THEN points * low_bar_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Higher' AND ROUND(value,0) >= network_below THEN points * below_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_above THEN points * above_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_target THEN points * target_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_low_bar THEN points * low_bar_multiplier
        WHEN spi.type = 'pct' AND scoring = 'Lower' AND ROUND(value,0) <= network_below THEN points * below_multiplier
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_above THEN points * above_multiplier
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_target THEN points * target_multiplier
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_low_bar THEN points * low_bar_multiplier
        WHEN spi.type = 'index' AND scoring = 'Higher' AND ROUND(value,2) >= network_below THEN points * below_multiplier
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_above THEN points * above_multiplier
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_target THEN points * target_multiplier
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_low_bar THEN points * low_bar_multiplier
        WHEN spi.type = 'index' AND scoring = 'Lower' AND ROUND(value,2) <= network_below THEN points * below_multiplier        
        ELSE points * far_below_multiplier
       END AS SPI_points_network
FROM
    (
     SELECT long_data.year
           ,long_data.schoolid
           ,long_data.reporting_schoolid
           ,long_data.grade_level           
           ,long_data.field
           ,AVG(long_data.value) AS value           
     FROM long_data     
     GROUP BY long_data.year
             ,long_data.schoolid
             ,long_data.reporting_schoolid
             ,CUBE(long_data.grade_level)
             ,long_data.field             
    ) sub
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_SPI_score_parameters spi WITH(NOLOCK)
  ON sub.schoolid = spi.schoolid
 AND sub.field = spi.field