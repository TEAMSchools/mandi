USE SPI
GO

ALTER VIEW REPORTING$SPI_time_series_data AS

WITH scaffold AS (
  SELECT CONVERT(DATE,rd.date) AS date
        ,rd.reporting_hash
        ,sch.abbreviation AS school
        ,sch.school_number AS schoolid
  FROM KIPP_NJ..UTIL$reporting_days rd WITH(NOLOCK)
  JOIN KIPP_NJ..SCHOOLS sch WITH(NOLOCK)
    ON sch.school_number != 999999
   AND 1=1
  WHERE rd.date >= CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year()) + '-08-01'
    AND rd.date <  GETDATE()
    AND rd.day_of_week = 'Monday'    
 )

,off_track AS (
  SELECT 1 AS strand_number
        ,'Student Achievement' AS strand_name
        ,5 AS indicator_number
        ,'Acad. Standing' As indicator_name
        ,1 AS goal_number
        ,'% off track for promotion' AS goal_title
        ,school
        ,reporting_hash
        ,pct_off_track_1 AS value
        ,'GOLF' AS direction
  FROM [SPI].[dbo].[TIME_SERIES_GRADES$weekly_off_track_totals#static] WITH(NOLOCK)
  WHERE grade_level = 'campus'
 )

,lit_ontrack AS (
  SELECT 1 AS strand_number
        ,'Student Achievement' AS strand_name
        ,6 AS indicator_number
        ,'Literacy (ES)' As indicator_name
        ,1 AS goal_number
        ,'EOY Benchmark' AS goal_title
        ,schools.abbreviation
        ,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + RIGHT('0' + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE()) - 1),2) AS reporting_hash
        ,sub.pct_on_track AS value
        ,'FOOTBALL' AS direction
  FROM
      (
       SELECT rs.SCHOOLID
             --,rs.test_round
             ,ROUND(AVG(CONVERT(FLOAT,rs.met_goal)) * 100,0) AS pct_on_track
       FROM KIPP_NJ..LIT$achieved_by_round#static rs WITH(NOLOCK)
       JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
         ON rs.schoolid = d.schoolid
        AND rs.academic_year = d.academic_year
        AND rs.test_round = d.time_per_name
        AND d.identifier = 'LIT'
        AND d.start_date <= CONVERT(DATE,GETDATE())
        AND d.end_date >= CONVERT(DATE,GETDATE())
       WHERE rs.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
         AND GRADE_LEVEL < 5
       GROUP BY rs.SCHOOLID
      ) sub
  JOIN KIPP_NJ..SCHOOLS WITH(NOLOCK)
    ON sub.schoolid = schools.school_number
 )
      
,ar_goals AS (
  --AR met goals
  SELECT 1 AS strand_number
        ,'Student Achievement' AS strand_name
        ,7 AS indicator_number
        ,'Independent Reading' As indicator_name
        ,1 AS goal_number
        ,'% students meeting individual words goal' AS goal_title
        ,schools.abbreviation
        ,CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) + RIGHT('0' + CONVERT(VARCHAR,DATEPART(WEEK,GETDATE()) - 1),2) AS reporting_hash
        ,sub.pct_met_goal AS value
        ,'FOOTBALL' AS direction
  FROM
      (
       SELECT cohort.schoolid
             ,CASE GROUPING(cohort.grade_level)
               WHEN 1 THEN 'campus'
               ELSE CAST(cohort.grade_level AS NVARCHAR)
              END AS grade_level
             ,ROUND(AVG(CONVERT(FLOAT,ar.stu_status_words_numeric)) * 100,0) AS pct_met_goal
       FROM KIPP_NJ..[AR$progress_to_goals_long#static] ar WITH(NOLOCK)
       JOIN KIPP_NJ..COHORT$comprehensive_long#static cohort WITH(NOLOCK)
         ON cohort.studentid = ar.studentid
        AND KIPP_NJ.dbo.YearToTerm(cohort.year) = ar.yearid        
        AND cohort.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
        AND cohort.rn = 1
       WHERE ar.time_hierarchy = 1
       GROUP BY cohort.schoolid
               ,ROLLUP(cohort.grade_level)
      ) sub
  JOIN KIPP_NJ..SCHOOLS WITH(NOLOCK)
    ON sub.schoolid = schools.school_number
  WHERE sub.grade_level = 'campus'
 )
 
       
,attrition AS (      
--attrition -- time series way, mid year
SELECT 2 AS strand_number
      ,'Student Culture & Climate' AS strand_name
      ,2 AS indicator_number
      ,'Student Attrition' As indicator_name
      ,1 AS goal_number
      ,'% students leaving school' AS goal_title
      ,attr.school
      ,attr.reporting_hash
      ,attr.pct_attr AS value
      ,'GOLF' AS direction
FROM SPI..[ATTRITION$weekly_counts#static] attr WITH(NOLOCK)
WHERE attr.grade_level = 'campus'
  AND attr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND attr.weekday_start <= GETDATE()
 )          

/* ATTENDANCE */
,attendance_pct AS (
  --/*
  -- weekly  
  SELECT 2 AS strand_number
        ,'Student Culture & Climate' AS strand_name
        ,3 AS indicator_number
        ,'Attendance' As indicator_name
        ,1 AS goal_number
        ,'Average attendance' AS goal_title
        ,school
        ,reporting_hash
        ,CAST(ROUND((SUM(CONVERT(FLOAT,att)) / SUM(CONVERT(FLOAT,mem))) * 100, 1) AS NUMERIC(4,1)) AS value
        ,'FOOTBALL' AS direction
  FROM SPI..ATT_MEM$attendance_by_week_unbounded#static WITH(NOLOCK)
  WHERE studentid = 'campus'
    AND yearid = KIPP_NJ.dbo.fn_Global_Term_Id()
    AND REPORTING_HASH <= (DATEPART(YEAR,GETDATE()) * 100) + DATEPART(WEEK,GETDATE())
  GROUP BY school
          ,reporting_hash
  --*/

  /*
  -- EOY/max value
  SELECT 2 AS strand_number
        ,'Student Culture & Climate' AS strand_name
        ,3 AS indicator_number
        ,'Student Attendance' As indicator_name
        ,1 AS goal_number
        ,'Average attendance' AS goal_title
        ,sub_1.school
        ,201325 AS reporting_hash
        ,CAST(ROUND((SUM(att + 0.0) / SUM(mem + 0.0)) * 100, 1) AS NUMERIC(4,1)) AS value
  FROM
      (
       SELECT school
              ,MAX(reporting_hash) max_hash
       FROM SPI..ATT_MEM$attendance_by_week_unbounded#static WITH(NOLOCK)
       WHERE studentid = 'campus'
         AND yearid = dbo.fn_Global_Term_Id()
       GROUP BY school
      ) sub_1
  JOIN SPI..ATT_MEM$attendance_by_week_unbounded#static att WITH(NOLOCK)
    ON sub_1.school = att.school
   AND sub_1.max_hash = att.reporting_hash
   AND att.studentid = 'campus'
  GROUP BY sub_1.school
  --*/
 )

,habit_absent AS (      
  --habitually absent                  
  SELECT 2 AS strand_number
        ,'Student Culture & Climate' AS strand_name
        ,3 AS indicator_number
        ,'Attendance' As indicator_name
        ,2 AS goal_number
        ,'% habitually absent' AS goal_title
        ,school
        ,reporting_hash
        ,CAST(ROUND((SUM(CONVERT(FLOAT,off_track)) / SUM(CONVERT(FLOAT,N))) * 100, 1) AS NUMERIC(4,1)) AS value
        ,'GOLF' AS direction
  FROM SPI..ATT_MEM$attendance_by_week_unbounded#static WITH(NOLOCK)
  WHERE studentid = 'campus'
    AND yearid = KIPP_NJ.dbo.fn_Global_Term_ID()
    AND REPORTING_HASH <= (DATEPART(YEAR,GETDATE()) * 100) + DATEPART(WEEK,GETDATE())
  GROUP BY school
          ,reporting_hash      
 )
      
,tardiness AS (      
  --tardiness, granular weekly way      
  SELECT 2 AS strand_number
        ,'Student Culture & Climate' AS strand_name
        ,4 AS indicator_number
        ,'Tardiness' As indicator_name
        ,1 AS goal_number
        ,'Average Tardy' AS goal_title
        ,school
        ,reporting_hash
        ,CAST(ROUND((SUM(CONVERT(FLOAT,tardy)) / SUM(CONVERT(FLOAT,mem))) * 100, 1) AS NUMERIC(4,1)) AS value
        ,'GOLF' AS direction
  FROM SPI..ATT_MEM$tardiness_by_week_unbounded#static WITH(NOLOCK)
  WHERE studentid = 'campus'
    AND yearid = KIPP_NJ.dbo.fn_Global_Term_Id()
    AND REPORTING_HASH <= (DATEPART(YEAR,GETDATE()) * 100) + DATEPART(WEEK,GETDATE())
  GROUP BY school
          ,reporting_hash
 )
      
,habit_tardy AS (
  --habitually tardy              
  SELECT 2 AS strand_number
        ,'Student Culture & Climate' AS strand_name
        ,4 AS indicator_number
        ,'Tardiness' As indicator_name
        ,2 AS goal_number
        ,'% habitually tardy' AS goal_title
        ,school
        ,reporting_hash
        ,CAST(ROUND((SUM(CONVERT(FLOAT,off_track)) / SUM(CONVERT(FLOAT,N))) * 100, 1) AS NUMERIC(4,1)) AS value
        ,'GOLF' AS direction
  FROM SPI..ATT_MEM$tardiness_by_week_unbounded#static WITH(NOLOCK)
  WHERE studentid = 'campus'
    AND yearid = KIPP_NJ.dbo.fn_Global_Term_ID()
    AND REPORTING_HASH <= (DATEPART(YEAR,GETDATE()) * 100) + DATEPART(WEEK,GETDATE())
  GROUP BY school
          ,reporting_hash      
 )

/* DEMOGRAPHICS */
,farm AS (  
  SELECT 4 AS strand_number
        ,'Leadership, Values, and Impact' AS strand_name
        ,1 AS indicator_number
        ,'Stu who need us' As indicator_name
        ,1 AS goal_number
        ,'Free & Reduced' AS goal_title
        ,school
        ,sub.reporting_hash
        ,ROUND((SUM(CONVERT(FLOAT,farm_dummy)) / CONVERT(FLOAT,COUNT(*))) * 100, 1) AS value
        ,'FOOTBALL' AS direction
  FROM
      (
       SELECT scaffold.*
             ,s.lastfirst
             ,CASE WHEN LOWER(s.lunchstatus) IN ('f','r') THEN 1 ELSE 0 END AS farm_dummy
       FROM scaffold WITH(NOLOCK)
       JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
         ON s.ENTRYDATE <= scaffold.date
        AND s.schoolid = scaffold.schoolid
        AND s.exitdate > scaffold.date
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
         ON s.id = cust.studentid       
      ) sub
  GROUP BY sub.date
          ,sub.reporting_hash
          ,sub.school
          ,sub.schoolid
 )

,iep AS (
  SELECT 4 AS strand_number
        ,'Leadership, Values, and Impact' AS strand_name
        ,1 AS indicator_number
        ,'Stu who need us' As indicator_name
        ,2 AS goal_number
        ,'% IEP' AS goal_title
        ,school
        ,sub.reporting_hash
        ,ROUND((SUM(sped_dummy + 0) / CAST(COUNT(*) AS FLOAT)) * 100, 1) AS value
        ,'FOOTBALL' AS direction
  FROM
      (
       SELECT scaffold.*
             ,s.lastfirst
             ,CASE WHEN cust.spedlep LIKE 'SPED%' THEN 1 ELSE 0 END AS sped_dummy  
       FROM scaffold WITH(NOLOCK)
       JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
         ON s.ENTRYDATE <= scaffold.date
        AND s.schoolid = scaffold.schoolid
        AND s.exitdate > scaffold.date
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
         ON s.id = cust.studentid
      ) sub
  GROUP BY sub.date
          ,sub.reporting_hash
          ,sub.school
          ,sub.schoolid
 )

,pct_male AS (
  SELECT 4 AS strand_number
        ,'Leadership, Values, and Impact' AS strand_name
        ,1 AS indicator_number
        ,'Stu who need us' As indicator_name
        ,3 AS goal_number
        ,'% Male' AS goal_title
        ,school
        ,sub.reporting_hash
        ,ROUND((SUM(male_dummy + 0) / CAST(COUNT(*) AS FLOAT)) * 100, 1) AS value
        ,'FOOTBALL' AS direction
  FROM
      (
       SELECT scaffold.*
               ,s.lastfirst
               ,CASE WHEN LOWER(s.gender) = 'm' THEN 1 ELSE 0 END AS male_dummy  
       FROM scaffold WITH(NOLOCK)
       JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
         ON s.ENTRYDATE <= scaffold.date
        AND s.schoolid = scaffold.schoolid
        AND s.exitdate > scaffold.date
       JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
         ON s.id = cust.studentid         
      ) sub
  GROUP BY sub.date
          ,sub.reporting_hash
          ,sub.school
          ,sub.schoolid
 )

,unioned AS (
  SELECT *
  FROM off_track WITH(NOLOCK)
  UNION ALL
  --SELECT *
  --FROM lit_ontrack WITH(NOLOCK)
  --UNION ALL
  SELECT *
  FROM ar_goals WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM attrition WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM attendance_pct WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM habit_absent WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM tardiness WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM habit_tardy WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM farm WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM iep WITH(NOLOCK)
  UNION ALL
  SELECT *
  FROM pct_male WITH(NOLOCK)
 )

SELECT unioned.*
      ,CAST(strand_number AS NVARCHAR) + '|' 
        + strand_name + '@' 
        + indicator_name + '@' 
        + goal_title + '@' 
        + school + '@' 
        + CAST(reporting_hash AS NVARCHAR) 
        AS hash
FROM unioned