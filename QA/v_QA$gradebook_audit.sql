USE KIPP_NJ
GO

ALTER VIEW QA$gradebook_audit AS

WITH enrollments AS (
  SELECT sec.schoolid
        ,sec.termid
        ,sec.DCID
        ,sec.id AS sectionid
        ,c.CREDITTYPE
        ,sec.COURSE_NUMBER
        ,c.COURSE_NAME        
        ,sec.SECTION_NUMBER
        ,CASE        
          WHEN sec.schoolid != 73253 THEN sec.SECTION_NUMBER
          WHEN sec.expression = '1(A)' THEN 'HR'
          WHEN sec.expression = '2(A)' THEN '1'
          WHEN sec.expression = '3(A)' THEN '2'
          WHEN sec.expression = '4(A)' THEN '3'
          WHEN sec.expression = '5(A)' THEN '4A'
          WHEN sec.expression = '6(A)' THEN '4B'
          WHEN sec.expression = '7(A)' THEN '4C'
          WHEN sec.expression = '8(A)' THEN '4D'
          WHEN sec.expression = '9(A)' THEN '5A'
          WHEN sec.expression = '10(A)' THEN '5B'
          WHEN sec.expression = '11(A)' THEN '5C'
          WHEN sec.expression = '12(A)' THEN '5D'
          WHEN sec.expression = '13(A)' THEN '6'
          WHEN sec.expression = '14(A)' THEN '7'
          ELSE NULL
         END AS period
        ,t.LASTFIRST AS teacher
  FROM SECTIONS sec WITH(NOLOCK)    
  JOIN COURSES c WITH(NOLOCK)
    ON sec.course_number = c.COURSE_NUMBER
  JOIN TEACHERS t WITH(NOLOCK)
    ON sec.TEACHER = t.ID
  WHERE sec.TERMID >= dbo.fn_Global_Term_Id()
    AND sec.SCHOOLID IN (73252, 73253, 133570965)
    AND sec.COURSE_NUMBER NOT IN ('HR', 'CCR405')
 )

SELECT enr.schoolid            
      ,enr.CREDITTYPE
      ,enr.teacher
      ,enr.COURSE_NAME  
      ,enr.COURSE_NUMBER          
      ,enr.sectionid
      ,enr.SECTION_NUMBER
      ,enr.period
      ,enr.TERMID
      ,cat.finalgradename      
      ,cat.startdate
      ,cat.ENDDATE
      ,cat.FINALGRADESETUPTYPE
      ,cat.NAME AS category
      ,LTRIM(RTRIM(cat.ABBREVIATION)) AS abbv
      ,ROUND(CONVERT(FLOAT,cat.WEIGHTING), 3) AS weight
FROM enrollments enr WITH(NOLOCK)
LEFT OUTER JOIN PS$category_weighting_setup#static cat WITH(NOLOCK)
  ON enr.dcid = cat.sectionsdcid