USE KIPP_NJ
GO

ALTER VIEW TABLEAU$writing_scores#ES AS

WITH test_order AS (
  SELECT student_number
        ,repository_id
        ,repository_row_id
        ,ROW_NUMBER() OVER(
           PARTITION BY student_number, academic_year, term
             ORDER BY date_administered DESC) AS rn_cur_term
  FROM
      (
       SELECT DISTINCT 
              student_number      
             ,academic_year
             ,repository_id           
             ,term
             ,repository_row_id
             ,date_administered            
       FROM KIPP_NJ..ILLUMINATE$writing_scores_long#ES WITH(NOLOCK)
      ) sub
 )

SELECT co.school_name
      ,co.student_number
      ,co.lastfirst AS student_name
      ,co.grade_level
      ,co.team
      ,co.SPEDLEP AS iep_status
      ,co.enroll_status
      ,w.title
      ,w.term
      ,w.date_administered
      ,w.writing_type
      ,w.total_points AS total_score
      ,w.total_prof
      ,w.writing_obj
      ,w.score AS obj_score
      ,w.proficiency AS obj_prof
      ,w.prof_numeric AS obj_prof_numeric     
      ,t.rn_cur_term
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$writing_scores_long#ES w WITH(NOLOCK)
  ON co.student_number = w.student_number
LEFT OUTER JOIN test_order t WITH(NOLOCK)
  ON co.student_number = t.student_number
 AND w.repository_id = t.repository_id
 AND w.repository_row_id = t.repository_row_id
WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
  AND co.rn = 1
  AND co.grade_level <= 4