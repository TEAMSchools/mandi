USE KIPP_NJ
GO

ALTER VIEW TABLEAU$gradebook_assignment_detail AS

SELECT sec.ID AS sectionid
      ,sec.academic_year            
      ,sec.COURSE_NUMBER
      ,sec.SECTION_NUMBER
      ,t.LASTFIRST AS teacher_name
      
      ,gb.REPORTINGTERM_NAME AS FINALGRADENAME
      ,LEFT(gb.REPORTINGTERM_NAME,1) AS finalgrade_category
      ,gb.FINALGRADESETUPTYPE
      ,gb.GRADINGFORMULAWEIGHTINGTYPE
      ,gb.CATEGORY_NAME AS grade_category
      ,gb.CATEGORY_ABBREVIATION AS grade_category_abbreviation
      ,gb.WEIGHTING
      ,gb.INCLUDEINFINALGRADES      
      
      ,a.ASSIGNMENTID
      ,a.ASSIGN_DATE
      ,a.ASSIGN_NAME
      ,a.POINTSPOSSIBLE
      ,a.WEIGHT
      ,a.EXTRACREDITPOINTS
      ,a.ISFINALSCORECALCULATED
      
      ,s.STUDENT_NUMBER
      ,s.SCHOOLID
      ,scores.SCORE
      ,scores.TURNEDINLATE
      ,scores.EXEMPT
      ,scores.ISMISSING
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid
 AND gb.FINALGRADESETUPTYPE NOT LIKE 'Total%Points' 
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID
 AND gb.ASSIGNMENTCATEGORYID = a.assignmentcategoryid
 AND a.ASSIGN_DATE BETWEEN gb.STARTDATE AND gb.ENDDATE
LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON sec.ID = cc.SECTIONID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON cc.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..GRADES$assignment_scores#STAGING scores WITH(NOLOCK)
  ON a.ASSIGNMENTID = scores.ASSIGNMENTID
 AND s.STUDENT_NUMBER = scores.STUDENTIDENTIFIER
WHERE sec.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()

UNION ALL

SELECT sec.ID AS sectionid
      ,sec.academic_year            
      ,sec.COURSE_NUMBER
      ,sec.SECTION_NUMBER
      ,t.LASTFIRST AS teacher_name
      
      ,gb.REPORTINGTERM_NAME AS FINALGRADENAME
      ,LEFT(gb.REPORTINGTERM_NAME,1) AS finalgrade_category
      ,gb.FINALGRADESETUPTYPE
      ,gb.GRADINGFORMULAWEIGHTINGTYPE
      ,gb.CATEGORY_NAME AS grade_category
      ,gb.CATEGORY_ABBREVIATION AS grade_category_abbreviation
      ,gb.WEIGHTING
      ,gb.INCLUDEINFINALGRADES      
      
      ,a.ASSIGNMENTID
      ,a.ASSIGN_DATE
      ,a.ASSIGN_NAME
      ,a.POINTSPOSSIBLE
      ,a.WEIGHT
      ,a.EXTRACREDITPOINTS
      ,a.ISFINALSCORECALCULATED
      
      ,s.STUDENT_NUMBER
      ,s.SCHOOLID
      ,scores.SCORE
      ,scores.TURNEDINLATE
      ,scores.EXEMPT
      ,scores.ISMISSING
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
JOIN KIPP_NJ..PS$TEACHERS#static t WITH(NOLOCK)
  ON sec.TEACHER = t.ID
JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid
 AND gb.FINALGRADESETUPTYPE LIKE 'Total%Points' 
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID 
 AND a.ASSIGN_DATE BETWEEN gb.STARTDATE AND gb.ENDDATE
LEFT OUTER JOIN KIPP_NJ..PS$CC#static cc WITH(NOLOCK)
  ON sec.ID = cc.SECTIONID
LEFT OUTER JOIN KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
  ON cc.studentid = s.ID
LEFT OUTER JOIN KIPP_NJ..GRADES$assignment_scores#STAGING scores WITH(NOLOCK)
  ON a.ASSIGNMENTID = scores.ASSIGNMENTID
 AND s.STUDENT_NUMBER = scores.STUDENTIDENTIFIER
WHERE sec.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()