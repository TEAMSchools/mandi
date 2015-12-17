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
             ,growth.growth_percentile
       FROM KIPP_NJ..MAP$best_baseline base WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
         ON base.studentid = goals.studentid
        AND base.year = goals.year
        AND base.measurementscale = goals.measurementscale
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
                    WHEN schoolid = 73253 AND moving_average < 70 THEN 1
                    WHEN schoolid != 73253 AND moving_average < 65 THEN 1
                    ELSE 0
                   END) > 0 THEN 1
          ELSE 0
         END AS is_offtrack_grades
  FROM KIPP_NJ..GRADES$time_series WITH(NOLOCK)
  WHERE finalgradename = 'Y1'
    AND date = CONVERT(DATE,GETDATE())
  GROUP BY student_number
          ,academic_year

  UNION ALL

  SELECT academic_year
        ,student_number
        ,CASE WHEN SUM(is_failing) > 0 THEN 1 ELSE 0 END AS is_offtrack_grades
  FROM
      (
       SELECT academic_year
             ,student_number                            
             ,ROW_NUMBER() OVER(
               PARTITION BY student_number, academic_year, course_number
                 ORDER BY date DESC) AS rn
             ,CASE 
               WHEN schoolid = 73253 AND moving_average < 70 THEN 1
               WHEN schoolid != 73253 AND moving_average < 65 THEN 1
               ELSE 0
              END AS is_failing
       FROM KIPP_NJ..GRADES$time_series WITH(NOLOCK)
       WHERE finalgradename = 'Y1'
         AND academic_year < KIPP_NJ.dbo.fn_Global_Academic_Year()  
      ) sub
  WHERE rn = 1
  GROUP BY student_number
          ,academic_year
 )

,curr_manager_survey AS (
  SELECT academic_year
        ,term        
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year
             ORDER BY term DESC) AS rn
  FROM
      (
       SELECT DISTINCT
              academic_year
             ,term       
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'Manager'
         AND is_open_ended = 0
      ) sub
 )

,manager_survey AS (
  SELECT academic_year
        ,schoolid      
        ,(AVG(CONVERT(FLOAT,is_topbox)) * 100) AS pct_topbox
  FROM
      (
       SELECT academic_year
             --,term
             ,subject_name
             --,question_code
             ,CASE WHEN response_value IN (3,4) THEN 1.0 ELSE 0.0 END AS is_topbox
             ,CASE
               WHEN subject_reporting_location = 'Bold Academy' THEN 73258
               WHEN subject_reporting_location = 'Lanning Square Middle School' THEN 179902
               WHEN subject_reporting_location = 'Lanning Square Primary' THEN 179901
               WHEN subject_reporting_location = 'Life Academy' THEN 73257
               WHEN subject_reporting_location = 'Newark Collegiate Academy' THEN 73253
               WHEN subject_reporting_location = 'Rise Academy' THEN 73252
               WHEN subject_reporting_location = 'Seek Academy' THEN 73256
               WHEN subject_reporting_location = 'SPARK Academy' THEN 73254
               WHEN subject_reporting_location = 'TEAM Academy' THEN 133570965
               WHEN subject_reporting_location = 'THRIVE Academy' THEN 73255
              END AS schoolid
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'Manager'
         AND is_open_ended = 0
         AND term IN (SELECT term FROM curr_manager_survey WHERE rn = 1)
      ) sub
  GROUP BY academic_year
          ,schoolid           
 )

,curr_Q12 AS (
  SELECT academic_year
        ,term
        ,ROW_NUMBER() OVER(
           PARTITION BY academic_year
             ORDER BY term DESC) AS rn
  FROM
      (
       SELECT DISTINCT 
              academic_year
             ,term
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'R9'
         AND competency = 'Q12'
      ) sub
 )

,q12_avg AS (
  SELECT academic_year
        ,CASE
          WHEN responder_reporting_location = 'Bold Academy' THEN 73258        
          WHEN responder_reporting_location = 'Lanning Square Middle School' THEN 179902        
          WHEN responder_reporting_location IN ('Life Upper','Life Lower','Pathways','Life Academy') THEN 73257        
          WHEN responder_reporting_location IN ('Newark Collegiate Academy','NCA') THEN 73253        
          WHEN responder_reporting_location IN ('Revolution','Lanning Square Primary') THEN 179901
          WHEN responder_reporting_location IN ('Rise Academy','Rise') THEN 73252        
          WHEN responder_reporting_location IN ('Seek Academy','Seek') THEN 73256        
          WHEN responder_reporting_location IN ('SPARK Academy','SPARK') THEN 73254        
          WHEN responder_reporting_location IN ('TEAM Academy','TEAM') THEN 133570965        
          WHEN responder_reporting_location IN ('THRIVE Academy','THRIVE') THEN 73255        
         END AS schoolid
        ,avg_response_value
  FROM
      (
       SELECT academic_year
             ,responder_reporting_location
             ,AVG(CONVERT(FLOAT,response_value)) AS avg_response_value
       FROM KIPP_NJ..PEOPLE$PM_survey_responses_long#static WITH(NOLOCK)
       WHERE survey_type = 'R9'
         AND competency = 'Q12'
         AND term IN (SELECT term FROM curr_Q12 WHERE rn = 1)
       GROUP BY academic_year
               ,responder_reporting_location

       UNION ALL

       SELECT academic_year      
             ,school
             ,AVG(CONVERT(FLOAT,response)) AS avg_response_value
       FROM KIPP_NJ..AUTOLOAD$GDOCS_SURVEY_historical_q12 WITH(NOLOCK)
       WHERE term_numeric = 3
       GROUP BY academic_year      
               ,school
      ) sub
 )

,long_data AS (
  SELECT *
  FROM
      (
       SELECT co.year            
             ,co.schoolid
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
               WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN CONVERT(FLOAT,CASE WHEN co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate <= CONVERT(DATE,GETDATE()) THEN 100.0 ELSE 0.0 END)
               ELSE CONVERT(FLOAT,attr_kipp.attr_flag) * 100
              END AS attrition_flag_10_15           

             /* attendance */
             --,att.n_present
             ,att.pct_present
             ,att.is_habitually_absent      
             --,att.n_ontime
             ,att.pct_ontime
             ,att.is_habitually_tardy
             --,att.n_attendance_days

             /* MAP data -- n/a for dropped students */
             ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL ELSE CONVERT(FLOAT,map_read.met_typical_growth_target) END * 100 AS map_reading_met_keepup
             ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL ELSE CONVERT(FLOAT,map_read.growth_percentile) END AS map_reading_SGP
             ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL ELSE CONVERT(FLOAT,map_math.met_typical_growth_target) END * 100 AS map_math_met_keepup
             ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() AND co.enroll_status != 0 THEN NULL ELSE CONVERT(FLOAT,map_math.growth_percentile) END AS map_math_SGP

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

             /* SPI walkthrough avgs -- some differences btw 2014 & 2015 scales */
             ,wlk.classroom_engagement_overall
             ,wlk.culture_schoolculture_overall            
             ,COALESCE(wlk.classroom_instruction_overall, wlk.classroom_instructionaldelivery_overall) AS classroom_instruction_overall
             ,COALESCE(wlk.classroom_routinesrules_overall, wlk.classroom_management_overall) AS classroom_management_overall
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
       LEFT OUTER JOIN manager_survey mgr
         ON co.schoolid = mgr.schoolid
        AND co.year = mgr.academic_year
       LEFT OUTER JOIN q12_avg q12
         ON co.schoolid = q12.schoolid
        AND co.year = q12.academic_year
       LEFT OUTER JOIN KIPP_NJ..SPI$walkthrough_avgs wlk WITH(NOLOCK)
         ON co.schoolid = wlk.schoolid
        AND co.year = wlk.academic_year
        AND wlk.rn = 1
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
                 ,pct_present
                 ,is_habitually_absent                 
                 ,pct_ontime
                 ,is_habitually_tardy                 
                 ,map_reading_met_keepup
                 ,map_reading_SGP
                 ,map_math_met_keepup	
                 ,map_math_SGP
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
                 ,classroom_management_overall)
   ) u
 )

SELECT sub.year
      ,sub.schoolid
      ,ISNULL(CONVERT(VARCHAR,sub.grade_level),'All') AS grade_level
      ,sub.field
      ,CASE
        WHEN spi.type = 'pct' THEN ROUND(sub.value,0)
        WHEN spi.type = 'index' THEN ROUND(sub.value,2)
        ELSE sub.value
       END AS value
      ,scoring
      ,points
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
           ,long_data.grade_level           
           ,long_data.field
           ,AVG(long_data.value) AS value           
     FROM long_data     
     GROUP BY long_data.year
             ,long_data.schoolid
             ,CUBE(long_data.grade_level)
             ,long_data.field             
    ) sub
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_SPI_score_parameters spi WITH(NOLOCK)
  ON sub.schoolid = spi.schoolid
 AND sub.field = spi.field