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
           ,rs.academic_year
           ,rs.test_round           
           ,rs.test_date
           
           -- student identifiers
           ,rs.schoolid
           ,ISNULL(cohort.grade_level, s.grade_level) AS grade_level
           ,cohort.COHORT 
           ,rs.studentid
           ,s.student_number
           ,cohort.LASTFIRST
           
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
             WHEN rs.testid = 3273 AND rs.indep_lvl IS NULL THEN rs.step_ltr_level
             ELSE rs.indep_lvl
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
     LEFT OUTER JOIN LIT$goals goals
       ON ISNULL(cohort.grade_level, s.grade_level) = goals.grade_level
      AND rs.test_round = goals.test_round
    ) sub