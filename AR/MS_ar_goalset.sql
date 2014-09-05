WITH roster AS (
  SELECT co.schoolid
        ,co.student_number
        ,co.lastfirst
        ,co.grade_level
        ,s.team
        ,cs.advisor
  FROM COHORT$comprehensive_long#static co WITH(NOLOCK)
  JOIN STUDENTS s WITH(NOLOCK)
    ON co.studentid = s.id
  JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
    ON s.id = cs.studentid
  WHERE co.rn = 1
    AND co.grade_level >= 5
    AND co.grade_level <= 8
    AND co.year = dbo.fn_Global_Academic_Year()
 )
 
,terms AS (
  SELECT DISTINCT REPLACE(alt_name, 'Hex', 'Round') AS term
  FROM REPORTING$dates
  WHERE academic_year = dbo.fn_Global_Academic_Year()
    AND identifier = 'HEX'
    AND school_level = 'MS'
 )

,goal_criteria AS (
  SELECT criteria
        ,min
        ,max
        ,tier
  FROM OPENROWSET(
    'MSDASQL'
    ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
    ,'select * from C:\data_robot\ar_goals\MS_goal_criteria.csv'
    )
 )

,tier_goals AS (
  SELECT tier
        ,words_goal
  FROM OPENROWSET(
    'MSDASQL'
    ,'Driver={Microsoft Access Text Driver (*.txt, *.csv)};'
    ,'select * from C:\data_robot\ar_goals\MS_tier_goals.csv'
    )
 )

,read_lvl AS (
  SELECT student_number
        ,CONVERT(INT,lvl_num) AS test
        ,read_lvl AS detail
        ,'lvl_num' AS criteria
  FROM LIT$test_events#identifiers rs WITH(NOLOCK)
  WHERE achv_curr_all = 1
    AND grade_level >= 5
    AND grade_level <= 8
 )

,fluency AS (  
  SELECT student_number        
        ,CASE WHEN fp_wpmrate = 0 THEN NULL ELSE fp_wpmrate END AS test
        ,CONVERT(VARCHAR,CASE WHEN fp_wpmrate = 0 THEN NULL ELSE fp_wpmrate END) AS detail
        ,'fluency' AS criteria
  FROM LIT$test_events#identifiers rs WITH(NOLOCK)
  WHERE achv_curr_all = 1
    AND schoolid != 73252
    AND grade_level >= 5
    AND grade_level <= 8

  UNION ALL

  SELECT STUDENT_NUMBER
        ,test
        ,detail
        ,criteria
  FROM
      (
       SELECT s.STUDENT_NUMBER
             ,wpm AS test
             ,CONVERT(VARCHAR,wpm) AS detail
             ,'fluency' AS criteria
             ,ROW_NUMBER() OVER(PARTITION BY rl.studentid ORDER BY rl.wpm DESC) AS rn
       FROM SRSLY_DIE_READLIVE rl WITH(NOLOCK)
       JOIN students s WITH(NOLOCK)
         ON rl.studentid = s.ID
        AND s.SCHOOLID = 73252
       WHERE rl.season = 'Winter'
      ) sub
  WHERE rn = 1
 )

,lexile AS (
  SELECT s.STUDENT_NUMBER
        ,REPLACE(base.lexile_score, 'BR', 0) AS test
        ,CONVERT(VARCHAR,base.lexile_score) AS detail
        ,'lexile' AS criteria
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  JOIN STUDENTS s WITH(NOLOCK)
    ON base.studentid = s.ID
  WHERE base.grade_level >= 5
    AND base.grade_level <= 8
    AND base.year = dbo.fn_Global_Academic_Year()
    AND base.measurementscale = 'Reading'    
 )

,all_data AS (
  SELECT *
        ,'Letter Level' AS title
  FROM read_lvl
  UNION
  SELECT *
        ,'Fluency'
  FROM fluency
  UNION
  SELECT *
        ,'Lexile'
  FROM lexile
 )

,average_tier AS (
  SELECT student_number        
        ,dbo.GROUP_CONCAT_BIGD(d.title + ': '+ CONVERT(VARCHAR,d.detail) + ' (Tier ' + CONVERT(VARCHAR,c.tier) + ')', '  //  ') AS details
        ,ROUND(AVG(tier),0) AS overall_tier
  FROM all_data d
  LEFT OUTER JOIN goal_criteria c
    ON d.criteria = c.criteria
   AND d.test >= c.min
   AND d.test <= c.max
  GROUP BY student_number
 )

SELECT r.*            
      ,terms.term
      ,g.words_goal
      ,t.overall_tier
      ,ISNULL(t.details, 'No Data') AS details
FROM roster r
JOIN terms
  ON 1 = 1
LEFT OUTER JOIN average_tier t
  ON r.STUDENT_NUMBER = t.student_number
LEFT OUTER JOIN tier_goals g
  ON t.overall_tier = g.tier
