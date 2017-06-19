USE KIPP_NJ
GO

ALTER VIEW LIT$ILLUMINATE_test_events#identifiers AS

WITH clean_data AS (
  SELECT CONCAT('IL', repository_id, repository_row_id) AS unique_id
        ,student_id AS student_number
        ,LEFT([academic_year],4) AS academic_year
        ,CASE WHEN [test_round] = 'Diagnostic' THEN 'DR' ELSE test_round END AS test_round
        ,CONVERT(DATE,[date_administered]) AS [date_administered]
        ,LTRIM(RTRIM([status])) AS [status]
        ,LTRIM(RTRIM(COALESCE([level_tested], [instructional_level_tested]))) AS [instructional_level_tested]
        ,LTRIM(RTRIM([achieved_independent_level])) AS [achieved_independent_level]
        ,CONVERT(FLOAT,[about_the_text]) AS [about_the_text]
        ,CONVERT(FLOAT,[beyond_the_text]) AS [beyond_the_text]
        ,CONVERT(FLOAT,[within_the_text]) AS [within_the_text]
        ,CONVERT(FLOAT,[accuracy]) AS [accuracy]
        ,CONVERT(FLOAT,[fluency]) AS [fluency]
        ,CONVERT(FLOAT,[reading_rate_wpm]) AS [reading_rate_wpm]
        ,LTRIM(RTRIM([rate_proficiency])) AS [rate_proficiency]
        ,LTRIM(RTRIM([key_lever])) AS [key_lever]
        ,LTRIM(RTRIM([fiction_nonfiction])) AS [fiction_nonfiction]      
        ,LTRIM(RTRIM([test_administered_by])) AS [test_administered_by]
  FROM
      (
       SELECT rd.student_id
             ,rd.repository_id
             ,rd.repository_row_id      
             ,KIPP_NJ.dbo.fn_StripCharacters(REPLACE(LOWER(LTRIM(RTRIM(rf.label))),' ','_'),'^A-Z0-9_') AS field
             ,rd.value
       FROM KIPP_NJ..ILLUMINATE$repositories#static r WITH(NOLOCK)
       JOIN KIPP_NJ..ILLUMINATE$repository_data rd WITH(NOLOCK)
         ON r.repository_id = rd.repository_id
       JOIN KIPP_NJ..ILLUMINATE$repository_fields#static rf WITH(NOLOCK)
         ON rd.repository_id = rf.repository_id
        AND rd.field = rf.name
       WHERE r.subject_area	= 'F&P' 
         AND r.scope =	'Reporting'
      ) sub
  PIVOT(
    MAX(value)
    FOR field IN ([about_the_text]
                 ,[academic_year]
                 ,[accuracy]
                 ,[beyond_the_text]
                 ,[date_administered]
                 ,[fiction_nonfiction]
                 ,[fluency]
                 ,[key_lever]
                 ,[achieved_independent_level]
                 ,[status]
                 ,[rate_proficiency]
                 ,[reading_rate_wpm]
                 ,[test_round]
                 ,[instructional_level_tested]
                 ,[within_the_text]
                 ,[test_administered_by]
                 ,[level_tested])
   ) p
 )

SELECT cd.unique_id
      ,cd.student_number
      ,cd.academic_year
      ,cd.test_round
      ,cd.date_administered
      ,CASE 
        WHEN cd.academic_year <= 2015 THEN 'Mixed' 
        WHEN cd.status LIKE '%Did Not Achieve%' THEN 'Did Not Achieve'
        WHEN cd.status LIKE '%Achieved%' THEN 'Achieved'
        ELSE cd.status
       END AS status
      ,cd.instructional_level_tested
      ,CASE 
        WHEN cd.academic_year >= 2016 AND cd.status LIKE '%Achieved%' THEN cd.instructional_level_tested
        ELSE cd.achieved_independent_level
       END AS achieved_independent_level
      ,cd.about_the_text
      ,cd.beyond_the_text
      ,cd.within_the_text
      ,CASE 
        WHEN cd.about_the_text IS NULL AND cd.beyond_the_text IS NULL AND cd.within_the_text IS NULL THEN NULL
        ELSE ISNULL(cd.within_the_text,0) + ISNULL(cd.about_the_text,0) + ISNULL(cd.beyond_the_text,0) 
       END AS comp_overall
      ,cd.accuracy
      ,cd.fluency
      ,cd.reading_rate_wpm
      ,cd.rate_proficiency
      ,cd.key_lever
      ,cd.fiction_nonfiction
      ,cd.test_administered_by
      ,CASE
        WHEN test_round = 'BOY' THEN 1
        WHEN test_round = 'MOY' THEN 2
        WHEN test_round = 'EOY' THEN 3
        WHEN test_round = 'DR' THEN 1
        WHEN test_round = 'Q1' THEN 2
        WHEN test_round = 'Q2' THEN 3
        WHEN test_round = 'Q3' THEN 4
        WHEN test_round = 'Q4' THEN 5
       END AS round_num
      
      ,co.studentid
      ,co.schoolid
      ,co.grade_level      
      ,co.LASTFIRST    
      
      ,achv.GLEQ
      ,achv.fp_lvl_num AS indep_lvl_num
      ,instr.fp_lvl_num AS instr_lvl_num
FROM clean_data cd
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq achv WITH(NOLOCK)
  ON CASE 
      WHEN cd.academic_year >= 2016 AND cd.status LIKE '%Achieved%' THEN cd.instructional_level_tested
      ELSE cd.achieved_independent_level
     END = achv.read_lvl
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
  ON cd.instructional_level_tested = instr.read_lvl
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON cd.student_number = co.student_number
 AND cd.academic_year = co.year
 AND co.rn = 1