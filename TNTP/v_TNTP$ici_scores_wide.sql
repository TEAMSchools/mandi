USE KIPP_NJ
GO

ALTER VIEW TNTP$ici_scores_wide AS

SELECT academic_year
      ,term      
      ,schoolid
      ,[Current Instructional Culture Index] AS instructional_culture_index
      ,[ICI Percentile] AS ici_pctile
      ,CASE WHEN [ICI Percentile] >= .75 THEN 1 ELSE 0 END AS is_ici_top_quartile
      ,[Career Progression Score] AS career_progression_index
      ,[Evaluation Score] AS evaluation_index
      ,[Instructional Planning Score] AS instructional_planning_index
      ,[Leadership Score] AS leadership_index
      ,[Learning Environment Score] AS learning_environment_index
      ,[Observation and Feedback Score] AS observation_feedback_index
      ,[Parent and Community Engagement Score] AS parent_community_index
      ,[Peer Culture Score] AS peer_culture_index
      ,[Professional Development Score] AS professional_development_index
      ,[School Operations Score] AS school_ops_index
      ,[Student Growth Measures Score] AS student_growth_index
      ,[Workload Score] AS workload_index
      ,ROW_NUMBER() OVER(
         PARTITION BY schoolid, academic_year
           ORDER BY term ASC) AS rn
FROM
    (
     SELECT academic_year
           ,term           
           ,schoolid
           ,field
           ,CONVERT(FLOAT,value) AS value
     FROM KIPP_NJ..TNTP$insight_survey_data_long WITH(NOLOCK)
     WHERE ISNUMERIC(value) = 1     
    ) sub
PIVOT(
  AVG(value) /* Life was split into Upper and Lower it's 1st year */
  FOR field IN ([Career Progression Score]
               ,[Current Instructional Culture Index]
               ,[Evaluation Score]
               ,[ICI Percentile]
               ,[Instructional Planning Score]
               ,[Leadership Score]
               ,[Learning Environment Score]
               ,[Observation and Feedback Score]
               ,[Parent and Community Engagement Score]
               ,[Peer Culture Score]
               ,[Professional Development Score]
               ,[School Operations Score]
               ,[Student Growth Measures Score]
               ,[Workload Score])
 ) p
WHERE schoolid IS NOT NULL