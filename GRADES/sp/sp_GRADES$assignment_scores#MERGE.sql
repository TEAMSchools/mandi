USE KIPP_NJ
GO

ALTER PROCEDURE sp_GRADES$assignment_scores#MERGE AS 

BEGIN
  
  IF OBJECT_ID(N'tempdb..#assign_update') IS NOT NULL
		BEGIN
		  DROP TABLE #assign_update
		END;

  SELECT assignmentid      
        ,studentidentifier
        ,score      
        ,turnedinlate
        ,exempt
        ,ismissing      
        ,lastupdated
        ,sectionenrollmentstatus
  INTO #assign_update
  FROM OPENQUERY(PS_TEAM,'    
      SELECT sub.lastupdated
            ,e.sectionenrollmentstatus              
            ,stu.studentidentifier
            ,a.score
            ,a.turnedinlate
            ,a.exempt
            ,a.ismissing
            ,s.assignmentid
      FROM
          (
           SELECT f.sectionenrollmentid          
                 ,MAX(f.lastupdated) AS lastupdated
           FROM PSM_FINALSCORE f
           WHERE f.lastupdated >= TRUNC(SYSDATE - INTERVAL ''72'' HOUR)        
           GROUP BY f.sectionenrollmentid
          ) sub
      JOIN PSM_SECTIONENROLLMENT e
        ON sub.sectionenrollmentid = e.id
      JOIN PSM_STUDENT stu
        ON e.studentid = stu.id
      JOIN PSM_ASSIGNMENTSCORE a  
        ON e.id = a.sectionenrollmentid          
      JOIN PSM_SECTIONASSIGNMENT s
        ON a.sectionassignmentid = s.id      
    ');

  MERGE KIPP_NJ..GRADES$assignment_scores#STAGING AS TARGET
  USING #assign_update AS SOURCE
     ON TARGET.assignmentid = SOURCE.assignmentid
    AND TARGET.studentidentifier = SOURCE.studentidentifier
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.score = SOURCE.score
       ,TARGET.turnedinlate = SOURCE.turnedinlate
       ,TARGET.exempt = SOURCE.exempt       
       ,TARGET.ismissing = SOURCE.ismissing
       ,TARGET.lastupdated = SOURCE.lastupdated
       ,TARGET.sectionenrollmentstatus = SOURCE.sectionenrollmentstatus
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (assignmentid
    ,studentidentifier
    ,score
    ,turnedinlate
    ,exempt
    ,ismissing
    ,lastupdated
    ,sectionenrollmentstatus)
   VALUES
    (SOURCE.assignmentid
    ,SOURCE.studentidentifier
    ,SOURCE.score
    ,SOURCE.turnedinlate
    ,SOURCE.exempt
    ,SOURCE.ismissing
    ,SOURCE.lastupdated
    ,SOURCE.sectionenrollmentstatus)
  WHEN NOT MATCHED BY SOURCE AND TARGET.lastupdated >= DATEADD(DAY,-3,CONVERT(DATE,GETDATE()))
   THEN DELETE;

END

GO