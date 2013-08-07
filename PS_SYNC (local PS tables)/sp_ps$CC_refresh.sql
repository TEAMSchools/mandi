USE [KIPP_NJ]
GO

/****** Object:  StoredProcedure [dbo].[spCC_REFRESH]    Script Date: 15.06.2013 17:21:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[sp_ps_CC_refresh]
AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 -- Step 1: truncate table
 EXEC('TRUNCATE TABLE dbo.[CC]');

 -- Step 2: disable all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'CC';

 EXEC (@sql);

 -- step 3: insert rows from remote source
 INSERT INTO [dbo].[CC]
      ([DCID]
      ,[ID]
      ,[STUDENTID]
      ,[SECTIONID]
      ,[DATEENROLLED]
      ,[DATELEFT]
      ,[SCHOOLID]
      ,[TERMID]
      ,[PERIOD_OBSOLETE]
      ,[ATTENDANCE_TYPE_CODE]
      ,[UNUSED2]
      ,[CURRENTABSENCES]
      ,[CURRENTTARDIES]
      ,[ATTENDANCE]
      ,[TEACHERID]
      ,[LASTGRADEUPDATE]
      ,[SECTION_NUMBER]
      ,[COURSE_NUMBER]
      ,[ORIGSECTIONID]
      ,[UNUSED3]
      ,[TEACHERCOMMENT]
      ,[LASTATTMOD]
      ,[ASMTSCORES]
      ,[FIRSTATTDATE]
      ,[FINALGRADES]
      ,[STUDYEAR]
      ,[LOG]
      ,[EXPRESSION]
      ,[STUDENTSECTENRL_GUID]
      ,[TEACHERPRIVATENOTE]
      ,[AB_COURSE_CMP_FUN_FLG]
      ,[AB_COURSE_CMP_EXT_CRD]
      ,[AB_COURSE_CMP_MET_CD]
      ,[AB_COURSE_EVA_PRO_CD]
      ,[AB_COURSE_CMP_STA_CD])
 SELECT  CONVERT(INT, DCID) AS DCID,
      CONVERT(INT, ID) AS ID,
   CONVERT(INT, STUDENTID) AS STUDENTID,
   CONVERT(INT, SECTIONID) AS SECTIONID,
   DATEENROLLED,
   DATELEFT,
   CONVERT(INT, SCHOOLID) AS SCHOOLID,
   CONVERT(INT, TERMID) AS TERMID,
   PERIOD_OBSOLETE,
   CONVERT(INT, ATTENDANCE_TYPE_CODE) AS ATTENDANCE_TYPE_CODE,
   CONVERT(INT, UNUSED2) AS UNUSED2,
   CONVERT(INT, CURRENTABSENCES) AS CURRENTABSENCES,
   CONVERT(INT, CURRENTTARDIES) AS CURRENTTARDIES,
   ATTENDANCE,
   CONVERT(INT, TEACHERID) AS TEACHERID,
   LASTGRADEUPDATE,
   SECTION_NUMBER,
   COURSE_NUMBER,
   CONVERT(INT, ORIGSECTIONID) AS ORIGSECTIONID,
   CONVERT(INT, UNUSED3) AS UNUSED3,
   TEACHERCOMMENT,
   LASTATTMOD,
   ASMTSCORES,
   FIRSTATTDATE,
   FINALGRADES,
   CONVERT(INT, STUDYEAR) AS STUDYEAR,
   [LOG],
   EXPRESSION,
   STUDENTSECTENRL_GUID,
   TEACHERPRIVATENOTE,
   AB_COURSE_CMP_FUN_FLG,
   AB_COURSE_CMP_EXT_CRD,
   AB_COURSE_CMP_MET_CD,
   AB_COURSE_EVA_PRO_CD,
   AB_COURSE_CMP_STA_CD
 FROM OPENQUERY(PS_TEAM, 'SELECT 
     TO_CHAR(dcid) AS dcid,
     TO_CHAR(id) AS id,
     TO_CHAR(studentid) AS studentid,
     TO_CHAR(sectionid) AS sectionid,
     dateenrolled,
     dateleft,
     TO_CHAR(schoolid) AS schoolid,
     TO_CHAR(termid) AS termid,
     period_obsolete,
     TO_CHAR(attendance_type_code) AS attendance_type_code,
     TO_CHAR(unused2) AS unused2,
     TO_CHAR(currentabsences) AS currentabsences,
     TO_CHAR(currenttardies) AS currenttardies,
     dbms_lob.substr(attendance, 2000) AS attendance,
     TO_CHAR(teacherid) AS teacherid,
     lastgradeupdate,
     section_number,
     course_number,
     TO_CHAR(origsectionid) AS origsectionid,
     TO_CHAR(unused3) AS unused3,
     dbms_lob.substr(teachercomment, 2000) AS teachercomment,
     lastattmod,
     dbms_lob.substr(asmtscores, 2000) AS asmtscores,
     firstattdate,
     dbms_lob.substr(finalgrades, 2000) AS finalgrades,
     TO_CHAR(studyear) AS studyear,
     dbms_lob.substr(log, 2000) AS log,
     expression,
     studentsectenrl_guid,
     dbms_lob.substr(teacherprivatenote, 2000) AS teacherprivatenote,
     ab_course_cmp_fun_flg,
     ab_course_cmp_ext_crd,
     ab_course_cmp_met_cd,
     ab_course_eva_pro_cd,
     ab_course_cmp_sta_cd
    FROM CC');


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
  AND sys.objects.name = 'CC';

 EXEC (@sql);

END
GO

