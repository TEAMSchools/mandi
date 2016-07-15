USE KIPP_NJ
GO

ALTER VIEW TABLEAU$gradebook_setup AS 

SELECT NULL AS sectionid
      ,NULL AS academic_year            
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

UNION ALL

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

      ,gb.FINALGRADENAME
      ,LEFT(gb.FINALGRADENAME,1) AS finalgrade_category
      ,gb.FINALGRADESETUPTYPE
      ,gb.GRADINGFORMULAWEIGHTINGTYPE
      ,gb.NAME AS grade_category
      ,gb.ABBREVIATION AS grade_category_abbreviation
      ,gb.WEIGHTING
      ,gb.INCLUDEINFINALGRADES                   
      ,gb.DEFAULTSCORETYPE            
      
      ,a.ASSIGNMENTID
      ,a.ASSIGN_DATE
      ,a.ASSIGN_NAME
      ,a.POINTSPOSSIBLE
      ,a.WEIGHT
      ,a.EXTRACREDITPOINTS
      ,a.ISFINALSCORECALCULATED

      ,ROW_NUMBER() OVER(
         PARTITION BY sec.id, gb.finalgradename, gb.assignmentcategoryid
           ORDER BY a.ASSIGN_DATE ASC) AS rn_category
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$PERIOD#static p WITH(NOLOCK)
  ON sec.academic_year = p.academic_year
 AND sec.schoolid = p.SCHOOLID
 AND KIPP_NJ.dbo.fn_StripCharacters(sec.expression,'^0-9') = p.PERIOD_NUMBER
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON sec.COURSE_NUMBER = cou.COURSE_NUMBER
JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid 
 AND gb.FINALGRADESETUPTYPE = 'WeightedFGSetup'
 AND gb.STARTDATE <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID
 AND gb.ASSIGNMENTCATEGORYID = a.assignmentcategoryid
 AND a.ASSIGN_DATE BETWEEN gb.STARTDATE AND gb.ENDDATE

 UNION ALL

 SELECT sec.ID AS sectionid
       ,sec.academic_year            
       ,sec.schoolid
       ,sec.SECTION_NUMBER
       ,p.abbreviation AS period
      
       ,t.TEACHERNUMBER
       ,t.LASTFIRST AS teacher_name
      
       ,cou.CREDITTYPE
       ,cou.COURSE_NUMBER
       ,cou.COURSE_NAME

       ,gb.FINALGRADENAME
       ,LEFT(gb.FINALGRADENAME,1) AS finalgrade_category
       ,gb.FINALGRADESETUPTYPE
       ,gb.GRADINGFORMULAWEIGHTINGTYPE
       ,gb.NAME AS grade_category
       ,gb.ABBREVIATION AS grade_category_abbreviation
       ,100 AS WEIGHTING
       ,1 AS INCLUDEINFINALGRADES                   
       ,gb.DEFAULTSCORETYPE            
      
       ,a.ASSIGNMENTID
       ,a.ASSIGN_DATE
       ,a.ASSIGN_NAME
       ,a.POINTSPOSSIBLE
       ,a.WEIGHT
       ,a.EXTRACREDITPOINTS
       ,a.ISFINALSCORECALCULATED

       ,ROW_NUMBER() OVER(
          PARTITION BY sec.id, gb.finalgradename, gb.assignmentcategoryid
            ORDER BY a.ASSIGN_DATE ASC) AS rn_category
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$PERIOD#static p WITH(NOLOCK)
  ON sec.academic_year = p.academic_year
 AND sec.schoolid = p.SCHOOLID
 AND KIPP_NJ.dbo.fn_StripCharacters(sec.expression,'^0-9') = p.PERIOD_NUMBER
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$COURSES#static cou WITH(NOLOCK)
  ON sec.COURSE_NUMBER = cou.COURSE_NUMBER
JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid 
 AND gb.FINALGRADESETUPTYPE = 'TotalPoints'
 AND gb.STARTDATE <= CONVERT(DATE,GETDATE())
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID 
 AND a.ASSIGN_DATE BETWEEN gb.STARTDATE AND gb.ENDDATE