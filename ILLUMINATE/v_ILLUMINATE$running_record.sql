USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$running_record AS

WITH running_record AS (
  SELECT CONVERT(INT,student_number) AS student_number
        ,CONVERT(DATE,[field_date_administered]) AS date_administered
        ,[field_administrator_1] AS administrator      
        ,[field_level_tested] AS level_tested
        ,[field_fiction_nonfiction] AS fiction_nonfiction
        ,[field_pass_fall] AS pass_fall
        ,CONVERT(FLOAT,[field_accuracy_1]) AS accuracy
        ,CONVERT(INT,[field_fluency_1]) AS fluency
        ,CONVERT(FLOAT,[field_reading_rate_wpm]) AS reading_rate_wpm
        ,CONVERT(INT,[field_about_the_text]) AS about_the_text
        ,CONVERT(INT,[field_within_the_text]) AS within_the_text
        ,CONVERT(INT,[field_beyond_the_text]) AS beyond_the_text
  FROM 
      (
       SELECT student_id AS student_number
             ,repository_row_id
             ,field
             ,value
       FROM ILLUMINATE$summary_assessment_results_long#static WITH(NOLOCK)
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

SELECT rr.*
      ,s.LASTFIRST
      ,s.SCHOOLID
      ,s.GRADE_LEVEL
FROM running_record rr
JOIN STUDENTS s
  ON rr.student_number = s.STUDENT_NUMBER