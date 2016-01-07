USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$CMA_standards_wide AS

WITH standards_rollup AS (
  SELECT academic_year
        ,term
        ,local_student_id AS student_number
        ,CONCAT(subj_abbrev, '_', proficiency) AS subj_prof
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(standard_description, CHAR(10)) AS std
  FROM
      (
       SELECT academic_year
             ,local_student_id
             ,standard_description
             ,subj_abbrev
             ,term
             ,ROUND(AVG(percent_correct),0) AS percent_correct
             ,CASE
               WHEN ROUND(AVG(percent_correct),0) >= 90 THEN 'ADV'
               WHEN ROUND(AVG(percent_correct),0) >= 80 THEN 'PROF'
               WHEN ROUND(AVG(percent_correct),0) BETWEEN 65 AND 79 THEN 'APRO'
               ELSE 'NY'
              END AS proficiency
       FROM
           (
            SELECT ovr.academic_year
                  ,ovr.local_student_id
                  ,a.standard_id
                  ,CASE                     
                    WHEN a.subject_area NOT IN ('Text Study','Mathematics','Writing') 
                         THEN CONCAT('- ', a.subject_area, ' - ', a.standard_description)
                    ELSE CONCAT('- ', a.standard_description)
                   END AS standard_description
                  ,a.subject_area
                  ,CASE
                    WHEN a.subject_area = 'Text Study' THEN 'ELA'                    
                    WHEN a.subject_area = 'Mathematics' THEN 'MATH'
                    WHEN a.subject_area = 'Writing' THEN 'WRIT'
                    ELSE 'SPEC'
                   END AS subj_abbrev
                  ,d.alt_name AS term
                  ,CONVERT(FLOAT,r.percent_correct) AS percent_correct                   
            FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
            JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
              ON ovr.local_student_id = co.student_number
             AND ovr.academic_year = co.year
             AND co.rn = 1
            JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
              ON co.schoolid = a.schoolid             
             AND ovr.assessment_id = a.assessment_id
             AND a.scope IN ('CMA - End-of-Module','Unit Assessment')
             AND a.subject_area != 'Writing'
             AND a.subject_area IS NOT NULL            
             AND a.standard_code NOT LIKE 'TES.W.%'
            JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
              ON co.schoolid = d.schoolid
             AND a.administered_at BETWEEN d.start_date AND d.end_date
             AND d.identifier = 'RT'            
            JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
              ON ovr.local_student_id = r.local_student_id
             AND ovr.assessment_id = r.assessment_id
             AND a.standard_id = r.standard_id      
            WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()              
              AND ovr.answered > 0
              AND co.grade_level <= 4
              AND co.schoolid != 73252
           ) sub       
       GROUP BY academic_year
               ,local_student_id
               ,standard_description
               ,subj_abbrev
               ,term
      ) sub  
  GROUP BY academic_year
          ,term
          ,local_student_id
          ,subj_abbrev
          ,proficiency
 )

SELECT academic_year
      ,term
      ,student_number      
      ,[MATH_ADV]
      ,[MATH_PROF]
      ,[MATH_APRO]
      ,[MATH_NY]
      ,[ELA_ADV]
      ,[ELA_PROF]
      ,[ELA_APRO]
      ,[ELA_NY]
      ,[SPEC_ADV]
      ,[SPEC_PROF]
      ,[SPEC_APRO]
      ,[SPEC_NY]
FROM standards_rollup          
PIVOT(
  MAX(std)
  FOR subj_prof IN ([MATH_ADV]
                   ,[MATH_PROF]
                   ,[MATH_APRO]
                   ,[MATH_NY]
                   ,[ELA_ADV]
                   ,[ELA_PROF]
                   ,[ELA_APRO]
                   ,[ELA_NY]
                   ,[SPEC_ADV]
                   ,[SPEC_PROF]
                   ,[SPEC_APRO]
                   ,[SPEC_NY])
 ) p