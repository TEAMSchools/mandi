USE SPI
GO

ALTER VIEW REPORTING$SPI_time_series_data AS
SELECT unioned.*
      ,CAST(strand_number AS NVARCHAR) + '|' + strand_name + '@' + indicator_name 
        + '@' + goal_title + '@' + school + '@' + cast(reporting_hash AS NVARCHAR) AS hash
FROM
      (SELECT 1 AS strand_number
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
       
       UNION ALL 
       
       --AR met goals
       SELECT 1 AS strand_number
             ,'Student Achievement' AS strand_name
             ,7 AS indicator_number
             ,'Independent Reading' As indicator_name
             ,1 AS goal_number
             ,'% students meeting individual words goal' AS goal_title
             ,schools.abbreviation
             ,201325 AS reporting_hash
             ,sub.pct_met_goal AS value
             ,'FOOTBALL' AS direction
       FROM
             (SELECT cohort.schoolid
                    ,CASE GROUPING(cohort.grade_level)
                       WHEN 1 THEN 'campus'
                       ELSE CAST(cohort.grade_level AS NVARCHAR)
                     END AS grade_level
                    ,CAST(ROUND(AVG(ar.stu_status_words_numeric + 0.0) * 100,0) AS NUMERIC(4,1)) AS pct_met_goal
              FROM KIPP_NJ..[AR$progress_to_goals_long#static] ar WITH(NOLOCK)
              JOIN KIPP_NJ..COHORT$comprehensive_long cohort WITH(NOLOCK)
                ON cohort.studentid = ar.studentid
               AND ((cohort.year - 1990) * 100) = ar.yearid
               AND ar.time_hierarchy = 1
               AND cohort.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
               AND cohort.rn = 1
               GROUP BY cohort.schoolid
                       ,ROLLUP(cohort.grade_level)
               ) sub
       JOIN KIPP_NJ..SCHOOLS
         ON sub.schoolid = schools.school_number
       WHERE sub.grade_level = 'campus'
       
       UNION ALL
       
       --attrition
 
       --time series way, mid year
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
          
      UNION ALL
      
      --attendance pct
      /*
      --how to get EOY/max value
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
           (SELECT school
                  ,MAX(reporting_hash) max_hash
            FROM SPI..ATT_MEM$attendance_by_week_unbounded#static
            WHERE studentid = 'campus'
              AND yearid = 2300
            GROUP BY school
            ) sub_1
      JOIN SPI..ATT_MEM$attendance_by_week_unbounded#static att
        ON sub_1.school = att.school
       AND sub_1.max_hash = att.reporting_hash
       AND att.studentid = 'campus'
      GROUP BY sub_1.school
      */
      
      --granular weekly way      
      SELECT 2 AS strand_number
            ,'Student Culture & Climate' AS strand_name
            ,3 AS indicator_number
            ,'Attendance' As indicator_name
            ,1 AS goal_number
            ,'Average attendance' AS goal_title
            ,school
            ,reporting_hash
            ,CAST(ROUND((SUM(att + 0.0) / SUM(mem + 0.0)) * 100, 1) AS NUMERIC(4,1)) AS value
            ,'FOOTBALL' AS direction
      FROM SPI..ATT_MEM$attendance_by_week_unbounded#static WITH(NOLOCK)
      WHERE studentid = 'campus'
        AND yearid = KIPP_NJ.dbo.fn_Global_Term_Id()
      GROUP BY school
              ,reporting_hash

      UNION ALL
      
      --habitually absent                  
      SELECT 2 AS strand_number
            ,'Student Culture & Climate' AS strand_name
            ,3 AS indicator_number
            ,'Attendance' As indicator_name
            ,2 AS goal_number
            ,'% habitually absent' AS goal_title
            ,school
            ,reporting_hash
            ,CAST(ROUND((SUM(off_track + 0.0) / SUM(N + 0.0)) * 100, 1) AS NUMERIC(4,1)) AS value
            ,'GOLF' AS direction
      FROM SPI..ATT_MEM$attendance_by_week_unbounded#static WITH(NOLOCK)
      WHERE studentid = 'campus'
        AND yearid = KIPP_NJ.dbo.fn_Global_Term_ID()
      GROUP BY school
              ,reporting_hash      
      
      UNION ALL
      
      --tardiness, granular weekly way      
      SELECT 2 AS strand_number
            ,'Student Culture & Climate' AS strand_name
            ,4 AS indicator_number
            ,'Tardiness' As indicator_name
            ,1 AS goal_number
            ,'Average Tardy' AS goal_title
            ,school
            ,reporting_hash
            ,CAST(ROUND((SUM(tardy + 0.0) / SUM(mem + 0.0)) * 100, 1) AS NUMERIC(4,1)) AS value
            ,'GOLF' AS direction
      FROM SPI..ATT_MEM$tardiness_by_week_unbounded#static WITH(NOLOCK)
      WHERE studentid = 'campus'
        AND yearid = KIPP_NJ.dbo.fn_Global_Term_Id()
      GROUP BY school
              ,reporting_hash

      UNION ALL
      
      --habitually tardy              
      SELECT 2 AS strand_number
            ,'Student Culture & Climate' AS strand_name
            ,4 AS indicator_number
            ,'Tardiness' As indicator_name
            ,2 AS goal_number
            ,'% habitually tardy' AS goal_title
            ,school
            ,reporting_hash
            ,CAST(ROUND((SUM(off_track + 0.0) / SUM(N + 0.0)) * 100, 1) AS NUMERIC(4,1)) AS value
            ,'GOLF' AS direction
      FROM SPI..ATT_MEM$tardiness_by_week_unbounded#static WITH(NOLOCK)
      WHERE studentid = 'campus'
        AND yearid = KIPP_NJ.dbo.fn_Global_Term_ID()
      GROUP BY school
              ,reporting_hash      

      /* DEMOGRAPHICS */
      UNION ALL

      SELECT 4 AS strand_number
            ,'Leadership, Values, and Impact' AS strand_name
            ,1 AS indicator_number
            ,'Stu who need us' As indicator_name
            ,1 AS goal_number
            ,'Free & Reduced' AS goal_title
            ,school
            ,sub.reporting_hash
            ,ROUND((SUM(farm_dummy + 0) / CAST(COUNT(*) AS FLOAT)) * 100, 1) AS value
            ,'FOOTBALL' AS direction
      FROM
            (SELECT TOP 10000000000000000 scaffold.*
                   ,s.lastfirst
                   ,CASE
                      WHEN LOWER(s.lunchstatus) IN ('f','r') THEN 1
                      ELSE 0
                    END AS farm_dummy   
               FROM 
              (SELECT CAST(rd.date AS date) AS date
                     ,rd.reporting_hash
                     ,sch.abbreviation AS school
                     ,sch.school_number AS schoolid
               FROM KIPP_NJ..UTIL$reporting_days rd WITH(NOLOCK)
               JOIN KIPP_NJ..SCHOOLS sch WITH(NOLOCK)
                 ON sch.school_number != 999999
                AND 1=1
               WHERE rd.date >= CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year()) + '-08-01' --'2013-08-05'
                 AND rd.date <  CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) + '-06-30' --'2014-06-22'
                 --AND rd.reporting_hash != 201301
                 AND rd.day_of_week = 'Monday'
               ) scaffold
             JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
               ON s.ENTRYDATE <= scaffold.date
              AND s.schoolid = scaffold.schoolid
              AND s.exitdate > scaffold.date
             JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
               ON s.id = cust.studentid
             ORDER BY scaffold.date
                     ,schoolid
             ) sub
      GROUP BY sub.date
              ,sub.reporting_hash
              ,sub.school
              ,sub.schoolid

      UNION ALL

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
            (SELECT TOP 10000000000000000 scaffold.*
                   ,s.lastfirst
                   ,CASE
                       WHEN cust.spedlep LIKE 'SPED%' THEN 1
                       ELSE 0
                    END AS sped_dummy  
               FROM 
              (SELECT CAST(rd.date AS date) AS date
                     ,rd.reporting_hash
                     ,sch.abbreviation AS school
                     ,sch.school_number AS schoolid
               FROM KIPP_NJ..UTIL$reporting_days rd WITH(NOLOCK)
               JOIN KIPP_NJ..SCHOOLS sch WITH(NOLOCK)
                 ON sch.school_number != 999999
                AND 1=1
               WHERE rd.date >= CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year()) + '-08-01' --'2013-08-05'
                 AND rd.date <  CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) + '-06-30' --'2014-06-22'
                 --AND rd.reporting_hash != 201301
                 AND rd.day_of_week = 'Monday'
               ) scaffold
             JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
               ON s.ENTRYDATE <= scaffold.date
              AND s.schoolid = scaffold.schoolid
              AND s.exitdate > scaffold.date
             JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
               ON s.id = cust.studentid
             ORDER BY scaffold.date
                     ,schoolid
             ) sub
      GROUP BY sub.date
              ,sub.reporting_hash
              ,sub.school
              ,sub.schoolid

      UNION ALL

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
            (SELECT TOP 10000000000000000 scaffold.*
                   ,s.lastfirst
                   ,CASE
                       WHEN LOWER(s.gender) = 'm' THEN 1
                       ELSE 0
                    END AS male_dummy  
               FROM 
              (SELECT CAST(rd.date AS date) AS date
                     ,rd.reporting_hash
                     ,sch.abbreviation AS school
                     ,sch.school_number AS schoolid
               FROM KIPP_NJ..UTIL$reporting_days rd WITH(NOLOCK)
               JOIN KIPP_NJ..SCHOOLS sch WITH(NOLOCK)
                 ON sch.school_number != 999999
                AND 1=1
               WHERE rd.date >= CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year()) + '-08-01' --'2013-08-05'
                 AND rd.date <  CONVERT(VARCHAR,KIPP_NJ.dbo.fn_Global_Academic_Year() + 1) + '-06-30' --'2014-06-22'
                 --AND rd.reporting_hash != 201301
                 AND rd.day_of_week = 'Monday'
               ) scaffold
             JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
               ON s.ENTRYDATE <= scaffold.date
              AND s.schoolid = scaffold.schoolid
              AND s.exitdate > scaffold.date
             JOIN KIPP_NJ..CUSTOM_STUDENTS cust WITH(NOLOCK)
               ON s.id = cust.studentid
             ORDER BY scaffold.date
                     ,schoolid
             ) sub
      GROUP BY sub.date
              ,sub.reporting_hash
              ,sub.school
              ,sub.schoolid
      ) unioned