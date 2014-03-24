USE KIPP_NJ
GO

ALTER VIEW NJASK$proficiency_rollup AS

WITH njask AS(
  SELECT *
  FROM
      (
       SELECT *
             ,ROW_NUMBER() OVER(
                 PARTITION BY studentid, test_year, subject
                     ORDER BY subject) AS rn
       FROM NJASK$detail#static
      ) sub
  WHERE rn = 1
 )

SELECT *
      ,ROUND(((prof + adv_prof) / n_tested * 100),0) AS pct_prof
FROM
    (
     SELECT test_year + 1 AS year
           ,CASE
             WHEN test_schoolid = 73252 THEN 'Rise'
             WHEN test_schoolid = 133570965 THEN 'TEAM'
             WHEN test_schoolid = 73254 THEN 'SPARK'
            END AS school            
           ,subject
           ,test_grade_level AS grade_level
           ,COUNT(studentid) AS n_tested
           ,ROUND(AVG(njask_scale_score),0) AS avg_scale           
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Below Proficient' THEN 1.0 ELSE 0.0 END)) AS part_prof
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END)) AS prof
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END)) AS adv_prof           
     FROM njask
     WHERE test_schoolid IN (73252,133570965,73254)
       AND test_year >= 2009
     GROUP BY test_year
             ,test_schoolid
             ,test_grade_level
             ,subject
    ) sub