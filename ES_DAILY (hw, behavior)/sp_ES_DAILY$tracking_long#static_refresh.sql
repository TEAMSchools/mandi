USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_ES_DAILY$tracking_long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ES_DAILY$tracking_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ES_DAILY$tracking_long#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#ES_DAILY$tracking_long#static|refresh]
  FROM (
        SELECT daily.studentid
              ,daily.schoolid
              ,CONVERT(DATE,daily.att_date) AS att_date
              ,daily.hw
              ,CASE WHEN daily.schoolid = 73255 THEN NULL ELSE daily.color END AS color_day
              ,CASE WHEN daily.schoolid = 73255 THEN daily.color     END AS color_am
              ,CASE WHEN daily.schoolid = 73255 THEN daily.color_mid END AS color_mid
              ,CASE WHEN daily.schoolid = 73255 THEN daily.color_pm  END AS color_pm
              ,CASE 
                WHEN daily.hw = 'Yes' THEN 1.0 
                WHEN daily.hw = 'No' THEN 0.0
                ELSE NULL END AS has_hw
              ,CASE WHEN daily.schoolid != 73255 AND daily.color IN ('purple','pink') THEN 1.0 ELSE NULL END AS purple_pink
              ,CASE WHEN daily.schoolid != 73255 AND daily.color = 'green' THEN 1.0 ELSE NULL END AS green
              ,CASE WHEN daily.schoolid != 73255 AND daily.color = 'yellow' THEN 1.0 ELSE NULL END AS yellow
              ,CASE WHEN daily.schoolid != 73255 AND daily.color = 'orange' THEN 1.0 ELSE NULL END AS orange
              ,CASE WHEN daily.schoolid != 73255 AND daily.color = 'red' THEN 1.0 ELSE NULL END AS red
              ,CASE WHEN daily.schoolid = 73255 AND daily.color IN ('purple','pink') THEN 1.0 ELSE NULL END AS am_purple_pink
              ,CASE WHEN daily.schoolid = 73255 AND daily.color = 'green' THEN 1.0 ELSE NULL END AS am_green
              ,CASE WHEN daily.schoolid = 73255 AND daily.color = 'yellow' THEN 1.0 ELSE NULL END AS am_yellow
              ,CASE WHEN daily.schoolid = 73255 AND daily.color = 'orange' THEN 1.0 ELSE NULL END AS am_orange
              ,CASE WHEN daily.schoolid = 73255 AND daily.color = 'red' THEN 1.0 ELSE NULL END AS am_red
              ,CASE WHEN daily.color_mid IN ('purple','pink') THEN 1.0 ELSE NULL END AS mid_purple_pink
              ,CASE WHEN daily.color_mid = 'green' THEN 1.0 ELSE NULL END AS mid_green
              ,CASE WHEN daily.color_mid = 'yellow' THEN 1.0 ELSE NULL END AS mid_yellow
              ,CASE WHEN daily.color_mid = 'orange' THEN 1.0 ELSE NULL END AS mid_orange
              ,CASE WHEN daily.color_mid = 'red' THEN 1.0 ELSE NULL END AS mid_red
              ,CASE WHEN daily.color_pm IN ('purple','pink') THEN 1.0 ELSE NULL END AS pm_purple_pink
              ,CASE WHEN daily.color_pm = 'green' THEN 1.0 ELSE NULL END AS pm_green
              ,CASE WHEN daily.color_pm = 'yellow' THEN 1.0 ELSE NULL END AS pm_yellow
              ,CASE WHEN daily.color_pm = 'orange' THEN 1.0 ELSE NULL END AS pm_orange
              ,CASE WHEN daily.color_pm = 'red' THEN 1.0 ELSE NULL END AS pm_red  
              ,dates.time_per_name AS week_num
        FROM OPENQUERY(PS_TEAM,'
          SELECT user_defined_date AS att_date
                ,foreignkey AS studentid
                ,schoolid
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field1'') hw
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field2'') color
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field3'') color_mid
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field4'') color_pm
                /*
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field5'') field5
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field6
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field7
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field8
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field9
                ,PS_CUSTOMFIELDS.GETCF(''dailytracking'',unique_id,''field6'') field10
                */
          FROM virtualtablesdata2
          WHERE related_to_table = ''dailytracking''					            
         ') daily
        LEFT OUTER JOIN REPORTING$dates dates WITH(NOLOCK)
          ON dates.school_level = 'ES'
         AND daily.att_date >= dates.start_date
         AND daily.att_date <= dates.end_date
         AND dates.identifier = 'FSA'
       ) brucewillisisdeadthewholetime;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ES_DAILY$tracking_long#static');

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
   AND sys.objects.name = 'ES_DAILY$tracking_long#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[ES_DAILY$tracking_long#static]
 SELECT *
 FROM [#ES_DAILY$tracking_long#static|refresh];
 
 -- STEP 7: rebuld all nonclustered indexes on table
 SELECT @sql = @sql + 
  'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
 FROM 
  sys.indexes
 JOIN 
  sys.objects 
  ON sys.indexes.object_id = sys.objects.object_id
 WHERE sys.indexes.type_desc = 'NONCLUSTERED'
  AND sys.objects.type_desc = 'USER_TABLE'
  AND sys.objects.name = 'ES_DAILY$tracking_long#static';

 EXEC (@sql);
  
END
GO


