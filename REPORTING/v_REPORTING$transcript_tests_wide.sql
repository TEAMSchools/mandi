USE KIPP_NJ
GO

ALTER VIEW REPORTING$transcript_tests_wide AS

WITH ACT AS (
  SELECT student_number
        ,CONCAT('ACT', CHAR(9), CHAR(9), 'Eng', CHAR(9), 'Math', CHAR(9), 'Read', CHAR(9), 'Sci', CHAR(9), 'Composite', CHAR(9), 'Writing') AS ACT_header
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(act_concat, CHAR(10)) AS ACT_grouped
  FROM
      (
       SELECT student_number
             ,CONCAT(
                FORMAT(test_date,'MMM yyyy'), CHAR(9)
               ,english, CHAR(9)
               ,math, CHAR(9)
               ,reading, CHAR(9)
               ,science, CHAR(9)
               ,composite, CHAR(9)
               ,writing_sub, CHAR(9)
              ) AS act_concat
       FROM KIPP_NJ..NAVIANCE$ACT_clean act WITH(NOLOCK)
       WHERE is_plan = 0
      ) sub
  GROUP BY student_number
 )

,SAT AS (
  SELECT student_number
        ,CONCAT('SAT', CHAR(9), CHAR(9), 'Math', CHAR(9), 'Read', CHAR(9), 'Wr', CHAR(9), 'MC', CHAR(9), 'Essay') AS SAT_header
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(SAT_concat, CHAR(10)) AS SAT_grouped
  FROM
      (
       SELECT student_number
             ,CONCAT(
                FORMAT(test_date,'MMM yyyy'), CHAR(9)
               ,math, CHAR(9)
               ,verbal, CHAR(9)
               ,writing, CHAR(9)
               ,mc_subscore, CHAR(9)
               ,essay_subscore, CHAR(9)
              ) AS SAT_concat
       FROM KIPP_NJ..NAVIANCE$SAT_clean sat WITH(NOLOCK)
       WHERE dupe_audit = 1
      ) sub
  GROUP BY student_number
 )

SELECT s.STUDENT_NUMBER
      ,ACT.ACT_header
      ,ACT.ACT_grouped
      ,SAT.SAT_header
      ,SAT.SAT_grouped
FROM KIPP_NJ..PS$STUDENTS#static s WITH(NOLOCK)
JOIN ACT
  ON s.STUDENT_NUMBER = ACT.student_number
JOIN SAT
  ON s.STUDENT_NUMBER = SAT.student_number
WHERE s.SCHOOLID = 73253
