USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$standards_tested AS
SELECT *
      ,ROW_NUMBER() OVER
        (PARTITION BY schoolid, grade_level, [subject]
             ORDER BY [standard]) AS std_count_subject
FROM
(SELECT DISTINCT
       schoolid
      ,grade_level
      ,[subject]
      ,custom_code AS [standard]
      ,standard_id
      ,parent_standard_id      
FROM
(SELECT oq.*
       ,s.schoolid
       ,s.grade_level
 FROM OPENQUERY(ILLUMINATE,'
        SELECT a.assessment_id
              ,a.title
              ,subj.code_translation AS subject              
              ,std.standard_id
              ,std.parent_standard_id
              ,std.custom_code
              ,s.local_student_id
        FROM dna_assessments.assessments a        
        LEFT OUTER JOIN codes.dna_subject_areas subj
          ON a.code_subject_area_id = subj.code_id        
        JOIN dna_assessments.assessment_standards a_std
          ON a.assessment_id = a_std.assessment_id
        JOIN standards.standards std
          ON a_std.standard_id = std.standard_id        
        JOIN dna_assessments.agg_student_responses resp
          ON a.assessment_id = resp.assessment_id
        JOIN public.students s
          ON s.student_id = resp.student_id
        ') oq
 LEFT OUTER JOIN STUDENTS s
   ON oq.local_student_id = s.student_number
) sub_1
) sub_2