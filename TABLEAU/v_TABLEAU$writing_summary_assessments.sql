USE KIPP_NJ
GO

ALTER VIEW TABLEAU$writing_summary_assessments AS

WITH assessments AS (
  SELECT a.repository_id
        ,a.schoolid
        ,a.grade_level
        ,a.title
        ,a.scope
        ,a.subject      
        ,a.date_administered
        ,dbo.fn_DateToSY(a.date_administered) AS academic_year
        ,f.label AS field_label
        ,f.name AS field_name        
  FROM ILLUMINATE$summary_assessments#static a WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields f WITH(NOLOCK)
    ON a.repository_id = f.repository_id      
  WHERE a.title IN ('Writing - Interim - TEAM MS', 'English OE - Quarterly Assessments')
 )

,results_wide AS (
  SELECT *
  FROM
      (
       SELECT s.SCHOOLID
             ,s.grade_level      
             ,s.id AS studentid
             ,s.STUDENT_NUMBER
             ,s.lastfirst      
             ,s.team
             ,a.repository_id
             ,a.title
             --,a.scope
             --,a.subject                            
             ,a.field_label
             ,res.repository_row_id
             ,res.value AS field_value           
       FROM STUDENTS s WITH(NOLOCK)        
       JOIN assessments a WITH(NOLOCK)
         ON s.schoolid = a.SCHOOLID
        AND s.grade_level = a.GRADE_LEVEL 
       JOIN ILLUMINATE$summary_assessment_results_long#static res WITH(NOLOCK)
         ON s.student_number = res.student_id
        AND a.repository_id = res.repository_id
        AND a.field_name = res.field     
      ) sub

  PIVOT(
    MAX(field_value)
    FOR field_label IN ([Year]
                       ,[Interim]
                       ,[Quarter]
                       ,[Overall]
                       ,[Organization]
                       ,[Elaboration]
                       ,[Conventions]
                       ,[Capitalization]
                       ,[End Punctuation]
                       ,[Prompt 1 - Overall]
                       ,[Prompt 1 - Quality of Ideas]
                       ,[Prompt 1 - Context of Evidence]
                       ,[Prompt 1 - Choice of Evidence]
                       ,[Prompt 1 - Analysis of Evidence]
                       ,[Prompt 1 - Justification ]
                       ,[Prompt 2 - Overall]
                       ,[Prompt 2 - Quality of Ideas]
                       ,[Prompt 2 - Context of Evidence]
                       ,[Prompt 2 - Choice of Evidence]
                       ,[Prompt 2 - Analysis of Evidence]
                       ,[Prompt 2 - Justification]
                       ,[Prompt 3 - Overall]
                       ,[Prompt 3 - Quality of Ideas]
                       ,[Prompt 3 - Context of Evidence]
                       ,[Prompt 3 - Choice of Evidence]
                       ,[Prompt 3 - Analysis of Evidence]
                       ,[Prompt 3 - Justification]
                       ,[Prompt 4 - Overall]
                       ,[Prompt 4 - Quality of Ideas]
                       ,[Prompt 4 - Context of Evidence]
                       ,[Prompt 4 - Choice of Evidence]
                       ,[Prompt 4 - Analysis of Evidence]
                       ,[Prompt 4 - Justification])
   ) p
 )

,enrollments AS (
  SELECT cc.studentid
        ,c.COURSE_NAME      
        ,dbo.fn_ExprToPeriod(cc.EXPRESSION) AS period
        ,ROW_NUMBER() OVER(
           PARTITION BY cc.studentid
             ORDER BY c.course_number DESC) AS rn
  FROM CC WITH(NOLOCK)
  JOIN COURSES c WITH(NOLOCK)
    ON cc.course_number = c.course_number
   AND c.CREDITTYPE = 'RHET'
  WHERE cc.SCHOOLID = 73253
    AND cc.TERMID >= dbo.fn_Global_Term_Id()
    AND cc.SECTIONID > 0
 )

SELECT w.SCHOOLID
      ,w.GRADE_LEVEL
      ,w.studentid
      ,w.student_number
      ,w.lastfirst
      ,w.team
      ,w.title
      ,w.year
      ,COALESCE(w.Interim, w.Quarter) AS interim
      ,[Overall]
      ,[Organization]
      ,[Elaboration]
      ,[Conventions]
      ,[Capitalization]
      ,[End Punctuation]
      ,[Prompt 1 - Overall]
      ,[Prompt 1 - Quality of Ideas]
      ,[Prompt 1 - Context of Evidence]
      ,[Prompt 1 - Choice of Evidence]
      ,[Prompt 1 - Analysis of Evidence]
      ,[Prompt 1 - Justification ]
      ,[Prompt 2 - Overall]
      ,[Prompt 2 - Quality of Ideas]
      ,[Prompt 2 - Context of Evidence]
      ,[Prompt 2 - Choice of Evidence]
      ,[Prompt 2 - Analysis of Evidence]
      ,[Prompt 2 - Justification]
      ,[Prompt 3 - Overall]
      ,[Prompt 3 - Quality of Ideas]
      ,[Prompt 3 - Context of Evidence]
      ,[Prompt 3 - Choice of Evidence]
      ,[Prompt 3 - Analysis of Evidence]
      ,[Prompt 3 - Justification]
      ,[Prompt 4 - Overall]
      ,[Prompt 4 - Quality of Ideas]
      ,[Prompt 4 - Context of Evidence]
      ,[Prompt 4 - Choice of Evidence]
      ,[Prompt 4 - Analysis of Evidence]
      ,[Prompt 4 - Justification]
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - Overall]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - Overall]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - Overall]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - Overall]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - Overall] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - Overall] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - Overall] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS overall_avg
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - quality of ideas]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - quality of ideas]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - quality of ideas]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - quality of ideas]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - quality of ideas] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS quality_of_ideas_avg
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - context of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - context of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - context of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - context of evidence]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - context of evidence] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS context_of_evidence_avg
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - choice of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - choice of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - choice of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - choice of evidence]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - choice of evidence] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS choice_of_evidence_avg
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - analysis of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - analysis of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - analysis of evidence]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - analysis of evidence]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - analysis of evidence] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS analysis_of_evidence_avg
      ,ROUND(
        (ISNULL(CONVERT(FLOAT,[Prompt 1 - justification]),0) + ISNULL(CONVERT(FLOAT,[Prompt 2 - justification]),0) + ISNULL(CONVERT(FLOAT,[Prompt 3 - justification]),0) + ISNULL(CONVERT(FLOAT,[Prompt 4 - justification]),0))
         /
        (CASE 
          WHEN (CASE WHEN [Prompt 1 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - justification] IS NOT NULL THEN 1 ELSE 0 END) = 0 THEN NULL
          ELSE (CASE WHEN [Prompt 1 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 2 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 3 - justification] IS NOT NULL THEN 1 ELSE 0 END + CASE WHEN [Prompt 4 - justification] IS NOT NULL THEN 1 ELSE 0 END)
         END),1) AS justification_avg
      ,[IA1IA2_Capitalization_growth]
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
      ,[QE3QE4_QualityofIdeas_growth]
      ,[YTD_capitalization_growth]
      ,[YTD_conventions_growth]
      ,[YTD_elaboration_growth]
      ,[YTD_endpunctuation_growth]
      ,[YTD_organization_growth]
      ,[YTD_analysisofevidence_growth]
      ,[YTD_choiceofevidence_growth]
      ,[YTD_contextofevidence_growth]
      ,[YTD_justification_growth]
      ,[YTD_qualityofideas_growth]
      ,[YTD_overall_growth]
      ,cs.SPEDLEP
      ,co.grade_level AS test_grade_level
      ,enr.course_name AS nca_course_name
      ,enr.period AS nca_period
FROM results_wide w WITH(NOLOCK)
LEFT OUTER JOIN ILLUMINATE$writing_growth_wide growth WITH(NOLOCK)
  ON w.student_number = growth.student_number
 AND w.repository_id = growth.repository_id
 AND LEFT(w.year,4) = growth.academic_year
LEFT OUTER JOIN CUSTOM_STUDENTS cs WITH(NOLOCK)
  ON w.studentid = cs.STUDENTID
JOIN COHORT$comprehensive_long#static co WITH(NOLOCK)
  ON w.student_number = co.student_number
 AND LEFT(w.year,4) = co.year
 AND co.rn = 1
LEFT OUTER JOIN enrollments enr WITH(NOLOCK)
  ON w.studentid = enr.STUDENTID
 AND enr.rn = 1