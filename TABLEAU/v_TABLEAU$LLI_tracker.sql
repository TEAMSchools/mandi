USE KIPP_NJ
GO

ALTER VIEW TABLEAU$LLI_tracker AS 

WITH running_records AS (
  SELECT repository_id
        ,repository_row_id
        ,student_number      
        ,KIPP_NJ.dbo.fn_DateToSY(CONVERT(DATE,[Date Administered])) AS academic_year
        ,CONVERT(DATE,[Date Administered]) AS date_administered
        ,[Level Tested] AS level_tested
        ,[Pass/ Fail] AS test_status
        ,[Text Familiarity] AS text_familiarity
        ,[Fiction/ Nonfiction] AS genre
        ,CONVERT(FLOAT,[Accuracy]) AS accuracy
        ,CONVERT(FLOAT,[Fluency]) AS fluency
        ,CONVERT(FLOAT,[Reading Rate (wpm)]) AS wpm
        ,CONVERT(FLOAT,[About the Text]) AS about_the_text      
        ,CONVERT(FLOAT,[Beyond the Text]) AS beyond_the_text
        ,CONVERT(FLOAT,[Within the Text]) AS within_the_text
        ,[Administrator] AS test_administrator      
  FROM
      (
       SELECT r.repository_id           
             ,rf.label AS field_label
             ,rd.repository_row_id
             ,rd.student_id AS student_number
             ,rd.value AS field_value      
       FROM KIPP_NJ..ILLUMINATE$repositories#static r WITH(NOLOCK)
       JOIN KIPP_NJ..ILLUMINATE$repository_fields#static rf WITH(NOLOCK)
         ON r.repository_id = rf.repository_id
       JOIN KIPP_NJ..ILLUMINATE$repository_data rd WITH(NOLOCK)
         ON r.repository_id = rd.repository_id
        AND rf.name = rd.field
       WHERE scope = 'Intervention'
         AND subject_area = 'F&P'
      ) sub
  PIVOT(
    MAX(field_value)
    FOR field_label IN ([Administrator]
                       ,[Date Administered]
                       ,[Level Tested]
                       ,[Text Familiarity]
                       ,[Fiction/ Nonfiction]
                       ,[Pass/ Fail]
                       ,[Accuracy]
                       ,[Fluency]
                       ,[Reading Rate (wpm)]
                       ,[Within the Text]
                       ,[Beyond the Text]
                       ,[About the Text])
   ) p
 )

SELECT rr.repository_id
      ,rr.repository_row_id
      ,rr.student_number
      ,rr.academic_year
      ,rr.date_administered
      ,rr.level_tested
      ,rr.test_status
      ,rr.text_familiarity
      ,rr.genre
      ,rr.accuracy
      ,rr.fluency
      ,rr.wpm
      ,rr.about_the_text
      ,rr.beyond_the_text
      ,rr.within_the_text
      ,rr.test_administrator      
      
      ,co.lastfirst
      ,co.reporting_schoolid
      ,co.grade_level
      ,co.SPEDLEP      
      ,co.team
FROM running_records rr
LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON rr.student_number = co.student_number
 AND rr.academic_year = co.year
 AND co.rn = 1