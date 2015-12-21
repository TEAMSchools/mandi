USE KIPP_NJ
GO

ALTER VIEW DISC$lunch_detention_roster AS

WITH lunch_period AS (
  SELECT enr.student_number 
        ,enr.period AS lunch_period
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND enr.drop_flags = 0
    AND enr.period IN ('LA','LB')
 )

SELECT s.STUDENT_NUMBER
      ,s.lastfirst AS student_name
      ,disc.consequence_date AS entry_date
      ,disc.subject      
      ,disc.entry_date AS detention_date
      ,disc.entry_author      
      ,s.advisor
      ,l.lunch_period
FROM KIPP_NJ..DISC$log#static disc WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static s
  ON disc.studentid = s.studentid
 AND disc.academic_year = s.year
 AND s.rn = 1
LEFT OUTER JOIN lunch_period l
  ON s.student_number = l.student_number
WHERE disc.schoolid = 73253
  AND disc.logtypeid = -100000
  AND disc.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()