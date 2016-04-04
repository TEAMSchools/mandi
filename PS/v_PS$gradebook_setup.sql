USE KIPP_NJ
GO

ALTER VIEW PS$gradebook_setup AS

SELECT *
      ,KIPP_NJ.dbo.fn_DateToSY(startdate) AS academic_year
FROM OPENQUERY(PS_TEAM,'
  SELECT rt.NAME AS finalgradename
        ,rt.STARTDATE        
        
        ,fgsetup.FINALGRADESETUPTYPE    
        ,ssm.sectionsdcid    
        
        ,gfw.GRADINGFORMULAWEIGHTINGTYPE
        ,gfw.weighting
        ,gfw.assignmentcategoryid
        
        ,cat.name
        ,cat.abbreviation        
        ,cat.defaultscoretype
        ,cat.includeinfinalgrades
  FROM PSM_ReportingTerm rt
  JOIN PSM_FinalGradeSetup fgsetup    
    ON rt.id = fgsetup.reportingtermid
  JOIN SYNC_SectionMap ssm
    ON fgsetup.sectionid = ssm.sectionid
  LEFT OUTER JOIN PSM_GradingFormulaWeighting gfw
    ON fgsetup.gradingformulaid = gfw.parentgradingformulaid  
  LEFT OUTER JOIN PSM_AssignmentCategory cat
    ON gfw.ASSIGNMENTCATEGORYID = cat.id
  WHERE rt.startdate >= TO_DATE(''2015-07-01'',''YYYY-MM-DD'') /* UPDATE ANNUALLY */
    AND rt.name != ''Y1''    
')