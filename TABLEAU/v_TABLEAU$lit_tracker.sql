USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lit_tracker AS

SELECT id.academic_year
      ,id.schoolid
      ,id.grade_level
      ,NULL AS cohort            
      ,id.test_round      
      ,id.test_date
      ,rs.testid
      ,rs.studentid      
      ,rs.read_lvl
      ,rs.status
      ,id.GLEQ
      ,id.lvl_num      
      ,id.instruct_lvl
      ,id.indep_lvl
      ,id.color
      ,id.genre
      ,id.fp_keylever
      ,id.fp_wpmrate            
      ,rs.domain
      ,rs.field
      ,rs.score
      ,rs.benchmark
      ,rs.is_prof
      ,rs.dna_reason      
FROM LIT$readingscores_long rs WITH(NOLOCK)
JOIN LIT$all_test_events#identifiers#static id WITH(NOLOCK)
  ON rs.unique_id = id.unique_id