USE KIPP_NJ
GO

ALTER VIEW MAP$domain_goals_long AS

WITH map_tests AS (
  SELECT studentid
        ,year
        ,fallwinterspring
        ,measurementscale           
        ,SUBSTRING(field, 6, LEN(field)) AS field
        ,SUBSTRING(field, 5, 1) AS n
        ,value
  FROM
      (
       SELECT ps_studentid AS studentid
             ,map_year_academic AS year
             ,fallwinterspring
             ,map.measurementscale             
             ,goal1name
             ,goal1ritscore      
             ,goal1range
             ,goal1adjective
             ,goal2name
             ,goal2ritscore      
             ,goal2range
             ,goal2adjective
             ,goal3name
             ,goal3ritscore      
             ,goal3range
             ,goal3adjective
             ,goal4name
             ,goal4ritscore      
             ,goal4range
             ,goal4adjective
             ,goal5name
             ,goal5ritscore      
             ,goal5range
             ,goal5adjective             
       FROM MAP$comprehensive#identifiers#static map WITH(NOLOCK)               
       WHERE map.rn = 1
         AND map.fallwinterspring IN ('Winter', 'Spring')

       UNION ALL
       
       SELECT base.studentid
             ,base.year
             ,'Fall' AS fallwinterspring
             ,base.measurementscale
             ,map.goal1name
             ,map.goal1ritscore      
             ,map.goal1range
             ,map.goal1adjective
             ,map.goal2name
             ,map.goal2ritscore      
             ,map.goal2range
             ,map.goal2adjective
             ,map.goal3name
             ,map.goal3ritscore      
             ,map.goal3range
             ,map.goal3adjective
             ,map.goal4name
             ,map.goal4ritscore      
             ,map.goal4range
             ,map.goal4adjective
             ,map.goal5name
             ,map.goal5ritscore      
             ,map.goal5range
             ,map.goal5adjective  
       FROM MAP$best_baseline#static base WITH(NOLOCK)
       JOIN MAP$comprehensive#identifiers#static map WITH(NOLOCK)
         ON base.studentid = map.ps_studentid
        AND base.measurementscale = map.measurementscale
        AND base.termname = map.termname
        AND map.rn = 1
      ) sub

  UNPIVOT (
     value
     FOR field IN (goal1name
                  ,goal1ritscore      
                  ,goal1range
                  ,goal1adjective
                  ,goal2name
                  ,goal2ritscore      
                  ,goal2range
                  ,goal2adjective
                  ,goal3name
                  ,goal3ritscore      
                  ,goal3range
                  ,goal3adjective
                  ,goal4name
                  ,goal4ritscore      
                  ,goal4range
                  ,goal4adjective
                  ,goal5name
                  ,goal5ritscore      
                  ,goal5range
                  ,goal5adjective)
   ) u
 )

,domain_scores AS (
  SELECT studentid
        ,year
        ,fallwinterspring
        ,measurementscale
        ,n
        ,[ritscore]
        ,[range]
        ,[adjective]
  FROM
      (
       SELECT *
       FROM map_tests WITH(NOLOCK)
       WHERE field != 'name'
      ) sub

  PIVOT (
    MAX(value)
    FOR field IN ([ritscore], [range], [adjective])
   ) p
 )
 
--,map_curr AS (
--  SELECT map.ps_studentid AS studentid
--        ,map.map_year_academic AS year
--        ,map.measurementscale
--        ,map.fallwinterspring
--        ,CONVERT(INT,map.testritscore) AS rit
--        ,CONVERT(INT,map.testpercentile) AS pct
--        ,CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)) AS lexile
--  FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
--  WHERE rn_curr = 1
-- )

SELECT domain.studentid      
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.spedlep
      ,domain.year
      ,domain.fallwinterspring
      ,domain.measurementscale
      ,domain.value AS domain
      ,scores.ritscore
      ,scores.range
      ,scores.adjective
      --,map_curr.rit AS cur_rit
      --,map_curr.pct AS cur_pct
      --,map_curr.lexile AS cur_lex
      --,map_curr.fallwinterspring AS cur_term
      ,enr.teacher_name
      ,enr.COURSE_NAME
      ,enr.COURSE_NUMBER
      ,enr.period
FROM map_tests domain
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON domain.studentid = co.studentid
 AND domain.year = co.year
 AND co.rn = 1
LEFT OUTER JOIN domain_scores scores
  ON domain.studentid = scores.studentid
 AND domain.year = scores.year
 AND domain.measurementscale = scores.measurementscale
 AND domain.fallwinterspring = scores.fallwinterspring
 AND domain.n = scores.n
--LEFT OUTER JOIN map_curr
--  ON domain.studentid = map_curr.studentid
-- AND domain.year = map_curr.year
-- AND domain.measurementscale = map_curr.measurementscale
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr
  ON domain.studentid = enr.STUDENTID
 AND domain.year = enr.academic_year
 AND domain.measurementscale = enr.measurementscale
WHERE field = 'name'