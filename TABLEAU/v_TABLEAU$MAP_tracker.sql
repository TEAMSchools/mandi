USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_tracker AS

WITH roster AS (
  SELECT co.year
        ,co.studentid
        ,co.student_number
        ,co.lastfirst
        ,co.schoolid
        ,co.grade_level
        ,s.team
        ,cs.SPEDLEP
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON co.studentid = cs.STUDENTID
  WHERE co.rn = 1
    AND co.grade_level < 99
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

,map_rounds AS (
  SELECT base.studentid
        ,base.year
        ,base.measurementscale
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,CASE WHEN base.lexile_score = 'BR' THEN 0 ELSE base.lexile_score END AS base_lex
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit
        ,CASE WHEN base.testritscore IS NOT NULL THEN 'Fall' ELSE map.fallwinterspring END AS fallwinterspring
        ,map.percentile_2011_norms AS pct
        ,map.testritscore AS rit
        ,CASE WHEN map.rittoreadingscore = 'BR' THEN 0 ELSE map.rittoreadingscore END AS lex      
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.year = rr.year
   AND base.measurementscale = rr.measurementscale
   AND base.studentid = rr.studentid
  LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
    ON base.studentid = map.ps_studentid
   AND base.year = map.map_year_academic
   AND base.measurementscale = map.measurementscale
   AND map.rn = 1
 )

SELECT r.*      
      ,map_rounds.measurementscale
      ,map_rounds.base_rit
      ,map_rounds.base_pct
      ,map_rounds.base_lex
      ,map_rounds.keep_up_goal
      ,map_rounds.keep_up_rit
      ,map_rounds.rutgers_ready_goal
      ,map_rounds.rutgers_ready_rit
      ,map_rounds.fallwinterspring
      ,CASE
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) AND map_rounds.base_rit IS NULL THEN map_rounds.rit
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) THEN map_rounds.base_rit
        ELSE map_rounds.rit
       END AS rit
      ,CASE
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) AND map_rounds.base_pct IS NULL THEN map_rounds.pct
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) THEN map_rounds.base_pct
        ELSE map_rounds.pct
       END AS pct
      ,CASE
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) AND map_rounds.base_lex IS NULL THEN map_rounds.lex
        WHEN (map_rounds.fallwinterspring = 'Fall' OR map_rounds.fallwinterspring IS NULL) THEN map_rounds.base_lex
        ELSE map_rounds.lex
       END AS lex      
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher
      ,enr.period
FROM roster r
LEFT OUTER JOIN map_rounds
  ON r.studentid = map_rounds.studentid
 AND r.year = map_rounds.year
LEFT OUTER JOIN enrollments enr
  ON r.studentid = enr.STUDENTID
 AND r.year = enr.year 
 AND map_rounds.measurementscale = enr.measurementscale