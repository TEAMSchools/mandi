USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[ATTRITION$yearly_totals] AS

WITH base_roster AS (
  SELECT c.studentid
        ,c.schoolid
        ,c.grade_level
        ,c.year
        ,c.cohort
        ,c.exitcode
        ,c.exitdate
  FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
  WHERE c.exitdate >= CONVERT(DATE,CONVERT(VARCHAR,c.year) + '-10-15')
    AND (c.year_in_network > 1 OR (c.year_in_network = 1 AND c.exitdate > CONVERT(DATE,CONVERT(VARCHAR,c.year) + '-10-15')))
    AND c.schoolid != 999999    
    AND c.rn = 1    
 )

SELECT CASE GROUPING(schools.abbreviation)
			     WHEN 1 THEN 'network'
			     ELSE schools.abbreviation
			    END AS school
			   ,CASE GROUPING(year)
				    WHEN 1 THEN 'all'
				    ELSE CAST(year AS NVARCHAR)
			    END AS year
      ,CASE GROUPING(grade_level)
				    WHEN 1 THEN 'campus'
				    ELSE CASE WHEN grade_level < 10 THEN '0' + CAST(grade_level AS NVARCHAR) ELSE CAST(grade_level AS NVARCHAR) END
			    END AS grade_level 
      ,100 - CAST(ROUND(AVG(attr_test + 0.0) * 100, 1) AS NUMERIC(4,1)) AS attr_pct
FROM 
    (
     SELECT base_roster.*
           ,CASE
              --don't count grads
              WHEN base_roster.grade_level IN (4, 8) AND base_roster.exitcode = 'G1' THEN 1
              WHEN base_roster.grade_level >= 9 AND base_roster.exitcode = 'G1' THEN 1
              --kids who didn't make it to 10-15 this year get charged against last year
              WHEN c_next.exitdate < CAST(CAST(c_next.year AS varchar) + '-' + CAST(10 AS varchar) + '-' + CAST(15 AS varchar) AS DATETIME) THEN 0
              WHEN c_next.grade_level IS NOT NULL THEN 1
              WHEN c_next.grade_level IS NULL THEN 0
            END as attr_test
     FROM base_roster WITH(NOLOCK)
     LEFT OUTER JOIN base_roster c_next WITH(NOLOCK)
       ON base_roster.studentid = c_next.studentid
      AND base_roster.year + 1 = c_next.year
      --AND c_next.rn = 1
     WHERE base_roster.year < KIPP_NJ.dbo.fn_Global_Academic_Year()
    ) sub
JOIN KIPP_NJ..PS$SCHOOLS#static schools WITH(NOLOCK)
  ON sub.schoolid = schools.school_number
GROUP BY ROLLUP(schools.abbreviation)
        ,ROLLUP(year)
        ,ROLLUP(grade_level)

/*
SELECT 1 AS strand_number
      ,'Student Culture and Climate' AS strand_name
      ,2 AS indicator_number
      ,'Attrition' As indicator_name
      ,1 AS goal_number
      ,'% students leaving school' AS goal_title
      ,attr.school
      ,attr.reporting_hash
      ,attr.pct_attr AS value
FROM SPI..ATTRITION$weekly_counts#static attr
WHERE attr.reporting_hash = 201325
  AND attr.grade_level = 'campus'
  */

GO


