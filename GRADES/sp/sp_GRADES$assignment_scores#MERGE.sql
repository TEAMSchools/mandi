USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$assignment_scores#MERGE AS 

BEGIN

  WITH assign_update AS (
    SELECT assignmentid      
          ,studentidentifier AS student_number
          ,score      
          ,turnedinlate
          ,exempt
          ,ismissing      
    FROM OPENQUERY(PS_TEAM,'
      SELECT DISTINCT
             s.assignmentid        
            ,stu.studentidentifier
            ,a.score
            ,a.turnedinlate
            ,a.exempt
            ,a.ismissing        
      FROM PSM_ASSIGNMENTSCORE a  
      JOIN PSM_SECTIONASSIGNMENT s
        ON a.sectionassignmentid = s.id
      JOIN PSM_SECTIONENROLLMENT e
        ON a.sectionenrollmentid = e.id       
      JOIN PSM_STUDENT stu
        ON e.studentid = stu.id  
      JOIN PSM_FINALSCORE f
        ON e.id = f.sectionenrollmentid      
      WHERE f.lastupdated >= (SYSDATE - INTERVAL ''24'' HOUR)        
    ')
   )

  MERGE KIPP_NJ..GRADES$assignment_scores#STAGING AS TARGET
  USING assign_update AS SOURCE
     ON TARGET.assignmentid = SOURCE.assignmentid
    AND TARGET.student_number = SOURCE.student_number
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.score = SOURCE.score
       ,TARGET.turnedinlate = SOURCE.turnedinlate
       ,TARGET.exempt = SOURCE.exempt       
       ,TARGET.ismissing = SOURCE.ismissing
  WHEN NOT MATCHED THEN
   INSERT
    (assignmentid
    ,student_number
    ,score
    ,turnedinlate
    ,exempt
    ,ismissing)
   VALUES
    (SOURCE.assignmentid
    ,SOURCE.student_number
    ,SOURCE.score
    ,SOURCE.turnedinlate
    ,SOURCE.exempt
    ,SOURCE.ismissing);

END

GO