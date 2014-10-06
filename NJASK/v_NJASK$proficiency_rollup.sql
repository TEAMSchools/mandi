USE KIPP_NJ
GO

ALTER VIEW NJASK$proficiency_rollup AS

SELECT year
      ,school
      ,subject
      ,grade_level
      ,n_tested
      ,avg_scale
      ,part_prof
      ,prof
      ,adv_prof
      ,ROUND(((prof + adv_prof) / n_tested * 100),0) AS pct_prof
FROM
    (
     SELECT academic_year + 1 AS year
           ,CASE GROUPING(test_schoolid)
              WHEN 1 THEN 'Network'
              ELSE CASE
                     WHEN test_schoolid = 73252 THEN 'Rise'
                     WHEN test_schoolid = 133570965 THEN 'TEAM'
                     WHEN test_schoolid = 73254 THEN 'SPARK'
                   END
            END AS school            
           ,subject
           ,test_grade_level AS grade_level
           ,COUNT(studentid) AS n_tested
           ,ROUND(AVG(njask_scale_score),0) AS avg_scale           
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Below Proficient' THEN 1.0 ELSE 0.0 END)) AS part_prof
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END)) AS prof
           ,CONVERT(FLOAT,SUM(CASE WHEN njask_proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END)) AS adv_prof           
     FROM NJASK$detail  WITH(NOLOCK)
     WHERE test_schoolid IN (73252,133570965,73254)       
     GROUP BY academic_year
             ,CUBE(test_schoolid)
             ,test_grade_level
             ,subject
    ) sub