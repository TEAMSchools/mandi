USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [sp_ILLUMINATE$FSA_scores_wide#static|refresh] AS
BEGIN

  DECLARE @sql AS VARCHAR(MAX)='';

  -- STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#ILLUMINATE$FSA_scores_wide#static|refresh') IS NOT NULL
		  BEGIN
						  DROP TABLE [#ILLUMINATE$FSA_scores_wide#static|refresh]
		  END
  IF OBJECT_ID(N'tempdb..#scores_long') IS NOT NULL
		  BEGIN
						  DROP TABLE #scores_long
		  END;


  -- STEP 2: load into a temporary staging table.
  WITH standard_descriptions AS (
    SELECT standard_code
          ,studentfriendly_description
          ,ROW_NUMBER() OVER(
             PARTITION BY standard_code
               ORDER BY BINI_ID DESC) AS rn           
    FROM KIPP_NJ..AUTOLOAD$GDOCS_LTP_standard_descriptions WITH(NOLOCK)
   )

  ,scores_long AS (
    SELECT ovr.academic_year
          ,ovr.local_student_id
          ,a.standard_id
          ,CASE                     
            WHEN a.subject_area NOT IN ('Comprehension','Text Study','Word Work','Phonics','Grammar','Mathematics') 
                 THEN CONCAT(a.subject_area, ' - ', a.standard_description)
            ELSE a.standard_description
           END AS standard_description
          ,a.subject_area
          ,CASE
            WHEN a.subject_area IN ('Comprehension','Text Study','Word Work','Phonics','Grammar') THEN 'ELA'                    
            WHEN a.subject_area = 'Mathematics' THEN 'MATH'
            ELSE 'SPEC'
           END AS subj_abbrev
          ,d.time_per_name AS reporting_week
          ,CONVERT(FLOAT,r.percent_correct) AS percent_correct 
          ,1 AS rn
    FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
      ON ovr.local_student_id = co.student_number
     AND ovr.academic_year = co.year
     AND co.rn = 1
    JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
      ON co.schoolid = d.schoolid
     AND ovr.date_taken BETWEEN DATEADD(DAY, (3 - DATEPART(DW,d.start_date)), d.start_date) /* Tuesday start */
                            AND DATEADD(DAY, 7, (DATEADD(DAY,(2 - DATEPART(DW,d.start_date)), d.start_date))) /* Monday end */               
     AND d.identifier = 'REP'
    JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
      ON co.schoolid = a.schoolid             
     AND ovr.assessment_id = a.assessment_id
     AND a.scope IN ('Common FSA','Exit Ticket','CMA - End-of-Module','CMA - Mid-Module','Unit Assessment')
     AND a.subject_area IS NOT NULL            
    JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
      ON ovr.local_student_id = r.local_student_id
     AND ovr.assessment_id = r.assessment_id
     AND a.standard_id = r.standard_id      
     AND r.answered > 0
    WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()              
      AND co.schoolid != 73258                   
            
    UNION ALL

    SELECT ovr.academic_year
          ,ovr.local_student_id
          ,a.standard_id
          ,CASE 
            WHEN co.schoolid = 73258 THEN COALESCE(ltp.studentfriendly_description, a.standard_description)
            WHEN a.subject_area NOT IN ('Comprehension','Writing','Text Study','Word Work','Phonics','Grammar','Mathematics') 
                 THEN CONCAT(a.subject_area, ' - ', a.standard_description)
            ELSE a.standard_description
           END AS standard_description
          ,a.subject_area
          ,CASE
            WHEN a.subject_area IN ('Comprehension','Writing','Text Study','Word Work','Phonics','Grammar') THEN 'ELA'                    
            WHEN a.subject_area = 'Mathematics' THEN 'MATH'
            ELSE 'SPEC'
           END AS subj_abbrev
          ,d.time_per_name AS reporting_week
          ,CONVERT(FLOAT,r.percent_correct) AS percent_correct       
          ,ROW_NUMBER() OVER(
             PARTITION BY ovr.local_student_id, d.time_per_name, a.subject_area, a.standard_id
               ORDER BY ovr.date_taken DESC) AS rn
    FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
      ON ovr.local_student_id = co.student_number
     AND ovr.academic_year = co.year
     AND co.rn = 1
    JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
      ON co.schoolid = d.schoolid
     AND ovr.date_taken BETWEEN d.start_date AND d.end_date /* Tues - Mon for BOLD */
     AND d.identifier = 'REP'
    JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
      ON co.schoolid = a.schoolid             
     AND ovr.assessment_id = a.assessment_id
     AND a.scope IN ('Common FSA','Exit Ticket')
     AND a.subject_area IS NOT NULL
    LEFT OUTER JOIN standard_descriptions ltp WITH(NOLOCK)
      ON a.standard_code = ltp.standard_code
     AND ltp.rn = 1
    JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
      ON ovr.local_student_id = r.local_student_id
     AND ovr.assessment_id = r.assessment_id
     AND a.standard_id = r.standard_id      
     AND r.answered > 0                  
    WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
      AND ovr.answered > 0
      AND co.schoolid = 73258     
   )
  
  SELECT *
  INTO #scores_long
  FROM scores_long;
  
  WITH standards_rollup AS (
    SELECT academic_year
          ,reporting_week
          ,local_student_id AS student_number
          ,CONCAT(subj_abbrev, '_', proficiency) AS subj_prof
          ,KIPP_NJ.dbo.GROUP_CONCAT_D(standard_description, CHAR(10)+CHAR(13)) AS std
    FROM
        (
         SELECT academic_year
               ,local_student_id
               ,standard_description
               ,subj_abbrev
               ,reporting_week             
               ,ROUND(AVG(percent_correct),0) AS percent_correct
               ,CASE
                 WHEN ROUND(AVG(percent_correct),0) >= 90.0 THEN 'ADV'
                 WHEN ROUND(AVG(percent_correct),0) >= 80.0 THEN 'PROF'
                 ELSE 'NY'
                END AS proficiency
         FROM #scores_long
         WHERE rn = 1
         GROUP BY academic_year
                 ,local_student_id
                 ,standard_description
                 ,subj_abbrev
                 ,reporting_week             
        ) sub  
    GROUP BY academic_year
            ,reporting_week
            ,local_student_id
            ,subj_abbrev
            ,proficiency
   )

  ,pivoted AS (
    SELECT academic_year
          ,reporting_week
          ,student_number      
          ,[MATH_ADV]
          ,[MATH_PROF]
          ,[MATH_NY]
          ,[ELA_ADV]
          ,[ELA_PROF]
          ,[ELA_NY]
          ,[SPEC_ADV]
          ,[SPEC_PROF]
          ,[SPEC_NY]
    FROM standards_rollup          
    PIVOT(
      MAX(std)
      FOR subj_prof IN ([MATH_ADV]
                         ,[MATH_PROF]
                         ,[MATH_NY]
                         ,[ELA_ADV]
                         ,[ELA_PROF]
                         ,[ELA_NY]
                         ,[SPEC_ADV]
                         ,[SPEC_PROF]
                         ,[SPEC_NY])
     ) p
   )
  
  SELECT *
		INTO [#ILLUMINATE$FSA_scores_wide#static|refresh]
  FROM pivoted;         


  -- STEP 3: truncate destination table
  EXEC('TRUNCATE TABLE KIPP_NJ..ILLUMINATE$FSA_scores_wide#static');


  -- STEP 4: disable all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                 + indexes.name + ' ON dbo.' 
                 + objects.name + ' DISABLE;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'ILLUMINATE$FSA_scores_wide#static';
  EXEC (@sql);


  -- STEP 5: insert into final destination
  INSERT INTO [ILLUMINATE$FSA_scores_wide#static]
  SELECT *
  FROM [#ILLUMINATE$FSA_scores_wide#static|refresh];
 

  -- STEP 6: rebuld all nonclustered indexes on table
  SELECT @sql = @sql + 'ALTER INDEX ' 
                  + indexes.name + ' ON dbo.' 
                  + objects.name + ' REBUILD;' + CHAR(13) + CHAR(10)
  FROM sys.indexes
  JOIN sys.objects 
    ON sys.indexes.object_id = sys.objects.object_id
  WHERE sys.indexes.type_desc = 'NONCLUSTERED'
    AND sys.objects.type_desc = 'USER_TABLE'
    AND sys.objects.name = 'ILLUMINATE$FSA_scores_wide#static';
  EXEC (@sql);
  
END                