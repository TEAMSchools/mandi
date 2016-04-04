USE KIPP_NJ
GO

ALTER VIEW TABLEAU$gradebook_assignment_detail AS

SELECT sec.ID AS sectionid
      ,sec.academic_year            
      ,gb.FINALGRADENAME
      ,LEFT(gb.FINALGRADENAME,1) AS finalgrade_category
      ,gb.FINALGRADESETUPTYPE
      ,gb.GRADINGFORMULAWEIGHTINGTYPE
      ,gb.NAME AS grade_category
      ,gb.ABBREVIATION AS grade_category_abbreviation
      ,gb.WEIGHTING
      ,gb.INCLUDEINFINALGRADES      
      ,a.ASSIGN_DATE
      ,a.ASSIGN_NAME
      ,a.POINTSPOSSIBLE
      ,a.WEIGHT
      ,a.EXTRACREDITPOINTS
      ,a.ISFINALSCORECALCULATED
      ,scores.studentidentifier AS student_number
      ,scores.SCORE
      ,scores.TURNEDINLATE
      ,scores.EXEMPT
      ,scores.ISMISSING
FROM KIPP_NJ..PS$SECTIONS#static sec WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$gradebook_setup#static gb WITH(NOLOCK)
  ON sec.DCID = gb.sectionsdcid
 AND gb.FINALGRADESETUPTYPE = 'WeightedFGSetup'
LEFT OUTER JOIN KIPP_NJ..GRADES$assignments#STAGING a WITH(NOLOCK)
  ON sec.ID = a.SECTIONID
 AND gb.ASSIGNMENTCATEGORYID = a.assignmentcategoryid
LEFT OUTER JOIN KIPP_NJ..GRADES$assignment_scores#STAGING scores WITH(NOLOCK)
  ON a.ASSIGNMENTID = scores.ASSIGNMENTID
WHERE sec.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()