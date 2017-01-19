USE KIPP_NJ
GO

ALTER VIEW DL$missing_assignments#extract AS 

SELECT a.STUDENT_NUMBER
      ,CONVERT(DATE,a.ASSIGN_DATE) AS assign_date
      ,a.grade_category            
      ,a.ASSIGN_NAME      
      ,c.COURSE_NAME
      ,t.LASTFIRST AS teacher_name
FROM KIPP_NJ..TABLEAU$gradebook_assignment_detail a WITH(NOLOCK)
JOIN KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
  ON a.sectionid = sec.ID
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$COURSES#static c WITH(NOLOCK)
  ON sec.COURSE_NUMBER = c.COURSE_NUMBER
WHERE a.academic_year = 2016
  AND a.ismissing = 1
  AND ISNULL(a.SCORE,0) = 0