USE KIPP_NJ
GO

ALTER VIEW LIT$running_record AS

WITH running_record AS (
  SELECT CONVERT(FLOAT,student_number) AS student_number
        ,ISNULL(KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[field_date_administered])),2014) AS academic_year
        ,CONVERT(DATE,[field_date_administered]) AS date_administered
        ,[field_administrator_1] AS administrator      
        ,[field_level_tested] AS level_tested
        ,RIGHT(LTRIM(RTRIM([field_level_tested])), 1) AS level_tested_JOIN
        ,[field_fiction_nonfiction] AS fiction_nonfiction
        ,[field_pass_fall] AS pass_fall
        ,CONVERT(FLOAT,[field_accuracy_1]) AS accuracy
        ,CONVERT(FLOAT,[field_fluency_1]) AS fluency
        ,CONVERT(FLOAT,[field_reading_rate_wpm]) AS reading_rate_wpm
        ,CONVERT(FLOAT,[field_about_the_text]) AS about_the_text
        ,CONVERT(FLOAT,[field_within_the_text]) AS within_the_text
        ,CONVERT(FLOAT,[field_beyond_the_text]) AS beyond_the_text
        ,CONVERT(FLOAT,[field_accuracy_1]) AS fp_accuracy
        ,ISNULL(CONVERT(FLOAT,[field_about_the_text]),0)
          + ISNULL(CONVERT(FLOAT,[field_within_the_text]),0)
          + iSNULL(CONVERT(FLOAT,[field_beyond_the_text]),0) AS fp_comp_prof
  FROM 
      (
       SELECT student_id AS student_number
             ,repository_row_id
             ,field
             ,value
       FROM KIPP_NJ..ILLUMINATE$repository_data WITH(NOLOCK)
       WHERE repository_id = 54
      ) sub
  PIVOT (
    MAX(value)
    FOR field IN ([field_about_the_text]
                 ,[field_administrator_1]
                 ,[field_date_administered]
                 ,[field_level_tested]
                 ,[field_fiction_nonfiction]
                 ,[field_pass_fall]
                 ,[field_accuracy_1]
                 ,[field_fluency_1]
                 ,[field_reading_rate_wpm]
                 ,[field_within_the_text]
                 ,[field_beyond_the_text])
   ) p
 )

,prof_wide AS (
  SELECT lvl_num
        ,fp_accuracy
        ,fp_comp_prof      
  FROM
      (
       SELECT lvl_num
             ,field_name
             ,score
       FROM KIPP_NJ..AUTOLOAD$GDOCS_LIT_proficiency_long WITH(NOLOCK)
       WHERE testid = 3273
         AND field_name IN ('fp_accuracy','fp_comp_prof')
      ) sub
  PIVOT (
     MAX(score)
     FOR field_name IN ([fp_accuracy],[fp_comp_prof])
   ) p
 )

SELECT s.LASTFIRST
      ,s.SCHOOLID
      ,s.GRADE_LEVEL
      ,s.team 
      ,s.SPEDLEP
      ,rr.student_number
      ,rr.academic_year
      ,rr.date_administered
      ,rr.administrator
      ,rr.level_tested
      ,rr.fiction_nonfiction
      ,rr.pass_fall
      ,rr.accuracy
      ,rr.fluency
      ,rr.reading_rate_wpm
      ,rr.about_the_text
      ,rr.within_the_text
      ,rr.beyond_the_text
      ,rr.fp_accuracy
      ,rr.fp_comp_prof
      ,gleq.lvl_num
      ,CASE WHEN rr.fp_comp_prof < prof_wide.fp_comp_prof THEN 1 ELSE 0 END AS dna_comp
      ,CASE WHEN rr.fp_accuracy < prof_wide.fp_accuracy THEN 1 ELSE 0 END AS dna_accuracy
      ,lli.subject AS comment_subject
      ,lli.comment
      ,lli.date AS comment_date
FROM running_record rr WITH(NOLOCK)
JOIN KIPP_NJ..AUTOLOAD$GDOCS_LIT_gleq gleq WITH(NOLOCK)
  ON rr.level_tested_join = gleq.read_lvl
JOIN prof_wide WITH(NOLOCK)
  ON gleq.lvl_num = prof_wide.lvl_num
JOIN KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
  ON rr.student_number = s.STUDENT_NUMBER
 AND rr.academic_year = s.year
 AND s.rn = 1
LEFT OUTER JOIN KIPP_NJ..REPORTING$SPED_comments#static lli WITH(NOLOCK)
  ON rr.student_number = lli.student_number
 AND rr.academic_year = KIPP_NJ.dbo.fn_DateToSY(lli.date)
 AND lli.subject = 'LLI'
 AND lli.rn = 1