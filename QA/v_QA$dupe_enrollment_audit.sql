USE KIPP_NJ
GO

ALTER VIEW QA$dupe_enrollment_audit AS

WITH dupe_enr AS (
  SELECT STUDENTID
        ,academic_year        
        ,TERMID        
        ,EXPRESSION
        ,COURSE_NUMBER        
        ,SECTION_NUMBER
        ,DATEENROLLED
        ,DATELEFT
        ,MAX(rn) OVER(PARTITION BY STUDENTID, academic_year, COURSE_NUMBER, TERMID, EXPRESSION) AS N_enrollments
  FROM
      (
       SELECT STUDENTID
             ,academic_year
             ,COURSE_NUMBER
             ,SECTIONID
             ,SECTION_NUMBER
             ,TERMID
             ,EXPRESSION
             ,CONVERT(DATE,DATEENROLLED) AS DATEENROLLED
             ,CONVERT(DATE,DATELEFT) AS DATELEFT
             ,ROW_NUMBER() OVER(
                PARTITION BY studentid, course_number, academic_year, termid, EXPRESSION
                  ORDER BY dateenrolled DESC, dateleft DESC) AS rn
       FROM KIPP_NJ..PS$CC#static WITH(NOLOCK)
       WHERE SECTIONID > 0
      ) sub
 )

SELECT enr.*
      ,co.STUDENT_NUMBER
      ,co.LASTFIRST
      ,co.reporting_schoolid AS schoolid
      ,co.GRADE_LEVEL
FROM dupe_enr enr
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON enr.STUDENTID = co.studentid
 AND enr.academic_year = co.year
 AND co.rn = 1
WHERE N_enrollments > 1