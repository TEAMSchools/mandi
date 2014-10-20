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
                ORDER BY test_date ASC, lvl_num ASC)
        ELSE NULL
       END AS achv_base_round
      
      ,CASE -- base letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date ASC, lvl_num ASC)
        ELSE NULL
       END AS achv_base_yr
       
      ,CASE -- base letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date ASC, lvl_num ASC)
        ELSE NULL
       END AS achv_base_all
       
      ,CASE -- current letter for the round
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, test_round, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS achv_curr_round
      
      ,CASE -- current letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS achv_curr_yr   
      
      ,CASE -- current letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS achv_curr_all
       
      ,CASE -- current DNA for the round
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, test_round, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS dna_round
       
      ,CASE -- current DNA for the year
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, academic_year, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS dna_yr
       
      ,CASE -- current DNA, all time
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY studentid, status
                ORDER BY test_date DESC, lvl_num DESC)
        ELSE NULL
       END AS dna_all
FROM
    (
     SELECT 
            -- test identifiers
            rs.unique_id
           ,rs.testid           
           
           -- date stuff
           ,COALESCE(rs.academic_year, dates.academic_year) AS academic_year
           ,CASE 
             WHEN rs.test_round IS NULL THEN (CASE
                                               WHEN rs.schoolid NOT IN (73252, 133570965) AND dates.time_per_name = 'Diagnostic' THEN 'DR' 
                                               WHEN rs.schoolid IN (73252, 133570965) AND dates.time_per_name IN ('Diagnostic', 'DR') THEN 'BOY' 
                                               ELSE dates.time_per_name 
                                              END)
             ELSE (CASE
                    WHEN rs.schoolid NOT IN (73252, 133570965) AND rs.test_round = 'Diagnostic' THEN 'DR' 
                    WHEN rs.schoolid IN (73252, 133570965) AND rs.test_round IN ('Diagnostic', 'DR') THEN 'BOY' 
                    ELSE rs.test_round
                   END) 
            END AS test_round
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
           ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
           ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num
           ,gleq.GLEQ
           ,gleq.lvl_num - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind           

           -- test metadata      
           ,rs.color
           ,rs.genre
           ,rs.fp_keylever           
           ,rs.fp_wpmrate
           ,COALESCE(rs.instruct_lvl, gleq.instruct_lvl) AS instruct_lvl
           ,COALESCE(rs.indep_lvl, rs.step_ltr_level) AS indep_lvl
           ,CASE WHEN rs.testid = 3273 THEN 1 ELSE 0 END AS is_fp
     FROM LIT$readingscores#static rs WITH(NOLOCK)
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
     LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
       ON ((rs.test_date > '2013-06-30' AND rs.schoolid = dates.schoolid) OR (rs.test_date <= '2013-06-30' AND dates.schoolid IS NULL))
      AND rs.test_date >= dates.start_date
      AND rs.test_date <= dates.end_date
      AND dates.identifier = 'LIT'
     LEFT OUTER JOIN LIT$goals goals WITH(NOLOCK)
       ON ISNULL(cohort.grade_level, s.grade_level) = goals.grade_level
      AND ISNULL(REPLACE(rs.test_round, 'EOY', 'T3'), REPLACE(REPLACE(dates.time_per_name, 'Diagnostic', 'DR'), 'EOY', 'T3')) = goals.test_round
     LEFT OUTER JOIN LIT$individual_goals indiv WITH(NOLOCK)
       ON cohort.STUDENT_NUMBER = indiv.student_number
      AND rs.test_round = indiv.test_round

     UNION ALL

     -- synthetic Pre_DNA "Achieved" record
     SELECT 
            -- test identifiers
            rs.unique_id
           ,rs.testid           
           
           -- date stuff
           ,COALESCE(rs.academic_year, dates.academic_year) AS academic_year
           ,CASE 
             WHEN rs.test_round IS NULL THEN (CASE
                                               WHEN rs.schoolid NOT IN (73252, 133570965) AND dates.time_per_name = 'Diagnostic' THEN 'DR' 
                                               WHEN rs.schoolid IN (73252, 133570965) AND dates.time_per_name IN ('Diagnostic', 'DR') THEN 'BOY' 
                                               ELSE dates.time_per_name 
                                              END)
             ELSE (CASE
                    WHEN rs.schoolid NOT IN (73252, 133570965) AND rs.test_round = 'Diagnostic' THEN 'DR' 
                    WHEN rs.schoolid IN (73252, 133570965) AND rs.test_round IN ('Diagnostic', 'DR') THEN 'BOY' 
                    ELSE rs.test_round
                   END) 
            END AS test_round
           ,rs.test_date
           
           -- student identifiers
           ,rs.schoolid
           ,ISNULL(cohort.grade_level, s.grade_level) AS grade_level
           ,cohort.COHORT 
           ,rs.studentid
           ,s.student_number
           ,cohort.LASTFIRST
           
           -- progress to goals
           ,'Achieved' AS status
           ,'Pre_DNA' AS read_lvl           
           ,gleq.lvl_num
           ,COALESCE(indiv.goal, goals.read_lvl) AS goal_lvl
           ,COALESCE(indiv.lvl_num, goals.lvl_num) AS goal_num
           ,gleq.GLEQ
           ,gleq.lvl_num - COALESCE(indiv.lvl_num, goals.lvl_num) AS levels_behind         
           
           -- test metadata      
           ,rs.color
           ,rs.genre
           ,rs.fp_keylever           
           ,rs.fp_wpmrate
           ,COALESCE(rs.instruct_lvl, gleq.instruct_lvl) AS instruct_lvl
           ,COALESCE(rs.indep_lvl, rs.step_ltr_level) AS indep_lvl
           ,CASE WHEN rs.testid = 3273 THEN 1 ELSE 0 END AS is_fp
     FROM LIT$readingscores#static rs WITH(NOLOCK)
     JOIN LIT$GLEQ gleq WITH(NOLOCK)
       ON gleq.read_lvl = 'Pre DNA'
     JOIN STUDENTS s WITH(NOLOCK)
       ON rs.studentid = s.id
     LEFT OUTER JOIN COHORT$comprehensive_long#static cohort WITH(NOLOCK)
       ON rs.studentid = cohort.studentid
      AND rs.test_date >= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.entrydate)) + '-07-01')
      AND rs.test_date <= CONVERT(DATE,CONVERT(VARCHAR,DATEPART(YYYY,cohort.exitdate)) + '-06-30')
      AND cohort.rn = 1          
     LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
       ON ((rs.test_date > '2013-06-30' AND rs.schoolid = dates.schoolid) OR (rs.test_date <= '2013-06-30' AND dates.schoolid IS NULL))
      AND rs.test_date >= dates.start_date
      AND rs.test_date <= dates.end_date
      AND dates.identifier = 'LIT'
     LEFT OUTER JOIN LIT$goals goals WITH(NOLOCK)
       ON ISNULL(cohort.grade_level, s.grade_level) = goals.grade_level
      AND ISNULL(REPLACE(rs.test_round, 'EOY', 'T3'), REPLACE(REPLACE(dates.time_per_name, 'Diagnostic', 'DR'), 'EOY', 'T3')) = goals.test_round
     LEFT OUTER JOIN LIT$individual_goals indiv WITH(NOLOCK)
       ON cohort.STUDENT_NUMBER = indiv.student_number
      AND rs.test_round = indiv.test_round
     WHERE rs.status = 'Did Not Achieve'
       AND rs.step_ltr_level = 'Pre'
    ) sub