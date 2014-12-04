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
     GROUP BY academic_year
             ,CUBE(test_schoolid)
             ,test_grade_level
             ,subject

     UNION ALL

     SELECT academic_year + 1 AS year
           ,CASE GROUPING(test_schoolid)
              WHEN 1 THEN 'Network'
              ELSE CASE                     
                     WHEN test_schoolid = 73253 THEN 'NCA'
                   END
            END AS school
           ,subject
           ,test_grade_level AS grade_level
           ,COUNT(studentid) AS n_tested
           ,ROUND(AVG(CONVERT(INT,scale_score)),0) AS avg_scale           
           ,CONVERT(FLOAT,SUM(CASE WHEN proficiency = 'Below Proficient' THEN 1.0 ELSE 0.0 END)) AS part_prof
           ,CONVERT(FLOAT,SUM(CASE WHEN proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END)) AS prof
           ,CONVERT(FLOAT,SUM(CASE WHEN proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END)) AS adv_prof           
     FROM HSPA$detail WITH(NOLOCK)
     GROUP BY academic_year
             ,CUBE(test_schoolid)
             ,test_grade_level
             ,subject
    ) sub

UNION ALL

SELECT academic_year + 1 AS year
      ,CASE
        WHEN district_code = 3570 THEN 'Newark'
        WHEN district_code = 9999 THEN 'NJ'
       END AS school
      ,CASE
        WHEN subject = 'LAL' THEN 'ELA'
        WHEN subject = 'MATH' THEN 'Math'
        WHEN subject = 'SCI' THEN 'Science'
       END AS subject
      ,grade_level       
      ,[N_Valid] AS n_tested      
      ,[AvgScale] AS avg_scale
      ,[approx_N_PP] AS part_prof
      ,[approx_N_P] AS prof
      ,[approx_N_AP] AS adv_prof
      ,[pct_prof]
FROM
    (
     SELECT academic_year
           ,district_code
           ,grade_level           
           ,LEFT(field,CHARINDEX('_', field) - 1) AS subject
           ,SUBSTRING(field,CHARINDEX('_', field) + 1, LEN(field)) AS measure
           ,value AS score
     FROM
         (
          SELECT academic_year
                ,district_code
                ,grade_level
                ,CONVERT(INT,LAL_N_Valid) AS LAL_N_Valid
                ,CONVERT(INT,LAL_AvgScale) AS LAL_AvgScale
                ,CONVERT(INT,LAL_approx_N_PP) AS LAL_approx_N_PP
                ,CONVERT(INT,LAL_approx_N_P) AS LAL_approx_N_P
                ,CONVERT(INT,LAL_approx_N_AP) AS LAL_approx_N_AP
                ,CONVERT(INT,LAL_P_pct) + CONVERT(INT,LAL_AP_pct) AS LAL_pct_prof
                ,CONVERT(INT,MATH_N_Valid) AS MATH_N_Valid
                ,CONVERT(INT,MATH_AvgScale) AS MATH_AvgScale
                ,CONVERT(INT,MATH_approx_N_PP) AS MATH_approx_N_PP
                ,CONVERT(INT,MATH_approx_N_P) AS MATH_approx_N_P
                ,CONVERT(INT,MATH_approx_N_AP) AS MATH_approx_N_AP
                ,CONVERT(INT,Math_P_pct) + CONVERT(INT,Math_AP_pct) AS MATH_pct_prof
                ,CONVERT(INT,SCI_N_Valid) AS SCI_N_Valid
                ,CONVERT(INT,SCI_AvgScale) AS SCI_AvgScale
                ,CONVERT(INT,SCI_approx_N_PP) AS SCI_approx_N_PP
                ,CONVERT(INT,SCI_approx_N_P) AS SCI_approx_N_P
                ,CONVERT(INT,SCI_approx_N_AP) AS SCI_approx_N_AP
                ,CONVERT(INT,SCI_P_pct) + CONVERT(INT,SCI_AP_pct) AS SCI_pct_prof
          FROM NJASKHSPA$state_data_clean WITH(NOLOCK)
          WHERE district_code IN (3570,9999)
         ) sub
     UNPIVOT(
       value
       FOR field IN (LAL_N_Valid
                    ,LAL_AvgScale
                    ,LAL_approx_N_PP
                    ,LAL_approx_N_P
                    ,LAL_approx_N_AP
                    ,MATH_N_Valid
                    ,MATH_AvgScale
                    ,MATH_approx_N_PP
                    ,MATH_approx_N_P
                    ,MATH_approx_N_AP
                    ,SCI_N_Valid
                    ,SCI_AvgScale
                    ,SCI_approx_N_PP
                    ,SCI_approx_N_P
                    ,SCI_approx_N_AP
                    ,LAL_pct_prof
                    ,MATH_pct_prof
                    ,SCI_pct_prof)
      ) u
     ) sub
PIVOT(
  MAX(score)
  FOR measure IN ([N_Valid]
                 ,[AvgScale]
                 ,[pct_prof]
                 ,[approx_N_PP]
                 ,[approx_N_P]
                 ,[approx_N_AP])
 ) p