USE KIPP_NJ
GO

ALTER VIEW PS$category_weighting_setup AS 

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT term.description AS term
        ,s.course_number
        ,sec.id AS psm_sectionid
        ,sync.sectionsDCID
        ,sec.sectionidentifier AS section_number
        ,rt.name AS finalgradename
        ,rt.startdate
        ,rt.enddate
        ,fgsetup.finalgradesetuptype
        ,cat.name
        ,cat.abbreviation
        ,cat.includeinfinalgrades
        ,gfw.weighting        
  FROM PSM_Term term
  JOIN PSM_Section sec
    ON term.id = sec.termid     
  JOIN PSM_FinalGradeSetup fgsetup
    ON sec.id = fgsetup.sectionid  
  JOIN SYNC_SectionMap sync
    ON sec.id = sync.sectionid   
  JOIN SECTIONS s
    ON sync.sectionsdcid = s.dcid
  JOIN PSM_ReportingTerm rt
    ON fgsetup.reportingtermid = rt.id
  LEFT OUTER JOIN PSM_GradingFormula grf
    ON fgsetup.gradingformulaid = grf.id
  LEFT OUTER JOIN PSM_GradingFormulaweighting gfw
    ON grf.id = gfw.parentgradingformulaid
  LEFT OUTER JOIN PSM_AssignmentCategory cat
    ON gfw.assignmentcategoryid = cat.id     
  WHERE term.schoolyear = 2015
') /*-- UPDATE schoolyear ANNUALLY --*/