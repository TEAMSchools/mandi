USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_ILLUMINATE$assessment_results_by_standard#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$assessment_results_by_standard#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$assessment_results_by_standard#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#ILLUMINATE$assessment_results_by_standard#static|refresh]
  FROM OPENQUERY(ILLUMINATE,'
         SELECT s.local_student_id 
               ,agg_resp_standard.*
               ,standards.parent_standard_id
               ,standards.category_id
               ,standards.subject_id
               ,standards.state_num
               ,standards.label AS standard_label
               ,standards.level
               ,standards.seq
               ,standards.description
               ,standards.custom_code
               ,ques.sheet_label AS questions
               ,ques.administered_at
               ,perf_bands.performance_band_set_id
               ,perf_bands.minimum_value
               ,perf_bands.label AS perf_band_label
               ,perf_bands.label_number
               ,perf_bands.color
               ,perf_bands.is_mastery
         FROM public.students s
         JOIN dna_assessments.agg_student_responses_standard agg_resp_standard
           ON s.student_id = agg_resp_standard.student_id
         JOIN standards.standards 
           USING (standard_id)
           --not sure how the logic works behind the scenes but this view has the performance band id, which 
           --indicates the proficiency bucket name.
         JOIN dna_assessments.performance_bands perf_bands
           USING (performance_band_id)
         LEFT OUTER JOIN (
                          SELECT a.assessment_id
                                ,a.administered_at             
                                ,fs.standard_id
                                ,GROUP_CONCAT(sheet_label) AS sheet_label       
                          FROM dna_assessments.assessments a
                          LEFT OUTER JOIN dna_assessments.fields f       
                            ON a.assessment_id = f.assessment_id
                          LEFT OUTER JOIN dna_assessments.field_standards fs
                            ON f.field_id = fs.field_id
                          GROUP BY a.assessment_id, fs.standard_id, a.administered_at
                         ) ques
           ON standards.standard_id = ques.standard_id
          AND agg_resp_standard.assessment_id = ques.assessment_id
          ');

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$assessment_results_by_standard#static');

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
   AND sys.objects.name = 'ILLUMINATE$assessment_results_by_standard#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$assessment_results_by_standard#static]
 SELECT *
 FROM [#ILLUMINATE$assessment_results_by_standard#static|refresh];
 
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
  AND sys.objects.name = 'ILLUMINATE$assessment_results_by_standard#static';

 EXEC (@sql);
  
END
GO


