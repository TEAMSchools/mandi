USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_GPA$cumulative|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#GPA$cumulative|refresh1') IS NOT NULL
		BEGIN
						DROP TABLE [#GPA$cumulative|refresh1]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#GPA$cumulative|refresh1]
  FROM (SELECT studentid
              ,ROUND(weighted_points / credit_hours,2) AS cumulative_Y1_gpa
              ,earned_credits_cum
              ,audit_trail
              ,schoolid
        FROM (SELECT studentid AS studentid
                    ,schoolid AS schoolid
                    ,ROUND(SUM(CONVERT(FLOAT,weighted_points)),3) AS weighted_points
                    ,CASE
                      WHEN SUM(CONVERT(FLOAT,potentialcrhrs)) = 0 THEN NULL
                      ELSE SUM(CONVERT(FLOAT,potentialcrhrs))
                     END AS credit_hours
                    ,SUM(earnedcrhrs) AS earned_credits_cum
                    ,dbo.GROUP_CONCAT(audit_hash) AS audit_trail
              FROM OPENQUERY(PS_TEAM,'
                     SELECT studentid
                           ,potentialcrhrs
                           ,CASE
                             WHEN course_number IS NULL THEN ''TRANSF''
                             ELSE course_number
                            END AS course_number            
                           ,grade_level
                           ,schoolid           
                           ,excludefromgpa
                           ,potentialcrhrs * gpa_points AS weighted_points
                           ,earnedcrhrs
                           ,''|'' || course_number || ''_gr'' || grade_level || ''['' || percent ||'']'' || '' ('' || gpa_points || '' pts*'' || earnedcrhrs || '' earned_cr)/'' || potentialcrhrs || '' pot. cr'' || ''|'' AS audit_hash
                     FROM storedgrades
                     WHERE storecode = ''Y1''
                       AND schoolid IN (73252, 73253, 133570965)
                       AND excludefromgpa != 1
                     ')                  
              GROUP BY studentid, schoolid
             ) sub_1
       ) q;


  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);


  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..GPA$cumulative');


  --STEP 5: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'GPA$cumulative';

 EXEC (@sql);


 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[GPA$cumulative]
 SELECT *
 FROM [#GPA$cumulative|refresh1];

 
 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'GPA$cumulative';

 EXEC (@sql);
  
END
GO