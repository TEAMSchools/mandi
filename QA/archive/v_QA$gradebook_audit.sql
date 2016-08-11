USE KIPP_NJ
GO

ALTER VIEW QA$gradebook_audit AS

WITH distinct_enr AS (
  SELECT DISTINCT 
         enr.schoolid
        ,enr.sectionsDCID
        ,enr.termid
        ,enr.sectionid
        ,enr.CREDITTYPE
        ,enr.COURSE_NUMBER
        ,enr.COURSE_NAME        
        ,enr.SECTION_NUMBER
        ,CASE WHEN enr.schoolid != 73253 THEN enr.SECTION_NUMBER ELSE enr.period END AS period        
        ,enr.teacher_name AS teacher      
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)  
  WHERE enr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

SELECT enr.schoolid        
      ,enr.termid
      ,enr.sectionid
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME        
      ,enr.SECTION_NUMBER
      ,enr.period        
      ,enr.teacher
      ,cat.finalgradename      
      ,cat.startdate
      ,cat.ENDDATE
      ,cat.FINALGRADESETUPTYPE
      ,cat.NAME AS category
      ,LTRIM(RTRIM(cat.ABBREVIATION)) AS abbv
      ,cat.includeinfinalgrades
      ,ROUND(CONVERT(FLOAT,cat.WEIGHTING), 3) AS weight      
FROM distinct_enr enr WITH(NOLOCK)
LEFT OUTER JOIN PS$category_weighting_setup#static cat WITH(NOLOCK)
  ON enr.sectionsDCID = cat.sectionsdcid
WHERE enr.TERMID >= dbo.fn_Global_Term_Id()
  AND enr.SCHOOLID IN (73252, 73253, 133570965)
  AND enr.COURSE_NUMBER NOT IN ('HR', 'CCR405')