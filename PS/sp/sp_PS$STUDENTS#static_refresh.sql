USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [sp_PS$STUDENTS#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$STUDENTS#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$STUDENTS#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$STUDENTS#static|refresh]
  FROM PS$STUDENTS;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$STUDENTS#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$STUDENTS#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$STUDENTS#static]
   (DCID,ID,LASTFIRST,FIRST_NAME,MIDDLE_NAME,LAST_NAME,STUDENT_NUMBER,ENROLL_STATUS,GRADE_LEVEL,SCHOOLID,GENDER,DOB,LUNCHSTATUS,ETHNICITY,ENTRYDATE,EXITDATE,ENTRYCODE,EXITCODE,FTEID,TEAM,STATE_STUDENTNUMBER,WEB_ID,WEB_PASSWORD,ALLOWWEBACCESS,STUDENT_WEB_ID,STUDENT_WEB_PASSWORD,STUDENT_ALLOWWEBACCESS,STREET,CITY,STATE,ZIP,MOTHER,FATHER,HOME_PHONE,EMERG_CONTACT_1,EMERG_CONTACT_2,EMERG_PHONE_1,EMERG_PHONE_2)
  SELECT DCID,ID,LASTFIRST,FIRST_NAME,MIDDLE_NAME,LAST_NAME,STUDENT_NUMBER,ENROLL_STATUS,GRADE_LEVEL,SCHOOLID,GENDER,DOB,LUNCHSTATUS,ETHNICITY,ENTRYDATE,EXITDATE,ENTRYCODE,EXITCODE,FTEID,TEAM,STATE_STUDENTNUMBER,WEB_ID,WEB_PASSWORD,ALLOWWEBACCESS,STUDENT_WEB_ID,STUDENT_WEB_PASSWORD,STUDENT_ALLOWWEBACCESS,STREET,CITY,STATE,ZIP,MOTHER,FATHER,HOME_PHONE,EMERG_CONTACT_1,EMERG_CONTACT_2,EMERG_PHONE_1,EMERG_PHONE_2
  FROM [#PS$STUDENTS#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$STUDENTS#static';
  EXEC (@sql);
  
END                  