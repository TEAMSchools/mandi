USE SPI
GO

ALTER VIEW ATTRITION$weekly_counts AS 

WITH week_scaffold AS (
  SELECT reporting_hash
        ,year
        ,week
        ,academic_year
        ,weekday_start
        ,weekday_sun AS weekday_end
  FROM KIPP_NJ..UTIL$reporting_weeks_days WITH(NOLOCK)
  WHERE weekday_start >= '2002-10-15'
    AND weekday_start <= CONVERT(DATE,CONVERT(VARCHAR,(KIPP_NJ.dbo.fn_Global_Academic_Year() + 1)) + '-06-30')    
    AND (weekday_start < CONVERT(DATE,(CONVERT(VARCHAR,year) + '-07-01')) OR weekday_start >= CONVERT(DATE,(CONVERT(VARCHAR,year) + '-10-15'))) --exclude dates before 10-15 in each year
 )
    
,scrubbed_cohort AS (
  SELECT cohort.studentid
        ,cohort.grade_level
        ,cohort.schoolid
        ,cohort.year
        ,cohort.entrydate
        ,cohort.exitdate
  FROM KIPP_NJ..COHORT$comprehensive_long#static cohort WITH(NOLOCK)
  WHERE cohort.rn = 1
    AND cohort.schoolid != 999999
    --exitdate must be AFTER 10-15 in given year
    AND cohort.EXITDATE > CONVERT(DATE,(CONVERT(VARCHAR,year) + '-10-15'))
 )

SELECT reporting_hash
      ,academic_year
      ,week
      ,weekday_start
      ,weekday_end
      ,CASE GROUPING(school) WHEN 1 THEN 'network' ELSE CAST(school AS NVARCHAR) END AS school
      ,CASE GROUPING(grade_level) WHEN 1 THEN 'campus' ELSE CAST(grade_level AS NVARCHAR) END AS grade_level 
      ,CAST(AVG(attr_dummy) * 100 AS NUMERIC (4,1)) AS pct_attr
      ,CAST(SUM(attr_dummy) AS INT) AS n_transf
      ,COUNT(*) AS N		
FROM    
    (
     SELECT wk.reporting_hash
           ,wk.academic_year
           ,wk.week
           ,wk.weekday_start
           ,wk.weekday_end      
           ,cht.schoolid
           ,schools.abbreviation AS school
           ,cht.grade_level
           ,CASE WHEN cht.exitdate > wk.weekday_end THEN 0.0 ELSE 1.0 END AS attr_dummy
     FROM week_scaffold wk WITH(NOLOCK)
     JOIN scrubbed_cohort cht WITH(NOLOCK)
       ON cht.entrydate <= wk.weekday_start --join logic is *everyone* who STARTED before this week
      AND wk.academic_year = cht.year
     JOIN KIPP_NJ..schools WITH(NOLOCK)
       ON cht.schoolid = schools.school_number
    ) sub    
GROUP BY reporting_hash
        ,academic_year
        ,week
        ,weekday_start
        ,weekday_end
        ,CUBE(school
             ,grade_level)