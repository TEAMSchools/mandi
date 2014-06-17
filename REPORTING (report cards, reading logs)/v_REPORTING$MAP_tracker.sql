USE KIPP_NJ
GO

ALTER VIEW REPORTING$MAP_tracker AS

WITH winter AS (
  SELECT schoolid
        ,grade_level
        ,percentile_2011_norms
        ,map_year_academic
        ,ps_studentid
        ,fallwinterspring
        ,measurementscale
        ,testritscore
  FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
  WHERE map.rn = 1 
    AND map.testtype = 'Survey With Goals'
    AND fallwinterspring = 'Winter'
    AND map_year_academic = dbo.fn_Global_Academic_Year()    
 )

,spring AS (
  SELECT schoolid
        ,grade_level
        ,percentile_2011_norms
        ,map_year_academic
        ,ps_studentid
        ,fallwinterspring
        ,measurementscale
        ,testritscore
  FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
  WHERE map.rn = 1 
    AND map.testtype = 'Survey With Goals'
    AND fallwinterspring = 'Spring'
    AND map_year_academic = dbo.fn_Global_Academic_Year()    
 )

,fall AS (
  SELECT schoolid
        ,grade_level
        ,percentile_2011_norms
        ,map_year_academic
        ,ps_studentid
        ,fallwinterspring
        ,measurementscale
        ,testritscore
  FROM MAP$comprehensive#identifiers map WITH(NOLOCK)
  WHERE map.rn = 1 
    AND map.testtype = 'Survey With Goals'
    AND fallwinterspring = 'Fall'
    AND map_year_academic = dbo.fn_Global_Academic_Year()    
 )


SELECT schoolid
      ,grade_level
      ,team
      ,studentid
      ,student_number
      ,lastfirst
      ,SPEDLEP
      ,measurementscale
      ,baseline_rit
      ,baseline_percentile
      ,baseline_lexile
      ,keep_up_rit
      ,keep_up_goal
      ,rutgers_ready_rit
      ,rutgers_ready_goal
      ,keep_up_status
      ,rr_status
      ,fallwinterspring
      ,testtype
      ,test_date
      ,testritscore
      ,testpercentile
      ,lexile
      ,lexile_min
      ,lexile_max
      ,keep_up_as_lexile
      ,rutgers_ready_as_lexile
      ,goal1adjective
      ,goal1name
      ,goal1ritscore
      ,goal2adjective
      ,goal2name
      ,goal2ritscore
      ,goal3adjective
      ,goal3name
      ,goal3ritscore
      ,goal4adjective
      ,goal4name
      ,goal4ritscore
      ,goal5adjective
      ,goal5name
      ,goal5ritscore
      ,goal6adjective
      ,goal6name
      ,goal6ritscore
      ,hash
      ,stu_hash
      ,stu_subj_hash
      ,pctl_change
      ,RIT_change      
      ,fall_RIT
      ,fall_pctle
      ,winter_RIT
      ,winter_pctle
      ,spring_RIT
      ,spring_pctle
FROM
    (
     SELECT
           /*--student identifiers--*/
            s.schoolid
           ,s.grade_level
           ,CASE 
             WHEN s.GRADE_LEVEL = 8 AND base.measurementscale = 'Reading' THEN eng1.COURSE_NAME
             WHEN s.GRADE_LEVEL = 8 AND base.measurementscale = 'Mathematics' THEN math1.COURSE_NAME
             WHEN s.GRADE_LEVEL = 8 AND base.measurementscale = 'Language Usage' THEN rhet1.COURSE_NAME
             WHEN s.GRADE_LEVEL = 8 AND base.measurementscale LIKE '%Science%' THEN sci1.COURSE_NAME
             WHEN s.GRADE_LEVEL > 8 AND base.measurementscale = 'Reading' THEN eng1.LASTFIRST
             WHEN s.GRADE_LEVEL > 8 AND base.measurementscale = 'Mathematics' THEN math1.LASTFIRST
             WHEN s.GRADE_LEVEL > 8 AND base.measurementscale = 'Language Usage' THEN rhet1.LASTFIRST
             WHEN s.GRADE_LEVEL > 8 AND base.measurementscale LIKE '%Science%' THEN sci1.lastfirst
             ELSE s.team
            END AS team
           ,s.id AS studentid
           ,s.student_number
           ,s.lastfirst
           ,cs.SPEDLEP

           /*--growth goals and measures--*/
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE base.measurementscale END AS measurementscale
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE base.testritscore END AS baseline_rit
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE base.testpercentile END AS baseline_percentile
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE base.lexile_score END AS baseline_lexile
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE goals.keep_up_rit END AS keep_up_rit
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE goals.keep_up_goal END keep_up_goal
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE goals.rutgers_ready_rit END rutgers_ready_rit
           ,CASE WHEN map.testname LIKE '%Algebra%' THEN NULL ELSE goals.rutgers_ready_goal END rutgers_ready_goal
           ,CASE              
             WHEN map.testname LIKE '%Algebra%' THEN NULL 
             WHEN map.testritscore >= goals.keep_up_rit THEN 'Met'
             WHEN (map.testritscore - goals.baseline_rit) >= (goals.keep_up_goal * 0.5) THEN 'On Track'
             WHEN (map.testritscore - goals.baseline_rit) < (goals.keep_up_goal * 0.5) THEN 'Off Track'
            END AS keep_up_status
           ,CASE             
             WHEN map.testname LIKE '%Algebra%' THEN NULL 
             WHEN map.testritscore >= goals.rutgers_ready_rit THEN 'Met'
             WHEN (map.testritscore - goals.baseline_rit) >= (goals.rutgers_ready_goal * 0.5) THEN 'On Track'
             WHEN (map.testritscore - goals.baseline_rit) < (goals.rutgers_ready_goal * 0.5) THEN 'Off Track'
            END AS rr_status      

          /*--test identifiers--*/
           ,map.fallwinterspring
           ,map.testtype
           ,map.teststartdate AS test_date
           ,map.testritscore
           ,map.percentile_2011_norms AS testpercentile
           ,map.rittoreadingscore AS lexile
           ,map.rittoreadingmin AS lexile_min
           ,map.rittoreadingmax AS lexile_max
           ,(-2998 + (18 * goals.keep_up_rit)) AS keep_up_as_lexile
           ,(-2998 + (18 * goals.rutgers_ready_rit)) AS rutgers_ready_as_lexile

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

          /*--reporting hashes, row numbers--*/
           ,ISNULL(CONVERT(VARCHAR,map.studentid), CONVERT(VARCHAR,s.student_number)) + '_'
             + ISNULL(CONVERT(VARCHAR,REPLACE(map.fallwinterspring,' ','')),SUBSTRING(base.termname, 0, CHARINDEX(' ', base.termname))) + '_'
             + ISNULL(CONVERT(VARCHAR,ROW_NUMBER() OVER (
                                         PARTITION BY map.studentid, map.map_year, map.termname, CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE goals.measurementscale END
                                             ORDER BY map.teststartdate DESC)), '1') AS hash
           ,ISNULL(CONVERT(VARCHAR,map.studentid), CONVERT(VARCHAR,s.student_number)) + '_'
             + ISNULL(CONVERT(VARCHAR,ROW_NUMBER() OVER (
                                         PARTITION BY map.studentid, map.map_year, map.termname, CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE goals.measurementscale END
                                             ORDER BY map.teststartdate DESC)), '1') AS stu_hash
           ,ISNULL(CONVERT(VARCHAR,map.studentid), CONVERT(VARCHAR,s.student_number)) + '_'
             + ISNULL(CONVERT(VARCHAR,REPLACE(map.fallwinterspring,' ','')),SUBSTRING(base.termname, 0, CHARINDEX(' ', base.termname))) + '_'
             + CONVERT(VARCHAR,CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE base.measurementscale END) AS stu_subj_hash
           ,CASE
             WHEN base.testpercentile IS NULL THEN (spring.percentile_2011_norms - winter.percentile_2011_norms) 
             ELSE (map.percentile_2011_norms - base.testpercentile) 
            END AS pctl_change
          ,CASE
            WHEN base.testritscore IS NULL THEN (spring.testritscore - winter.testritscore) 
            ELSE (map.testritscore - base.testritscore) 
           END AS RIT_change
          ,ROW_NUMBER() OVER (
              PARTITION BY map.studentid, map.map_year, map.termname, CASE WHEN map.testname LIKE '%Algebra%' THEN 'Algebra' ELSE goals.measurementscale END
                  ORDER BY map.teststartdate DESC) AS rn_curr
                  
          /*--by trimester--*/
          ,fall.testritscore AS fall_RIT
          ,fall.percentile_2011_norms AS fall_pctle
          ,winter.testritscore AS winter_RIT
          ,winter.percentile_2011_norms AS winter_pctle
          ,spring.testritscore AS spring_RIT
          ,spring.percentile_2011_norms AS spring_pctle
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
     LEFT OUTER JOIN (
                      SELECT cc.STUDENTID                       
                            ,t.LASTFIRST
                            ,c.course_name
                            ,ROW_NUMBER() OVER
                               (PARTITION BY cc.studentid
                                    ORDER BY c.course_name) AS rn
                      FROM COURSES c WITH (NOLOCK)
                      JOIN CC WITH (NOLOCK)
                        ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                       AND cc.TERMID >= dbo.fn_Global_Term_Id()                       
                      JOIN TEACHERS t WITH (NOLOCK)
                        ON cc.TEACHERID = t.ID
                      WHERE CREDITTYPE = 'ENG'                        
                     ) eng1
       ON s.ID = eng1.STUDENTID
      AND eng1.rn = 1
     LEFT OUTER JOIN (
                      SELECT cc.STUDENTID                       
                            ,t.LASTFIRST
                            ,c.course_name
                            ,ROW_NUMBER() OVER
                               (PARTITION BY cc.studentid
                                    ORDER BY c.course_name) AS rn
                      FROM COURSES c WITH (NOLOCK)
                      JOIN CC WITH (NOLOCK)
                        ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                       AND cc.TERMID >= dbo.fn_Global_Term_Id()                       
                      JOIN TEACHERS t WITH (NOLOCK)
                        ON cc.TEACHERID = t.ID
                      WHERE CREDITTYPE = 'MATH'                        
                     ) math1
       ON s.ID = math1.STUDENTID
      AND math1.rn = 1
     LEFT OUTER JOIN (
                      SELECT cc.STUDENTID                       
                            ,t.LASTFIRST
                            ,c.COURSE_NAME
                            ,ROW_NUMBER() OVER
                               (PARTITION BY cc.studentid
                                    ORDER BY c.course_name) AS rn
                      FROM COURSES c WITH (NOLOCK)
                      JOIN CC WITH (NOLOCK)
                        ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                       AND cc.TERMID >= dbo.fn_Global_Term_Id()                       
                      JOIN TEACHERS t WITH (NOLOCK)
                        ON cc.TEACHERID = t.ID
                      WHERE CREDITTYPE = 'RHET'
                     ) rhet1
       ON s.ID = rhet1.STUDENTID
      AND rhet1.rn = 1
     LEFT OUTER JOIN (
                      SELECT cc.STUDENTID
                            ,t.LASTFIRST
                            ,c.COURSE_NAME
                            ,ROW_NUMBER() OVER
                               (PARTITION BY cc.studentid
                                    ORDER BY c.course_name) AS rn
                      FROM COURSES c WITH (NOLOCK)
                      JOIN CC WITH (NOLOCK)
                        ON c.COURSE_NUMBER = cc.COURSE_NUMBER
                       AND cc.TERMID >= dbo.fn_Global_Term_Id()
                      JOIN TEACHERS t WITH (NOLOCK)
                        ON cc.TEACHERID = t.ID
                      WHERE CREDITTYPE = 'SCI'
                     ) sci1
       ON s.ID = sci1.STUDENTID
      AND sci1.rn = 1
     LEFT OUTER JOIN winter
       ON base.studentid = winter.ps_studentid
      AND base.schoolid = winter.schoolid
      AND base.grade_level = winter.grade_level
      AND REPLACE(base.measurementscale, ' Usage','') = REPLACE(winter.measurementscale, ' Usage','')      
      AND base.year = winter.map_year_academic
     LEFT OUTER JOIN spring
       ON base.studentid = spring.ps_studentid
      AND base.schoolid = spring.schoolid
      AND base.grade_level = spring.grade_level
      AND REPLACE(base.measurementscale, ' Usage','') = REPLACE(spring.measurementscale, ' Usage','')
      AND base.year = spring.map_year_academic
     LEFT OUTER JOIN fall
       ON base.studentid = fall.ps_studentid
      AND base.schoolid = fall.schoolid
      AND base.grade_level = fall.grade_level
      AND REPLACE(base.measurementscale, ' Usage','') = REPLACE(fall.measurementscale, ' Usage','')
      AND base.year = fall.map_year_academic 
     WHERE base.year = dbo.fn_Global_Academic_Year()
    ) sub
WHERE rn_curr = 1