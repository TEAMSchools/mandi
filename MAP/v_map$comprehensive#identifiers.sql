USE KIPP_NJ
GO

ALTER VIEW [dbo].[MAP$comprehensive#identifiers] AS

SELECT cohort.schoolid
      ,cohort.grade_level
      ,cohort.cohort
      ,cohort.year_in_network AS stu_year_in_network
      ,cohort.abbreviation AS year_abbreviation
      ,norms_2008.percentile AS percentile_2008_norms
      ,norms_2011.percentile AS percentile_2011_norms
      ,sq_2.*
      ,ROW_NUMBER() OVER(
         PARTITION BY sq_2.studentid, sq_2.map_year_academic, sq_2.measurementscale
           ORDER BY sq_2.teststartdate ASC, sq_2.teststarttime ASC) AS rn_base
      ,ROW_NUMBER() OVER( 
         PARTITION BY sq_2.studentid, sq_2.map_year_academic, sq_2.measurementscale
           ORDER BY sq_2.teststartdate DESC, sq_2.teststarttime DESC) AS rn_curr
      ,ROW_NUMBER() OVER( 
         PARTITION BY sq_2.rn, sq_2.studentid, sq_2.measurementscale
           ORDER BY sq_2.teststartdate ASC, sq_2.teststarttime ASC) AS rn_asc
      ,CASE
        --MATH ACT model
        WHEN sq_2.measurementscale = 'Mathematics'
         THEN ROUND(-28.193 --intercept
                + (0.307 * CAST(sq_2.testritscore AS FLOAT)) 
                + ((-4.256 * cohort.grade_level) + (0.183 * (cohort.grade_level * cohort.grade_level)))
                + CASE
                   WHEN sq_2.fallwinterspring = 'Fall' THEN 0                 
                   WHEN sq_2.fallwinterspring = 'Winter' THEN -1.173  --half of Spring
                   WHEN sq_2.fallwinterspring = 'Spring' THEN -2.346 
                   ELSE NULL
                  END,0)
        --READING ACT model
        WHEN sq_2.measurementscale = 'Reading'
         THEN ROUND(-52.748 --intercept
                + (0.417 * sq_2.testritscore)
                + ((-3.433 * cohort.grade_level) + (0.132 * (cohort.grade_level * cohort.grade_level)))
                + CASE
                   WHEN sq_2.fallwinterspring = 'Fall' THEN 0
                   WHEN sq_2.fallwinterspring = 'Winter' THEN -0.829  --half of Spring
                   WHEN sq_2.fallwinterspring = 'Spring' THEN -1.655
                   ELSE NULL
                  END,0)
        ELSE NULL
       END AS proj_ACT_subj_score
      FROM
          (
           SELECT KIPP_NJ.dbo.fn_DateToSY(teststartdate) AS map_year_academic
                 ,CASE
                   WHEN fallwinterspring = 'Fall'   THEN 1 
                   WHEN fallwinterspring = 'Winter' THEN 2
                   WHEN fallwinterspring = 'Spring' THEN 3
                   ELSE NULL
                  END fallwinterspring_numeric
                 ,sq_1.*
                 ,ROW_NUMBER() OVER(
                    PARTITION BY studentid, termname, measurementscale
                      ORDER BY growthmeasureyn DESC
                              ,teststartdate DESC
                              ,teststandarderror ASC) AS rn
           FROM
               (
                SELECT s.id AS ps_studentid
                      --,s.student_number
                      ,s.lastfirst
                      ,SUBSTRING(termname, 1, CHARINDEX(' ', termname)) AS fallwinterspring 
                      ,CASE
                        WHEN termname LIKE 'Fall%' THEN SUBSTRING(SUBSTRING(termname, CHARINDEX(' ', termname) + 1, 100), 1, 4)
                        ELSE SUBSTRING(SUBSTRING(termname, CHARINDEX(' ', termname) + 1, 100), 6, 4)
                       END AS map_year
                      ,map.termname
                      ,map.studentid
                      ,map.schoolname
                      ,CASE WHEN map.measurementscale = 'Language' THEN 'Language Usage' ELSE map.measurementscale END AS measurementscale
                      ,map.discipline
                      ,map.growthmeasureyn
                      ,map.testtype
                      ,map.testname
                      ,map.testid
                      ,map.teststartdate
                      ,map.testdurationminutes
                      ,CAST(map.testritscore AS INT) AS testritscore
                      ,map.teststandarderror
                      ,map.testpercentile
                      ,map.typicalfalltofallgrowth
                      ,map.typicalspringtospringgrowth
                      ,map.typicalfalltospringgrowth
                      ,map.typicalfalltowintergrowth
                      ,map.rittoreadingscore
                      ,map.rittoreadingmin
                      ,map.rittoreadingmax
                      ,map.goal1name
                      ,map.goal1ritscore
                      ,map.goal1stderr
                      ,map.goal1range
                      ,map.goal1adjective
                      ,map.goal2name
                      ,map.goal2ritscore
                      ,map.goal2stderr
                      ,map.goal2range
                      ,map.goal2adjective
                      ,map.goal3name
                      ,map.goal3ritscore
                      ,map.goal3stderr
                      ,map.goal3range
                      ,map.goal3adjective
                      ,map.goal4name
                      ,map.goal4ritscore
                      ,map.goal4stderr
                      ,map.goal4range
                      ,map.goal4adjective
                      ,map.goal5name
                      ,map.goal5ritscore
                      ,map.goal5stderr
                      ,map.goal5range
                      ,map.goal5adjective
                      ,map.goal6name
                      ,map.goal6ritscore
                      ,map.goal6stderr
                      ,map.goal6range
                      ,map.goal6adjective
                      ,map.goal7name
                      ,map.goal7ritscore
                      ,map.goal7stderr
                      ,map.goal7range
                      ,map.goal7adjective
                      ,map.goal8name
                      ,map.goal8ritscore
                      ,map.goal8stderr
                      ,map.goal8range
                      ,map.goal8adjective
                      ,map.teststarttime
                      ,map.percentcorrect
                      ,map.projectedproficiency                     
                FROM NWEA..map$cdf map WITH (NOLOCK)
                JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                  ON s.student_number = map.studentid
                WHERE map.StudentID != '11XXX'
                  AND (map.TestID IS NULL OR map.TestID NOT IN (SELECT TestID FROM KIPP_NJ..MAP$exclusion_audit#static WITH(NOLOCK) WHERE is_excluded = 1))
               ) sq_1
          ) sq_2
LEFT OUTER JOIN COHORT$comprehensive_long#static cohort WITH(NOLOCK)
  ON cohort.studentid = sq_2.ps_studentid 
 AND sq_2.map_year_academic = cohort.year
 AND cohort.rn = 1
LEFT OUTER JOIN MAP$norm_table#2008 norms_2008 WITH(NOLOCK)
  ON cohort.grade_level = norms_2008.grade 
 AND REPLACE(sq_2.measurementscale, 'Science - General Science', 'General Science') = norms_2008.measurementscale 
 AND sq_2.testritscore = norms_2008.rit 
 AND sq_2.fallwinterspring = norms_2008.fallwinterspring
LEFT OUTER JOIN MAP$norm_table#2011 norms_2011 WITH(NOLOCK)
  ON CASE WHEN sq_2.measurementscale = 'Reading' AND cohort.grade_level = 12 THEN 11 ELSE cohort.grade_level END = norms_2011.grade 
 AND REPLACE(sq_2.measurementscale, 'Science - General Science', 'General Science')  = norms_2011.measurementscale 
 AND sq_2.testritscore = norms_2011.rit 
 AND sq_2.fallwinterspring = norms_2011.fallwinterspring