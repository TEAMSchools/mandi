USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$category_weighting_setup#MERGE AS

BEGIN

  WITH cat_update AS (
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(startdate) AS academic_year
    FROM OPENQUERY(PS_TEAM,'
      SELECT DISTINCT 
             term.description AS term
            ,s.course_number
            ,sec.id AS psm_sectionid
            ,sync.sectionsDCID
            ,sec.sectionidentifier AS section_number
            ,rt.name AS finalgradename
            ,rt.startdate
            ,rt.enddate
            ,fgsetup.finalgradesetuptype
            ,NVL(cat.name, rt.name || NVL(TO_CHAR(gfw.weighting), ''TP'')) AS name
            ,cat.abbreviation
            ,cat.includeinfinalgrades
            ,gfw.weighting        
            ,NVL(gfw.lowscorestodiscard,0) AS lowscorestodiscard
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
       AND rt.name != ''Y1''
      LEFT OUTER JOIN PSM_GradingFormulaWeighting gfw
        ON fgsetup.gradingformulaid = gfw.parentgradingformulaid
      LEFT OUTER JOIN PSM_AssignmentCategory cat
        ON gfw.assignmentcategoryid = cat.id     
      WHERE term.schoolyear = 2015
    ') /*-- UPDATE schoolyear ANNUALLY --*/
   )

  MERGE KIPP_NJ..PS$category_weighting_setup#static AS TARGET
  USING cat_update AS SOURCE
     ON TARGET.PSM_SECTIONID = SOURCE.PSM_SECTIONID
    AND TARGET.FINALGRADENAME = SOURCE.FINALGRADENAME
    AND TARGET.FINALGRADESETUPTYPE = SOURCE.FINALGRADESETUPTYPE
    AND TARGET.NAME = SOURCE.NAME
    --AND ((TARGET.FINALGRADESETUPTYPE = 'WeightedFGSetup' AND TARGET.NAME = SOURCE.NAME) OR (TARGET.FINALGRADESETUPTYPE = 'TotalPoints' AND TARGET.NAME IS NULL))
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.TERM = SOURCE.TERM
         ,TARGET.COURSE_NUMBER = SOURCE.COURSE_NUMBER       
         ,TARGET.SECTIONSDCID = SOURCE.SECTIONSDCID
         ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER       
         ,TARGET.STARTDATE = SOURCE.STARTDATE
         ,TARGET.ENDDATE = SOURCE.ENDDATE              
         ,TARGET.ABBREVIATION = SOURCE.ABBREVIATION
         ,TARGET.INCLUDEINFINALGRADES = SOURCE.INCLUDEINFINALGRADES
         ,TARGET.WEIGHTING = SOURCE.WEIGHTING
         ,TARGET.LOWSCORESTODISCARD = SOURCE.LOWSCORESTODISCARD
         ,TARGET.academic_year = SOURCE.academic_year
    WHEN NOT MATCHED BY TARGET THEN
     INSERT
      (TERM
      ,COURSE_NUMBER
      ,PSM_SECTIONID
      ,SECTIONSDCID
      ,SECTION_NUMBER
      ,FINALGRADENAME
      ,STARTDATE
      ,ENDDATE
      ,FINALGRADESETUPTYPE
      ,NAME
      ,ABBREVIATION
      ,INCLUDEINFINALGRADES
      ,WEIGHTING
      ,LOWSCORESTODISCARD
      ,academic_year)
     VALUES
      (SOURCE.TERM
      ,SOURCE.COURSE_NUMBER
      ,SOURCE.PSM_SECTIONID
      ,SOURCE.SECTIONSDCID
      ,SOURCE.SECTION_NUMBER
      ,SOURCE.FINALGRADENAME
      ,SOURCE.STARTDATE
      ,SOURCE.ENDDATE
      ,SOURCE.FINALGRADESETUPTYPE
      ,SOURCE.NAME
      ,SOURCE.ABBREVIATION
      ,SOURCE.INCLUDEINFINALGRADES
      ,SOURCE.WEIGHTING
      ,SOURCE.LOWSCORESTODISCARD
      ,SOURCE.academic_year)
    WHEN NOT MATCHED BY SOURCE AND TARGET.STARTDATE >= CONVERT(DATE,CONCAT(KIPP_NJ.dbo.fn_Global_Academic_Year(), '-08-01')) THEN
     DELETE;
    --OUTPUT $ACTION, deleted.*;

END

GO