USE KIPP_NJ
GO

ALTER VIEW LIT$step_headline_long AS
SELECT step.*      
FROM OPENQUERY(PS_TEAM, '
     SELECT s.id AS studentid                                    
           ,s.lastfirst
           ,s.student_number
           ,scores.user_defined_date AS date_taken
           ,scores.user_defined_text AS step_level
           ,scores.foreignkey_alpha AS testid
           ,scores.user_defined_text2 AS status
           ,CASE
              WHEN scores.user_defined_text IN (''Pre'', ''Pre DNA'', ''PreDNA'') THEN 0
              ELSE TO_NUMBER(scores.user_defined_text)
            END AS step_level_numeric
     FROM virtualtablesdata3 scores
     JOIN students s ON s.id = scores.foreignKey 
     WHERE scores.related_to_table = ''readingScores'' 
       AND user_defined_text IS NOT NULL
       AND foreignkey_alpha >= 3274
     ORDER BY scores.schoolid
             ,s.grade_level
             ,s.team
             ,s.lastfirst
             ,scores.user_defined_date DESC
') step