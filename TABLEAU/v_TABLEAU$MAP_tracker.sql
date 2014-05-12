/*

TODO: Investigate performance goals feed, JOIN to each test event

*/

USE KIPP_NJ
GO

SELECT
      /*--student identifiers--*/
       s.schoolid
      ,s.grade_level
      ,CASE WHEN s.SCHOOLID = 73253 THEN eng1.LASTFIRST ELSE s.team END AS team      
      ,s.student_number
      ,s.lastfirst
      ,cs.SPEDLEP

      /*--growth goals--*/
      ,base.year
      ,base.measurementscale
      ,base.testritscore AS baseline_rit
      ,base.testpercentile AS baseline_percentile
      ,base.lexile_score AS baseline_lexile
      ,goals.keep_up_rit
      ,goals.keep_up_goal
      ,goals.rutgers_ready_rit
      ,goals.rutgers_ready_goal

      /*--growth measures--*/
      ,CASE
        WHEN map.testritscore >= goals.keep_up_rit THEN 'Met'
        WHEN map.fallwinterspring = 'Winter' AND (map.testritscore - goals.baseline_rit) >= (goals.keep_up_goal * 0.5) THEN 'On Track'
        WHEN map.fallwinterspring = 'Winter' AND (map.testritscore - goals.baseline_rit) < (goals.keep_up_goal * 0.5) THEN 'Off Track'
        WHEN map.fallwinterspring = 'Spring' AND map.testritscore < goals.keep_up_rit THEN 'Did Not Meet'
       END AS keep_up_status
      ,CASE
        WHEN map.testritscore >= goals.rutgers_ready_rit THEN 'Met'
        WHEN map.fallwinterspring = 'Winter' AND (map.testritscore - goals.baseline_rit) >= (goals.rutgers_ready_goal * 0.5) THEN 'On Track'
        WHEN map.fallwinterspring = 'Winter' AND (map.testritscore - goals.baseline_rit) < (goals.rutgers_ready_goal * 0.5) THEN 'Off Track'        
        WHEN map.fallwinterspring = 'Spring' AND map.testritscore < goals.rutgers_ready_goal THEN 'Did Not Meet'
       END AS rr_status
      ,(map.percentile_2011_norms - base.testpercentile) AS base_pctle_growth
      ,(map.testritscore - base.testritscore) AS base_rit_growth

     /*--test identifiers--*/      
      ,map.fallwinterspring      
      ,map.teststartdate AS test_date
      ,map.testritscore
      ,map.percentile_2011_norms AS testpercentile
      ,map.rittoreadingscore AS lexile
      ,map.rittoreadingmin AS lexile_min
      ,map.rittoreadingmax AS lexile_max
      ,CASE WHEN map.measurementscale = 'Reading' THEN (-2998 + (18 * goals.keep_up_rit)) ELSE NULL END AS keep_up_as_lexile
      ,CASE WHEN map.measurementscale = 'Reading' THEN (-2998 + (18 * goals.rutgers_ready_rit)) ELSE NULL END AS rutgers_ready_as_lexile      

     /*--subject goals--*/
      ,map.goal1adjective
      ,map.goal1name
      ,map.goal1ritscore
      ,map.goal2adjective
      ,map.goal2name
      ,map.goal2ritscore
      ,map.goal3adjective
      ,map.goal3name
      ,map.goal3ritscore
      ,map.goal4adjective
      ,map.goal4name
      ,map.goal4ritscore
      ,map.goal5adjective
      ,map.goal5name
      ,map.goal5ritscore
      ,map.goal6adjective
      ,map.goal6name
      ,map.goal6ritscore
      ,map.goal7adjective
      ,map.goal7name
      ,map.goal7ritscore
      ,map.goal8adjective
      ,map.goal8name
      ,map.goal8ritscore
      
FROM MAP$best_baseline#static base WITH(NOLOCK)
JOIN STUDENTS s WITH(NOLOCK)
  ON base.studentid = s.ID
 AND base.schoolid = s.SCHOOLID
 AND s.ENROLL_STATUS = 0
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON s.id = cs.studentid
LEFT OUTER JOIN MAP$rutgers_ready_student_goals goals WITH(NOLOCK)
  ON base.studentid = goals.studentid
 AND base.schoolid = goals.schoolid
 AND base.grade_level = goals.grade_level
 AND REPLACE(base.measurementscale, ' Usage','') = goals.measurementscale
 AND base.year = goals.year
LEFT OUTER JOIN MAP$comprehensive#identifiers map WITH(NOLOCK)
  ON base.studentid = map.ps_studentid
 AND base.schoolid = map.schoolid
 AND base.grade_level = map.grade_level
 AND REPLACE(base.measurementscale, ' Usage','') = REPLACE(map.measurementscale, ' Usage','')
 AND base.year = map.map_year_academic  
 AND map.testtype = 'Survey With Goals'
 AND map.rn = 1
LEFT OUTER JOIN (
                 SELECT cc.STUDENTID                       
                       ,t.LASTFIRST
                       ,ROW_NUMBER() OVER
                          (PARTITION BY cc.studentid
                               ORDER BY c.course_name) AS rn
                 FROM COURSES c WITH (NOLOCK)
                 JOIN CC WITH (NOLOCK)
                   ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                  AND cc.TERMID >= dbo.fn_Global_Term_Id()
                  AND cc.SCHOOLID = 73253
                 JOIN TEACHERS t WITH (NOLOCK)
                   ON cc.TEACHERID = t.ID
                 WHERE CREDITTYPE = 'ENG'
                   AND cc.SCHOOLID = 73253
                ) eng1
  ON s.ID = eng1.STUDENTID
 AND eng1.rn = 1