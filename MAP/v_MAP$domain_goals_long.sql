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
             ,measurementscale
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
       FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
       WHERE map.rn = 1
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
       FROM map_tests
       WHERE field != 'name'
      ) sub

  PIVOT (
    MAX(value)
    FOR field IN ([ritscore], [range], [adjective])
   ) p
 )
 
,map_curr AS (
  SELECT map.ps_studentid AS studentid
        ,map.map_year_academic AS year
        ,map.measurementscale
        ,map.fallwinterspring
        ,CONVERT(INT,map.testritscore) AS rit
        ,CONVERT(INT,map.testpercentile) AS pct
        ,CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)) AS lexile
  FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
  WHERE rn_curr = 1
 )

,enrollments AS (
  SELECT *
        ,CASE 
          WHEN CREDITTYPE = 'ENG' THEN 'Reading'
          WHEN CREDITTYPE = 'MATH' THEN 'Mathematics'
          WHEN CREDITTYPE = 'RHT' THEN 'Language Usage'
          WHEN CREDITTYPE = 'SCI' THEN 'Science - General Science'
         END AS measurementscale
  FROM
      (
       SELECT *
             ,ROW_NUMBER() OVER (
                PARTITION BY year, studentid, credittype
                    ORDER BY termid DESC) AS rn
       FROM
           (
            SELECT cc.studentid                
                  ,cc.TERMID
                  ,(CONVERT(FLOAT,(LEFT(cc.TERMID, 2) + '00')) + CONVERT(FLOAT, '1.990000e+05')) / 100 AS year
                  ,c.credittype
                  ,cc.COURSE_NUMBER
                  ,c.course_name                
                  ,t.LASTFIRST AS teacher
                  ,cc.EXPRESSION AS period
            FROM cc WITH(NOLOCK)
            JOIN COURSES c WITH(NOLOCK)
              ON cc.course_number = c.course_number
             AND cc.SCHOOLID = c.SCHOOLID
             AND c.CREDITTYPE IN ('ENG','RHET','SCI','MATH')
             AND c.course_name NOT LIKE '% Lab%'
            JOIN teachers t WITH(NOLOCK)
              ON cc.teacherid = t.id
            WHERE cc.TERMID > 0
           ) sub
      ) sub2
  WHERE rn = 1
 )

SELECT domain.studentid      
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,s.team
      ,cs.spedlep
      ,domain.year
      ,domain.fallwinterspring
      ,domain.measurementscale
      ,domain.value AS domain
      ,scores.ritscore
      ,scores.range
      ,scores.adjective
      ,map_curr.rit AS cur_rit
      ,map_curr.pct AS cur_pct
      ,map_curr.lexile AS cur_lex
      ,map_curr.fallwinterspring AS cur_term
      ,enr.COURSE_NAME
      ,enr.COURSE_NUMBER
      ,enr.period
FROM map_tests domain
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON domain.studentid = co.studentid
 AND domain.year = co.year
 AND co.rn = 1
JOIN STUDENTS s WITH(NOLOCK)
  ON co.studentid = s.id
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON co.studentid = cs.STUDENTID
JOIN domain_scores scores
  ON domain.studentid = scores.studentid
 AND domain.year = scores.year
 AND domain.measurementscale = scores.measurementscale
 AND domain.fallwinterspring = scores.fallwinterspring
 AND domain.n = scores.n
JOIN map_curr
  ON domain.studentid = map_curr.studentid
 AND domain.year = map_curr.year
 AND domain.measurementscale = map_curr.measurementscale
LEFT OUTER JOIN enrollments enr
  ON domain.studentid = enr.STUDENTID
 AND domain.year = enr.year
 AND domain.measurementscale = enr.measurementscale
WHERE field = 'name'