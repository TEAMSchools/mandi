USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_PS$CC#static|refresh] AS

BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$CC#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$CC#static|refresh]
		END


  -- STEP 2: load into a temporary staging table.
  SELECT *
		INTO [#PS$CC#static|refresh]
  FROM PS$CC;
         

  -- STEP 3: truncate destination table
  EXEC('DELETE FROM KIPP_NJ..PS$CC#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$CC#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [PS$CC#static]
   (DCID,ID,STUDENTID,SECTIONID,DATEENROLLED,DATELEFT,SCHOOLID,TERMID,PERIOD_OBSOLETE,ATTENDANCE_TYPE_CODE,UNUSED2,CURRENTABSENCES,CURRENTTARDIES,ATTENDANCE,TEACHERID,LASTGRADEUPDATE,SECTION_NUMBER,COURSE_NUMBER,ORIGSECTIONID,UNUSED3,TEACHERCOMMENT,LASTATTMOD,ASMTSCORES,FIRSTATTDATE,FINALGRADES,STUDYEAR,LOG,EXPRESSION,STUDENTSECTENRL_GUID,TEACHERPRIVATENOTE,AB_COURSE_CMP_FUN_FLG,AB_COURSE_CMP_EXT_CRD,AB_COURSE_CMP_MET_CD,AB_COURSE_EVA_PRO_CD,AB_COURSE_CMP_STA_CD,academic_year,period)
  SELECT DCID,ID,STUDENTID,SECTIONID,DATEENROLLED,DATELEFT,SCHOOLID,TERMID,PERIOD_OBSOLETE,ATTENDANCE_TYPE_CODE,UNUSED2,CURRENTABSENCES,CURRENTTARDIES,ATTENDANCE,TEACHERID,LASTGRADEUPDATE,SECTION_NUMBER,COURSE_NUMBER,ORIGSECTIONID,UNUSED3,TEACHERCOMMENT,LASTATTMOD,ASMTSCORES,FIRSTATTDATE,FINALGRADES,STUDYEAR,LOG,EXPRESSION,STUDENTSECTENRL_GUID,TEACHERPRIVATENOTE,AB_COURSE_CMP_FUN_FLG,AB_COURSE_CMP_EXT_CRD,AB_COURSE_CMP_MET_CD,AB_COURSE_EVA_PRO_CD,AB_COURSE_CMP_STA_CD,academic_year,period
  FROM [#PS$CC#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'PS$CC#static';
  EXEC (@sql);
  
END                  