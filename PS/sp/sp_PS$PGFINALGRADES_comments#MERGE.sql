USE KIPP_NJ
GO

ALTER PROCEDURE sp_PS$PGFINALGRADES_comments#MERGE AS

BEGIN

  IF OBJECT_ID(N'tempdb..#comments_UPDATE') IS NOT NULL
  BEGIN
				  DROP TABLE [#comments_UPDATE]
  END;

  WITH comments_update AS (
    SELECT studentid
          ,sectionid
          ,startdate
          ,finalgradename
          ,comment_value    
    FROM OPENQUERY(PS_TEAM,'
      SELECT pgf.studentid            
            ,pgf.sectionid           
            ,TRUNC(pgf.startdate) AS startdate
            ,pgf.finalgradename             
            ,TRIM(pgf.comment_value) AS comment_value
      FROM pgfinalgrades pgf       
      WHERE pgf.comment_value IS NOT NULL         
        AND pgf.finalgradename LIKE ''Q%''
        AND pgf.startdate >= TO_DATE(''2015-07-01'',''YYYY-MM-DD'') /* UPDATE DATE ANNUALLY */
    ')
   )

  SELECT *
  INTO #comments_UPDATE
  FROM comments_update;

  MERGE KIPP_NJ..PS$PGFINALGRADES_comments AS TARGET
  USING #comments_UPDATE AS SOURCE
     ON TARGET.studentid = SOURCE.studentid        
    AND TARGET.sectionid = SOURCE.sectionid
    AND TARGET.finalgradename = SOURCE.finalgradename
  WHEN MATCHED THEN
   UPDATE
    SET TARGET.startdate = SOURCE.startdate
       ,TARGET.comment_value = SOURCE.comment_value       
  WHEN NOT MATCHED BY TARGET THEN
   INSERT
    (studentid
    ,sectionid
    ,startdate
    ,finalgradename
    ,comment_value)
   VALUES
    (SOURCE.studentid
    ,SOURCE.sectionid
    ,SOURCE.startdate
    ,SOURCE.finalgradename
    ,SOURCE.comment_value)
  WHEN NOT MATCHED BY SOURCE AND TARGET.startdate >= '2015-07-01' THEN /* UPDATE ANNUALLY */
   DELETE;
  --OUTPUT $ACTION, DELETED.*

END

GO