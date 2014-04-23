USE KIPP_NJ
GO

ALTER VIEW LIT$test_events#identifiers AS

SELECT 
       -- test identifiers
       rs.unique_id
      ,rs.testid
      
      -- date stuff
      ,cohort.YEAR AS academic_year
      ,dates.time_per_name AS test_round
      --,rs.academic_year
      --,rs.test_round
      ,rs.test_date
      
      -- student identifiers
      ,cohort.schoolid
      ,cohort.grade_level      
      ,cohort.COHORT 
      ,rs.studentid
      ,s.student_number
      ,s.LASTFIRST
      
      -- test metadata
      ,rs.step_ltr_level
      ,gleq.GLEQ
      ,gleq.lvl_num
      ,rs.status      
      ,rs.instruct_lvl
      ,CASE
        WHEN rs.indep_lvl IS NULL THEN rs.step_ltr_level
        ELSE rs.step_ltr_level
       END AS indep_lvl
      ,rs.color
      ,rs.genre
      ,rs.fp_keylever
      ,rs.fp_wpmrate
      
      -- test sequence identifiers      
      ,CASE -- base letter for the round
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                ORDER BY rs.test_date ASC, step_ltr_level ASC)
        ELSE NULL
       END AS achv_base_round
      
      ,CASE -- base letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, rs.status
                ORDER BY rs.test_date ASC, step_ltr_level ASC)
        ELSE NULL
       END AS achv_base_yr
       
      ,CASE -- base letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, rs.status
                ORDER BY rs.test_date ASC, step_ltr_level ASC)
        ELSE NULL
       END AS achv_base_all
       
      ,CASE -- current letter for the round
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS achv_curr_round
      
      ,CASE -- current letter for the year
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS achv_curr_yr   
      
      ,CASE -- current letter, all time
        WHEN status = 'Achieved' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS achv_curr_all
       
      ,CASE -- current DNA for the round
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, dates.time_per_name, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS dna_round
       
      ,CASE -- current DNA for the year
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, cohort.year, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS dna_yr
       
      ,CASE -- current DNA, all time
        WHEN status = 'Did Not Achieve' THEN
         ROW_NUMBER() OVER
           (PARTITION BY rs.studentid, rs.status
                ORDER BY rs.test_date DESC, step_ltr_level DESC)
        ELSE NULL
       END AS dna_all
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