USE KIPP_NJ
GO

ALTER VIEW DL$act_scores#extract AS

WITH long_data AS (
  SELECT a.subject_area
        ,a.academic_year                
        ,d.time_per_name AS administration_round
        ,ovr.local_student_id AS student_number
        ,CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) AS overall_number_correct   
        ,ROW_NUMBER() OVER(
           PARTITION BY ovr.local_student_id, a.academic_year, a.subject_area, d.time_per_name
             ORDER BY CONVERT(INT,ROUND(((ovr.percent_correct / 100) * ovr.number_of_questions),0)) DESC) AS rn_highscore
  FROM KIPP_NJ..ILLUMINATE$assessments#static a WITH(NOLOCK)
  JOIN KIPP_NJ..REPORTING$dates d WITH(NOLOCK)
    ON a.academic_year = d.academic_year
   AND a.administered_at BETWEEN d.start_date AND d.end_date
   AND d.identifier = 'ACT'
  JOIN KIPP_NJ..ILLUMINATE$agg_student_responses#static ovr WITH(NOLOCK)
    ON a.assessment_id = ovr.assessment_id
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON a.academic_year = co.year
   AND ovr.local_student_id = co.student_number      
   AND co.rn = 1
  WHERE a.scope = 'ACT Prep'
    AND a.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
 )

,overall_scores AS (
  SELECT d.student_number
        ,d.academic_year        
        ,d.administration_round              
        ,d.subject_area        
        ,act.scale_score        
  FROM long_data d
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
    ON d.academic_year = act.academic_year
   AND d.administration_round = act.administration_round
   AND d.subject_area = act.subject
   AND d.overall_number_correct = act.raw_score
  WHERE d.rn_highscore = 1

  UNION ALL

  SELECT student_number
        ,academic_year        
        ,administration_round        
        ,'Composite' AS subject_area        
        ,CASE WHEN COUNT(student_number) = 4 THEN ROUND(AVG(scale_score),0) END AS scale_score
  FROM
      (
       SELECT d.student_number           
             ,d.academic_year             
             ,d.administration_round                   
             ,d.subject_area      
             ,CONVERT(FLOAT,act.scale_score) AS scale_score           
       FROM long_data d
       LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_ACT_scale_score_key act WITH(NOLOCK)
         ON d.academic_year = act.academic_year
        AND d.administration_round = act.administration_round
        AND d.subject_area = act.subject
        AND d.overall_number_correct = act.raw_score     
       WHERE d.rn_highscore = 1
      ) sub
  GROUP BY student_number
          ,academic_year
          ,administration_round        
 )

SELECT student_number	
      ,academic_year
      ,scale_score_pretest	
      ,scale_score_midyear	
      ,scale_score_posttest
FROM
    (
     SELECT student_number
           ,academic_year      
           ,CONCAT('scale_score_', LOWER(REPLACE(administration_round,'-',''))) AS field
           ,scale_score
     FROM overall_scores
     WHERE subject_area = 'Composite'
    ) sub
PIVOT(
  MAX(scale_score)
  FOR field IN (scale_score_pretest
               ,scale_score_midyear
               ,scale_score_posttest)               
 ) p