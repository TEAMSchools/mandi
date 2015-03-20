USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$TEACHERS_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$TEACHERS|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$TEACHERS|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#PS$TEACHERS|refresh]
  FROM OPENQUERY(PS_TEAM,'
    SELECT USERS_DCID
          ,DCID
          ,ID
          ,LASTFIRST
          ,FIRST_NAME
          ,MIDDLE_NAME
          ,LAST_NAME
          ,SCHOOLID
          ,STATUS
          ,TITLE
          ,EMAIL_ADDR
          ,PASSWORD
          ,PSACCESS
          ,LOGINID
          ,CLASSPUA
          ,NOOFCURCLASSES
          ,GROUPVALUE
          ,CAST(TEACHERNUMBER AS INT) AS TEACHERNUMBER
          ,HOME_PHONE
          ,SCHOOL_PHONE
          ,STREET
          ,CITY
          ,STATE
          ,ZIP
          ,PERIODSAVAIL
          ,CANCHANGESCHOOL
          ,LOG
          ,TEACHERLOGINPW
          ,NAMEASIMPORTED
          ,TEACHERLOGINID
          ,TEACHERLOGINIP
          ,STAFFSTATUS
          ,ETHNICITY
          ,ADMINLDAPENABLED
          ,TEACHERLDAPENABLED
          ,SIF_STATEPRID
          ,GRADEBOOKTYPE
          ,HOMESCHOOLID
          ,PTACCESS
    FROM teachers
  ');

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..TEACHERS');

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
   AND sys.objects.name = 'TEACHERS';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[TEACHERS]
 SELECT *
 FROM [#PS$TEACHERS|refresh];

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
  AND sys.objects.name = 'TEACHERS';

 EXEC (@sql);
  
END