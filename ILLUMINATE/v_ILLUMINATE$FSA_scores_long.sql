USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$FSA_scores_long AS

SELECT ovr.academic_year
      ,ovr.local_student_id
      ,r.standard_id
      ,COALESCE(ltp.studentfriendly_description, std.description) AS standard_description
      ,a.subject_area
      ,CASE
        WHEN a.subject_area = 'Text Study' THEN 'ELA'                    
        WHEN a.subject_area = 'Mathematics' THEN 'MATH'
        ELSE 'SPEC'
       END AS subj_abbrev
      ,d.time_per_name AS reporting_week
      ,CONVERT(FLOAT,r.percent_correct) AS percent_correct       
      ,ROW_NUMBER() OVER(
         PARTITION BY ovr.local_student_id, d.time_per_name, a.subject_area, r.standard_id
           ORDER BY ovr.date_taken DESC) AS rn
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
 AND a.scope IN ('Exit Ticket','Topic Assessments')
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