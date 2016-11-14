USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_wide AS 

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
               WHEN ROUND(AVG(percent_correct),0) >= 70.0 THEN 'ADV'
               WHEN ROUND(AVG(percent_correct),0) >= 50.0 THEN 'PROF'
               ELSE 'NY'
              END AS proficiency
       FROM KIPP_NJ..ILLUMINATE$FSA_scores_long#static WITH(NOLOCK)
       --WHERE rn = 1
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

SELECT academic_year
      ,reporting_week
      ,student_number      
      ,[ELA_ADV]
      ,[ELA_PROF]
      ,[ELA_NY]
            
      ,[MATH_ADV]
      ,[MATH_PROF]      
      ,[MATH_NY]      
      
      ,[SCI_ADV]
      ,[SCI_PROF]
      ,[SCI_NY]

      ,[SOC_ADV]
      ,[SOC_PROF]
      ,[SOC_NY]
      
      ,[PERFARTS_ADV]
      ,[PERFARTS_PROF]
      ,[PERFARTS_NY]      

      ,[VIZARTS_ADV]
      ,[VIZARTS_PROF]
      ,[VIZARTS_NY]      
FROM standards_rollup          
PIVOT(
  MAX(std)
  FOR subj_prof IN ([ELA_ADV]
                   ,[ELA_PROF]
                   ,[ELA_NY]            
                   ,[MATH_ADV]
                   ,[MATH_PROF]      
                   ,[MATH_NY]            
                   ,[SCI_ADV]
                   ,[SCI_PROF]
                   ,[SCI_NY]
                   ,[SOC_ADV]
                   ,[SOC_PROF]
                   ,[SOC_NY]      
                   ,[PERFARTS_ADV]
                   ,[PERFARTS_PROF]
                   ,[PERFARTS_NY]
                   ,[VIZARTS_ADV]
                   ,[VIZARTS_PROF]
                   ,[VIZARTS_NY])
 ) p