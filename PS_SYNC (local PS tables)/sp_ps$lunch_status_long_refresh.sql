USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_PS$lunch_status_long_refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$lunch_status_long|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$lunch_status_long|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
  INTO [#PS$lunch_status_long|refresh]
  FROM (
        SELECT sub2.studentid
              ,sub2.year
              ,sub2.lunch_status
        FROM
            (
             SELECT sub.*
                   ,ROW_NUMBER() OVER(
                       PARTITION BY studentid, year, lunch_status
                           ORDER BY lunch_status) AS rn
             FROM
                 (
                  SELECT studentid
                        ,CASE
                          WHEN field_name LIKE ('%0708%') THEN 2007
                          WHEN field_name LIKE ('%0809%') THEN 2008
                          WHEN field_name LIKE ('%0910%') THEN 2009
                          WHEN field_name LIKE ('%1011%') THEN 2010
                          WHEN field_name LIKE ('%1112%') THEN 2011
                          WHEN field_name LIKE ('%1213%') THEN 2012
                          WHEN field_name LIKE ('%1314%') THEN 2013
                         END AS year        
                        ,CASE                  
                          WHEN string_value = 'Free' THEN 'F'
                          WHEN string_value = 'TANF' THEN 'F'
                          WHEN LOWER(string_value) LIKE '%food%stamp%' THEN 'F'
                          WHEN string_value = 'Reduced' THEN 'R'
                          WHEN string_value = 'Paid' THEN 'P'        
                          WHEN string_value = 'Income too high' THEN 'P'
                          WHEN LOWER(string_value) LIKE '%direct%cert%' THEN 'Direct Certified'                                    
                          WHEN UPPER(LTRIM(RTRIM(string_value))) IN ('F','R','P') THEN UPPER(LTRIM(RTRIM(string_value)))
                          WHEN string_value = 'Incomplete' THEN 'NoD'
                          ELSE 'NoD'
                         END AS lunch_status
                  FROM OPENQUERY(PS_TEAM,'
                    SELECT field_name
                          ,string_value
                          ,studentid
                    FROM PVSIS_CUSTOM_STUDENTS
                    WHERE LOWER(field_name) LIKE (''%lunch_status%'')
                      AND LOWER(field_name) NOT LIKE (''%category%'')
                  ')
                 ) sub
            ) sub2
        WHERE rn = 1
       ) FrankUnderwoodbecomesVP;
       
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate
  EXEC('TRUNCATE TABLE KIPP_NJ..PS$lunch_status_long');

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
   AND sys.objects.name = 'PS$lunch_status_long';

 EXEC (@sql);
 
 -- STEP 6: INSERT INTO final destination
 INSERT INTO [dbo].[PS$lunch_status_long]
 SELECT *
 FROM [#PS$lunch_status_long|refresh];

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
  AND sys.objects.name = 'PS$lunch_status_long';

 EXEC (@sql);
  
END
GO


