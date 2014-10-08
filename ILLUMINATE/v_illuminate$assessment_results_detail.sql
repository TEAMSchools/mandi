USE KIPP_NJ
GO

CREATE VIEW ILLUMINATE$assessment_results_detail AS 
     --first get the questions per assessment
WITH assess_questions AS
    (SELECT *
     FROM OPENQUERY(illuminate,'
       SELECT f.*
             ,a.title AS assessment_name
       FROM dna_assessments.fields f
       JOIN dna_assessments.assessments a
         ON f.assessment_id = a.assessment_id
       --WHERE a.title = ''Science - GR8 - IA3''
       ')
     )
     --then get students per assessment
    ,assess_students AS
    (SELECT *
     FROM OPENQUERY(illuminate,'
       SELECT sa.*
             ,s.local_student_id
             ,s.first_name
             ,s.last_name
       FROM dna_assessments.students_assessments sa
       JOIN public.students s
         ON sa.student_id = s.student_id
       --WHERE sa.assessment_id = ''3762''
       ')
     )
     --cartesian those into a scaffold.  this has one row per student, per response
     --this step is necessary because NULL / not answered responses are not recorded
     --and you have to 'densify' to see the rows where a response is *expected*, but wasn't
     --provided by the student
    ,scaffold AS
     (SELECT a_stu.local_student_id
            ,a_stu.last_name
            ,a_stu.first_name
            ,a_stu.assessment_id
            ,a_q.assessment_name
            ,a_stu.student_id
            ,a_stu.student_assessment_id
            ,a_q.field_id
            ,a_q.[order]
            ,a_q.sheet_label
            ,a_q.sort_order
            ,a_q.maximum
      FROM assess_students a_stu
      JOIN assess_questions a_q
        ON 1=1
      )
     --this table has the actual responses
    ,stu_responses AS
    (SELECT *
     FROM OPENQUERY(illuminate,'
       SELECT sar.*
       FROM dna_assessments.students_assessments_responses sar
       JOIN dna_assessments.assessments a
         ON sar.assessment_id = a.assessment_id
        AND a.assessment_id = ''3762''
       ')
     )
     --illuminate normalizes responses via an ID.  join to resposnes
     --to recover the *actual* student response
    ,canonical_responses AS
    (SELECT *
     FROM OPENQUERY(illuminate,'
       SELECT r.*
       FROM dna_assessments.responses r
       ')
     )
    ,field_resp AS
    (SELECT *
     FROM OPENQUERY(illuminate,'
       SELECT fr.*
       FROM dna_assessments.field_responses fr
       JOIN dna_assessments.fields f
         ON fr.field_id = f.field_id
        --AND f.assessment_id = ''3762''
       ')
     )
SELECT scaffold.*
      ,canonical_responses.response AS stu_resp
      ,ISNULL(field_resp.points, 0) AS points_earned
FROM scaffold
LEFT OUTER JOIN stu_responses
  ON scaffold.student_assessment_id = stu_responses.student_assessment_id
 AND scaffold.field_id = stu_responses.field_id
LEFT OUTER JOIN canonical_responses
  ON stu_responses.response_id = canonical_responses.response_id
LEFT OUTER JOIN field_resp 
  ON scaffold.field_id = field_resp.field_id
 AND stu_responses.response_id = field_resp.response_id
--ORDER BY scaffold.assessment_id
--        ,scaffold.student_id
--        ,scaffold.[order]