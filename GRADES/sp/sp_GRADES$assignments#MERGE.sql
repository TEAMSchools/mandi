USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$assignments#MERGE AS

BEGIN

  WITH assign_update AS (
    SELECT *
          ,KIPP_NJ.dbo.fn_DateToSY(assign_date) AS academic_year
          ,COALESCE(whenmodified, whencreated) AS lastmodified
    FROM OPENQUERY(PS_TEAM,'
      SELECT sec.schoolid
            ,sec.id AS sectionid
            ,sec.section_number                
            ,sectassign.sectionid AS psm_sectionid                
            ,sectassign.assignmentid AS assignmentid
            ,sectassign.dateassignmentdue AS assign_date
            ,asmt.name AS assign_name
            ,asmt.pointspossible
            ,asmt.weight        
            ,asmt.extracreditpoints
            ,asmt.assignmentcategoryid
            ,cat.abbreviation AS category  
            ,asmt.isfinalscorecalculated         
            ,asmt.whencreated
            ,asmt.whenmodified
      FROM psm_sectionassignment sectassign
      JOIN psm_assignment asmt
        ON sectassign.assignmentid = asmt.id  
      JOIN sync_sectionmap map
        ON sectassign.sectionid = map.sectionid
      JOIN sections sec
        ON map.sectionsDCID = sec.dcid
      JOIN psm_assignmentcategory cat
        ON asmt.assignmentcategoryid = cat.id              
      WHERE (asmt.whencreated >= TRUNC(SYSDATE - INTERVAL ''24'' HOUR) OR asmt.whenmodified >= TRUNC(SYSDATE - INTERVAL ''24'' HOUR))
    ') 
   )

    MERGE KIPP_NJ..GRADES$assignments#STAGING AS TARGET
    USING assign_update AS SOURCE
       ON TARGET.assignmentid = SOURCE.assignmentid    
      AND TARGET.PSM_SECTIONID = SOURCE.PSM_SECTIONID
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.SCHOOLID = SOURCE.SCHOOLID
         ,TARGET.SECTIONID = SOURCE.SECTIONID
         ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER         
         ,TARGET.ASSIGN_DATE = SOURCE.ASSIGN_DATE
         ,TARGET.ASSIGN_NAME = SOURCE.ASSIGN_NAME
         ,TARGET.POINTSPOSSIBLE = SOURCE.POINTSPOSSIBLE
         ,TARGET.WEIGHT = SOURCE.WEIGHT
         ,TARGET.EXTRACREDITPOINTS = SOURCE.EXTRACREDITPOINTS
         ,TARGET.CATEGORY = SOURCE.CATEGORY
         ,TARGET.ASSIGNMENTCATEGORYID = SOURCE.ASSIGNMENTCATEGORYID
         ,TARGET.ISFINALSCORECALCULATED = SOURCE.ISFINALSCORECALCULATED
         ,TARGET.academic_year = SOURCE.academic_year
         ,TARGET.lastmodified = SOURCE.lastmodified
    WHEN NOT MATCHED BY TARGET THEN
     INSERT
      (SCHOOLID
      ,SECTIONID
      ,SECTION_NUMBER
      ,PSM_SECTIONID
      ,ASSIGNMENTID
      ,ASSIGN_DATE
      ,ASSIGN_NAME
      ,POINTSPOSSIBLE
      ,WEIGHT
      ,EXTRACREDITPOINTS
      ,CATEGORY
      ,ASSIGNMENTCATEGORYID
      ,ISFINALSCORECALCULATED
      ,academic_year
      ,lastmodified)
     VALUES
      (SOURCE.SCHOOLID
      ,SOURCE.SECTIONID
      ,SOURCE.SECTION_NUMBER
      ,SOURCE.PSM_SECTIONID
      ,SOURCE.ASSIGNMENTID
      ,SOURCE.ASSIGN_DATE
      ,SOURCE.ASSIGN_NAME
      ,SOURCE.POINTSPOSSIBLE
      ,SOURCE.WEIGHT
      ,SOURCE.EXTRACREDITPOINTS
      ,SOURCE.CATEGORY
      ,SOURCE.ASSIGNMENTCATEGORYID
      ,SOURCE.ISFINALSCORECALCULATED
      ,SOURCE.academic_year
      ,SOURCE.lastmodified)
    WHEN NOT MATCHED BY SOURCE AND TARGET.lastmodified >= DATEADD(DAY,-1,CONVERT(DATE,GETDATE()))
     THEN DELETE
    --OUTPUT $ACTION, DELETED.*
   ;

END

GO