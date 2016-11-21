USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_long AS

SELECT sub.academic_year	
      ,sub.local_student_id	
      ,sub.standard_id	
      ,sub.standard_description	
      ,sub.subject_area	
      ,sub.subj_abbrev	
      ,d.time_per_name AS reporting_week	
      ,sub.percent_correct	
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.local_student_id, sub.subject_area, sub.standard_id, d.time_per_name
           ORDER BY sub.date_taken DESC) AS rn
FROM
    (
     SELECT ovr.academic_year
           ,ovr.local_student_id
           ,MIN(ovr.date_taken) OVER(PARTITION BY ovr.academic_year, ovr.assessment_id, co.schoolid) AS date_taken
           ,r.standard_id      
           ,COALESCE(ltp.studentfriendly_description, std.description) AS standard_description
           ,a.title
           ,a.scope           
           ,a.subject_area
           ,CASE
             WHEN a.subject_area = 'Text Study' THEN 'ELA'                    
             WHEN a.subject_area = 'Mathematics' THEN 'MATH'
             WHEN a.subject_area = 'Science' THEN 'SCI'
             WHEN a.subject_area IN ('Social Studies','History') THEN 'SOC' 
             WHEN a.subject_area = 'Performing Arts' THEN 'PERFARTS'
             WHEN a.subject_area = 'Visual Arts' THEN 'VIZARTS'
             ELSE ISNULL(a.subject_area,'Missing')
            END AS subj_abbrev           
           ,CONVERT(FLOAT,r.percent_correct) AS percent_correct                  
           ,co.schoolid
     FROM KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
     JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
       ON ovr.local_student_id = co.student_number
      AND ovr.academic_year = co.year
      AND co.schoolid = 73258
      AND co.rn = 1 
     JOIN KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
       ON ovr.assessment_id = a.assessment_id
      AND ((a.subject_area IN ('Text Study','Mathematics') AND (a.scope NOT IN ('CMA - Mid-Module', 'CMA - End-of-Module','Process Piece','KIPP Network-Wide') OR a.scope IS NULL))
            OR (a.subject_area NOT IN ('Text Study','Mathematics')))     
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard r WITH(NOLOCK)
       ON ovr.local_student_id = r.local_student_id
      AND ovr.assessment_id = r.assessment_id 
      AND r.answered > 0
     LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static std WITH(NOLOCK)
       ON r.standard_id = std.standard_id
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LTP_standard_descriptions ltp WITH(NOLOCK)
       ON std.custom_code = ltp.standard_code
     WHERE ovr.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND ovr.answered > 0
    ) sub
LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
  ON sub.schoolid = d.schoolid
 AND sub.date_taken BETWEEN d.start_date AND d.end_date
 AND d.identifier = 'RT'