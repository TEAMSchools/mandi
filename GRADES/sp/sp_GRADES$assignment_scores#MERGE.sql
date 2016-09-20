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
        ,sectionassignmentid
  INTO #assign_update
  FROM OPENQUERY(PS_TEAM,'    
      SELECT sub.lastupdated            
            ,e.sectionenrollmentstatus              
            ,CAST(stu.studentidentifier AS INT) AS studentidentifier
            ,a.score
            ,a.turnedinlate
            ,a.exempt
            ,a.ismissing
            ,s.assignmentid            
            ,a.sectionassignmentid
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

      UNION ALL

      SELECT COALESCE(a.WHENMODIFIED, a.WHENCREATED) AS LASTUPDATED
            ,NULL AS SECTIONENROLLMENTSTATUS
            ,s.STUDENT_NUMBER AS STUDENTIDENTIFIER
            ,a.SCOREPOINTS AS SCORE
            ,a.ISLATE AS TURNEDINLATE
            ,a.ISEXEMPT AS EXEMPT
            ,a.ISMISSING
            ,asec.ASSIGNMENTID            
            ,a.assignmentsectionid AS sectionassignmentid
      FROM ASSIGNMENTSCORE a
      JOIN STUDENTS s
        ON a.STUDENTSDCID = s.DCID
      JOIN ASSIGNMENTSECTION asec
        ON a.assignmentsectionid = asec.assignmentsectionid    
      WHERE TRUNC(COALESCE(a.WHENMODIFIED, a.WHENCREATED)) >= TRUNC(SYSDATE - INTERVAL ''72'' HOUR)
    ');

  MERGE KIPP_NJ..GRADES$assignment_scores#STAGING AS TARGET
  USING #assign_update AS SOURCE
     ON TARGET.assignmentid = SOURCE.assignmentid
    AND TARGET.studentidentifier = SOURCE.studentidentifier
    AND TARGET.sectionassignmentid = SOURCE.sectionassignmentid
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
    ,sectionenrollmentstatus
    ,sectionassignmentid)
   VALUES
    (SOURCE.assignmentid
    ,SOURCE.studentidentifier
    ,SOURCE.score
    ,SOURCE.turnedinlate
    ,SOURCE.exempt
    ,SOURCE.ismissing
    ,SOURCE.lastupdated
    ,SOURCE.sectionenrollmentstatus
    ,SOURCE.sectionassignmentid)
  WHEN NOT MATCHED BY SOURCE AND TARGET.lastupdated >= DATEADD(DAY,-3,CONVERT(DATE,GETDATE()))
   THEN DELETE
  OUTPUT $ACTION, DELETED.*;
END

GO