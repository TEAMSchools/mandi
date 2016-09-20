USE KIPP_NJ
GO

ALTER VIEW TABLEAU$gradebook_setup AS 

SELECT sec.ID AS sectionid
      ,sec.academic_year            
      ,sec.schoolid
      ,sec.section_number
      ,p.abbreviation AS period
      
      ,t.TEACHERNUMBER
      ,t.LASTFIRST AS teacher_name
      
      ,cou.CREDITTYPE
      ,cou.COURSE_NUMBER
      ,cou.COURSE_NAME
      
      ,gb.REPORTINGTERM_NAME AS FINALGRADENAME
      ,LEFT(gb.REPORTINGTERM_NAME,1) AS finalgrade_category
      ,gb.FINALGRADESETUPTYPE
      ,gb.GRADINGFORMULAWEIGHTINGTYPE
      ,gb.CATEGORY_NAME AS grade_category
      ,gb.CATEGORY_ABBREVIATION AS grade_category_abbreviation
      ,CASE WHEN gb.FINALGRADESETUPTYPE LIKE 'Total%Points' THEN 100 ELSE gb.WEIGHTING END AS weighting
      ,CASE WHEN gb.FINALGRADESETUPTYPE LIKE 'Total%Points' THEN 1 ELSE gb.INCLUDEINFINALGRADES END AS INCLUDEINFINALGRADES
      ,gb.DEFAULTSCORETYPE            
      
      ,a.ASSIGNMENTID
      ,a.ASSIGN_DATE
      ,a.ASSIGN_NAME
      ,a.POINTSPOSSIBLE
      ,a.WEIGHT
      ,a.EXTRACREDITPOINTS
      ,a.ISFINALSCORECALCULATED

      ,ROW_NUMBER() OVER(
         PARTITION BY sec.id, gb.REPORTINGTERM_NAME, gb.assignmentcategoryid
           ORDER BY a.ASSIGN_DATE ASC) AS rn_category
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$PERIOD#static p WITH(NOLOCK)
  ON sec.academic_year = p.academic_year
 AND sec.schoolid = p.SCHOOLID
 AND CONVERT(NUMERIC,KIPP_NJ.dbo.fn_StripCharacters(sec.expression,'^0-9')) = p.PERIOD_NUMBER
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON sec.COURSE_NUMBER = cou.COURSE_NUMBER
JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid  
 AND gb.STARTDATE <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID
 AND gb.ASSIGNMENTCATEGORYID = a.assignmentcategoryid
 AND a.ASSIGN_DATE BETWEEN gb.STARTDATE AND gb.ENDDATE
WHERE sec.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT *
FROM KIPP_NJ..TABLEAU$gradebook_setup#archive WITH(NOLOCK)

UNION ALL

SELECT NULL AS sectionid
      ,KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year            
      ,NULL AS schoolid
      ,NULL AS section_number
      ,NULL AS period
      
      ,NULL AS TEACHERNUMBER
      ,NULL AS teacher_name
      
      ,NULL AS CREDITTYPE
      ,NULL AS COURSE_NUMBER
      ,NULL AS COURSE_NAME

      ,NULL AS FINALGRADENAME
      ,NULL AS finalgrade_category
      ,NULL AS FINALGRADESETUPTYPE
      ,NULL AS GRADINGFORMULAWEIGHTINGTYPE
      ,NULL AS grade_category
      ,NULL AS grade_category_abbreviation
      ,NULL AS WEIGHTING
      ,NULL AS INCLUDEINFINALGRADES                   
      ,NULL AS DEFAULTSCORETYPE            
      
      ,NULL AS ASSIGNMENTID
      ,NULL AS ASSIGN_DATE
      ,NULL AS ASSIGN_NAME
      ,NULL AS POINTSPOSSIBLE
      ,NULL AS WEIGHT
      ,NULL AS EXTRACREDITPOINTS
      ,NULL AS ISFINALSCORECALCULATED

      ,NULL AS rn_category