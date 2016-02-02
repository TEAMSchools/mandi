USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$RC_standards_wide#BOLD AS

WITH standard_descriptions AS (
  SELECT standard_code
        ,studentfriendly_description
        ,ROW_NUMBER() OVER(
           PARTITION BY standard_code
             ORDER BY BINI_ID DESC) AS rn           
  FROM KIPP_NJ..AUTOLOAD$GDOCS_LTP_standard_descriptions WITH(NOLOCK)
 )

,standards_rollup AS (
  SELECT academic_year
        ,term
        ,local_student_id AS student_number
        ,CONCAT(subj_abbrev, '_', proficiency) AS subj_prof
        ,KIPP_NJ.dbo.GROUP_CONCAT_D(standard_description, CHAR(10)) AS stds
        ,MAX(N) AS N
  FROM
      (
       SELECT academic_year
             ,local_student_id
             ,standard_id
             ,CONCAT('- ', standard_description) AS standard_description
             ,subj_abbrev
             ,term
             ,percent_correct
             ,N_times_tested
             --,prof_bucket
             ,proficiency
             ,CONVERT(NVARCHAR(MAX),COUNT(standard_id) OVER(PARTITION BY academic_year, term, local_student_id, subj_abbrev, proficiency)) AS N
             ,ROW_NUMBER() OVER(
                PARTITION BY academic_year, term, local_student_id, subj_abbrev
                  ORDER BY n_times_tested DESC, percent_correct DESC) AS rn_priority
       FROM
           (
            SELECT academic_year
                  ,local_student_id
                  ,standard_id
                  ,standard_description
                  ,subj_abbrev
                  ,term
                  ,ROUND(AVG(percent_correct),0) AS percent_correct
                  ,MAX(rn) AS N_times_tested                  
                  --,CASE WHEN ROUND(AVG(percent_correct),0) >= 80 THEN 'GLOW' ELSE 'GROW' END AS prof_bucket
                  ,CASE
                    --WHEN ROUND(AVG(percent_correct),0) >= 90 THEN 'ADV'
                    WHEN ROUND(AVG(percent_correct),0) >= 80 THEN 'PROF'
                    WHEN ROUND(AVG(percent_correct),0) BETWEEN 65 AND 79 THEN 'APPRO'
                    ELSE 'NY'
                   END AS proficiency
            FROM
                (
                 SELECT ovr.academic_year
                       ,ovr.local_student_id
                       ,a.standard_id                  
                       ,COALESCE(ltp.studentfriendly_description, a.standard_description) AS standard_description
                       ,a.subject_area
                       ,CASE
                         WHEN a.subject_area IN ('Comprehension','Text Study','Word Work','Phonics','Grammar') THEN 'ELA'                    
                         WHEN a.subject_area = 'Mathematics' THEN 'MATH'
                         WHEN a.subject_area = 'History' THEN 'HIST'
                         WHEN a.subject_area = 'Science' THEN 'SCI'
                         WHEN a.subject_area = 'Performing Arts' THEN 'PERFARTS'
                         ELSE a.subject_area
                        END AS subj_abbrev
                       ,d.alt_name AS term
                       ,CONVERT(FLOAT,r.percent_correct) AS percent_correct                  
                       ,ROW_NUMBER() OVER(
                          PARTITION BY ovr.local_student_id, d.time_per_name, a.subject_area, a.standard_id
                            ORDER BY r.percent_correct ASC) AS rn
                 FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
                 JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
                   ON ovr.local_student_id = co.student_number
                  AND ovr.academic_year = co.year
                  AND co.rn = 1
                 JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
                   ON co.schoolid = d.schoolid
                  AND ovr.date_taken BETWEEN d.start_date AND d.end_date
                  AND d.identifier = 'RT'
                 JOIN KIPP_NJ..ILLUMINATE$assessments_long#static a WITH(NOLOCK)
                   ON co.schoolid = a.schoolid             
                  AND ovr.assessment_id = a.assessment_id
                  AND ((a.subject_area = 'Performing Arts' AND a.scope IN ('Exit Ticket','Unit Assessment'))
                       OR (a.subject_area != 'Performing Arts' AND a.scope IN ('Exit Ticket','CMA - Mid-Module')))                  
                 LEFT OUTER JOIN standard_descriptions ltp WITH(NOLOCK)
                   ON a.standard_code = ltp.standard_code
                  AND ltp.rn = 1
                 JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
                   ON ovr.local_student_id = r.local_student_id
                  AND ovr.assessment_id = r.assessment_id
                  AND a.standard_id = r.standard_id                        
                  AND r.answered > 0
                 WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
                   AND ovr.answered > 0
                   AND co.schoolid = 73258     
                ) sub       
            WHERE ((subject_area = 'Performing Arts') OR (subject_area != 'Performing Arts' AND rn > 1))
            GROUP BY academic_year
                    ,local_student_id
                    ,standard_id
                    ,standard_description
                    ,subj_abbrev
                    ,term
           ) sub  
       ) sub
  WHERE rn_priority <= 5
  GROUP BY academic_year
          ,term
          ,local_student_id
          ,subj_abbrev
          ,proficiency
 )

SELECT academic_year
      ,term
      ,student_number      
      --,[MATH_ADV_stds]
      ,[MATH_PROF_stds]
      ,[MATH_APPRO_stds]
      ,[MATH_NY_stds]
      --,[MATH_ADV_N]
      ,[MATH_PROF_N]
      ,[MATH_APPRO_N]
      ,[MATH_NY_N]
      --,[ELA_ADV_stds]
      ,[ELA_PROF_stds]
      ,[ELA_APPRO_stds]
      ,[ELA_NY_stds]            
      --,[ELA_ADV_N]
      ,[ELA_PROF_N]
      ,[ELA_APPRO_N]
      ,[ELA_NY_N]
      --,[HIST_ADV_stds]
      ,[HIST_PROF_stds]
      ,[HIST_APPRO_stds]
      ,[HIST_NY_stds]                   
      --,[HIST_ADV_N]
      ,[HIST_PROF_N]
      ,[HIST_APPRO_N]
      ,[HIST_NY_N]
      --,[SCI_ADV_stds]
      ,[SCI_PROF_stds]
      ,[SCI_APPRO_stds]
      ,[SCI_NY_stds]                   
      --,[SCI_ADV_N]
      ,[SCI_PROF_N]
      ,[SCI_APPRO_N]
      ,[SCI_NY_N]
      --,[PERFARTS_ADV_stds]
      ,[PERFARTS_PROF_stds]
      ,[PERFARTS_APPRO_stds]
      ,[PERFARTS_NY_stds]                   
      --,[PERFARTS_ADV_N]
      ,[PERFARTS_PROF_N]
      ,[PERFARTS_APPRO_N]
      ,[PERFARTS_NY_N]      
FROM
    (
     SELECT academic_year
           ,term
           ,student_number
           ,CONCAT(subj_prof, '_', field) AS pivot_field
           ,value
     FROM standards_rollup          
     UNPIVOT(
       value
       FOR field IN (stds, N)
      ) u
    ) sub
PIVOT(
  MAX(value)
  FOR pivot_field IN ([MATH_PROF_stds]
                     --,[MATH_ADV_stds]                     
                     ,[MATH_APPRO_stds]
                     ,[MATH_NY_stds]
                     --,[MATH_ADV_N]
                     ,[MATH_PROF_N]
                     ,[MATH_APPRO_N]
                     ,[MATH_NY_N]
                     --,[ELA_ADV_stds]
                     ,[ELA_PROF_stds]
                     ,[ELA_APPRO_stds]
                     ,[ELA_NY_stds]                   
                     --,[ELA_ADV_N]
                     ,[ELA_PROF_N]
                     ,[ELA_APPRO_N]
                     ,[ELA_NY_N]                     
                     --,[HIST_ADV_stds]
                     ,[HIST_PROF_stds]
                     ,[HIST_APPRO_stds]
                     ,[HIST_NY_stds]                   
                     --,[HIST_ADV_N]
                     ,[HIST_PROF_N]
                     ,[HIST_APPRO_N]
                     ,[HIST_NY_N]
                     --,[SCI_ADV_stds]
                     ,[SCI_PROF_stds]
                     ,[SCI_APPRO_stds]
                     ,[SCI_NY_stds]                   
                     --,[SCI_ADV_N]
                     ,[SCI_PROF_N]
                     ,[SCI_APPRO_N]
                     ,[SCI_NY_N]
                     --,[PERFARTS_ADV_stds]
                     ,[PERFARTS_PROF_stds]
                     ,[PERFARTS_APPRO_stds]
                     ,[PERFARTS_NY_stds]                   
                     --,[PERFARTS_ADV_N]
                     ,[PERFARTS_PROF_N]
                     ,[PERFARTS_APPRO_N]
                     ,[PERFARTS_NY_N])                     
 ) p