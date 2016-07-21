USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$assessments_sites AS

SELECT DISTINCT
       oq.assessment_id
      ,co.schoolid
      ,NULL AS grade_level
FROM OPENQUERY(ILLUMINATE,'
  SELECT a.assessment_id       
        ,a.created_at
        ,s.local_student_id          
  FROM dna_assessments.students_assessments a
  JOIN public.students s
    ON a.student_id = s.student_id    
') oq
JOIN KIPP_NJ..COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON oq.local_student_id = co.student_number
 AND KIPP_NJ.dbo.fn_DateToSY(oq.created_at) = co.year
 AND co.rn = 1