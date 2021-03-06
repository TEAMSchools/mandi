USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_scores_long#ES AS

WITH raw_data AS (
  SELECT sub.repository_id        
        ,sub.title        
        ,repo.student_id AS student_number                        
        ,repo.repository_row_id        
        ,sub.label
        ,repo.value
  FROM
      (
       SELECT a.repository_id             
             ,a.title
             ,fields.label
             ,fields.name
       FROM KIPP_NJ..ILLUMINATE$repositories#static a WITH(NOLOCK)         
       JOIN KIPP_NJ..ILLUMINATE$repository_fields#static fields WITH(NOLOCK)
         ON a.repository_id = fields.repository_id            
       WHERE a.scope = 'Interim Assessment'
         AND a.subject_area = 'Writing'
         AND a.repository_id IN (SELECT s.repository_id FROM KIPP_NJ..ILLUMINATE$repositories_sites#static s WITH(NOLOCK) WHERE s.GRADE_LEVEL <= 4)
      ) sub
  LEFT OUTER JOIN KIPP_NJ..ILLUMINATE$repository_data repo WITH(NOLOCK)
      ON sub.repository_id = repo.repository_id
     AND repo.field = sub.name      
 )

,test_metadata AS (
  SELECT student_number
        ,repository_row_id
        ,repository_id
        ,title
        ,KIPP_NJ.dbo.fn_DateToSY(date_administered) AS academic_year
        ,date_administered        
        ,assmt_notes
        ,writing_type
        ,total_points
        ,total_prof
  FROM
      (
       SELECT student_number             
             ,repository_id
             ,title
             ,repository_row_id             
             ,COALESCE([Date of Administration],[Date Administered]) AS date_administered
             ,[Anecdotal Notes] AS assmt_notes
             ,[Writing Type] AS writing_type
             ,[Total Points] AS total_points
             ,STUFF([Total Proficiency], 3, 0, '= ') AS total_prof
       FROM raw_data rw WITH(NOLOCK)       
       PIVOT(
         MAX(value)
         FOR label IN ([Date of Administration],[Date Administered],[Anecdotal Notes],[Writing Type],[Total Points],[Total Proficiency])
        ) p
      ) sub  
 )

SELECT student_number
      ,repository_id
      ,title
      ,repository_row_id
      ,KIPP_NJ.dbo.fn_DateToSY(date_administered) AS academic_year
      ,term      
      ,date_administered
      ,writing_type
      ,total_points
      ,total_prof
      ,assmt_notes
      ,writing_obj
      ,score
      ,proficiency
      ,prof_numeric
      ,'writing_obj_' + CONVERT(VARCHAR,
                          ROW_NUMBER() OVER(
                            PARTITION BY student_number, repository_row_id
                              ORDER BY writing_obj ASC)) AS pivot_hash_obj
      ,'writing_prof_' + CONVERT(VARCHAR,
                          ROW_NUMBER() OVER(
                            PARTITION BY student_number, repository_row_id
                              ORDER BY writing_obj ASC)) AS pivot_hash_prof
FROM
    (
     SELECT student_number
           ,repository_id
           ,title
           ,repository_row_id
           ,writing_obj
           ,MAX(term) AS term
           ,MAX(date_administered) AS date_administered
           ,MAX(writing_type) AS writing_type
           ,MAX(total_points) AS total_points
           ,MAX(total_prof) AS total_prof
           ,MAX(assmt_notes) AS assmt_notes           
           ,MAX(score) AS score
           ,MAX(proficiency) AS proficiency
           ,MAX(prof_numeric) AS prof_numeric      
     FROM
         (
          SELECT student_number      
                ,repository_id
                ,title
                ,repository_row_id
                ,term
                ,date_administered
                ,writing_type      
                ,total_points
                ,total_prof
                ,assmt_notes
                ,writing_obj
                ,[score]
                ,[proficiency]
                ,numeric_score AS prof_numeric

          FROM 
              (
               SELECT md.student_number                 
                     ,md.repository_id
                     ,md.title
                     ,md.repository_row_id
                     ,CASE WHEN dt.alt_name = 'Capstone' THEN 'T3' ELSE dt.alt_name END AS term
                     ,md.date_administered
                     ,md.writing_type
                     ,md.assmt_notes           
                     ,md.total_points
                     ,md.total_prof
                     ,scores.label
                     ,LTRIM(RTRIM(LEFT(
                       scores.label, CHARINDEX(CASE 
                                                WHEN scores.label LIKE '%score' THEN 'Score' 
                                                WHEN scores.label LIKE '%points' THEN 'points' 
                                                WHEN scores.label LIKE '%proficiency'THEN 'Proficiency' 
                                                ELSE NULL 
                                               END, scores.label) - 1)
                      )) AS writing_obj
                     ,CASE 
                       WHEN scores.label LIKE '%score' THEN 'Score' 
                       WHEN scores.label LIKE '%points' THEN 'Score' 
                       WHEN scores.label LIKE '%proficiency'THEN 'Proficiency' 
                       ELSE NULL 
                      END AS measure                     
                     ,scores.value -- T1, everyone had a number and words for the score, now it's inconsistent, so I had to take the = signs out
                     --,CASE WHEN  scores.label LIKE '%proficiency%' THEN STUFF(scores.value, 3, 0, '= ') ELSE scores.value END AS value
                     ,CASE WHEN ISNUMERIC(LEFT(scores.value, 1)) = 1 THEN LEFT(scores.value, 1) ELSE NULL END AS numeric_score
               FROM test_metadata md WITH(NOLOCK)
               LEFT OUTER JOIN REPORTING$dates dt WITH(NOLOCK)
                 ON md.date_administered >= dt.start_date
                AND md.date_administered <= dt.end_date
                AND md.academic_year = dt.academic_year
                AND dt.identifier = 'RT'
                AND dt.schoolid = 73254   
               JOIN raw_data scores WITH(NOLOCK)
                 ON md.student_number = scores.student_number
                AND md.repository_row_id = scores.repository_row_id
                AND scores.label NOT IN ('Date of Administration','Anecdotal Notes','Writing Type','Total Points','Total Proficiency','Date Administered')               
              ) sub
          PIVOT(
            MAX(value)
            FOR measure IN ([score], [proficiency])
           ) p
         ) sub
     GROUP BY student_number
             ,repository_id
             ,title
             ,repository_row_id
             ,writing_obj
    ) sub