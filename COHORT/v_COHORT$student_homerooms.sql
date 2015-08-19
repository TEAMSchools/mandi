USE KIPP_NJ
GO

ALTER VIEW COHORT$student_homerooms AS
WITH hr_rost AS (
  SELECT sect.academic_year AS year
        ,sect.studentid
        ,sect.dateenrolled
        ,sch.abbreviation AS school
        ,sect.teacher_name        
        ,sect.section_number
        ,sect.course_number
        ,sect.teachernumber
  FROM KIPP_NJ..PS$course_enrollments#static sect WITH(NOLOCK)
  JOIN KIPP_NJ..PS$SCHOOLS#static sch WITH(NOLOCK)
    ON sect.schoolid = sch.SCHOOL_NUMBER
  WHERE sect.course_number = 'HR'
 )

SELECT hr_rost.*
      ,ROW_NUMBER() OVER (
        PARTITION BY studentid, year
         ORDER BY dateenrolled DESC) AS rn_stu_year
FROM hr_rost