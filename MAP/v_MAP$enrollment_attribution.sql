USE KIPP_NJ 
GO

ALTER VIEW MAP$enrollment_attribution AS 
WITH es_hr AS
    (SELECT hr.studentid
          ,hr.year
          ,hr.teacher_name AS teacher
          ,hr.section_number AS enrollment
    FROM KIPP_NJ..COHORT$student_homerooms hr
    JOIN KIPP_NJ..COHORT$comprehensive_long#static c
      ON hr.studentid = c.studentid
     AND hr.year = c.year
     AND c.rn = 1
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
         ,cc.academic_year
         ,cc.course_number
         ,t.lastfirst AS teacher
         ,CASE 
            WHEN c.credittype = 'MATH' THEN 'Mathematics'
            WHEN c.credittype = 'ENG' THEN 'Reading'
            WHEN c.credittype = 'RHET' THEN 'Language Usage'
            WHEN c.credittype = 'SCI' THEN 'General Science'
          END AS join_subj
         ,ROW_NUMBER() OVER
           (PARTITION BY ms_base.studentid, cc.academic_year, cc.course_number
            ORDER BY cc.dateleft DESC
           ) AS rn_decode
         ,ROW_NUMBER() OVER
           (PARTITION BY ms_base.studentid, cc.academic_year, c.credittype
            ORDER BY c.credit_hours DESC, cc.dateleft DESC
           ) AS rn_credittype
   FROM ms_base
   JOIN KIPP_NJ..CC
     ON ms_base.studentid = cc.studentid
    AND ms_base.year = cc.academic_year
   JOIN KIPP_NJ..SECTIONS sect 
     ON cc.sectionid = sect.id
   JOIN KIPP_NJ..TEACHERS t
     ON sect.teacher = t.id
   JOIN KIPP_NJ..COURSES c
     ON sect.course_number = c.course_number
    AND c.credittype IN ('ENG', 'MATH', 'RHET', 'SCI')
   ),
   ms_subj_slim AS 
  (SELECT studentid,
          year, 
          teacher,
          course_number AS enrollment,
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

 