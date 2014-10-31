USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$MEMBERSHIP|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$MEMBERSHIP|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$MEMBERSHIP|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
        ,dbo.fn_DateToSY(calendardate) AS academic_year
		INTO [#PS$MEMBERSHIP|refresh]
  FROM OPENQUERY(PS_TEAM,'
    SELECT ctod.studentid         
          ,ctod.schoolid
          ,ctod.calendardate         
          ,ctod.attendancevalue
          ,ctod.membershipvalue             
          ,ctod.potential_attendancevalue
    FROM ps_adaadm_daily_ctod ctod   
    WHERE calendardate >= TO_DATE(''2012-08-01'',''YYYY-MM-DD'')
      AND calendardate <= TRUNC(SYSDATE)
  '); /*-- UPDATE EVERY YEAR --*/
  

  --STEP 3: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..MEMBERSHIP');

  --STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 
   'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
  FROM 
   sys.indexes
  JOIN 
   sys.objects 
   ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
   AND sys.objects.type_desc = 'USER_TABLE'
   AND sys.objects.name = 'MEMBERSHIP';
 EXEC (@sql);

 -- step 5: insert into final destination
 INSERT INTO [dbo].[MEMBERSHIP]
 SELECT *
 FROM [#PS$MEMBERSHIP|refresh];

 -- Step 6: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'MEMBERSHIP';
 EXEC (@sql);
  
END