USE KIPP_NJ
GO

ALTER VIEW LEXIA$goals AS 

WITH grade_level_goals AS (
  SELECT CASE
          WHEN grade_level_material = 'PreK' THEN -1
          ELSE CONVERT(INT,grade_level_material)
         END AS grade_level
        ,SUM(units) AS units_goal
  FROM KIPP_NJ..AUTOLOAD$GDOCS_LEXIA_goals_by_level WITH(NOLOCK)
  GROUP BY grade_level_material 
 )

,min_level AS(
  SELECT username
        ,grade_level        
        ,academic_year
        ,MIN(level_number) AS min_level_number        
        ,MAX(level_number) AS max_level_number
        ,MAX(lexia_grade_level) AS max_lexia_grade_level
  FROM
      (
       SELECT DISTINCT 
              username                  
             ,KIPP_NJ.dbo.fn_DateToSY(activity_timestamp) AS academic_year
             ,CASE WHEN LEFT(grade_label,1) = 'K' THEN 0 ELSE CONVERT(INT,LEFT(grade_label,1)) END AS grade_level
             ,CASE
               WHEN grade_level_material IN ('Pre K') THEN -1
               WHEN grade_level_material IN ('Beg K','Beg to Mid K','End K','Mid to End K') THEN 0
               WHEN grade_level_material IN ('Beg 1st','Beg to Mid 1st','End 1st','Mid to End 1st') THEN 1
               WHEN grade_level_material IN ('Beg 2nd','End 2nd','Mid 2nd') THEN 2
               WHEN grade_level_material IN ('Beg to Mid 3rd','Mid to End 3rd') THEN 3
               WHEN grade_level_material IN ('Beg to Mid 4th','Mid to End 4th') THEN 4
               WHEN grade_level_material IN ('Beg to Mid 5th','Mid to End 5th') THEN 5
              END AS lexia_grade_level
             ,CONVERT(INT,REPLACE(levelname,'Level ','')) AS level_number
       FROM KIPP_NJ..AUTOLOAD$LEXIA_detail WITH(NOLOCK)
      ) sub  
  GROUP BY username
          ,academic_year
          , grade_level
 )

,other_goals AS (
  SELECT sub.username            
        ,sub.academic_year                
        ,CASE WHEN goals.grade_level_material = 'PreK' THEN -1 ELSE CONVERT(INT,goals.grade_level_material) END AS lexia_grade_level
        ,sub.min_level_number
        ,sub.max_level_number
        ,goals.level        
        ,SUM(goals.units) AS units_goal
  FROM min_level sub
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LEXIA_goals_by_level goals WITH(NOLOCK)
    ON sub.min_level_number <= goals.level
   AND CASE
        WHEN sub.grade_level >= sub.max_lexia_grade_level THEN sub.grade_level
        WHEN sub.grade_level < sub.max_lexia_grade_level THEN sub.max_lexia_grade_level
       END >= CASE WHEN goals.grade_level_material = 'PreK' THEN -1 ELSE CONVERT(INT,goals.grade_level_material) END       
  GROUP BY sub.username
          ,sub.academic_year          
          ,sub.grade_level
          ,goals.level
          ,goals.grade_level_material
          ,sub.min_level_number
          ,sub.max_level_number
 )

SELECT STUDENT_NUMBER
      ,academic_year
      ,SUM(units_goal) AS target_units
      ,SUM(CASE WHEN grade_level = lexia_grade_level THEN units_goal END) AS grade_level_target
      ,SUM(CASE WHEN grade_level != lexia_grade_level THEN units_goal ELSE 0 END) AS other_level_target     
FROM
    (
     SELECT s.STUDENT_NUMBER
           ,s.year AS academic_year
           ,s.GRADE_LEVEL
           ,s.GRADE_LEVEL AS lexia_grade_level
           ,g.units_goal
     FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)
     JOIN grade_level_goals g
       ON s.GRADE_LEVEL = g.grade_level
     WHERE s.year >= 2015

     UNION ALL

     SELECT s.STUDENT_NUMBER
           ,s.year AS academic_year
           ,s.GRADE_LEVEL
           ,og.lexia_grade_level
           ,og.units_goal
     FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)      
     JOIN other_goals og
       ON s.STUDENT_WEB_ID = og.username
      AND s.year = og.academic_year
      AND s.GRADE_LEVEL != og.lexia_grade_level
     WHERE s.year >= 2015     
    ) sub
GROUP BY STUDENT_NUMBER
        ,academic_year