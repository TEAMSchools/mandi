USE KIPP_NJ
GO

ALTER VIEW GRADES$assignment_scores AS

SELECT assignmentid
      ,student_number
      ,score
      ,NULL AS extracreditpoints -- we can pull this from the assigmnents sync instead
      ,turnedinlate
      ,exempt
      ,ismissing
FROM OPENQUERY(PS_TEAM,'
  SELECT psm_sectionassignment.assignmentid        
        ,psm_student.studentidentifier AS student_number
        ,psm_assignmentscore.score                
        ,psm_assignmentscore.turnedinlate        
        ,psm_assignmentscore.exempt
        ,psm_assignmentscore.ismissing      
  FROM sync_sectionmap    
  JOIN psm_sectionenrollment
    ON sync_sectionmap.sectionid = psm_sectionenrollment.sectionid
  JOIN psm_assignmentscore
    ON psm_sectionenrollment.id = psm_assignmentscore.sectionenrollmentid
  JOIN psm_student
    ON psm_sectionenrollment.studentid = psm_student.id
  JOIN psm_sectionassignment
    ON psm_assignmentscore.sectionassignmentid = psm_sectionassignment.id  
  WHERE sync_sectionmap.created >= TO_DATE(''2014-08-01'',''YYYY-MM-DD'')
')