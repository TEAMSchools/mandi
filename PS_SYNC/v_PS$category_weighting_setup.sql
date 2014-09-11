USE KIPP_NJ
GO

ALTER VIEW PS$category_weighting_setup AS 

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT term.description AS term
        ,sec.id AS psm_sectionid
        ,sync.sectionsDCID
        ,sec.sectionidentifier AS section_number
        ,rt.name AS finalgradename
        ,rt.startdate
        ,rt.enddate
        ,fgsetup.finalgradesetuptype
        ,cat.name
        ,cat.abbreviation
        ,gfw.weighting        
  FROM PSM_Term term
  JOIN PSM_Section sec
    ON term.id = sec.termid  
  JOIN PSM_FinalGradeSetup fgsetup
    ON sec.id = fgsetup.sectionid  
  JOIN PSM_ReportingTerm rt
    ON fgsetup.reportingtermid = rt.id
  JOIN PSM_GradingFormula grf
    ON fgsetup.gradingformulaid = grf.id
  JOIN PSM_GradingFormulaweighting gfw
    ON grf.id = gfw.parentgradingformulaid
  JOIN PSM_AssignmentCategory cat
    ON gfw.assignmentcategoryid = cat.id
   AND cat.includeinfinalgrades = 1
  JOIN SYNC_SectionMap sync
    ON sec.id = sync.sectionid
  WHERE term.schoolyear = 2015
')