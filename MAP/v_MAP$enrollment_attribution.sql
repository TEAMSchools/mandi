USE KIPP_NJ 
GO

ALTER VIEW MAP$enrollment_attribution AS 
WITH es_hr AS
    (SELECT hr.studentid
          ,hr.year
          ,hr.teacher_name AS teacher
          ,hr.course_number AS course_number
          ,hr.section_number AS enrollment
          ,t.last_name AS teacher_last
    FROM KIPP_NJ..COHORT$student_homerooms hr
    JOIN KIPP_NJ..COHORT$comprehensive_long#static c
      ON hr.studentid = c.studentid
     AND hr.year = c.year
     AND c.rn = 1
    JOIN KIPP_NJ..TEACHERS t
      ON CAST(hr.teachernumber AS varchar) = t.teachernumber
    WHERE hr.rn_stu_year = 1
      AND c.grade_level < 5
    ),
    es_hr_subj AS
   (SELECT es_hr.*,
           'Mathematics' AS join_subj
    FROM es_hr
    UNION ALL
    SELECT es_hr.*,
           'Reading' AS join_subj
    FROM es_hr
   ),
   ms_base AS (
   SELECT c.studentid, 
          c.year
   FROM KIPP_NJ..COHORT$comprehensive_long#static c
   WHERE c.rn = 1
   ),
   ms_subj AS (
   SELECT ms_base.*
         ,ce.academic_year
         ,ce.course_number
         ,ce.teacher_name AS teacher
         ,ce.section_number
         ,t.last_name AS teacher_last
         ,CASE 
            WHEN ce.credittype = 'MATH' THEN 'Mathematics'
            WHEN ce.credittype = 'ENG' THEN 'Reading'
            WHEN ce.credittype = 'RHET' THEN 'Language Usage'
            WHEN ce.credittype = 'SCI' THEN 'General Science'
          END AS join_subj
         ,ROW_NUMBER() OVER
           (PARTITION BY ms_base.studentid, ce.academic_year, ce.course_number
            ORDER BY ce.dateleft DESC
           ) AS rn_decode
         ,ROW_NUMBER() OVER
           (PARTITION BY ms_base.studentid, ce.academic_year, ce.credittype
            ORDER BY ce.credit_hours DESC, ce.dateleft DESC
           ) AS rn_credittype
   FROM ms_base
   JOIN PS$course_enrollments#static ce
     ON ms_base.studentid = ce.studentid
    AND ms_base.year = ce.academic_year
    AND ce.credittype IN ('ENG', 'MATH', 'RHET', 'SCI')
    AND ce.drop_flags = 0
    JOIN KIPP_NJ..TEACHERS t
      ON CAST(ce.teachernumber AS varchar) = t.teachernumber
   ),
   ms_subj_slim AS 
  (SELECT studentid,
          year, 
          teacher,
          course_number,
          course_number + ' ' + section_number AS enrollment,
          teacher_last,
          join_subj
   FROM ms_subj
   WHERE ms_subj.rn_credittype = 1
   ),
   es_ms AS
  (SELECT es.*
   FROM es_hr_subj es
   UNION ALL
   SELECT ms.*
   FROM ms_subj_slim ms
  )
SELECT *
FROM es_ms

 