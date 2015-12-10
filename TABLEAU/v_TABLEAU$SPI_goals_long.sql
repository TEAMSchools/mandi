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
       WHERE base.year >= 2014
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
  WHERE mem.academic_year >= 2014
  GROUP BY mem.STUDENTID
          ,mem.academic_year          
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
       WHERE co.year >= 2014
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
                 ,map_math_SGP)
   ) u
 )

SELECT sub.year
      ,sub.schoolid
      ,ISNULL(CONVERT(VARCHAR,sub.grade_level),'All') AS grade_level
      ,sub.field
      ,sub.value      
      ,scoring
      ,points
      ,network_above
      ,network_target
      ,network_low_bar      
      ,network_below
      ,CASE
        WHEN scoring = 'Higher' AND value >= network_above THEN 'Above'
        WHEN scoring = 'Higher' AND value >= network_target THEN 'Target'
        WHEN scoring = 'Higher' AND value >= network_low_bar THEN 'Low Bar'
        WHEN scoring = 'Higher' AND value >= network_below THEN 'Below'
        WHEN scoring = 'Lower' AND value <= network_above THEN 'Above'
        WHEN scoring = 'Lower' AND value <= network_target THEN 'Target'
        WHEN scoring = 'Lower' AND value <= network_low_bar THEN 'Low Bar'
        WHEN scoring = 'Lower' AND value <= network_below THEN 'Below'
        ELSE 'Far Below'
       END AS SPI_status_network
      ,CASE
        WHEN scoring = 'Higher' AND value >= network_above THEN points * above_multiplier
        WHEN scoring = 'Higher' AND value >= network_target THEN points * target_multiplier
        WHEN scoring = 'Higher' AND value >= network_low_bar THEN points * low_bar_multiplier
        WHEN scoring = 'Higher' AND value >= network_below THEN points * below_multiplier
        WHEN scoring = 'Lower' AND value <= network_above THEN points * above_multiplier
        WHEN scoring = 'Lower' AND value <= network_target THEN points * target_multiplier
        WHEN scoring = 'Lower' AND value <= network_low_bar THEN points * low_bar_multiplier
        WHEN scoring = 'Lower' AND value <= network_below THEN points * below_multiplier
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