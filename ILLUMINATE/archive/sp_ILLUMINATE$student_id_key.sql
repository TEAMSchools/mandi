USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [sp_ILLUMINATE$student_id_key#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$student_id_key#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$student_id_key#static|refresh]
		END
		
		
		--STEP 2: load into a TEMPORARY staging table.  
  SELECT *
		INTO [#ILLUMINATE$student_id_key#static|refresh]
		FROM (
		      SELECT student_id AS ill_stu_id
              ,local_student_id AS student_number
              ,s.ID AS studentid      
        FROM OPENQUERY(ILLUMINATE,'
          SELECT student_id
                ,local_student_id
          FROM kippteamschools.public.students
          ') ill_stu
        LEFT OUTER JOIN STUDENTS s WITH(NOLOCK)  
          ON ill_stu.local_student_id = s.STUDENT_NUMBER
		     ) rustandmartysurvive;
  

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$student_id_key');


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
   AND sys.objects.name = 'ILLUMINATE$student_id_key';
 EXEC (@sql);


 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$student_id_key]
 SELECT *
 FROM [#ILLUMINATE$student_id_key#static|refresh];
 

 -- Step 4: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'ILLUMINATE$student_id_key';
 EXEC (@sql);

END

GO