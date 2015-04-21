USE KIPP_NJ
GO

ALTER VIEW TABLEAU$course_enrollments AS

SELECT cc.STUDENTID
      ,cc.STUDENT_NUMBER
      ,cc.SCHOOLID
      ,cc.GRADE_LEVEL
      ,co.TEAM
      ,CONVERT(DATE,cc.DATEENROLLED) AS dateenrolled
      ,CONVERT(DATE,cc.DATELEFT) AS dateleft      
      ,CASE
        WHEN cc.TERMID = 2300 THEN 'Y1'
        WHEN cc.SCHOOLID IN(73252,133570965) AND cc.TERMID = 2301 THEN 'T1'
        WHEN cc.SCHOOLID IN(73252,133570965) AND cc.TERMID = 2302 THEN 'T2'        
        WHEN cc.SCHOOLID IN(73252,133570965) AND cc.TERMID = 2303 THEN 'T3'
        WHEN cc.SCHOOLID = 73253 AND cc.TERMID = 2301 THEN 'S1'
        WHEN cc.SCHOOLID = 73253 AND cc.TERMID = 2302 THEN 'S2'        
       END AS term
      ,cc.SECTION_NUMBER      
      ,cc.CREDITTYPE
      ,cc.COURSE_NUMBER
      ,cc.COURSE_NAME
      ,co.school_name + ' - ' 
        + CONVERT(VARCHAR,cc.grade_level) + ' - ' 
        + cc.COURSE_NUMBER + ' - '
        + CC.SECTION_NUMBER AS synth_course
FROM KIPP_NJ..PS$course_enrollments#static cc WITH(NOLOCK)
JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  ON cc.student_number = co.student_number
 AND cc.academic_year = co.year
 AND co.rn = 1
WHERE cc.TERMID >= KIPP_NJ.dbo.fn_Global_Term_Id()
  AND cc.SCHOOLID IN (73252,73253,133570965)