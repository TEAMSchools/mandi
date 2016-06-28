USE KIPP_NJ
GO

ALTER VIEW TABLEAU$SPI_time_series AS

WITH map_data AS (
  SELECT sub.*
        ,dts.start_date
        ,dts.end_date
  FROM
      (
       SELECT base.studentid
             ,base.year
             ,base.measurementscale            
             --,base.testritscore AS base_RIT
             --,base.testpercentile AS base_pctile
             --,goals.keep_up_goal
             --,goals.keep_up_rit
             --,goals.rutgers_ready_goal
             --,goals.rutgers_ready_rit
             ,growth.end_term_string AS term      
             --,growth.end_rit AS term_RIT
             --,growth.end_npr AS term_pctile
             --,growth.rit_change
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
       WHERE base.measurementscale IN ('Mathematics','Reading')

       /*
       UNION ALL

       SELECT base.studentid
             ,base.year
             ,base.measurementscale            
             ,base.testritscore AS base_RIT
             ,base.testpercentile AS base_pctile
             ,goals.keep_up_goal
             ,goals.keep_up_rit
             ,goals.rutgers_ready_goal
             ,goals.rutgers_ready_rit
             ,'Baseline' AS term      
             ,base.testritscore AS term_RIT
             ,base.testpercentile AS term_pctile
             ,NULL AS rit_change
             ,NULL AS met_typical_growth_target
             ,NULL AS growth_percentile
       FROM KIPP_NJ..MAP$best_baseline base WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
         ON base.studentid = goals.studentid
        AND base.year = goals.year
        AND base.measurementscale = goals.measurementscale
       WHERE base.measurementscale IN ('Mathematics','Reading')
      --*/
      ) sub
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates dts WITH(NOLOCK)
    ON sub.year = dts.academic_year
   AND sub.term = dts.alt_name
   AND dts.identifier = 'MAP'
  WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,attendance AS (
  SELECT mem.STUDENTID
        ,mem.academic_year
        ,MIN(CONVERT(DATE,mem.CALENDARDATE)) AS week_of
        ,SUM(CONVERT(INT,mem.ATTENDANCEVALUE)) AS n_present
        ,SUM(CASE 
              WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NOT NULL THEN 0
              WHEN mem.ATTENDANCEVALUE IS NOT NULL AND tdy.ATT_CODE IS NULL THEN 1
             END) AS n_ontime
        ,COUNT(mem.calendardate) AS n_attendance_days      
  FROM KIPP_NJ..ATT_MEM$MEMBERSHIP mem WITH(NOLOCK)    
  LEFT OUTER JOIN KIPP_NJ..ATT_MEM$ATTENDANCE tdy WITH(NOLOCK)
    ON mem.studentid = tdy.STUDENTID
   AND mem.academic_year = tdy.academic_year
   AND mem.CALENDARDATE = tdy.ATT_DATE
   AND tdy.ATT_CODE IN ('T','T10')
  WHERE mem.academic_year = 2015
  GROUP BY mem.STUDENTID
          ,mem.academic_year
          ,DATEPART(WEEK,mem.calendardate)        
 )

SELECT co.year            
      ,co.schoolid
      ,co.grade_level
      ,co.team      
      ,co.student_number
      ,co.lastfirst
      ,co.advisor
      ,co.enroll_status                  
      ,CASE WHEN co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate >= CONVERT(DATE,CONCAT(co.year,'-10-15')) THEN 1 ELSE 0 END AS is_baseline_10_15

      /* date stuff */      
      ,dates.date AS week_start_date
      ,DATEADD(DAY, 6, dates.date) AS week_end_date
      ,CASE WHEN CONVERT(DATE,GETDATE()) BETWEEN dates.date AND DATEADD(DAY, 6, dates.date) THEN 1 ELSE 0 END AS is_current_week
      ,rt.alt_name AS term

      /* demographics */
      ,co.GENDER
      ,co.ETHNICITY
      ,co.LUNCHSTATUS
      ,co.SPEDLEP
      ,co.lep_status            

      /* attrition */
      ,CASE WHEN co.entrydate <= CONVERT(DATE,CONCAT(co.year,'-10-15')) AND co.exitdate <= CONVERT(DATE,GETDATE()) THEN 1 ELSE 0 END AS attrition_flag_10_15
      ,attr_kipp.attr_flag AS attrition_flag_KIPP

      /* attendance */
      ,att.n_present
      ,att.n_ontime
      ,att.n_attendance_days      

      /* MAP data -- n/a for dropped students */
      ,CASE WHEN co.enroll_status = 0 THEN map_read.met_typical_growth_target ELSE NULL END AS map_reading_met_keepup
      ,CASE WHEN co.enroll_status = 0 THEN map_read.growth_percentile ELSE NULL END AS map_reading_SGP
      ,CASE WHEN co.enroll_status = 0 THEN map_math.met_typical_growth_target ELSE NULL END AS map_math_met_keepup
      ,CASE WHEN co.enroll_status = 0 THEN map_math.growth_percentile ELSE NULL END AS map_math_SGP
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..UTIL$reporting_days#static dates WITH(NOLOCK)
  ON co.year = dates.academic_year
 AND DATEPART(WEEKDAY,dates.date) = 1
 AND dates.date <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates rt WITH(NOLOCK)
  ON co.schoolid = rt.schoolid
 AND dates.date BETWEEN rt.start_date AND rt.end_date
 AND rt.identifier = 'RT'
LEFT OUTER JOIN KIPP_NJ..DEVFIN$mobility_long#KIPP attr_kipp WITH(NOLOCK)
  ON co.studentid = attr_kipp.d_studentid
 AND co.year = attr_kipp.year
LEFT OUTER JOIN attendance att
  ON co.studentid = att.STUDENTID
 AND att.week_of BETWEEN dates.date AND DATEADD(DAY, 6, dates.date)
LEFT OUTER JOIN map_data map_read
  ON co.studentid = map_read.studentid
 AND co.year = map_read.year
 AND dates.date BETWEEN map_read.start_date AND map_read.end_date
 AND map_read.measurementscale = 'Reading'
LEFT OUTER JOIN map_data map_math
  ON co.studentid = map_math.studentid
 AND co.year = map_math.year
 AND dates.date BETWEEN map_math.start_date AND map_math.end_date
 AND map_math.measurementscale = 'Mathematics'
WHERE co.year = 2015
  AND co.schoolid != 999999
  AND co.grade_level != 99
  AND co.rn = 1