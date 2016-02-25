USE KIPP_NJ
GO

ALTER VIEW LIT$PS_test_events#identifiers AS

WITH clean_data AS (
  /* pre-2015 STEP */
  SELECT rs.unique_id
        ,rs.testid   
        ,rs.test_date
        ,rs.schoolid
        ,rs.studentid
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code
        ,COALESCE(rs.status,'Did Not Achieve') AS status              
        ,COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) AS academic_year      
      
        ,COALESCE(rs.test_round, d.time_per_name) AS test_round
            
        ,co.student_number
        ,co.grade_level      
        ,co.LASTFIRST
      
        ,COALESCE(rs.read_lvl, gleq.read_lvl) AS read_lvl       
      
        ,gleq.lvl_num
        ,gleq.GLEQ
      
        ,NULL AS dna_lvl
        ,NULL AS dna_lvl_num        
      
        ,instr.read_lvl AS instruct_lvl
        ,instr.lvl_num AS instruct_lvl_num      
      
        ,ind.read_lvl AS indep_lvl      
        ,ind.lvl_num AS indep_lvl_num
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON rs.testid = gleq.testid
   AND gleq.lvl_num > -1 
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
    ON rs.instruct_lvl = instr.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq ind WITH(NOLOCK)
    ON COALESCE(rs.indep_lvl, rs.read_lvl) = ind.read_lvl
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON rs.schoolid = d.schoolid 
   AND rs.test_date BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'LIT'
  WHERE rs.testid != 3273
    AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) <= 2014

  UNION ALL

  /* pre-2015 F&P */
  SELECT rs.unique_id
        ,rs.testid   
        ,rs.test_date
        ,rs.schoolid
        ,rs.studentid
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code      
        ,COALESCE(rs.status,'Did Not Achieve') AS status              
        ,COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) AS academic_year

        ,COALESCE(rs.test_round, d.time_per_name) AS test_round
      
        ,co.student_number
        ,co.grade_level      
        ,co.LASTFIRST

        ,COALESCE(rs.read_lvl, gleq.read_lvl) AS read_lvl       
      
        ,gleq.fp_lvl_num AS lvl_num
        ,gleq.GLEQ
      
        ,NULL AS dna_lvl
        ,NULL AS dna_lvl_num        
      
        ,instr.read_lvl AS instruct_lvl
        ,instr.fp_lvl_num AS instruct_lvl_num      
      
        ,ind.read_lvl AS indep_lvl      
        ,ind.fp_lvl_num AS indep_lvl_num
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON rs.read_lvl = gleq.read_lvl /* before 2015-2016, JOIN Achieved F&P on reading level */   
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
    ON rs.instruct_lvl = instr.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq ind WITH(NOLOCK)
    ON COALESCE(rs.indep_lvl, rs.read_lvl) = ind.read_lvl
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON rs.schoolid = d.schoolid 
   AND rs.test_date BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'LIT'
  WHERE rs.testid = 3273
    AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) <= 2014
  
  UNION ALL

  /* pre-2015, synth Pre-DNA Achieved */
  SELECT rs.unique_id
        ,rs.testid                    
        ,rs.test_date
        ,rs.schoolid
        ,rs.studentid
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever
        ,rs.coaching_code
        ,'Achieved' AS status      
        ,COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) AS academic_year                  
        ,COALESCE(rs.test_round, d.time_per_name) AS test_round
      
        ,co.student_number
        ,co.grade_level      
        ,co.LASTFIRST              
      
        ,'Pre DNA' AS read_lvl
        ,-1 AS lvl_num
        ,-1 AS GLEQ
        ,'Pre' AS dna_lvl
        ,0 AS dna_lvl_num
        ,'A' AS instruct_lvl
        ,0 AS instruct_lvl_num
        ,'AA' AS indep_lvl
        ,-1 AS indep_lvl_num
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON rs.schoolid = d.schoolid 
   AND rs.test_date BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'LIT'
  WHERE rs.testid = 3280
    AND rs.status = 'Did Not Achieve'
    AND rs.academic_year <= 2014

  UNION ALL

  /* post-2015 STEP */
  SELECT rs.unique_id
        ,rs.testid   
        ,rs.test_date
        ,rs.schoolid
        ,rs.studentid
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code
        ,'Mixed' AS status
        ,COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) AS academic_year      
            
        ,COALESCE(rs.test_round, d.time_per_name) AS test_round
      
        ,co.student_number
        ,co.grade_level      
        ,co.LASTFIRST

        ,rs.read_lvl
      
        ,achv.lvl_num
        ,achv.GLEQ
      
        ,stepdna.read_lvl AS dna_lvl
        ,stepdna.lvl_num AS dna_lvl_num        
      
        ,instr.read_lvl AS instruct_lvl
        ,instr.lvl_num AS instruct_lvl_num      
      
        ,ind.read_lvl AS indep_lvl      
        ,ind.lvl_num AS indep_lvl_num
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq achv WITH(NOLOCK)
    ON rs.read_lvl = achv.read_lvl 
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq stepdna WITH(NOLOCK)
    ON rs.testid = stepdna.testid 
   AND stepdna.lvl_num > -1
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
    ON rs.instruct_lvl = instr.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq ind WITH(NOLOCK)
    ON COALESCE(rs.indep_lvl, rs.read_lvl) = ind.read_lvl
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON rs.schoolid = d.schoolid 
   AND rs.test_date BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'LIT'
  WHERE rs.testid != 3273
    AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) >= 2015

  UNION ALL

  /* post-2015 F&P */
  SELECT rs.unique_id
        ,rs.testid   
        ,rs.test_date
        ,rs.schoolid
        ,rs.studentid
        ,rs.color
        ,rs.genre
        ,rs.fp_wpmrate
        ,rs.fp_keylever      
        ,rs.coaching_code
        ,'Mixed' AS status
        ,COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) AS academic_year      
            
        ,COALESCE(rs.test_round, d.time_per_name) AS test_round
      
        ,co.student_number
        ,co.grade_level      
        ,co.LASTFIRST            
      
        ,rs.read_lvl
      
        ,gleq.fp_lvl_num AS lvl_num
        ,gleq.GLEQ
      
        ,rs.instruct_lvl AS dna_lvl
        ,instr.fp_lvl_num AS dna_lvl_num        
      
        ,instr.read_lvl AS instruct_lvl
        ,instr.fp_lvl_num AS instruct_lvl_num      
      
        ,ind.read_lvl AS indep_lvl      
        ,ind.fp_lvl_num AS indep_lvl_num
  FROM KIPP_NJ..LIT$readingscores#static rs WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
    ON rs.read_lvl = gleq.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
    ON rs.instruct_lvl = instr.read_lvl
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq ind WITH(NOLOCK)
    ON COALESCE(rs.indep_lvl, rs.read_lvl) = ind.read_lvl
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON rs.studentid = co.studentid
   AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON rs.schoolid = d.schoolid 
   AND rs.test_date BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'LIT'
  WHERE rs.testid = 3273
    AND COALESCE(rs.academic_year, KIPP_NJ.dbo.fn_DateToSY(rs.test_date)) >= 2015
 )

SELECT unique_id     
      
      ,studentid
      ,student_number
      ,schoolid
      ,grade_level
      ,LASTFIRST

      ,academic_year
      ,CASE
        WHEN grade_level >= 5 AND test_round IN ('Diagnostic','DR') THEN 'BOY'
        WHEN test_round = 'Diagnostic' THEN 'DR'
        ELSE test_round
       END AS test_round
      ,CASE
        WHEN test_round IN ('Diagnostic', 'DR', 'BOY') THEN 1
        WHEN test_round IN ('T1','Q1') THEN 2
        WHEN test_round IN ('MOY','T2','Q2') THEN 3
        WHEN test_round IN ('T3','Q3') THEN 4
        WHEN test_round IN ('EOY','Q4') THEN 5       
       END AS round_num
      ,test_date      
      
      ,testid
      ,CASE WHEN testid = 3273 THEN 1 ELSE 0 END AS is_fp
      ,read_lvl
      ,lvl_num
      ,status      
      ,GLEQ
      
      ,dna_lvl
      ,dna_lvl_num
      ,instruct_lvl
      ,instruct_lvl_num
      ,indep_lvl
      ,indep_lvl_num

      ,color
      ,genre
      ,fp_wpmrate
      ,fp_keylever
      ,coaching_code      
FROM clean_data