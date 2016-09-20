USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$gradebook_setup#MERGE AS

BEGIN

  /* drop temp table if exists */
  IF OBJECT_ID(N'tempdb..#gbsetup') IS NOT NULL
    BEGIN
				    DROP TABLE #gbsetup
    END;

  /* load into temp table */
  SELECT *        
  INTO #gbsetup
  FROM OPENQUERY(PS_TEAM,'
    WITH default_gfs AS (
      SELECT DISTINCT 
             gfs.GRADEFORMULASETID	        
            ,gfs.YEARID  
            ,gct.abbreviation
            ,gct.storecode
            ,gct.GRADECALCULATIONTYPEID
            ,gct.TYPE
            ,sch.school_number AS schoolid
      FROM GradeFormulaSet gfs
      JOIN GradeCalculationType gct
        ON gfs.GRADEFORMULASETID = gct.GRADEFORMULASETID
      JOIN GradeCalcSchoolAssoc gcsa
        ON gct.GRADECALCULATIONTYPEID = gcsa.GRADECALCULATIONTYPEID
      JOIN SCHOOLS sch
        ON gcsa.SCHOOLSDCID = sch.DCID
      WHERE gfs.SECTIONSDCID IS NULL
        AND gfs.GRADEFORMULASETID != 3 /* NCA Alternative */
     )
    
    SELECT sec.DCID AS SECTIONSDCID        
          ,ssm.sectionid AS PSM_SECTIONID
        
          ,fg.ID AS FINALGRADESETUPID
          ,fg.FINALGRADESETUPTYPE
        
          ,rt.ID AS FG_REPORTINGTERMID        
          ,rt.NAME AS REPORTINGTERM_NAME
          ,rt.STARTDATE
          ,rt.ENDDATE
        
          ,CASE WHEN gfw.GRADINGFORMULAWEIGHTINGTYPE = ''TermBasedWeighting'' THEN gfw.REPORTINGTERMID ELSE NVL(gfw.parentgradingformulaid, rt.ID) END AS GRADINGFORMULAID
          ,CASE WHEN gfw.GRADINGFORMULAWEIGHTINGTYPE = ''TermBasedWeighting'' THEN ''TermBasedWeighting'' ELSE NVL(gfw.GRADINGFORMULAWEIGHTINGTYPE, fg.FINALGRADESETUPTYPE) END AS GRADINGFORMULAWEIGHTINGTYPE
          ,NVL(gfw.WEIGHTING, 100) AS WEIGHTING
        
          ,CASE WHEN gfw.GRADINGFORMULAWEIGHTINGTYPE = ''TermBasedWeighting'' THEN gfw.REPORTINGTERMID ELSE NVL(cat.ID, rt.ID) END AS ASSIGNMENTCATEGORYID
          ,CASE WHEN gfw.GRADINGFORMULAWEIGHTINGTYPE = ''TermBasedWeighting'' THEN ''TermBasedWeighting'' ELSE NVL(cat.NAME, fg.FINALGRADESETUPTYPE) END AS CATEGORY_NAME
          ,CASE WHEN gfw.GRADINGFORMULAWEIGHTINGTYPE = ''TermBasedWeighting'' THEN ''TermBasedWeighting'' ELSE NVL(cat.ABBREVIATION, fg.FINALGRADESETUPTYPE) END AS CATEGORY_ABBREVIATION
          ,CAST(cat.DEFAULTSCORETYPE AS VARCHAR2(30)) AS DEFAULTSCORETYPE 
          ,NVL(cat.INCLUDEINFINALGRADES, 1) AS INCLUDEINFINALGRADES
    FROM SECTIONS sec
    JOIN SYNC_SectionMap ssm
      ON sec.dcid = ssm.sectionsdcid
    JOIN PSM_FinalGradeSetup fg
      ON ssm.sectionid = fg.sectionid
    JOIN PSM_ReportingTerm rt
      ON fg.reportingtermid = rt.id  
    LEFT OUTER JOIN PSM_GradingFormulaWeighting gfw
      ON fg.gradingformulaid = gfw.parentgradingformulaid   
    LEFT OUTER JOIN PSM_AssignmentCategory cat
      ON gfw.ASSIGNMENTCATEGORYID = cat.id    
    WHERE sec.termid >= 2500
      AND sec.gradebooktype != 2

    UNION ALL

    SELECT SECTIONSDCID
          ,SECTIONSDCID AS PSM_SECTIONID
                
          ,NVL(GRADEFORMULASETID, 0) AS FINALGRADESETUPID
          ,GCT_TYPE AS FINALGRADESETUPTYPE        
        
          ,GRADECALCULATIONTYPEID AS FG_REPORTINGTERMID
          ,STORECODE AS REPORTINGTERM_NAME
          ,DATE1 AS STARTDATE
          ,DATE2 AS ENDDATE

          ,NVL(GRADECALCFORMULAWEIGHTID, GRADECALCULATIONTYPEID)AS GRADINGFORMULAID
          ,NVL(GCFW_TYPE, GCT_TYPE) AS GRADINGFORMULAWEIGHTINGTYPE
          ,WEIGHT AS WEIGHTING         
          
          ,COALESCE(DISTRICTTEACHERCATEGORYID, TEACHERCATEGORYID, GRADECALCULATIONTYPEID) AS ASSIGNMENTCATEGORYID
          ,COALESCE(dtc_NAME, tc_NAME, GCT_TYPE) AS CATEGORY_NAME
          ,COALESCE(dtc_name, tc_NAME, GCT_TYPE) AS CATEGORY_ABBREVIATION
          ,COALESCE(dtc_DEFAULTSCORETYPE, tc_DEFAULTSCORETYPE) AS DEFAULTSCORETYPE
          ,COALESCE(dtc_ISINFINALGRADES, tc_ISINFINALGRADES, 1) AS INCLUDEINFINALGRADES
    FROM
        (
         SELECT sec.DCID AS SECTIONSDCID
        
               ,tb.STORECODE
               ,tb.DATE1
               ,tb.DATE2

               ,gfs.GRADEFORMULASETID
                
               ,gct.GRADECALCULATIONTYPEID
               ,gct.TYPE AS gct_type       

               ,gcfw.GRADECALCFORMULAWEIGHTID
               ,gcfw.TEACHERCATEGORYID
               ,gcfw.DISTRICTTEACHERCATEGORYID
               ,gcfw.WEIGHT
               ,gcfw.TYPE AS gcfw_type        
        
               ,tc.TEACHERMODIFIED
               ,tc.NAME AS tc_name
               ,tc.DEFAULTSCORETYPE AS tc_defaultscoretype
               ,tc.ISINFINALGRADES AS tc_ISINFINALGRADES

               ,dtc.NAME AS dtc_name
               ,dtc.DEFAULTSCORETYPE AS dtc_DEFAULTSCORETYPE
               ,dtc.ISINFINALGRADES AS dtc_ISINFINALGRADES                
         FROM SECTIONS sec       
         JOIN TermBins tb
           ON sec.schoolid = tb.schoolid
          AND sec.termid = tb.termid   
         JOIN GradeFormulaSet gfs         
           ON sec.DCID = gfs.SECTIONSDCID         
         JOIN GradeCalculationType gct
           ON gfs.GRADEFORMULASETID = gct.gradeformulasetid    
          AND tb.storecode = gct.storecode 
         LEFT OUTER JOIN GradeCalcFormulaWeight gcfw
           ON gct.gradecalculationtypeid = gcfw.gradecalculationtypeid
         LEFT OUTER JOIN TeacherCategory tc
           ON gcfw.teachercategoryid = tc.teachercategoryid 
         LEFT OUTER JOIN DistrictTeacherCategory dtc
           ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
         WHERE sec.termid >= 2500           
           AND sec.gradebooktype = 2                
           
         UNION ALL
         
         SELECT sec.DCID AS SECTIONSDCID       
               
               ,tb.STORECODE
               ,tb.DATE1
               ,tb.DATE2

               ,d.GRADEFORMULASETID                
               ,d.GRADECALCULATIONTYPEID
               ,d.TYPE AS gct_type       

               ,gcfw.GRADECALCFORMULAWEIGHTID
               ,gcfw.TEACHERCATEGORYID
               ,gcfw.DISTRICTTEACHERCATEGORYID
               ,gcfw.WEIGHT
               ,gcfw.TYPE AS gcfw_type        
        
               ,tc.TEACHERMODIFIED
               ,tc.NAME AS tc_name
               ,tc.DEFAULTSCORETYPE AS tc_defaultscoretype
               ,tc.ISINFINALGRADES AS tc_ISINFINALGRADES

               ,dtc.NAME AS dtc_name
               ,dtc.DEFAULTSCORETYPE AS dtc_DEFAULTSCORETYPE
               ,dtc.ISINFINALGRADES AS dtc_ISINFINALGRADES                
         FROM SECTIONS sec       
         JOIN TermBins tb
           ON sec.schoolid = tb.schoolid
          AND sec.termid = tb.termid            
         JOIN TERMS rt
           ON tb.termid = rt.id
          AND sec.schoolid = rt.schoolid
         JOIN default_gfs d
           ON sec.schoolid = d.schoolid
          AND SUBSTR(sec.termid, 0, 2) = d.yearid
          AND tb.storecode = d.storecode
          AND rt.abbreviation = d.abbreviation
         LEFT OUTER JOIN GradeCalcFormulaWeight gcfw
           ON d.gradecalculationtypeid = gcfw.gradecalculationtypeid
         LEFT OUTER JOIN TeacherCategory tc
           ON gcfw.teachercategoryid = tc.teachercategoryid 
         LEFT OUTER JOIN DistrictTeacherCategory dtc
           ON gcfw.districtteachercategoryid = dtc.districtteachercategoryid
         WHERE sec.termid >= 2500           
           AND sec.gradebooktype = 2   
        ) sub
  ')

  /* merge into destination table */
  MERGE KIPP_NJ..PS$gradebook_setup#static AS TARGET
  USING #gbsetup AS SOURCE
     ON TARGET.SECTIONSDCID = SOURCE.SECTIONSDCID
    AND TARGET.FINALGRADESETUPID = SOURCE.FINALGRADESETUPID    
    AND TARGET.GRADINGFORMULAID = SOURCE.GRADINGFORMULAID
    AND TARGET.ASSIGNMENTCATEGORYID = SOURCE.ASSIGNMENTCATEGORYID
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.FINALGRADESETUPTYPE = SOURCE.FINALGRADESETUPTYPE       
       ,TARGET.PSM_SECTIONID = SOURCE.PSM_SECTIONID       
       ,TARGET.FG_REPORTINGTERMID = SOURCE.FG_REPORTINGTERMID
       ,TARGET.REPORTINGTERM_NAME = SOURCE.REPORTINGTERM_NAME
       ,TARGET.STARTDATE = SOURCE.STARTDATE
       ,TARGET.ENDDATE = SOURCE.ENDDATE       
       ,TARGET.GRADINGFORMULAWEIGHTINGTYPE = SOURCE.GRADINGFORMULAWEIGHTINGTYPE
       ,TARGET.WEIGHTING = SOURCE.WEIGHTING       
       ,TARGET.CATEGORY_NAME = SOURCE.CATEGORY_NAME
       ,TARGET.CATEGORY_ABBREVIATION = SOURCE.CATEGORY_ABBREVIATION
       ,TARGET.DEFAULTSCORETYPE = SOURCE.DEFAULTSCORETYPE
       ,TARGET.INCLUDEINFINALGRADES = SOURCE.INCLUDEINFINALGRADES
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (FINALGRADESETUPID
    ,FINALGRADESETUPTYPE
    ,PSM_SECTIONID
    ,SECTIONSDCID
    ,FG_REPORTINGTERMID
    ,REPORTINGTERM_NAME
    ,STARTDATE
    ,ENDDATE
    ,GRADINGFORMULAID
    ,GRADINGFORMULAWEIGHTINGTYPE
    ,WEIGHTING
    ,ASSIGNMENTCATEGORYID
    ,CATEGORY_NAME
    ,CATEGORY_ABBREVIATION
    ,DEFAULTSCORETYPE
    ,INCLUDEINFINALGRADES)
   VALUES
    (SOURCE.FINALGRADESETUPID
    ,SOURCE.FINALGRADESETUPTYPE
    ,SOURCE.PSM_SECTIONID
    ,SOURCE.SECTIONSDCID
    ,SOURCE.FG_REPORTINGTERMID
    ,SOURCE.REPORTINGTERM_NAME
    ,SOURCE.STARTDATE
    ,SOURCE.ENDDATE
    ,SOURCE.GRADINGFORMULAID
    ,SOURCE.GRADINGFORMULAWEIGHTINGTYPE
    ,SOURCE.WEIGHTING
    ,SOURCE.ASSIGNMENTCATEGORYID
    ,SOURCE.CATEGORY_NAME
    ,SOURCE.CATEGORY_ABBREVIATION
    ,SOURCE.DEFAULTSCORETYPE
    ,SOURCE.INCLUDEINFINALGRADES); 

END