USE KIPP_NJ
GO

ALTER PROCEDURE sp_AR$goals#MERGE AS

MERGE AR$goals AS TARGET
USING (
       SELECT student_number
             ,schoolid
             ,words_goal
             ,points_goal
             ,yearid
             ,time_period_name
             ,time_period_start
             ,time_period_end
             ,time_period_hierarchy
             ,academic_year
       FROM KIPP_NJ..AR$goals_staging#static WITH(NOLOCK)
       WHERE rn = 1
      ) AS SOURCE  
  (student_number
  ,schoolid
  ,words_goal
  ,points_goal
  ,yearid
  ,time_period_name
  ,time_period_start
  ,time_period_end
  ,time_period_hierarchy
  ,academic_year)
 ON TARGET.student_number = SOURCE.student_number
AND TARGET.academic_year = SOURCE.academic_year
AND TARGET.time_period_name = SOURCE.time_period_name
WHEN MATCHED THEN 
  UPDATE  
    SET TARGET.words_goal = SOURCE.words_goal
       ,TARGET.points_goal = SOURCE.points_goal     
       ,TARGET.time_period_start = SOURCE.time_period_start
       ,TARGET.time_period_end = SOURCE.time_period_end
       ,TARGET.time_period_hierarchy = SOURCE.time_period_hierarchy
       ,TARGET.yearid = SOURCE.yearid
WHEN NOT MATCHED THEN 
  INSERT
    (student_number
    ,schoolid
    ,words_goal
    ,points_goal
    ,yearid
    ,time_period_name
    ,time_period_start
    ,time_period_end
    ,time_period_hierarchy
    ,academic_year)
  VALUES 
    (SOURCE.student_number
    ,SOURCE.schoolid
    ,SOURCE.words_goal
    ,SOURCE.points_goal
    ,SOURCE.yearid
    ,SOURCE.time_period_name
    ,SOURCE.time_period_start
    ,SOURCE.time_period_end
    ,SOURCE.time_period_hierarchy
    ,SOURCE.academic_year);