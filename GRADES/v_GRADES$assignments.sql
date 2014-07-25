USE KIPP_NJ
GO

ALTER VIEW GRADES$assignments AS

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
        ,cat.abbreviation AS category           
  FROM psm_sectionassignment sectassign
  JOIN psm_assignment asmt
    ON sectassign.assignmentid = asmt.id  
  JOIN sync_sectionmap map
    ON sectassign.sectionid = map.sectionid
  JOIN sections sec
    ON map.sectionsDCID = sec.dcid
  JOIN psm_assignmentcategory cat
    ON asmt.assignmentcategoryid = cat.id  
  WHERE sectassign.dateassignmentdue >= TO_DATE(''2013-08-01'',''YYYY-MM-DD'')
')