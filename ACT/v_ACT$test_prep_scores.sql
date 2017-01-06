USE KIPP_NJ
GO

ALTER VIEW ACT$test_prep_scores AS

WITH long_data AS (
  SELECT a.assessment_id
        ,a.subject_area
        ,a.academic_year
        ,a.administered_at
        
        ,ovr.local_student_id AS student_number        
        ,ovr.performance_band_level AS overall_performance_band                      
        ,CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) AS overall_number_correct

        ,co.grade_level
        ,d.time_per_name
        ,d.alt_name AS administration_round
        ,ROW_NUMBER() OVER(
           PARTITION BY ovr.local_student_id, a.academic_year, a.subject_area, d.time_per_name
             ORDER BY CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) DESC) AS rn_highscore
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    ON a.assessment_id = ovr.assessment_id
  LEFT OUTER JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON ovr.local_student_id = co.STUDENT_NUMBER
   AND a.academic_year = co.year
   AND co.rn = 1
  LEFT OUTER JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON a.administered_at BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'ACT'
  WHERE a.scope = 'ACT Prep'
 )

,overall_scores AS (
  SELECT d.student_number
        ,d.academic_year
        ,d.assessment_id
        ,d.time_per_name
        ,d.administration_round      
        ,d.administered_at
        ,d.subject_area
        ,d.overall_number_correct
        ,d.overall_performance_band
        ,act.scale_score
  FROM long_data d
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
    ON d.academic_year = act.academic_year
   AND d.grade_level = act.grade_level
   AND d.time_per_name = act.administration_round
   AND d.subject_area = act.subject
   AND d.overall_number_correct = act.raw_score
  WHERE d.rn_highscore = 1

  UNION ALL

  SELECT student_number
        ,academic_year
        ,NULL AS assessment_id
        ,time_per_name
        ,administration_round
        ,MIN(administered_at) AS administered_at
        ,'Composite' AS subject_area
        ,NULL AS overall_number_correct
        ,NULL AS overall_performance_band            
        ,CASE WHEN COUNT(scale_score) = 4 THEN ROUND(AVG(scale_score),0) END AS scale_score
  FROM
      (
       SELECT d.student_number           
             ,d.academic_year
             ,d.assessment_id
             ,d.time_per_name
             ,d.administration_round                   
             ,d.administered_at
             ,d.subject_area   
             ,CONVERT(FLOAT,act.scale_score) AS scale_score           
       FROM long_data d
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
         ON d.academic_year = act.academic_year
        AND d.grade_level = act.grade_level
        AND d.time_per_name = act.administration_round
        AND d.subject_area = act.subject
        AND d.overall_number_correct = act.raw_score     
       WHERE d.rn_highscore = 1
      ) sub
  GROUP BY student_number
          ,academic_year
          ,administration_round       
          ,time_per_name 
 )

SELECT sub.student_number
      ,sub.academic_year
      ,sub.assessment_id
      ,sub.time_per_name
      ,sub.administration_round      
      ,sub.administered_at
      ,sub.subject_area
      ,sub.overall_number_correct
      ,sub.overall_performance_band
      ,sub.scale_score
      ,sub.prev_scale_score
      ,sub.pretest_scale_score
      ,sub.growth_from_pretest
      
      ,s.custom_code AS standard_code
      ,s.description AS standard_description
      ,CONVERT(FLOAT,std.percent_correct) AS standard_percent_correct
      
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.administration_round, sub.subject_area
           ORDER BY sub.student_number) AS rn_dupe
      ,ROW_NUMBER() OVER(
         PARTITION BY sub.student_number, sub.academic_year, sub.subject_area
           ORDER BY sub.time_per_name DESC) AS rn_curr
FROM
    (
     SELECT student_number
           ,academic_year
           ,assessment_id
           ,time_per_name
           ,administration_round
           ,administered_at
           ,subject_area
           ,overall_number_correct
           ,overall_performance_band
           ,scale_score
           ,LAG(scale_score) OVER(PARTITION BY student_number, academic_year, subject_area ORDER BY administered_at) AS prev_scale_score
           ,MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(PARTITION BY student_number, academic_year, subject_area) AS pretest_scale_score
           ,CASE WHEN administration_round = 'Pre-Test' THEN NULL ELSE scale_score END 
              - MAX(CASE WHEN administration_round = 'Pre-Test' THEN scale_score END) OVER(PARTITION BY student_number, academic_year, subject_area) AS growth_from_pretest
     FROM overall_scores
    ) sub
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$agg_student_responses_standard std WITH(NOLOCK)
  ON sub.assessment_id = std.assessment_id
 AND sub.student_number = std.local_student_id
LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$standards#static s WITH(NOLOCK)
  ON std.standard_id = s.standard_id  