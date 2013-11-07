USE KIPP_NJ
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [sp_ES_DAILY$daily_tracking_long#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ES_DAILY$daily_tracking_long#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ES_DAILY$daily_tracking_long#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#ES_DAILY$daily_tracking_long#static|refresh]
  FROM (SELECT ROW_NUMBER() OVER(
                  PARTITION BY schoolid 
                      ORDER BY att_date) AS rn
		            ,schoolid
		            ,REPLACE(CONVERT(NVARCHAR,att_date, 6),' ','-') AS att_date
		            ,studentid
		            ,student_number
		            ,lastfirst
		            ,grade_level
		            ,team
		            ,hw
		            ,color_day
		            ,thrive_am
		            ,thrive_mid
		            ,thrive_pm
		            ,CAST(student_number AS VARCHAR(20)) + '_' + CAST(REPLACE(CONVERT(NVARCHAR,att_date,6),' ','-') AS VARCHAR(20)) AS hash
        FROM	(SELECT s.schoolid			         
			                 ,scores.att_date
			                 ,s.id AS studentid
			                 ,s.student_number
			                 ,s.lastfirst
			                 ,s.grade_level
			                 ,s.team								
			                 ,scores.hw
			                 ,CASE WHEN scores.schoolid = 73255 THEN NULL ELSE scores.color END AS color_day
			                 ,CASE WHEN scores.schoolid = 73255 THEN scores.color     END AS thrive_am
			                 ,CASE WHEN scores.schoolid = 73255 THEN scores.color_mid END AS thrive_mid
			                 ,CASE WHEN scores.schoolid = 73255 THEN scores.color_pm  END AS thrive_pm
		            FROM OPENQUERY(PS_TEAM,'
                     SELECT schoolid
                           ,user_defined_date AS att_date
                           ,foreignkey AS studentid
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
                     ') scores
		            JOIN STUDENTS s WITH (NOLOCK)
		              ON s.id = scores.studentid
		            WHERE s.enroll_status = 0
		              AND s.grade_level < 5		    
	            ) sub_1	    
       ) sub_2;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ES_DAILY$daily_tracking_long#static');

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
   AND sys.objects.name = 'ES_DAILY$daily_tracking_long#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[ES_DAILY$daily_tracking_long#static]
 SELECT *
 FROM [#ES_DAILY$daily_tracking_long#static|refresh];
 
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
  AND sys.objects.name = 'ES_DAILY$daily_tracking_long#static';

 EXEC (@sql);
  
END