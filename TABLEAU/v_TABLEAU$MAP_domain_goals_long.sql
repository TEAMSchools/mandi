USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_domain_goals_long AS

WITH map_tests AS (
  SELECT studentid
        ,student_number
        ,academic_year
        ,term
        ,measurementscale           
        ,testritscore
        ,SUBSTRING(field, 6, LEN(field)) AS field
        ,SUBSTRING(field, 5, 1) AS n
        ,value
  FROM
      (
       SELECT studentid
             ,student_number
             ,academic_year
             ,term
             ,map.measurementscale             
             ,testritscore
             ,CONVERT(VARCHAR,goal1name) AS goal1name
             ,CONVERT(VARCHAR,goal1ritscore) AS goal1ritscore
             ,CONVERT(VARCHAR,goal1range) AS goal1range
             ,CONVERT(VARCHAR,goal1adjective) AS goal1adjective
             ,CONVERT(VARCHAR,goal2name) AS goal2name
             ,CONVERT(VARCHAR,goal2ritscore) AS goal2ritscore
             ,CONVERT(VARCHAR,goal2range) AS goal2range
             ,CONVERT(VARCHAR,goal2adjective) AS goal2adjective
             ,CONVERT(VARCHAR,goal3name) AS goal3name
             ,CONVERT(VARCHAR,goal3ritscore) AS goal3ritscore
             ,CONVERT(VARCHAR,goal3range) AS goal3range
             ,CONVERT(VARCHAR,goal3adjective) AS goal3adjective
             ,CONVERT(VARCHAR,goal4name) AS goal4name
             ,CONVERT(VARCHAR,goal4ritscore) AS goal4ritscore
             ,CONVERT(VARCHAR,goal4range) AS goal4range
             ,CONVERT(VARCHAR,goal4adjective) AS goal4adjective
             ,CONVERT(VARCHAR,goal5name) AS goal5name
             ,CONVERT(VARCHAR,goal5ritscore) AS goal5ritscore
             ,CONVERT(VARCHAR,goal5range) AS goal5range
             ,CONVERT(VARCHAR,goal5adjective) AS goal5adjective
             ,CONVERT(VARCHAR,goal6name) AS goal6name
             ,CONVERT(VARCHAR,goal6ritscore) AS goal6ritscore
             ,CONVERT(VARCHAR,goal6range) AS goal6range
             ,CONVERT(VARCHAR,goal6adjective) AS goal6adjective
             ,CONVERT(VARCHAR,goal7name) AS goal7name
             ,CONVERT(VARCHAR,goal7ritscore) AS goal7ritscore
             ,CONVERT(VARCHAR,goal7range) AS goal7range
             ,CONVERT(VARCHAR,goal7adjective) AS goal7adjective
             ,CONVERT(VARCHAR,goal8name) AS goal8name
             ,CONVERT(VARCHAR,goal8ritscore) AS goal8ritscore
             ,CONVERT(VARCHAR,goal8range) AS goal8range
             ,CONVERT(VARCHAR,goal8adjective) AS goal8adjective
       FROM KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)               
       WHERE map.rn = 1         

       UNION ALL
       
       SELECT base.studentid
             ,base.student_number
             ,base.year AS academic_year
             ,'Baseline' AS term
             ,base.measurementscale
             ,base.testritscore
             ,CONVERT(VARCHAR,goal1name) AS goal1name
             ,CONVERT(VARCHAR,goal1ritscore) AS goal1ritscore
             ,CONVERT(VARCHAR,goal1range) AS goal1range
             ,CONVERT(VARCHAR,goal1adjective) AS goal1adjective
             ,CONVERT(VARCHAR,goal2name) AS goal2name
             ,CONVERT(VARCHAR,goal2ritscore) AS goal2ritscore
             ,CONVERT(VARCHAR,goal2range) AS goal2range
             ,CONVERT(VARCHAR,goal2adjective) AS goal2adjective
             ,CONVERT(VARCHAR,goal3name) AS goal3name
             ,CONVERT(VARCHAR,goal3ritscore) AS goal3ritscore
             ,CONVERT(VARCHAR,goal3range) AS goal3range
             ,CONVERT(VARCHAR,goal3adjective) AS goal3adjective
             ,CONVERT(VARCHAR,goal4name) AS goal4name
             ,CONVERT(VARCHAR,goal4ritscore) AS goal4ritscore
             ,CONVERT(VARCHAR,goal4range) AS goal4range
             ,CONVERT(VARCHAR,goal4adjective) AS goal4adjective
             ,CONVERT(VARCHAR,goal5name) AS goal5name
             ,CONVERT(VARCHAR,goal5ritscore) AS goal5ritscore
             ,CONVERT(VARCHAR,goal5range) AS goal5range
             ,CONVERT(VARCHAR,goal5adjective) AS goal5adjective
             ,CONVERT(VARCHAR,goal6name) AS goal6name
             ,CONVERT(VARCHAR,goal6ritscore) AS goal6ritscore
             ,CONVERT(VARCHAR,goal6range) AS goal6range
             ,CONVERT(VARCHAR,goal6adjective) AS goal6adjective
             ,CONVERT(VARCHAR,goal7name) AS goal7name
             ,CONVERT(VARCHAR,goal7ritscore) AS goal7ritscore
             ,CONVERT(VARCHAR,goal7range) AS goal7range
             ,CONVERT(VARCHAR,goal7adjective) AS goal7adjective
             ,CONVERT(VARCHAR,goal8name) AS goal8name
             ,CONVERT(VARCHAR,goal8ritscore) AS goal8ritscore
             ,CONVERT(VARCHAR,goal8range) AS goal8range
             ,CONVERT(VARCHAR,goal8adjective) AS goal8adjective
       FROM KIPP_NJ..MAP$best_baseline#static base WITH(NOLOCK)
       JOIN KIPP_NJ..MAP$CDF#identifiers#static map WITH(NOLOCK)
         ON base.studentid = map.studentid
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
                  ,goal5adjective
                  ,goal6name
                  ,goal6ritscore      
                  ,goal6range
                  ,goal6adjective
                  ,goal7name
                  ,goal7ritscore      
                  ,goal7range
                  ,goal7adjective
                  ,goal8name
                  ,goal8ritscore      
                  ,goal8range
                  ,goal8adjective)
   ) u
 )

,domain_scores AS (
  SELECT studentid
        ,student_number
        ,academic_year
        ,term
        ,measurementscale
        ,n
        ,[ritscore]
        ,[range]
        ,[adjective]
  FROM
      (
       SELECT studentid
             ,student_number
             ,academic_year
             ,term
             ,MeasurementScale
             ,field
             ,n
             ,value
       FROM map_tests WITH(NOLOCK)
       WHERE field != 'name'
      ) sub
  PIVOT (
    MAX(value)
    FOR field IN ([ritscore], [range], [adjective])
   ) p
 )

,illuminate_groups AS (
  SELECT DISTINCT 
         student_number
        ,illuminate_group
  FROM KIPP_NJ..PS$enrollments_rollup#static WITH(NOLOCK)
  WHERE academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND illuminate_group IS NOT NULL
 )
 
SELECT domain.studentid      
      ,domain.student_number
      ,co.lastfirst
      ,CASE WHEN co.team LIKE '%pathways%' THEN 732570 ELSE co.schoolid END AS schoolid
      ,co.grade_level
      ,co.team
      ,co.spedlep
      ,co.enroll_status
      ,co.retained_yr_flag
      ,co.retained_ever_flag
      ,CASE WHEN co.year = KIPP_NJ.dbo.fn_Global_Academic_Year() THEN 1 ELSE 0 END AS is_current_year
      ,domain.academic_year AS year
      ,domain.term AS fallwinterspring
      ,domain.measurementscale
      ,domain.testritscore
      ,domain.value AS domain
      ,scores.ritscore
      ,scores.range
      ,scores.adjective      
      ,enr.teacher_name
      ,enr.COURSE_NAME
      ,enr.COURSE_NUMBER
      ,enr.period
      ,ill.illuminate_group
FROM map_tests domain
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON domain.studentid = co.studentid
 AND domain.academic_year = co.year
 AND co.rn = 1
LEFT OUTER JOIN domain_scores scores
  ON domain.studentid = scores.studentid
 AND domain.academic_year = scores.academic_year
 AND domain.measurementscale = scores.measurementscale
 AND domain.term = scores.term
 AND domain.n = scores.n
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr
  ON domain.studentid = enr.STUDENTID
 AND domain.academic_year = enr.academic_year
 AND domain.measurementscale = enr.measurementscale
LEFT OUTER JOIN illuminate_groups ill
  ON co.student_number = ill.student_number
WHERE field = 'name'