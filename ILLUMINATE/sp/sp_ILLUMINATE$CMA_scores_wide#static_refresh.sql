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
  -- STEP 2: load into a temporary staging table.
  WITH assessments AS (
    SELECT assessment_id
          ,subject_area
          ,module_num
          --,title
          ,scope
          ,grade_level_tags      
          ,MIN(rn) OVER(PARTITION BY grade_level_tags, subject_area, module_num) AS rn_unit
    FROM
        (
         SELECT a.assessment_id        
               ,CASE
                 WHEN a.subject_area = 'Text Study' THEN 'ELA'
                 WHEN a.subject_area = 'Mathematics' THEN 'MATH'
                END AS subject_area                 
               ,a.title                           
               ,a.administered_at
               ,CASE WHEN PATINDEX('%M[0-9]%', a.title) = 0 THEN NULL ELSE SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1) END AS module_num
               ,CASE 
                 WHEN a.scope LIKE '%End-of-Module%' THEN 'EOM'
                 WHEN a.scope LIKE '%Mid-Module%' AND a.title LIKE '%Checkpoint%' THEN CONCAT('MID',SUBSTRING(a.title, CHARINDEX('Checkpoint', a.title) + 11, 1))
                 WHEN a.scope LIKE '%Mid-Module%' AND a.title NOT LIKE '%Checkpoint%' THEN 'MID1'
                END AS scope
               ,KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K') AS grade_level_tags      
               ,ROW_NUMBER() OVER(
                  PARTITION BY a.subject_area, KIPP_NJ.dbo.fn_StripCharacters(tags,'^0-9,K')
                    ORDER BY CASE WHEN PATINDEX('%M[0-9]%', a.title) = 0 THEN NULL ELSE SUBSTRING(a.title, PATINDEX('%M[0-9]%', a.title) + 1, 1) END) AS rn
         FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)       
         WHERE a.scope IN ('CMA - End-of-Module','CMA - Mid-Module')    
           AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
        ) sub
   )

  ,extern AS (
    SELECT subject_area
          ,module_num
          ,rn_unit
          ,student_number
          ,CASE
            WHEN ((GRADE_LEVEL <= 4 AND SCHOOLID != 73252) OR SCHOOLID = 73258) AND subject_area = 'ELA' THEN CONCAT([MID1], CHAR(9), [MID2], CHAR(9), [EOM]) /* ES and BOLD ELA */
            WHEN ((GRADE_LEVEL <= 4 AND SCHOOLID != 73252) OR SCHOOLID = 73258) AND subject_area != 'ELA' THEN CONCAT([MID1], CHAR(9), [EOM]) /* ES and BOLD not ELA */
            ELSE CONVERT(VARCHAR,[EOM]) /* MS */
           END AS scores_concat
    FROM
        (
         SELECT a.subject_area
               ,a.module_num
               ,a.scope
               ,a.rn_unit
               ,ovr.local_student_id AS student_number
               ,CONCAT(ROUND(AVG(CONVERT(FLOAT,ovr.percent_correct)),0),'%') AS percent_correct                                
               ,s.SCHOOLID
               ,s.GRADE_LEVEL
         FROM assessments a    
         JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
           ON a.assessment_id = ovr.assessment_id   
         JOIN KIPP_NJ..PS$STUDENTS#static s
           ON ovr.local_student_id = s.STUDENT_NUMBER
         GROUP BY a.subject_area
                 ,a.module_num
                 ,a.scope
                 ,a.rn_unit
                 ,ovr.local_student_id
                 ,s.SCHOOLID
                 ,s.GRADE_LEVEL
        ) sub
    PIVOT(
      MAX(percent_correct)
      FOR scope IN ([MID1],[MID2],[EOM])
     ) p
   )

  SELECT*
  INTO #extern
  FROM extern;

  WITH grouped AS (
      SELECT student_number
            ,subject_area
            ,x2.short_title
            ,y2.percent_correct          
      FROM #extern
      CROSS APPLY (
                   SELECT CONCAT(module_num, CHAR(10)) AS short_title                   
                   FROM #extern intern WITH(NOLOCK)           
                   WHERE #extern.student_number = intern.student_number                   
                     AND #extern.subject_area = intern.subject_area
                   ORDER BY rn_unit
                   FOR XML PATH(''), TYPE
                  ) x1 (short_title)
      CROSS APPLY (
                   SELECT x1.short_title.value('.', 'NVARCHAR(MAX)')
                  ) x2 (short_title)
      CROSS APPLY (
                   SELECT CONCAT(scores_concat,CHAR(10)) AS percent_correct
                   FROM #extern intern WITH(NOLOCK)           
                   WHERE #extern.student_number = intern.student_number                   
                     AND #extern.subject_area = intern.subject_area
                   ORDER BY rn_unit
                   FOR XML PATH(''), TYPE
                  ) y1 (percent_correct)
      CROSS APPLY (
                   SELECT y1.percent_correct.value('.', 'NVARCHAR(MAX)')
                  ) y2 (percent_correct)
     )

  ,pivoted AS (
    SELECT KIPP_NJ.dbo.fn_Global_Academic_Year() AS academic_year
          ,student_number
          ,[MATH_short_title]
          ,[MATH_percent_correct]
          ,[ELA_short_title]
          ,[ELA_percent_correct]
    FROM
        (
         SELECT student_number
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
