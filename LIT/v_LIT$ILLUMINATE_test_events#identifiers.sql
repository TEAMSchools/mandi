USE KIPP_NJ
GO

ALTER VIEW LIT$ILLUMINATE_test_events#identifiers AS

WITH clean_data AS (
  SELECT CONCAT('IL',repository_row_id) AS unique_id
        ,student_id AS student_number
        ,LEFT([academic_year],4) AS academic_year
        ,[test_round]
        ,CONVERT(DATE,[date_administered]) AS [date_administered]
        ,LTRIM(RTRIM([status])) AS [status]
        ,LTRIM(RTRIM([instructional_level_tested])) AS [instructional_level_tested]
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
  FROM
      (
       SELECT rd.student_id
             ,rd.repository_row_id      
             ,KIPP_NJ.dbo.fn_StripCharacters(REPLACE(LOWER(LTRIM(RTRIM(rf.label))),' ','_'),'^A-Z0-9_') AS field
             ,rd.value
       FROM KIPP_NJ..ILLUMINATE$repository_data rd WITH(NOLOCK)
       JOIN KIPP_NJ..ILLUMINATE$repository_fields#static rf WITH(NOLOCK)
         ON rd.repository_id = rf.repository_id
        AND rd.field = rf.name
       WHERE rd.repository_id = 126
      ) sub
  PIVOT(
    MAX(value)
    FOR field IN ([about_the_text]
                 ,[academic_year]
                 ,[accuracy]
                 ,[achieved_independent_level]
                 ,[beyond_the_text]
                 ,[date_administered]
                 ,[fiction_nonfiction]
                 ,[fluency]
                 ,[instructional_level_tested]
                 ,[key_lever]
                 ,[rate_proficiency]
                 ,[reading_rate_wpm]
                 ,[status]
                 ,[test_round]
                 ,[within_the_text])
   ) p
 )

SELECT cd.unique_id
      ,cd.student_number
      ,cd.academic_year
      ,cd.test_round
      ,cd.date_administered
      ,cd.status
      ,cd.instructional_level_tested
      ,cd.achieved_independent_level
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
      ,CASE
        WHEN test_round = 'BOY' THEN 1
        WHEN test_round = 'MOY' THEN 2
        WHEN test_round = 'EOY' THEN 3
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
  ON cd.achieved_independent_level = achv.read_lvl
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr WITH(NOLOCK)
  ON cd.instructional_level_tested = instr.read_lvl
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON cd.student_number = co.student_number
 AND cd.academic_year = co.year
 AND co.rn = 1