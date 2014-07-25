USE KIPP_NJ
GO

ALTER VIEW DEVFIN$NJASK_results AS

WITH njask AS(
  SELECT *
  FROM
      (
       SELECT *
             ,ROW_NUMBER() OVER(
                 PARTITION BY studentid, test_year, subject
                     ORDER BY subject) AS rn
       FROM NJASK$detail#static WITH(NOLOCK)
      ) sub
  WHERE rn = 1
 )
 
,external_NJASK AS (
  SELECT academic_year
        ,test_year
        ,schoolid
        ,studentid
        ,grade_level
        ,cohort
        ,year_in_network
        ,subject
        ,[AvgScale] AS njask_scale_score
        ,NULL AS njask_proficiency
        ,[PP_pct] / 100 AS part_prof
        ,[P_pct] / 100 AS prof
        ,[AP_pct] / 100 AS adv_prof
  FROM
      (
       SELECT academic_year
             ,test_year
             ,schoolid
             ,studentid
             ,grade_level
             ,cohort
             ,year_in_network
             ,CASE
               WHEN identifier LIKE '%LAL%' THEN 'ELA'
               WHEN identifier LIKE '%MATH%' THEN 'Math'
               WHEN identifier LIKE '%SCI%' THEN 'Science'
              END AS subject            
             ,RIGHT(identifier,(LEN(identifier) - CHARINDEX('_',identifier))) AS identifier
             ,value
       FROM
           (
            SELECT academic_year
                  ,(academic_year + 1) AS test_year
                  ,district_code AS schoolid
                  ,district_code AS studentid
                  ,grade_level
                  ,(academic_year + 1) + (12 - grade_level) AS cohort
                  ,NULL AS year_in_network      
                  ,LAL_AvgScale
                  ,LAL_AP_pct
                  ,LAL_P_pct
                  ,LAL_PP_pct
                  ,MATH_AvgScale
                  ,MATH_AP_pct
                  ,MATH_P_pct
                  ,MATH_PP_pct
                  ,SCI_AvgScale
                  ,SCI_AP_pct
                  ,SCI_P_pct
                  ,SCI_PP_pct
            FROM DEVFIN$external_data
            WHERE district_code IN (3310,3570,9999)              
              AND school_code = 999
           ) sub

       UNPIVOT (
         value 
         FOR identifier IN (LAL_AvgScale
                           ,LAL_AP_pct
                           ,LAL_P_pct
                           ,LAL_PP_pct
                           ,MATH_AvgScale
                           ,MATH_AP_pct
                           ,MATH_P_pct
                           ,MATH_PP_pct
                           ,SCI_AvgScale
                           ,SCI_AP_pct
                           ,SCI_P_pct
                           ,SCI_PP_pct)
        ) upiv
      ) sub2  
  PIVOT (
    MAX(value)
    FOR identifier IN ([AvgScale]
                      ,[AP_pct]
                      ,[P_pct]
                      ,[PP_pct])
   ) piv
 )    
 
SELECT njask.test_year AS academic_year 
      ,(njask.test_year + 1) AS test_year      
      ,co.SCHOOLID
      ,njask.studentid
      ,co.GRADE_LEVEL
      ,co.COHORT
      ,co.YEAR_IN_NETWORK
      ,njask.subject
      ,njask.njask_scale_score
      ,njask.njask_proficiency
      ,CASE WHEN njask.njask_proficiency = 'Below Proficient' THEN 1.0 ELSE 0.0 END AS part_prof
      ,CASE WHEN njask.njask_proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END AS prof
      ,CASE WHEN njask.njask_proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END AS adv_prof      
FROM njask
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON njask.studentid = co.STUDENTID
 AND njask.test_year = co.YEAR
 AND co.RN = 1
WHERE njask.test_year >= 2009

UNION ALL

SELECT *
FROM external_NJASK