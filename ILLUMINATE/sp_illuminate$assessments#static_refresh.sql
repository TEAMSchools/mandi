USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [sp_ILLUMINATE$assessments#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$assessments#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#ILLUMINATE$assessments#static|refresh]
		END
		
		--STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#ILLUMINATE$assessments#static|refresh]
		FROM (
        SELECT sub.*
              ,rt.alt_name AS term
              ,ROW_NUMBER() OVER
                   (PARTITION BY sub.scope, fsa_week, sub.schoolid, grade_level
                        ORDER BY standards_tested) AS fsa_std_rn
              ,ROW_NUMBER() OVER
                  (PARTITION BY sub.scope, sub.schoolid, standards_tested                
                       ORDER BY administered_at) AS std_freq_rn                    
        FROM
             (
              SELECT oq.assessment_id                          
                    ,sch.schoolid --no hard-coded schoolid, derived from JOIN to distinct test results
                    ,oq.title
                    ,oq.description AS test_descr
                    --/*
                    --hard-coded grade-level involves multiple joins to an
                    --indexed grade level (k = 1, 12 = 13) for whatever reason
                    --it's simpler just to use the tag
                    ,CASE 
                      WHEN tag = 'k' THEN '0'
                      WHEN tag IN ('1','2','3','4','5','6','7','8','9','10','11','12') THEN tag
                      ELSE NULL
                     END AS grade_level
                    --*/
                    ,oq.subject
                    ,oq.scope
                    ,oq.custom_code AS standards_tested
                    ,oq.parent_standard
                    ,oq.label AS standard_type
                    ,oq.std_descr AS standard_descr
                    ,oq.user_id
                    ,t.lastfirst AS created_by                          
                    ,fsa_dates.time_per_name AS fsa_week --needed to get clean row number for FSA standard by week                  
                    ,CASE
                      WHEN DATEPART(MM,oq.administered_at) >= 07 THEN DATEPART(YYYY,oq.administered_at)
                      WHEN DATEPART(MM,oq.administered_at) < 07 THEN (DATEPART(YYYY,oq.administered_at) - 1)
                      ELSE NULL
                     END AS academic_year
                    ,oq.administered_at
                    ,CONVERT(DATE,oq.created_at) AS created_at
                    ,CONVERT(DATE,oq.updated_at) AS updated_at             
                    ,oq.code_scope_id
                    ,oq.code_subject_area_id
                    ,oq.standard_id
                    ,oq.parent_standard_id
                    ,oq.reports_db_virtual_table_id             
                    ,oq.local_assessment_id             
                    ,oq.performance_band_set_id
                    ,oq.itembank_assessment_id
                    ,oq.locked
                    ,oq.raw_score_performance_band_set_id
                    ,oq.tags                          
                    --UNUSED STUFF FROM ASSESSMENTS TABLE
                    --,oq.academic_year
                    --,oq.deleted_at
                    --,oq.intel_assess_guid
                    --,oq.guid
                    --,oq.edusoft_guid
                    --,oq.als_guid
                    --,oq.curriculum_associate_guid
                    --,oq.allow_duplicates
                    --,oq.show_in_parent_portal            
                    /*
                    --only used for PIVOT
                    ,CASE
                      WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12') 
                       THEN 'grade' 
                              + CONVERT(VARCHAR,ROW_NUMBER() OVER(
                                                   PARTITION BY assessment_id
                                                    ORDER BY CASE WHEN tag IN ('k','1','2','3','4','5','6','7','8','9','10','11','12' ) THEN '1' ELSE '2' END))        
                      --ELSE 'other' + CONVERT(VARCHAR,ROW_NUMBER() OVER(PARTITION BY assessment_id ORDER BY tag))
                      ELSE NULL
                     END AS tag_type
                    --*/
              FROM OPENQUERY(ILLUMINATE,'
                     SELECT a.*
                           ,subj.code_translation AS subject
                           ,scope.code_translation AS scope
                           ,tags.tag
                           ,u.state_id
                           ,std.standard_id
                           ,std.parent_standard_id
                           ,std.custom_code
                           ,std.label                                 
                           ,std.description AS std_descr
                           ,parent.custom_code AS parent_standard
                     FROM dna_assessments.assessments a
                     LEFT OUTER JOIN dna_assessments.assessments_tags tag_index
                       ON a.assessment_id = tag_index.assessment_id
                     JOIN dna_assessments.tags tags
                       ON tags.tag_id = tag_index.tag_id                    
                      AND tags.tag IN (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''k'')
                     LEFT OUTER JOIN codes.dna_subject_areas subj
                       ON a.code_subject_area_id = subj.code_id
                     LEFT OUTER JOIN codes.dna_scopes scope
                       ON a.code_scope_id = scope.code_id
                     LEFT OUTER JOIN public.users u
                       ON a.user_id = u.user_id
                     LEFT OUTER JOIN dna_assessments.assessment_standards a_std
                       ON a.assessment_id = a_std.assessment_id
                     LEFT OUTER JOIN standards.standards std
                       ON a_std.standard_id = std.standard_id
                     LEFT OUTER JOIN standards.standards parent
                       ON std.parent_standard_id = parent.standard_id                           
                     ') oq            
              LEFT OUTER JOIN TEACHERS t WITH (NOLOCK)
                ON oq.state_id = t.teachernumber
              LEFT OUTER JOIN REPORTING$dates fsa_dates WITH (NOLOCK)
                ON oq.administered_at >= fsa_dates.start_date
               AND oq.administered_at <= fsa_dates.end_date
               AND fsa_dates.identifier = 'FSA'                    
              LEFT OUTER JOIN (
                               SELECT DISTINCT
                                      co.schoolid
                                     ,oq.assessment_id
                               FROM OPENQUERY(ILLUMINATE,'
                                      SELECT agg.assessment_id       
                                            ,s.local_student_id
                                            ,a.administered_at
                                      FROM dna_assessments.agg_student_responses agg
                                      JOIN public.students s
                                        ON agg.student_id = s.student_id
                                      JOIN dna_assessments.assessments a
                                        ON agg.assessment_id = a.assessment_id
                                      ') oq 
                               JOIN STUDENTS s WITH (NOLOCK)
                                 ON oq.local_student_id = s.student_number
                               JOIN COHORT$comprehensive_long#static co WITH (NOLOCK)
                                 ON s.id = co.studentid
                                --this is going to be an issue around January
                                AND CASE
                                     WHEN DATEPART(MM,oq.administered_at) >= 07 THEN DATEPART(YYYY,oq.administered_at)
                                     WHEN DATEPART(MM,oq.administered_at) < 07 THEN (DATEPART(YYYY,oq.administered_at) - 1)
                                     ELSE NULL
                                    END = co.YEAR
                              ) sch         
                ON oq.assessment_id = sch.assessment_id
              WHERE oq.deleted_at IS NULL --deleted tests are kept in the database for the record
             ) sub
        LEFT OUTER JOIN REPORTING$dates rt WITH (NOLOCK)
          ON sub.administered_at >= rt.start_date
         AND sub.administered_at <= rt.end_date
         AND sub.schoolid = rt.schoolid
         AND rt.identifier = 'RT'
       ) rosebudwashissled;
   
  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
  --SELECT 1 FROM [LIT$FP_test_events_long#identifiers] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$assessments#static');

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
   AND sys.objects.name = 'ILLUMINATE$assessments#static';

 EXEC (@sql);

 -- step 6: insert into final destination
 INSERT INTO [dbo].[ILLUMINATE$assessments#static]
 SELECT *
 FROM [#ILLUMINATE$assessments#static|refresh];

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
  AND sys.objects.name = 'ILLUMINATE$assessments#static';

 EXEC (@sql);

END

GO