USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_ILLUMINATE$CMA_scores_wide#static|refresh] AS

BEGIN  
  
  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$CMA_scores_wide#static|refresh') IS NOT NULL
		  BEGIN
						DROP TABLE [#ILLUMINATE$CMA_scores_wide#static|refresh]
		  END
  IF OBJECT_ID(N'tempdb..#extern') IS NOT NULL
    BEGIN
      DROP TABLE #extern
    END;

  -- STEP 2: load into a temporary staging table.
  WITH assessments AS (
    SELECT academic_year
          ,assessment_id
          ,subject_area
          ,short_title        
          ,MIN(rn) OVER(PARTITION BY academic_year, grade_level_tags, subject_area, short_title) AS rn
    FROM
        (
         SELECT a.academic_year
               ,a.assessment_id        
               ,CASE
                 WHEN a.subject_area IN ('English','Comprehension','Text Study') THEN 'ELA'
                 WHEN a.subject_area IN ('Mathematics') THEN 'MATH'
                END AS subject_area             
               ,a.title                           
               ,CONCAT(
                  CASE WHEN PATINDEX('%M[0-9]%', a.title) = 0 THEN NULL ELSE SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title), 2) END
                 ,'-'
                 ,CASE 
                   WHEN a.scope LIKE '%End-of-Module%' THEN 'End'
                   WHEN a.scope LIKE '%Mid-Module%' AND a.title LIKE '%Checkpoint%' THEN CONCAT('Mid',SUBSTRING(a.title, CHARINDEX('Checkpoint', a.title) + 11, 1))
                   WHEN a.scope LIKE '%Mid-Module%' AND a.title NOT LIKE '%Checkpoint%' THEN 'Mid'
                  END) AS short_title      
               ,KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K') AS grade_level_tags
               ,ROW_NUMBER() OVER(
                  PARTITION BY a.subject_area, KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K')
                    ORDER BY a.administered_at) AS rn
         FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
         WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
           AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()    
        ) sub
   )

  ,extern AS (
    SELECT a.academic_year        
          ,a.subject_area
          ,a.short_title      
          ,a.rn
          ,ovr.local_student_id AS student_number
          ,ROUND(AVG(CONVERT(FLOAT,ovr.percent_correct)),0) AS percent_correct                                
    FROM assessments a    
    JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
      ON a.assessment_id = ovr.assessment_id   
    GROUP BY a.academic_year          
            ,a.subject_area
            ,a.short_title      
            ,a.rn
            ,ovr.local_student_id
   )

  SELECT *
  INTO #extern
  FROM extern;

  WITH grouped AS (
    SELECT academic_year
          ,student_number
          ,subject_area
          ,x2.short_title
          ,y2.percent_correct
          --,y.short_title
    FROM #extern
    CROSS APPLY (
                 SELECT CONCAT(short_title,CHAR(9)) AS short_title                   
                 FROM #extern intern WITH(NOLOCK)           
                 WHERE #extern.student_number = intern.student_number
                   AND #extern.academic_year = intern.academic_year
                   AND #extern.subject_area = intern.subject_area
                 ORDER BY rn
                 FOR XML PATH(''), TYPE
                ) x1 (short_title)
    CROSS APPLY (
                 SELECT x1.short_title.value('.', 'NVARCHAR(MAX)')
                ) x2 (short_title)
    CROSS APPLY (
                 SELECT CONCAT(percent_correct,CHAR(9)) AS percent_correct
                 FROM #extern intern WITH(NOLOCK)           
                 WHERE #extern.student_number = intern.student_number
                   AND #extern.academic_year = intern.academic_year
                   AND #extern.subject_area = intern.subject_area
                 ORDER BY rn
                 FOR XML PATH(''), TYPE
                ) y1 (percent_correct)
    CROSS APPLY (
                 SELECT y1.percent_correct.value('.', 'NVARCHAR(MAX)')
                ) y2 (percent_correct)
   )

  ,pivoted AS (
    SELECT academic_year
          ,student_number
          ,[MATH_short_title]
          ,[MATH_percent_correct]
          ,[ELA_short_title]
          ,[ELA_percent_correct]
    FROM
        (
         SELECT academic_year
               ,student_number
               ,CONCAT(subject_area, '_', field) AS pivot_field
               ,value
         FROM grouped
         UNPIVOT(
           value
           FOR field IN (short_title
                        ,percent_correct)
          ) u
     ) sub
    PIVOT(
      MAX(value)
      FOR pivot_field IN ([MATH_short_title]
                         ,[MATH_percent_correct]
                         ,[ELA_short_title]
                         ,[ELA_percent_correct])
     ) p
   )

  SELECT *
		INTO [#ILLUMINATE$CMA_scores_wide#static|refresh]
  FROM pivoted;         

  -- STEP 3: truncate destination table
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$CMA_scores_wide#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'ILLUMINATE$CMA_scores_wide#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [ILLUMINATE$CMA_scores_wide#static]
  SELECT *
  FROM [#ILLUMINATE$CMA_scores_wide#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'ILLUMINATE$CMA_scores_wide#static';
  EXEC (@sql);
  
END                  
