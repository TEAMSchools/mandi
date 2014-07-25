USE KIPP_NJ
GO

ALTER VIEW GRADES$assignment_scores AS

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT psm_sectionassignment.assignmentid        
        ,psm_student.studentidentifier AS student_number
        ,psm_assignmentscore.score        
        ,psm_assignment.extracreditpoints
        ,psm_assignmentscore.turnedinlate        
        ,psm_assignmentscore.exempt
        ,psm_assignmentscore.ismissing      
  FROM psm_section
  JOIN sync_sectionmap
    ON sync_sectionmap.sectionid = psm_section.id
  JOIN sections
    ON sync_sectionmap.sectionsdcid = sections.dcid      
   AND sections.termid >= 2300
  LEFT OUTER JOIN psm_sectionenrollment
    ON psm_section.id = psm_sectionenrollment.sectionid
  LEFT OUTER JOIN psm_assignmentscore
    ON psm_sectionenrollment.id = psm_assignmentscore.sectionenrollmentid
  LEFT OUTER JOIN psm_student
    ON psm_sectionenrollment.studentid = psm_student.id
  LEFT OUTER JOIN psm_sectionassignment
    ON psm_assignmentscore.sectionassignmentid = psm_sectionassignment.id
  LEFT OUTER JOIN psm_assignment
    ON psm_sectionassignment.assignmentid = psm_assignment.id
')