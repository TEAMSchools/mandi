USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_DAILY$tracking_wide#ES#static|refresh] AS
BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#DAILY$tracking_wide#ES#static|refresh') IS NOT NULL
		  BEGIN
						  DROP TABLE [#DAILY$tracking_wide#ES#static|refresh]
		  END
  IF OBJECT_ID(N'tempdb..#extern') IS NOT NULL
    BEGIN
      DROP TABLE #extern
    END;

  -- STEP 2: load into a temporary staging table.
  WITH extern AS (
    SELECT co.schoolid                
          ,co.year AS academic_year                
          ,co.studentid                                
          ,cd.date_value
          ,FORMAT(cd.date_value,'ddd') AS day                
          ,dt.time_per_name AS week_num                
          ,CASE
            WHEN co.schoolid IN (73255) THEN CONCAT(daily.color_am, CHAR(9), daily.color_mid, CHAR(9), daily.color_pm, CHAR(9), daily.hw)
            WHEN co.schoolid IN (179901) THEN CONCAT(daily.color_am, CHAR(9), daily.color_pm, CHAR(9), daily.hw)
            ELSE CONCAT(daily.color_day, CHAR(9), CHAR(9), daily.hw)
           END AS color_hw_data                
          ,ROW_NUMBER() OVER(
             PARTITION BY co.studentid, co.year, dt.time_per_name
               ORDER BY cd.date_value) AS rn
    FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    JOIN KIPP_NJ..PS$CALENDAR_DAY cd WITH(NOLOCK)
      ON co.year = cd.academic_year
     AND co.schoolid = cd.schoolid
     AND cd.date_value BETWEEN co.entrydate AND co.exitdate
     AND cd.insession = 1   
     AND cd.date_value <= CONVERT(DATE,GETDATE())
    JOIN KIPP_NJ..REPORTING$dates dt WITH(NOLOCK)
      ON co.year = dt.academic_year
     AND co.schoolid = dt.schoolid
     AND cd.date_value BETWEEN dt.start_date AND dt.end_date
     AND dt.identifier = 'REP'
    LEFT OUTER JOIN KIPP_NJ..DAILY$tracking_long#ES#static daily WITH(NOLOCK)
      ON co.studentid = daily.studentid
     AND cd.date_value = daily.att_date      
    WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
   )

  SELECT *
  INTO #extern
  FROM extern;

  WITH grouped AS (
    SELECT schoolid
          ,academic_year
          ,studentid      
          ,week_num      
          ,CASE 
            WHEN schoolid IN (73255) THEN CONCAT(CHAR(9), 'AM', CHAR(9), 'Mid', CHAR(9), 'PM', CHAR(9), 'HW')
            WHEN schoolid IN (179901) THEN CONCAT(CHAR(9), 'AM', CHAR(9), 'PM', CHAR(9), 'HW')
            ELSE CONCAT(CHAR(9), 'Color', CHAR(9), CHAR(9), 'HW')
           END AS color_hw_header
          ,LEFT(y.color_hw_data, LEN(y.color_hw_data) - 2) AS color_hw_data
    FROM #extern e
    CROSS APPLY (
                 SELECT CONCAT(day, ':', CHAR(9), color_hw_data, CHAR(10)+CHAR(13))
                 FROM #extern daily WITH(NOLOCK)           
                 WHERE e.studentid = daily.studentid
                   AND e.academic_year = daily.academic_year
                   AND e.week_num = daily.week_num               
                 ORDER BY date_value
                 FOR XML PATH(''), TYPE
                ) x (color_hw_data)
    CROSS APPLY (
                 SELECT x.color_hw_data.value('.', 'NVARCHAR(MAX)')
                ) y (color_hw_data)
    WHERE e.rn = 1
   )
  
  SELECT *
		INTO [#DAILY$tracking_wide#ES#static|refresh]
  FROM grouped;
         

  -- STEP 3: truncate destination table
  EXEC('TRUNCATE TABLE KIPP_NJ..DAILY$tracking_wide#ES#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DAILY$tracking_wide#ES#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [DAILY$tracking_wide#ES#static]
  SELECT *
  FROM [#DAILY$tracking_wide#ES#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'DAILY$tracking_wide#ES#static';
  EXEC (@sql);
  
END                  
