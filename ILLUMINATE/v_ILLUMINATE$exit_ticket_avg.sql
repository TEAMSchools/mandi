USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$exit_ticket_avg AS

SELECT academic_year
      ,local_student_id
      ,term
      ,[ELA]      
      ,[MATH]
      ,[SCI]
      ,[SOC]
      ,[PERFARTS]
      ,[VIZARTS]
FROM
    (
     SELECT academic_year
           ,local_student_id
           ,subj_abbrev
           ,term
           ,ROUND(AVG(percent_correct),0) AS avg_pct_correct
     FROM
         (
          SELECT ovr.academic_year
                ,ovr.local_student_id                  
                ,CASE
                  WHEN a.subject_area = 'Text Study' THEN 'ELA'                    
                  WHEN a.subject_area = 'Mathematics' THEN 'MATH'
                  WHEN a.subject_area = 'Science' THEN 'SCI'
                  WHEN a.subject_area IN ('Social Studies','History') THEN 'SOC' 
                  WHEN a.subject_area = 'Performing Arts' THEN 'PERFARTS'
                  WHEN a.subject_area = 'Visual Arts' THEN 'VIZARTS'
                  ELSE ISNULL(a.subject_area,'Missing')
                 END AS subj_abbrev
                ,d.alt_name AS term
                ,CONVERT(FLOAT,ovr.percent_correct) AS percent_correct                  
                ,ROW_NUMBER() OVER(
                   PARTITION BY ovr.local_student_id, d.time_per_name, a.subject_area
                     ORDER BY ovr.percent_correct ASC) AS rn
          FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
          JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
            ON ovr.local_student_id = co.student_number
           AND ovr.academic_year = co.year
           AND co.schoolid = 73258
           AND co.rn = 1
          JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
            ON co.schoolid = d.schoolid
           AND ovr.date_taken BETWEEN d.start_date AND d.end_date
           AND d.identifier = 'RT'
          JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
            ON ovr.assessment_id = a.assessment_id
           AND (a.scope NOT IN ('CMA - Mid-Module', 'CMA - End-of-Module','Process Piece','KIPP Network-Wide') OR a.scope IS NULL)
           AND a.subject_area IS NOT NULL                  
          WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
            AND ovr.answered > 0            
         ) sub     
     GROUP BY academic_year
             ,local_student_id
             ,subj_abbrev
             ,term
    ) sub
PIVOT(
  MAX(avg_pct_correct)
  FOR subj_abbrev IN ([ELA]
                     ,[MATH]
                     ,[SCI]
                     ,[SOC]
                     ,[PERFARTS]
                     ,[VIZARTS])
 ) p