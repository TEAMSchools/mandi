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
         SELECT DISTINCT
                s.id AS studentid
               ,DBMS_LOB.SUBSTR(s.guardianemail,2000,1) AS guardianemail
               ,pvcs_SID.string_value   AS SID
               ,pvcs_adv.string_value   AS advisor
               ,pvcs_adv_e.string_value AS advisor_email
               ,pvcs_adv_c.string_value AS advisor_cell
               ,pvcs_sped.string_value  AS SPEDLEP
               ,pvcs_mom_c.string_value AS mother_cell
               ,pvcs_mom_d.string_value AS mother_day
               ,pvcs_mom_h.string_value AS mother_home
               ,pvcs_dad_c.string_value AS father_cell
               ,pvcs_dad_d.string_value AS father_day
               ,pvcs_dad_h.string_value AS father_home      
               ,pvcs_LS.string_value    AS lunch_status_1213
               ,pvcs_LB.string_value    AS lunch_balance
               ,pvcs_diy.string_value   AS diy_nickname
               ,pvcs_504.string_value   AS status_504
         FROM STUDENTS s
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv   ON s.id = pvcs_adv.studentid   AND pvcs_adv.field_name   = ''Advisor''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv_e ON s.id = pvcs_adv_e.studentid AND pvcs_adv_e.field_name = ''Advisor_Email''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_adv_c ON s.id = pvcs_adv_c.studentid AND pvcs_adv_c.field_name = ''Advisor_Cell''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_sped  ON s.id = pvcs_sped.studentid  AND pvcs_sped.field_name  = ''SPEDLEP''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_c ON s.id = pvcs_mom_c.studentid AND pvcs_mom_c.field_name = ''Mother_Cell''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_d ON s.id = pvcs_mom_d.studentid AND pvcs_mom_d.field_name = ''motherdayphone''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_mom_h ON s.id = pvcs_mom_h.studentid AND pvcs_mom_h.field_name = ''Mother_home_phone''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_c ON s.id = pvcs_dad_c.studentid AND pvcs_dad_c.field_name = ''Father_Cell''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_d ON s.id = pvcs_dad_d.studentid AND pvcs_dad_d.field_name = ''fatherdayphone''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_dad_h ON s.id = pvcs_dad_h.studentid AND pvcs_dad_h.field_name = ''Father_home_phone''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_SID   ON s.id = pvcs_SID.studentid   AND pvcs_SID.field_name   = ''SID''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_LS    ON s.id = pvcs_LS.studentid    AND pvcs_LS.field_name    = ''Lunch_Status_1213''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_LB    ON s.id = pvcs_LB.studentid    AND pvcs_LB.field_name    = ''Lunch_Balance''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_diy   ON s.id = pvcs_diy.studentid   AND pvcs_diy.field_name   = ''DIYNickname''
         LEFT OUTER JOIN PVSIS_CUSTOM_STUDENTS pvcs_504   ON s.id = pvcs_504.studentid   AND pvcs_504.field_name   = ''504_status''
         --WHERE s.enroll_status = 0
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