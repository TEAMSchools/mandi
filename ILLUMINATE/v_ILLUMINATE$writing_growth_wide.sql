USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_growth_wide AS

WITH agg_scores AS (
  SELECT student_number
        ,repository_id        
        ,academic_year
        ,series
        ,strand
        ,term
        ,ROUND(AVG(field_value),1) AS avg_strand_score
  FROM KIPP_NJ..ILLUMINATE$writing_scores_long#static WITH(NOLOCK)
  GROUP BY student_number
          ,repository_id
          ,academic_year
          ,term
          ,series
          ,strand
 )

SELECT student_number
      ,repository_id
      ,academic_year
      ,[IA1IA2_Capitalization_growth]
      ,[IA2IA3_Capitalization_growth]
      ,ISNULL([IA1IA2_Capitalization_growth],0) + ISNULL([IA2IA3_Capitalization_growth],0) AS YTD_capitalization_growth
      ,[IA1IA2_Conventions_growth]
      ,[IA2IA3_Conventions_growth]
      ,ISNULL([IA1IA2_conventions_growth],0) + ISNULL([IA2IA3_conventions_growth],0) AS YTD_conventions_growth
      ,[IA1IA2_Elaboration_growth]
      ,[IA2IA3_Elaboration_growth]
      ,ISNULL([IA1IA2_elaboration_growth],0) + ISNULL([IA2IA3_elaboration_growth],0) AS YTD_elaboration_growth
      ,[IA1IA2_EndPunctuation_growth]
      ,[IA2IA3_EndPunctuation_growth]
      ,ISNULL([IA1IA2_endpunctuation_growth],0) + ISNULL([IA2IA3_endpunctuation_growth],0) AS YTD_endpunctuation_growth
      ,[IA1IA2_Organization_growth]
      ,[IA2IA3_Organization_growth]
      ,ISNULL([IA1IA2_organization_growth],0) + ISNULL([IA2IA3_organization_growth],0) AS YTD_organization_growth
      ,[IA1IA2_Overall_growth]
      ,[IA2IA3_Overall_growth]      
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
      ,COALESCE(
         (ISNULL([IA1IA2_overall_growth],0) + ISNULL([IA2IA3_overall_growth],0)) 
        ,(ISNULL([QE1QE2_overall_growth],0) + ISNULL([QE2QE3_overall_growth],0) + ISNULL([QE3QE4_overall_growth],0))
        ) AS YTD_overall_growth
FROM
    (
     SELECT a1.student_number
           ,a1.repository_id      
           ,a1.academic_year
           ,a1.term + a2.term + '_' + REPLACE(a1.strand, ' ', '') + '_growth' AS growth_period
           ,ROUND(a2.avg_strand_score - a1.avg_strand_score,1) AS avg_strand_growth
     FROM agg_scores a1 WITH(NOLOCK)
     LEFT OUTER JOIN agg_scores a2 WITH(NOLOCK)
       ON a1.student_number = a2.student_number
      AND a1.repository_id = a2.repository_id
      AND a1.academic_year = a2.academic_year
      AND a1.strand = a2.strand
      AND a1.series = (a2.series - 1)
    ) sub
PIVOT(
  MAX(avg_strand_growth)
  FOR growth_period IN ([IA1IA2_Capitalization_growth]
                       ,[IA1IA2_Conventions_growth]
                       ,[IA1IA2_Elaboration_growth]
                       ,[IA1IA2_EndPunctuation_growth]
                       ,[IA1IA2_Organization_growth]
                       ,[IA1IA2_Overall_growth]
                       ,[IA2IA3_Capitalization_growth]
                       ,[IA2IA3_Conventions_growth]
                       ,[IA2IA3_Elaboration_growth]
                       ,[IA2IA3_EndPunctuation_growth]
                       ,[IA2IA3_Organization_growth]
                       ,[IA2IA3_Overall_growth]
                       ,[QE1QE2_AnalysisofEvidence_growth]
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