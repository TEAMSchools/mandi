USE KIPP_NJ
GO

ALTER VIEW LIT$test_events#identifiers AS

SELECT sub.*
      ,CASE 
        WHEN status IS NOT NULL AND lvl_num >= goal_num THEN 1 
        WHEN status IS NOT NULL AND lvl_num < goal_num THEN 0
        ELSE NULL
       END AS met_goal
       
      -- test sequence identifiers      
      ,CASE -- base letter for the round
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, test_round, status
                ORDER BY test_date ASC, read_lvl ASC)
        ELSE NULL
       END AS achv_base_round
      
      ,CASE -- base letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date ASC, read_lvl ASC)
        ELSE NULL
       END AS achv_base_yr
       
      ,CASE -- base letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date ASC, read_lvl ASC)
        ELSE NULL
       END AS achv_base_all
       
      ,CASE -- current letter for the round
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, test_round, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS achv_curr_round
      
      ,CASE -- current letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS achv_curr_yr   
      
      ,CASE -- current letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS achv_curr_all
       
      ,CASE -- current DNA for the round
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, test_round, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS dna_round
       
      ,CASE -- current DNA for the year
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS dna_yr
       
      ,CASE -- current DNA, all time
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date DESC, read_lvl DESC)
        ELSE NULL
       END AS dna_all
FROM
    (
     SELECT 
            -- test identifiers
            rs.unique_id
           ,rs.testid
           
           -- date stuff
           ,CASE 
             WHEN dates.time_per_name IN ('BOY','Diagnostic') AND DATEPART(MONTH,rs.test_date) < 7 THEN cohort.YEAR + 1
             WHEN dates.time_per_name IN ('T3','EOY') AND DATEPART(MONTH,rs.test_date) > 6 THEN cohort.YEAR - 1
             ELSE cohort.YEAR
            END AS academic_year -- replace with rs.academic_year
           ,CASE
             WHEN dates.time_per_name IN ('BOY','Diagnostic') THEN 'DR'
             ELSE dates.time_per_name
            END AS test_round -- replace with rs.test_round           
           ,rs.test_date
           
           -- student identifiers
           ,cohort.schoolid
           ,cohort.grade_level      
           ,cohort.COHORT 
           ,rs.studentid
           ,s.student_number
           ,s.LASTFIRST
           
           -- progress to goals
           ,rs.status
           ,rs.step_ltr_level AS read_lvl           
           ,gleq.lvl_num
           ,goals.read_lvl AS goal_lvl
           ,goals.lvl_num AS goal_num
           ,gleq.GLEQ
           
           -- test metadata      
           ,rs.color
           ,rs.genre
           ,rs.fp_keylever           
           ,rs.fp_wpmrate
           ,rs.instruct_lvl
           ,CASE
             WHEN rs.indep_lvl IS NULL THEN rs.step_ltr_level
             ELSE rs.step_ltr_level
            END AS indep_lvl
     FROM READINGSCORES rs WITH(NOLOCK)
     JOIN LIT$GLEQ gleq WITH(NOLOCK)
       ON rs.testid = gleq.testid
      AND rs.step_ltr_level = gleq.read_lvl
     JOIN STUDENTS s WITH(NOLOCK)
       ON rs.studentid = s.id
     LEFT OUTER JOIN COHORT$comprehensive_long#static cohort WITH(NOLOCK)
       ON rs.studentid = cohort.studentid
      AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
      AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
      AND cohort.rn = 1
     -- to be replaced by direct input from readingScores
     LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK) 
       ON rs.test_date >= dates.start_date
      AND rs.test_date <= dates.end_date
      AND cohort.SCHOOLID = dates.schoolid 
      AND dates.identifier = 'LIT'
     LEFT OUTER JOIN LIT$goals goals
       ON s.GRADE_LEVEL = goals.grade_level
      AND CASE --fyx dis
           WHEN dates.time_per_name IN ('BOY','Diagnostic') THEN 'DR'
           ELSE dates.time_per_name
          END = goals.test_round
    ) sub      