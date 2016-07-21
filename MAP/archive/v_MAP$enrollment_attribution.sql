USE KIPP_NJ 
GO

ALTER VIEW MAP$enrollment_attribution AS 
WITH es_hr AS (
  SELECT hr.studentid
        ,hr.year
        ,hr.teacher_name AS teacher
        ,hr.section_number AS enrollment
  FROM KIPP_NJ..COHORT$student_homerooms hr WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
    ON hr.studentid = c.studentid
   AND hr.year = c.year
   AND c.rn = 1
  WHERE hr.rn_stu_year = 1
    AND c.grade_level < 5
)
    
,es_hr_subj AS (
  SELECT es_hr.*
        ,'Mathematics' AS join_subj
  FROM es_hr
  UNION ALL
  SELECT es_hr.*
        ,'Reading' AS join_subj
  FROM es_hr
 )
 
,ms_base AS (
  SELECT c.studentid, 
         c.year
  FROM KIPP_NJ..COHORT$comprehensive_long#static c WITH(NOLOCK)
  WHERE c.rn = 1
 )
 
,ms_subj AS (
  SELECT ms_base.*
        ,ce.academic_year
        ,ce.course_number
        ,ce.teacher_name AS teacher
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
  JOIN PS$course_enrollments#static ce WITH(NOLOCK)
    ON ms_base.studentid = ce.studentid
   AND ce.credittype IN ('ENG', 'MATH', 'RHET', 'SCI')
   AND ce.drop_flags = 0
 )
 
,ms_subj_slim AS (
  SELECT studentid
        ,year
        ,teacher
        ,course_number AS enrollment
        ,join_subj
  FROM ms_subj
  WHERE ms_subj.rn_credittype = 1
 )
 
SELECT es.studentid
      ,es.year
      ,es.teacher
      ,es.enrollment
      ,es.join_subj
FROM es_hr_subj es
UNION ALL
SELECT ms.studentid
      ,ms.year
      ,ms.teacher
      ,ms.enrollment
      ,ms.join_subj
FROM ms_subj_slim ms
