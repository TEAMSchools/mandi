USE KIPP_NJ
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [sp_NJASK$detail#static|refresh] AS
BEGIN

 DECLARE @sql AS VARCHAR(MAX)='';

  --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#NJASK$detail#static|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#NJASK$detail#static|refresh]
		END

  --STEP 2: load into a TEMPORARY staging table.
  SELECT *
		INTO [#NJASK$detail#static|refresh]
  FROM (SELECT s.id AS studentid
              ,s.grade_level AS cur_grade_level
              ,sch.abbreviation AS cur_school
              ,cohort.schoolid AS test_schoolid      
              ,cohort.year AS test_year
              ,stutest.test_date AS test_date
              ,SUBSTRING(test.name, 7, 1) AS test_grade_level
              ,score.numscore AS njask_scale_score
              ,CASE 
                WHEN score.numscore >= 250 THEN 'Advanced Proficient' 
                WHEN score.numscore >= 200 THEN 'Proficient' 
                WHEN score.numscore <  200 THEN 'Below Proficient' 
                ELSE NULL
               END njask_proficiency
              ,test.name AS full_name
              ,SUBSTRING(test.name, 9, 10) AS subject
        FROM STUDENTS s
        JOIN SCHOOLS sch 
          ON s.schoolid = sch.school_number
        LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
               SELECT *
               FROM studenttestscore
               WHERE testscoreid IN (375,383,391,399,406,471,419,427,434,442,449,457,464)
               ') score
          ON s.id = score.studentid 
        JOIN OPENQUERY(PS_TEAM,'
               SELECT *
               FROM studenttest
               ') stutest 
          ON score.studenttestid = stutest.id
        JOIN OPENQUERY(PS_TEAM,'
               SELECT *
               FROM test
               ') test 
          ON stutest.testid = test.id
        LEFT OUTER JOIN COHORT$comprehensive_long#static cohort
          ON s.id = cohort.studentid
         AND cohort.entrydate <= stutest.test_date
         AND cohort.exitdate >= stutest.test_date
         AND cohort.rn = 1
       ) sub;

  --STEP 3: LOCK destination table exclusively load into a TEMPORARY staging table.
    --SELECT 1 FROM [] WITH (TABLOCKX);

  --STEP 4: truncate 
  EXEC('TRUNCATE TABLE KIPP_NJ..NJASK$detail#static');

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
   AND sys.objects.name = 'NJASK$detail#static';

 EXEC (@sql);

 -- STEP 6: insert into final destination
 INSERT INTO [dbo].[NJASK$detail#static]
 SELECT *
 FROM [#NJASK$detail#static|refresh];
 
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
  AND sys.objects.name = 'NJASK$detail#static';

 EXEC (@sql);
  
END