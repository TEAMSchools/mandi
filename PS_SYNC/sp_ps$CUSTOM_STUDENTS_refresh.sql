USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_PS$CUSTOM_STUDENTS_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$CUSTOM_STUDENTS|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$CUSTOM_STUDENTS|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
  INTO [#PS$CUSTOM_STUDENTS|refresh]
  FROM OPENQUERY(PS_TEAM,'
    SELECT id AS studentid      
          ,DBMS_LOB.SUBSTR(guardianemail,2000,1) AS guardianemail
          ,ps_customfields.getcf(''Students'',id,''SID'') AS SID
          ,ps_customfields.getcf(''Students'',id,''Advisor'') AS advisor
          ,ps_customfields.getcf(''Students'',id,''Advisor_Email'') AS advisor_email
          ,ps_customfields.getcf(''Students'',id,''Advisor_Cell'') AS advisor_cell
          ,ps_customfields.getcf(''Students'',id,''SPEDLEP'') AS SPEDLEP
          ,ps_customfields.getcf(''Students'',id,''Mother_Cell'') AS mother_cell
          ,ps_customfields.getcf(''Students'',id,''motherdayphone'') AS mother_day
          ,ps_customfields.getcf(''Students'',id,''Mother_home_phone'') AS mother_home
          ,ps_customfields.getcf(''Students'',id,''Father_Cell'') AS father_cell
          ,ps_customfields.getcf(''Students'',id,''fatherdayphone'') AS father_day
          ,ps_customfields.getcf(''Students'',id,''Father_home_phone'') AS father_home      
          ,ps_customfields.getcf(''Students'',id,''Lunch_Status_1213'') AS Lunch_Status_1213
          ,ps_customfields.getcf(''Students'',id,''Lunch_Balance'') AS lunch_balance
          ,ps_customfields.getcf(''Students'',id,''DIYNickname'') AS diy_nickname
          ,ps_customfields.getcf(''Students'',id,''504_status'') AS status_504
          ,ps_customfields.getcf(''Students'',id,''SPEDLEP_CODES'') AS SPEDLEP_code
          ,(CAST(transfercomment AS VARCHAR(50))) AS transfercomment
          ,ps_customfields.getcf(''Students'',id,''DEFAULT_STUDENT_WEB_ID'') AS DEFAULT_STUDENT_WEB_ID
          ,ps_customfields.getcf(''Students'',id,''DEFAULT_STUDENT_WEB_PASSWORD'') AS DEFAULT_STUDENT_WEB_PASSWORD
          ,ps_customfields.getcf(''Students'',id,''DEFAULT_FAMILY_WEB_ID'') AS DEFAULT_FAMILY_WEB_ID
          ,ps_customfields.getcf(''Students'',id,''DEFAULT_FAMILY_WEB_PASSWORD'') AS DEFAULT_FAMILY_WEB_PASSWORD
          ,ps_customfields.getcf(''Students'',id,''MIDDLE_NAME_CUSTOM'') AS MIDDLE_NAME_CUSTOM
    FROM students s
  ');
         
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate
  EXEC('TRUNCATE TABLE KIPP_NJ..CUSTOM_STUDENTS');

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
   AND sys.objects.name = 'CUSTOM_STUDENTS';

 EXEC (@sql);
 
 -- STEP 6: INSERT INTO final destination
 INSERT INTO [dbo].[CUSTOM_STUDENTS]
 SELECT *
 FROM [#PS$CUSTOM_STUDENTS|refresh];

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
  AND sys.objects.name = 'CUSTOM_STUDENTS';

 EXEC (@sql);
  
END