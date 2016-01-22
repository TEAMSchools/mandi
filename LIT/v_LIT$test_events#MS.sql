USE KIPP_NJ
GO

ALTER VIEW LIT$test_events#MS AS

WITH clean_data AS (
  SELECT repository_row_id
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

SELECT *
      /* test sequence identifiers */      
      /* base/curr letter for the round */
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, test_round
           ORDER BY date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS base_round      
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year, test_round
           ORDER BY date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS curr_round

      /* base/curr letter for the year */
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY round_num ASC, date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS base_yr      
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number, academic_year
           ORDER BY round_num DESC, date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS curr_yr

      /* base/curr letter, all time */
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number
           ORDER BY academic_year ASC, round_num ASC, date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS base_all            
      ,ROW_NUMBER() OVER(
         PARTITION BY student_number
           ORDER BY academic_year DESC, round_num DESC, date_administered DESC, indep_lvl_num DESC, instr_lvl_num DESC) AS curr_all 
FROM
    (
     SELECT cd.*
           ,CASE
             WHEN test_round = 'BOY' THEN 1
             WHEN test_round = 'MOY' THEN 2
             WHEN test_round = 'EOY' THEN 3
            END AS round_num
           ,achv.GLEQ
           ,achv.fp_lvl_num AS indep_lvl_num
           ,instr.fp_lvl_num AS instr_lvl_num
     FROM clean_data cd
     JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq achv
       ON cd.achieved_independent_level = achv.read_lvl
     JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq instr
       ON cd.instructional_level_tested = instr.read_lvl
    ) sub