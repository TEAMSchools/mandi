USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_tool AS

WITH map_long AS (  
  SELECT base.studentid        
        ,base.student_number
        ,base.year
        ,base.schoolid
        ,base.grade_level
        ,'Baseline' AS term                
        ,base.measurementscale
        ,base.testid
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct        
        ,CONVERT(INT,REPLACE(base.lexile_score,'BR',0)) AS base_lex        
        ,base.testpercentile AS pct
        ,base.testritscore AS rit      
        ,REPLACE(base.lexile_score, 'BR', 0) AS lex      
        ,NULL AS testdurationminutes
  FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
  
  UNION ALL
  
  SELECT base.studentid                
        ,base.student_number
        ,base.year
        ,base.schoolid
        ,base.grade_level                     
        ,map.term
        ,base.measurementscale
        ,map.TestID
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,CONVERT(INT,REPLACE(base.lexile_score,'BR',0)) AS base_lex                
        ,map.percentile_2015_norms AS pct
        ,map.testritscore AS rit      
        ,REPLACE(map.rittoreadingscore, 'BR', 0) AS lex      
        ,map.TestDurationMinutes
  FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)  
  LEFT OUTER JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
    ON base.studentid = map.studentid
   AND base.year = map.academic_year
   AND base.measurementscale = map.measurementscale   
   AND map.rn = 1
 )

SELECT sub.*      
      ,domain.testname AS domain_testname
      ,ISNULL(domain.goal_number, 1) AS goal_number
      ,domain.name AS domain_name
      ,domain.ritscore
      ,domain.range      
      ,domain.adjective
FROM
    (
     SELECT r.year
           ,r.studentid
           ,r.student_number
           ,r.lastfirst
           ,r.reporting_schoolid AS schoolid
           ,r.school_level
           ,r.grade_level
           ,r.cohort
           ,r.team        
           ,r.SPEDLEP      
           ,r.enroll_status      
      
           ,map_long.testid
           ,map_long.term      
           ,map_long.measurementscale            
           ,map_long.base_rit
           ,map_long.base_pct
           ,map_long.base_lex                 
           ,map_long.rit       
           ,map_long.pct       
           ,map_long.lex           
           ,map_long.testdurationminutes                 
           ,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY map_long.rit)
              OVER(PARTITION BY r.reporting_schoolid
                               ,r.grade_level
                               ,r.year
                               ,map_long.term
                               ,map_long.measurementscale) AS median_rit
           ,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY map_long.pct)
              OVER(PARTITION BY r.reporting_schoolid
                               ,r.grade_level
                               ,r.year
                               ,map_long.term
                               ,map_long.measurementscale) AS median_pct

           /* Quartiles */
           ,CASE 
             WHEN map_long.pct BETWEEN 0 AND 24 THEN 1
             WHEN map_long.pct BETWEEN 25 AND 49 THEN 2
             WHEN map_long.pct BETWEEN 50 AND 74 THEN 3
             WHEN map_long.pct >= 75 THEN 4                
            END AS term_quartile

           ,pct50.testritscore AS testritscore_50th_percentile
           ,pct75.testritscore AS testritscore_75th_percentile
     FROM KIPP_NJ..COHORT$identifiers_long#static r WITH(NOLOCK)
     LEFT OUTER JOIN map_long
       ON r.studentid = map_long.studentid
      AND r.year = map_long.year      
     LEFT OUTER JOIN KIPP_NJ..MAP$norms_table#dense pct50 WITH(NOLOCK)
       ON r.grade_level = pct50.grade_level
      AND CASE WHEN map_long.term = 'Baseline' THEN 'Fall' ELSE map_long.term END = pct50.term
      AND map_long.measurementscale = pct50.measurementscale
      AND pct50.testpercentile = 50
     LEFT OUTER JOIN KIPP_NJ..MAP$norms_table#dense pct75 WITH(NOLOCK)
       ON r.grade_level = pct75.grade_level
      AND CASE WHEN map_long.term = 'Baseline' THEN 'Fall' ELSE map_long.term END = pct75.term
      AND map_long.measurementscale = pct75.measurementscale
      AND pct75.testpercentile = 75
     WHERE r.year >= 2008 /* first year of MAP data */
       AND r.schoolid != 999999
       AND r.rn = 1
    ) sub
LEFT OUTER JOIN KIPP_NJ..MAP$domain_goals_long#static domain WITH(NOLOCK)
  ON sub.student_number = domain.student_number
 AND sub.testid = domain.TestID