USE KIPP_NJ
GO

ALTER VIEW QA$word_work_audit AS

SELECT co.student_number
      ,co.studentid
      ,co.lastfirst
      ,co.schoolid
      ,co.grade_level
      ,co.team
      ,co.enroll_status
      ,NULL AS term      
      ,t.listweek_num AS time_per_name
      ,t.repository_id
      ,t.subject_area
      ,t.word
      ,CONVERT(FLOAT,res.value) AS value
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN KIPP_NJ..LIT$word_work_long#static t WITH(NOLOCK)
  ON co.grade_level = t.grade_level
 AND co.year = t.academic_year 
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_data res WITH(NOLOCK)
  ON co.student_number = res.student_id
 AND t.repository_id = res.repository_id
 AND t.field_name = res.field
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()