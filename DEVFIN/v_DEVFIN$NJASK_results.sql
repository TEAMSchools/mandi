USE KIPP_NJ
GO

ALTER VIEW DEVFIN$NJASK_results AS
 
WITH external_NJASK AS (
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
            FROM DEVFIN$external_data WITH(NOLOCK)
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
 

SELECT njask.academic_year AS academic_year 
      ,(njask.academic_year + 1) AS test_year      
      ,co.SCHOOLID
      ,njask.studentid
      ,co.GRADE_LEVEL
      ,co.LUNCHSTATUS
      ,co.SPEDLEP
      ,co.COHORT
      ,co.YEAR_IN_NETWORK
      ,njask.subject
      ,njask.njask_scale_score
      ,njask.njask_proficiency
      ,CASE WHEN njask.njask_proficiency = 'Below Proficient' THEN 1.0 ELSE 0.0 END AS part_prof
      ,CASE WHEN njask.njask_proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END AS prof
      ,CASE WHEN njask.njask_proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END AS adv_prof      
      ,0 AS is_retest
FROM NJASK$detail njask WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON njask.studentid = co.STUDENTID
 AND njask.academic_year = co.YEAR
 AND co.RN = 1
WHERE njask.academic_year >= 2009

UNION ALL

SELECT hspa.academic_year
      ,hspa.academic_year + 1 AS test_year
      ,hspa.test_schoolid AS schoolid
      ,hspa.studentid
      ,test_grade_level AS grade_level
      ,co.LUNCHSTATUS
      ,co.SPEDLEP
      ,co.cohort
      ,co.year_in_network
      ,hspa.subject
      ,hspa.scale_score AS njask_scale_score
      ,hspa.proficiency AS njask_proficiency
      ,CASE WHEN hspa.proficiency = 'Partially Proficient' THEN 1.0 ELSE 0.0 END AS part_prof
      ,CASE WHEN hspa.proficiency = 'Proficient' THEN 1.0 ELSE 0.0 END AS prof
      ,CASE WHEN hspa.proficiency = 'Advanced Proficient' THEN 1.0 ELSE 0.0 END AS adv_prof
      ,hspa.is_retest
FROM HSPA$detail hspa WITH(NOLOCK)
JOIN COHORT$identifiers_long#static co WITH(NOLOCK)
  ON hspa.studentid = co.studentid
 AND hspa.academic_year = co.year
 AND co.rn = 1

UNION ALL

SELECT academic_year
      ,test_year
      ,schoolid
      ,studentid
      ,grade_level
      ,NULL AS lunchstatus
      ,NULL AS spedlep
      ,cohort
      ,year_in_network
      ,subject
      ,njask_scale_score
      ,NULL AS njask_proficiency
      ,part_prof
      ,prof
      ,adv_prof
      ,0 AS is_retest
FROM external_NJASK WITH(NOLOCK)