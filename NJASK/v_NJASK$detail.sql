/*
PURPOSE:
  NJASK state test information long by student
  
MAINTENANCE:
  None
MAJOR STRUCTURAL REVISIONS OR CHANGES:

CREATED BY:
  
ORIGIN DATE:
  Fall 2011
*/

USE KIPP_NJ
GO

--CREATE OR REPLACE VIEW njask$detail AS
SELECT s.id AS njask_studentid
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
         WHEN score.numscore < 200  THEN 'Below Proficient' 
         ELSE NULL
       END njask_proficiency
      ,test.name AS full_name
      ,SUBSTRING(test.name, 9, 10) AS subject
FROM STUDENTS s
JOIN SCHOOLS sch
  ON s.schoolid = sch.school_number
LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
                  SELECT studentid
                        ,numscore
                        ,studenttestid
                  FROM studenttestscore
                  WHERE testscoreid IN (375,383,391,399,406,471,419,427,434,442,449,457,464)
                  ') score
  ON s.id = score.studentid 
LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
                  SELECT id
                        ,test_date
                        ,testid
                  FROM studenttest
                  ') stutest 
  ON score.studenttestid = stutest.id
LEFT OUTER JOIN OPENQUERY(PS_TEAM,'
                  SELECT id
                        ,name
                  FROM test
                  ') test
  ON stutest.testid = test.id
LEFT OUTER JOIN COHORT$comprehensive_long cohort
  ON s.id = cohort.studentid
 AND cohort.entrydate <= stutest.test_date
 AND cohort.exitdate  >= stutest.test_date
 AND cohort.rn = 1
ORDER BY stutest.test_date DESC