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
            ,fgsetup.id AS finalgradesetupid
            ,fgsetup.finalgradesetuptype            
            ,NVL(cat.name, rt.name || NVL(TO_CHAR(gfw.weighting), ''TP'')) AS name
            ,gfw.assignmentcategoryid
            ,cat.abbreviation
            ,cat.includeinfinalgrades
            ,cat.defaultscoretype
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
    AND TARGET.finalgradesetupid = SOURCE.finalgradesetupid
    AND ((SOURCE.FINALGRADESETUPTYPE = 'WeightedFGSetup' AND TARGET.ASSIGNMENTCATEGORYID = SOURCE.ASSIGNMENTCATEGORYID) 
          OR (SOURCE.FINALGRADESETUPTYPE = 'TotalPoints'))
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.TERM = SOURCE.TERM
         ,TARGET.COURSE_NUMBER = SOURCE.COURSE_NUMBER       
         ,TARGET.SECTIONSDCID = SOURCE.SECTIONSDCID
         ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER       
         ,TARGET.STARTDATE = SOURCE.STARTDATE
         ,TARGET.ENDDATE = SOURCE.ENDDATE              
         ,TARGET.ABBREVIATION = SOURCE.ABBREVIATION
         ,TARGET.FINALGRADESETUPTYPE = SOURCE.FINALGRADESETUPTYPE
         ,TARGET.INCLUDEINFINALGRADES = SOURCE.INCLUDEINFINALGRADES
         ,TARGET.DEFAULTSCORETYPE= SOURCE.DEFAULTSCORETYPE
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
      ,FINALGRADESETUPID
      ,FINALGRADESETUPTYPE
      ,NAME
      ,ABBREVIATION
      ,INCLUDEINFINALGRADES
      ,DEFAULTSCORETYPE
      ,WEIGHTING
      ,LOWSCORESTODISCARD
      ,ASSIGNMENTCATEGORYID
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
      ,SOURCE.FINALGRADESETUPID
      ,SOURCE.FINALGRADESETUPTYPE
      ,SOURCE.NAME
      ,SOURCE.ABBREVIATION
      ,SOURCE.INCLUDEINFINALGRADES
      ,SOURCE.DEFAULTSCORETYPE
      ,SOURCE.WEIGHTING
      ,SOURCE.LOWSCORESTODISCARD
      ,SOURCE.ASSIGNMENTCATEGORYID
      ,SOURCE.academic_year)
    WHEN NOT MATCHED BY SOURCE AND TARGET.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
     THEN DELETE
    --OUTPUT $ACTION, deleted.*
   ;

END

GO