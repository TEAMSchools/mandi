USE KIPP_NJ
GO

ALTER PROCEDURE sp_AR$goals#MERGE AS

MERGE AR$goals AS TARGET
USING (
       SELECT CONVERT(VARCHAR,student_number) AS student_number
             ,schoolid
             ,words_goal
             ,points_goal
             ,yearid
             ,time_period_name
             ,time_period_start
             ,time_period_end
             ,time_period_hierarchy
       FROM KIPP_NJ..AR$goals_staging
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
  ,time_period_hierarchy)
 ON target.student_number = source.student_number
AND target.yearid = source.yearid
AND target.time_period_name = source.time_period_name

WHEN MATCHED THEN UPDATE  
  SET target.words_goal = source.words_goal
     ,target.points_goal = source.points_goal     
     ,target.time_period_start = source.time_period_start
     ,target.time_period_end = source.time_period_end
     ,target.time_period_hierarchy = source.time_period_hierarchy

WHEN NOT MATCHED THEN INSERT
  (student_number
  ,schoolid
  ,words_goal
  ,points_goal
  ,yearid
  ,time_period_name
  ,time_period_start
  ,time_period_end
  ,time_period_hierarchy)
VALUES (source.student_number
       ,source.schoolid
       ,source.words_goal
       ,source.points_goal
       ,source.yearid
       ,source.time_period_name
       ,source.time_period_start
       ,source.time_period_end
       ,source.time_period_hierarchy);