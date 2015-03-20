USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_PS$TEACHERS#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$TEACHERS#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$TEACHERS#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$TEACHERS#static|refresh]
  FROM PS$TEACHERS;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$TEACHERS#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$TEACHERS#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$TEACHERS#static]
   (USERS_DCID,DCID,ID,LASTFIRST,FIRST_NAME,MIDDLE_NAME,LAST_NAME,SCHOOLID,STATUS,TITLE,EMAIL_ADDR,PASSWORD,PSACCESS,LOGINID,CLASSPUA,NOOFCURCLASSES,GROUPVALUE,TEACHERNUMBER,HOME_PHONE,SCHOOL_PHONE,STREET,CITY,STATE,ZIP,PERIODSAVAIL,CANCHANGESCHOOL,LOG,TEACHERLOGINPW,NAMEASIMPORTED,TEACHERLOGINID,TEACHERLOGINIP,STAFFSTATUS,ETHNICITY,ADMINLDAPENABLED,TEACHERLDAPENABLED,SIF_STATEPRID,GRADEBOOKTYPE,HOMESCHOOLID,PTACCESS)
  SELECT USERS_DCID,DCID,ID,LASTFIRST,FIRST_NAME,MIDDLE_NAME,LAST_NAME,SCHOOLID,STATUS,TITLE,EMAIL_ADDR,PASSWORD,PSACCESS,LOGINID,CLASSPUA,NOOFCURCLASSES,GROUPVALUE,TEACHERNUMBER,HOME_PHONE,SCHOOL_PHONE,STREET,CITY,STATE,ZIP,PERIODSAVAIL,CANCHANGESCHOOL,LOG,TEACHERLOGINPW,NAMEASIMPORTED,TEACHERLOGINID,TEACHERLOGINIP,STAFFSTATUS,ETHNICITY,ADMINLDAPENABLED,TEACHERLDAPENABLED,SIF_STATEPRID,GRADEBOOKTYPE,HOMESCHOOLID,PTACCESS
  FROM [#PS$TEACHERS#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$TEACHERS#static';
  EXEC (@sql);
  
END                  
