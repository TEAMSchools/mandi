USE SPI
GO

ALTER VIEW ATTRITION$weekly_counts AS
WITH week_scaffold AS
    (SELECT reporting_hash
           ,year
           ,week
           ,academic_year
           ,weekday_start
           ,weekday_sun AS weekday_end
     FROM KIPP_NJ..UTIL$reporting_weeks_days
     WHERE reporting_hash >= 200232
       AND reporting_hash < 201430
       --no dates before 10-15 in each year
       AND (weekday_start < CAST(CAST(year AS varchar) + '-' + CAST(7 AS varchar) + '-' + CAST(1 AS varchar) AS DATETIME) 
             OR weekday_start >= CAST(CAST(year AS varchar) + '-' + CAST(10 AS varchar) + '-' + CAST(15 AS varchar) AS DATETIME)
           )
     )
    
    ,scrubbed_cohort AS
   (SELECT cohort.studentid
          ,cohort.grade_level
          ,cohort.schoolid
          ,cohort.year
          ,cohort.entrydate
          ,cohort.exitdate
    FROM KIPP_NJ..COHORT$comprehensive_long#static cohort
    WHERE cohort.rn = 1
      AND cohort.schoolid != 999999
      --exitdate must be AFTER 10-15 in given year
      AND cohort.EXITDATE > CAST(CAST(cohort.year AS varchar) + '-' + CAST(10 AS varchar) + '-' + CAST(15 AS varchar) AS DATETIME)
    )

SELECT TOP 10000000000
       reporting_hash
      ,academic_year
      ,week
      ,weekday_start
      ,weekday_end
      ,CASE GROUPING(school)
         WHEN 1 THEN 'network'
         ELSE CAST(school AS NVARCHAR)
       END AS school
      ,CASE GROUPING(grade_level)
         WHEN 1 THEN 'campus'
         ELSE CAST(grade_level AS NVARCHAR)
       END AS grade_level 
      ,CAST(AVG(attr_dummy) * 100 AS NUMERIC (4,1)) AS pct_attr
      ,CAST(SUM(attr_dummy) AS INT) AS n_transf
      ,COUNT(*) AS N
FROM    
   (SELECT wk.reporting_hash
          ,wk.academic_year
          ,wk.week
          ,wk.weekday_start
          ,wk.weekday_end      
          ,cht.schoolid
          ,schools.abbreviation AS school
          ,cht.grade_level
          ,CASE
             WHEN cht.exitdate > wk.weekday_end THEN 0.00
             ELSE 1.00
           END AS attr_dummy
    FROM week_scaffold wk
    JOIN scrubbed_cohort cht
      --join logic is *everyone* who STARTED before this week
      ON cht.entrydate <= wk.weekday_start
     AND wk.academic_year = cht.year
    JOIN KIPP_NJ..schools
      ON cht.schoolid = schools.school_number
    ) sub
    
GROUP BY reporting_hash
        ,academic_year
        ,week
        ,weekday_start
        ,weekday_end
        ,CUBE(school
             ,grade_level)
ORDER BY reporting_hash
        ,school