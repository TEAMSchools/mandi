USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--ALTER PROCEDURE [sp_ILLUMINATE$standards_tested#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$standards_tested#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$standards_tested#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.  
  SELECT *
		INTO [#ILLUMINATE$standards_tested#static|refresh]
		FROM (SELECT *
              ,ROW_NUMBER() OVER
                (PARTITION BY year, schoolid, grade_level, [subject]
                     ORDER BY [standard]) AS std_count_subject
        FROM
             (SELECT DISTINCT
                     CASE
                      WHEN DATEPART(MM,administered_at) >= 07 THEN DATEPART(YYYY,administered_at)
                      WHEN DATEPART(MM,administered_at) < 07 THEN (DATEPART(YYYY,administered_at) - 1)
                      ELSE NULL
                     END AS year
                    ,schoolid
                    ,grade_level
                    ,[subject]
                    ,custom_code AS [standard]
                    ,standard_id
                    ,parent_standard_id      
              FROM
                   (SELECT oq.*
                          ,s.schoolid
                          ,s.grade_level
                    FROM OPENQUERY(ILLUMINATE,'
                           SELECT a.assessment_id
                                 ,a.title
                                 ,a.administered_at
                                 ,subj.code_translation AS subject              
                                 ,std.standard_id
                                 ,std.parent_standard_id
                                 ,std.custom_code
                                 ,s.local_student_id
                           FROM dna_assessments.assessments a        
                           LEFT OUTER JOIN codes.dna_subject_areas subj
                             ON a.code_subject_area_id = subj.code_id        
                           JOIN dna_assessments.assessment_standards a_std
                             ON a.assessment_id = a_std.assessment_id
                           JOIN standards.standards std
                             ON a_std.standard_id = std.standard_id        
                           JOIN dna_assessments.agg_student_responses resp
                             ON a.assessment_id = resp.assessment_id
                           JOIN public.students s
                             ON s.student_id = resp.student_id
                           ') oq
                    LEFT OUTER JOIN STUDENTS s
                      ON oq.local_student_id = s.student_number
                   ) sub_1
             ) sub_2
       ) nedstarkgetshisheadcutoffbykingjoffrey;
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$standards_tested#static');

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
   AND sys.objects.name = 'ILLUMINATE$standards_tested#static';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$standards_tested#static]
 SELECT *
 FROM [#ILLUMINATE$standards_tested#static|refresh];

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
  AND sys.objects.name = 'ILLUMINATE$standards_tested#static';

 EXEC (@sql);

END

GO