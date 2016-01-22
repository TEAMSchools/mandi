USE KIPP_NJ
GO

ALTER VIEW ACT$test_prep_scores AS

WITH long_data AS (
  SELECT a.subject_area
        ,a.academic_year
        ,a.administered_at
        ,d.time_per_name AS administration_round
        ,ovr.local_student_id AS student_number
        ,CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) AS overall_number_correct
        ,ovr.performance_band_level AS overall_performance_band
        ,s.custom_code AS standard_code
        ,s.description AS standard_description
        ,CONVERT(FLOAT,std.percent_correct) AS standard_percent_correct
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON a.academic_year = d.academic_year
   AND a.administered_at BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'ACT'
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    ON a.assessment_id = ovr.assessment_id
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard std WITH(NOLOCK)
    ON a.assessment_id = std.assessment_id
   AND ovr.local_student_id = std.local_student_id
  JOIN KIPP_NJ..ILLUMINATE$standards#static s WITH(NOLOCK)
    ON std.standard_id = s.standard_id
  JOIN PS$STUDENTS#static stu WITH(NOLOCK)
    ON ovr.local_student_id = stu.STUDENT_NUMBER
   AND stu.SCHOOLID = 73253
  WHERE a.scope = 'ACT Prep'
 )

SELECT d.student_number
      ,d.academic_year
      ,d.administration_round      
      ,d.administered_at
      ,d.subject_area
      ,d.overall_number_correct
      ,d.overall_performance_band
      ,d.standard_code
      ,d.standard_description
      ,d.standard_percent_correct
      ,act.scale_score
      ,ROW_NUMBER() OVER(
         PARTITION BY d.academic_year, d.administration_round, d.subject_area, d.student_number
           ORDER BY d.student_number) AS rn_dupe
FROM long_data d
LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
  ON d.academic_year = act.academic_year
 AND d.administration_round = act.administration_round
 AND d.subject_area = act.subject
 AND d.overall_number_correct = act.raw_score

UNION ALL

SELECT student_number
      ,academic_year
      ,administration_round
      ,administered_at
      ,'Composite' AS subject_area
      ,NULL AS overall_number_correct
      ,NULL AS overall_performance_band
      ,NULL AS standard_code
      ,NULL AS standard_description
      ,NULL AS standard_percent_correct
      ,CASE WHEN COUNT(student_number) = 4 THEN ROUND(AVG(scale_score),0) END AS scale_score
      ,rn_dupe
FROM
    (
     SELECT d.student_number
           ,d.academic_year
           ,d.administration_round      
           ,d.administered_at
           ,d.subject_area      
           ,CONVERT(FLOAT,act.scale_score) AS scale_score
           ,ROW_NUMBER() OVER(
              PARTITION BY d.academic_year, d.administration_round, d.subject_area, d.student_number
                ORDER BY d.student_number) AS rn_dupe
     FROM long_data d
     LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
       ON d.academic_year = act.academic_year
      AND d.administration_round = act.administration_round
      AND d.subject_area = act.subject
      AND d.overall_number_correct = act.raw_score     
    ) sub
WHERE rn_dupe = 1
GROUP BY student_number
        ,academic_year
        ,administration_round
        ,administered_at        
        ,rn_dupe