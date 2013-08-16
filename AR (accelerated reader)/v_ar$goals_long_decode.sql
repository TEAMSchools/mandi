USE KIPP_NJ
GO

ALTER VIEW AR$goals_long_decode AS
SELECT CAST(sub_1.student_number AS NVARCHAR) AS student_number
      ,sub_1.schoolid
      ,CASE
         WHEN ar_specific.id IS NULL THEN sub_1.words_goal
         ELSE ar_specific.words_goal
       END AS words_goal
      ,CASE
         WHEN ar_specific.id IS NULL THEN sub_1.points_goal
         ELSE ar_specific.points_goal
       END AS points_goal
      ,sub_1.yearid
      ,sub_1.time_period_name
      ,CASE
         WHEN ar_specific.id IS NULL THEN sub_1.time_period_start
         ELSE ar_specific.time_period_start
       END AS time_period_start
      ,CASE
         WHEN ar_specific.id IS NULL THEN sub_1.time_period_end
         ELSE ar_specific.time_period_end
       END AS time_period_end
      ,CASE
         WHEN ar_specific.id IS NULL THEN sub_1.time_period_hierarchy
         ELSE ar_specific.time_period_hierarchy
       END AS time_period_hierarchy
FROM
     (SELECT s.student_number
            ,cohort.schoolid
            ,cohort.year
            ,ar_default.words_goal
            ,ar_default.points_goal
            ,ar_default.yearid
            ,ar_default.time_period_name
            ,ar_default.time_period_start
            ,ar_default.time_period_end
            ,ar_default.time_period_hierarchy
      FROM COHORT$comprehensive_long#static cohort
      JOIN STUDENTS s
        ON cohort.studentid = s.id
       AND cohort.rn = 1
       --AND cohort.year >= 2011
       AND cohort.schoolid != 999999
             
      JOIN AR$goals ar_default
        ON 'Default_Gr' + CAST(cohort.grade_level AS NVARCHAR) = ar_default.student_number
       AND cohort.schoolid = ar_default.schoolid
       AND CAST(((cohort.year - 1990) * 100) AS INT) = ar_default.yearid  
      ) sub_1
LEFT OUTER JOIN AR$goals ar_specific
  ON CAST(sub_1.student_number AS VARCHAR) = ar_specific.student_number
 AND sub_1.schoolid = ar_specific.schoolid
 AND sub_1.yearid = ar_specific.yearid
 AND sub_1.time_period_name = ar_specific.time_period_name
 AND sub_1.time_period_hierarchy = ar_specific.time_period_hierarchy

--union picks up any specific goals where there is NO corresponding default.
UNION
SELECT CAST(student_number AS nvarchar)
      ,schoolid
      ,words_goal
      ,points_goal
      ,yearid
      ,time_period_name
      ,time_period_start
      ,time_period_end
      ,time_period_hierarchy
FROM AR$goals
WHERE student_number NOT LIKE 'Default_%'