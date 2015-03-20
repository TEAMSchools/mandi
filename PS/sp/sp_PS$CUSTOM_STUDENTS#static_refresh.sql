USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_PS$CUSTOM_STUDENTS#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$CUSTOM_STUDENTS#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$CUSTOM_STUDENTS#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$CUSTOM_STUDENTS#static|refresh]
  FROM PS$CUSTOM_STUDENTS;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$CUSTOM_STUDENTS#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$CUSTOM_STUDENTS#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$CUSTOM_STUDENTS#static]
   (STUDENTID,SID,ADVISOR,ADVISOR_EMAIL,ADVISOR_CELL,SPEDLEP,MOTHER_CELL,MOTHER_DAY,MOTHER_HOME,FATHER_CELL,FATHER_DAY,FATHER_HOME,LUNCH_STATUS_1213,LUNCH_BALANCE,DIY_NICKNAME,STATUS_504,SPEDLEP_CODE,DEFAULT_STUDENT_WEB_ID,DEFAULT_STUDENT_WEB_PASSWORD,DEFAULT_FAMILY_WEB_ID,DEFAULT_FAMILY_WEB_PASSWORD,MIDDLE_NAME_CUSTOM,LEP_STATUS,NEWARK_ENROLLMENT_NUMBER)
  SELECT STUDENTID,SID,ADVISOR,ADVISOR_EMAIL,ADVISOR_CELL,SPEDLEP,MOTHER_CELL,MOTHER_DAY,MOTHER_HOME,FATHER_CELL,FATHER_DAY,FATHER_HOME,LUNCH_STATUS_1213,LUNCH_BALANCE,DIY_NICKNAME,STATUS_504,SPEDLEP_CODE,DEFAULT_STUDENT_WEB_ID,DEFAULT_STUDENT_WEB_PASSWORD,DEFAULT_FAMILY_WEB_ID,DEFAULT_FAMILY_WEB_PASSWORD,MIDDLE_NAME_CUSTOM,LEP_STATUS,NEWARK_ENROLLMENT_NUMBER
  FROM [#PS$CUSTOM_STUDENTS#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$CUSTOM_STUDENTS#static';
  EXEC (@sql);
  
END                  