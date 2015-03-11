USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$assignments#MERGE AS

BEGIN

  WITH assign_update AS (
    SELECT *
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
            ,cat.abbreviation AS category  
            ,asmt.isfinalscorecalculated         
      FROM psm_sectionassignment sectassign
      JOIN psm_assignment asmt
        ON sectassign.assignmentid = asmt.id  
      JOIN sync_sectionmap map
        ON sectassign.sectionid = map.sectionid
      JOIN sections sec
        ON map.sectionsDCID = sec.dcid
      JOIN psm_assignmentcategory cat
        ON asmt.assignmentcategoryid = cat.id  
      WHERE (asmt.whencreated >= (SYSDATE - INTERVAL ''24'' HOUR) OR asmt.whenmodified >= (SYSDATE - INTERVAL ''24'' HOUR))
    ')
   )

    MERGE KIPP_NJ..GRADES$assignments#STAGING AS TARGET
    USING assign_update AS SOURCE
       ON TARGET.assignmentid = SOURCE.assignmentid    
    WHEN MATCHED THEN
     UPDATE
      SET TARGET.SCHOOLID = SOURCE.SCHOOLID
         ,TARGET.SECTIONID = SOURCE.SECTIONID
         ,TARGET.SECTION_NUMBER = SOURCE.SECTION_NUMBER
         ,TARGET.PSM_SECTIONID = SOURCE.PSM_SECTIONID
         ,TARGET.ASSIGN_DATE = SOURCE.ASSIGN_DATE
         ,TARGET.ASSIGN_NAME = SOURCE.ASSIGN_NAME
         ,TARGET.POINTSPOSSIBLE = SOURCE.POINTSPOSSIBLE
         ,TARGET.WEIGHT = SOURCE.WEIGHT
         ,TARGET.EXTRACREDITPOINTS = SOURCE.EXTRACREDITPOINTS
         ,TARGET.CATEGORY = SOURCE.CATEGORY
         ,TARGET.ISFINALSCORECALCULATED = SOURCE.ISFINALSCORECALCULATED
    WHEN NOT MATCHED THEN
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
      ,ISFINALSCORECALCULATED)
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
      ,SOURCE.ISFINALSCORECALCULATED);

END

GO