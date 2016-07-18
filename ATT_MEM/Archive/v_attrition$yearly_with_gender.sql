USE KIPP_NJ
GO

ALTER VIEW ATTRITION$yearly_with_gender_and_MAP AS

WITH base_roster AS
    (SELECT c.studentid
           ,c.schoolid
           ,c.grade_level
           ,s.gender
           ,c.year
           ,c.cohort
           ,c.exitcode
     FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
     JOIN KIPP_NJ..STUDENTS s WITH(NOLOCK)
       ON c.studentid = s.id
     WHERE c.exitdate >= CAST(CAST(c.year AS varchar) + '-' + CAST(10 AS varchar) + '-' + CAST(15 AS varchar) AS DATETIME)
      AND c.schoolid != 999999
      AND c.rn = 1
     )

SELECT CASE GROUPING(schools.abbreviation)
			      WHEN 1 THEN 'network'
			      ELSE schools.abbreviation
			    END AS school
			   ,CASE GROUPING(year)
				     WHEN 1 THEN 'all'
				     ELSE 
				       CAST(year AS NVARCHAR)
			    END AS year
      ,CASE GROUPING(sub.grade_level)
				     WHEN 1 THEN 'campus'
				     ELSE 
				       CASE 
				         WHEN sub.grade_level < 10 THEN '0' + CAST(sub.grade_level AS NVARCHAR)
				         ELSE CAST(sub.grade_level AS NVARCHAR)
				       END
			   END AS grade_level 
			  ,CASE GROUPING(gender)
				     WHEN 1 THEN 'all'
				     ELSE 
				       gender
			    END AS gender
      ,100 - CAST(ROUND(AVG(attr_test + 0.0) * 100, 1) AS NUMERIC(4,1)) AS attr_pct
      ,COUNT(*) AS n
      ,SUM(
         CASE
           WHEN sub.attr_test = 0 THEN 1
         END) AS n_leavers
      ,SUM(
         CASE
           WHEN sub.attr_test = 1 THEN 1
         END) AS n_stayers
      ,AVG(
         CASE
           WHEN sub.attr_test = 0 THEN m_math.percentile_2011_norms
         END) AS math_npr_leavers
      ,AVG(
         CASE
           WHEN sub.attr_test = 1 THEN m_math.percentile_2011_norms
         END) AS math_npr_stayers
      ,AVG(
         CASE
           WHEN sub.attr_test = 0 THEN m_reading.percentile_2011_norms
         END) AS read_npr_leavers
      ,AVG(
         CASE
           WHEN sub.attr_test = 1 THEN m_reading.percentile_2011_norms
         END) AS read_npr_stayers
      --njask
      ,ROUND(AVG(
         CASE
           WHEN sub.attr_test = 0 THEN njask_math.njask_scale_score
         END),1) AS njask_math_scale_leavers
      ,ROUND(AVG(
         CASE
           WHEN sub.attr_test = 1 THEN njask_math.njask_scale_score
         END),1) AS njask_math_scale_stayers
      ,ROUND(AVG(
         CASE
           WHEN sub.attr_test = 0 THEN njask_ela.njask_scale_score
         END),1) AS njask_ela_scale_leavers
      ,ROUND(AVG(
         CASE
           WHEN sub.attr_test = 1 THEN njask_ela.njask_scale_score
         END),1) AS njask_ela_scale_stayers
FROM 
      (SELECT base_roster.*
             ,CASE
                --don't count grads
                WHEN base_roster.grade_level IN (4, 8, 11) AND base_roster.exitcode = 'G1' THEN 1
                --kids who didn't make it to 10-15 this year get charged against last year
                WHEN c_next.exitdate < CAST(CAST(c_next.year AS varchar) + '-' + CAST(10 AS varchar) + '-' + CAST(15 AS varchar) AS DATETIME) THEN 0
                WHEN c_next.grade_level IS NOT NULL THEN 1
                WHEN c_next.grade_level IS NULL THEN 0
              END as attr_test
       FROM base_roster WITH(NOLOCK)
       LEFT OUTER JOIN KIPP_NJ..COHORT$comprehensive_long#static c_next WITH(NOLOCK)
         ON base_roster.studentid = c_next.studentid
        AND base_roster.year + 1 = c_next.year
        AND c_next.rn = 1
       WHERE base_roster.year < 2014
       ) sub
JOIN KIPP_NJ..SCHOOLS WITH(NOLOCK)
  ON sub.schoolid = schools.school_number
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static m_math WITH(NOLOCK)
  ON sub.studentid = m_math.ps_studentid
 AND sub.year = m_math.map_year_academic
 AND m_math.fallwinterspring = 'Spring'
 AND m_math.measurementscale = 'Mathematics'
 AND m_math.rn = 1
LEFT OUTER JOIN KIPP_NJ..MAP$comprehensive#identifiers#static m_reading WITH(NOLOCK)
  ON sub.studentid = m_reading.ps_studentid
 AND sub.year = m_reading.map_year_academic
 AND m_reading.fallwinterspring = 'Spring'
 AND m_reading.measurementscale = 'Reading'
 AND m_reading.rn = 1
LEFT OUTER JOIN KIPP_NJ..aa_delete_after_2014_09_01_bride_of_frankenstein_unified_njask njask_math WITH(NOLOCK)
  ON sub.studentid = njask_math.studentid
 AND sub.year = njask_math.test_year
 AND njask_math.subject = 'Math'
LEFT OUTER JOIN KIPP_NJ..aa_delete_after_2014_09_01_bride_of_frankenstein_unified_njask njask_ela WITH(NOLOCK)
  ON sub.studentid = njask_ela.studentid
 AND sub.year = njask_ela.test_year
 AND njask_ela.subject = 'ELA'
GROUP BY ROLLUP(schools.abbreviation)
        ,ROLLUP(year)
        ,ROLLUP(sub.grade_level)
        ,ROLLUP(gender)

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
