USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_growth_wide AS

WITH agg_scores AS (
  SELECT student_number
        ,repository_id        
        ,academic_year
        ,CASE WHEN academic_year <= 2014 THEN term ELSE REPLACE(term,'Q','QE') END AS term
        ,series
        ,strand        
        ,ROUND(AVG(field_value),1) AS avg_strand_score
  FROM KIPP_NJ..ILLUMINATE$writing_scores_long#static WITH(NOLOCK)
  GROUP BY student_number
          ,repository_id
          ,academic_year
          ,term          
          ,strand
          ,series
 )

SELECT student_number
      ,repository_id
      ,academic_year
      ,[QE1QE2_AnalysisofEvidence_growth]
      ,[QE2QE3_AnalysisofEvidence_growth]
      ,[QE3QE4_AnalysisofEvidence_growth]
      ,ISNULL([QE1QE2_AnalysisofEvidence_growth],0) + ISNULL([QE2QE3_AnalysisofEvidence_growth],0) + ISNULL([QE3QE4_AnalysisofEvidence_growth],0) AS YTD_analysisofevidence_growth
      ,[QE1QE2_ChoiceofEvidence_growth]
      ,[QE2QE3_ChoiceofEvidence_growth]
      ,[QE3QE4_ChoiceofEvidence_growth]
      ,ISNULL([QE1QE2_choiceofEvidence_growth],0) + ISNULL([QE2QE3_choiceofEvidence_growth],0) + ISNULL([QE3QE4_choiceofEvidence_growth],0) AS YTD_choiceofevidence_growth
      ,[QE1QE2_ContextofEvidence_growth]
      ,[QE2QE3_ContextofEvidence_growth]
      ,[QE3QE4_ContextofEvidence_growth]
      ,ISNULL([QE1QE2_contextofEvidence_growth],0) + ISNULL([QE2QE3_contextofEvidence_growth],0) + ISNULL([QE3QE4_contextofEvidence_growth],0) AS YTD_contextofevidence_growth
      ,[QE1QE2_Justification_growth]
      ,[QE2QE3_Justification_growth]
      ,[QE3QE4_Justification_growth]
      ,ISNULL([QE1QE2_justification_growth],0) + ISNULL([QE2QE3_justification_growth],0) + ISNULL([QE3QE4_justification_growth],0) AS YTD_justification_growth
      ,[QE1QE2_QualityofIdeas_growth]
      ,[QE2QE3_QualityofIdeas_growth]
      ,[QE3QE4_QualityofIdeas_growth]
      ,ISNULL([QE1QE2_qualityofideas_growth],0) + ISNULL([QE2QE3_qualityofideas_growth],0) + ISNULL([QE3QE4_qualityofideas_growth],0) AS YTD_qualityofideas_growth
      ,[QE1QE2_Overall_growth]
      ,[QE2QE3_Overall_growth]
      ,[QE3QE4_Overall_growth]
      ,(ISNULL([QE1QE2_overall_growth],0) + ISNULL([QE2QE3_overall_growth],0) + ISNULL([QE3QE4_overall_growth],0)) AS YTD_overall_growth
      ,ROW_NUMBER() OVER(
        PARTITION BY student_number, academic_year
          ORDER BY student_number) AS rn
FROM
    (
     SELECT a1.student_number
           ,a1.repository_id      
           ,a1.academic_year
           ,CONCAT(
               a1.term
              ,a2.term, '_'
              ,REPLACE(a1.strand,' ',''), '_growth'
             ) AS growth_period
           ,ROUND(a2.avg_strand_score - a1.avg_strand_score,1) AS avg_strand_growth
     FROM agg_scores a1 WITH(NOLOCK)
     JOIN agg_scores a2 WITH(NOLOCK)
       ON a1.student_number = a2.student_number      
      AND a1.academic_year = a2.academic_year
      AND a1.strand = a2.strand
      AND a1.series = (a2.series - 1)
    ) sub
PIVOT(
  MAX(avg_strand_growth)
  FOR growth_period IN ([QE1QE2_AnalysisofEvidence_growth]
                       ,[QE1QE2_ChoiceofEvidence_growth]
                       ,[QE1QE2_ContextofEvidence_growth]
                       ,[QE1QE2_Justification_growth]
                       ,[QE1QE2_Overall_growth]
                       ,[QE1QE2_QualityofIdeas_growth]
                       ,[QE2QE3_AnalysisofEvidence_growth]
                       ,[QE2QE3_ChoiceofEvidence_growth]
                       ,[QE2QE3_ContextofEvidence_growth]
                       ,[QE2QE3_Justification_growth]
                       ,[QE2QE3_Overall_growth]
                       ,[QE2QE3_QualityofIdeas_growth]
                       ,[QE3QE4_AnalysisofEvidence_growth]
                       ,[QE3QE4_ChoiceofEvidence_growth]
                       ,[QE3QE4_ContextofEvidence_growth]
                       ,[QE3QE4_Justification_growth]
                       ,[QE3QE4_Overall_growth]
                       ,[QE3QE4_QualityofIdeas_growth])
 ) p