USE KIPP_NJ
GO

ALTER VIEW TABLEAU$lexia_tracker AS 

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
  FROM
      (
       SELECT DISTINCT 
              username                  
             ,KIPP_NJ.dbo.fn_DateToSY(activity_timestamp) AS academic_year
             ,CASE WHEN LEFT(grade_label,1) = 'K' THEN 0 ELSE CONVERT(INT,LEFT(grade_label,1)) END AS grade_level
             ,CONVERT(INT,REPLACE(levelname,'Level ','')) AS level_number
       FROM KIPP_NJ..AUTOLOAD$LEXIA_detail WITH(NOLOCK)     
      ) sub
  GROUP BY username, grade_level, academic_year
 )

,other_goals AS (
  SELECT sub.username            
        ,sub.academic_year
        ,CASE WHEN goals.grade_level_material = 'PreK' THEN -1 ELSE CONVERT(INT,goals.grade_level_material) END AS grade_level      
        ,SUM(goals.units) AS units_goal
  FROM min_level sub
  LEFT OUTER JOIN KIPP_NJ..AUTOLOAD$GDOCS_LEXIA_goals_by_level goals WITH(NOLOCK)
    ON goals.level >= sub.min_level_number   
  GROUP BY sub.username
          ,sub.academic_year
          ,CASE WHEN goals.grade_level_material = 'PreK' THEN -1 ELSE CONVERT(INT,goals.grade_level_material) END
 )

,student_goals AS (
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
             ,og.grade_level AS lexia_grade_level
             ,og.units_goal
       FROM KIPP_NJ..COHORT$identifiers_long#static s WITH(NOLOCK)      
       JOIN other_goals og
         ON s.STUDENT_WEB_ID = og.username
        AND s.GRADE_LEVEL > og.grade_level
       WHERE s.year >= 2015
      ) sub
  GROUP BY STUDENT_NUMBER, academic_year
 )

,prev_week_time AS (
  SELECT username
        ,KIPP_NJ.dbo.fn_DateToSY(datestamp) AS academic_year
        ,datestamp
        ,week_time
        ,ROW_NUMBER() OVER(
          PARTITION BY username, KIPP_NJ.dbo.fn_DateToSY(datestamp)
            ORDER BY datestamp DESC) AS rn
  FROM KIPP_NJ..LEXIA$units_to_target WITH(NOLOCK)
  WHERE DATEPART(WEEKDAY,datestamp) = 1
 )

SELECT co.student_number
      ,co.lastfirst
      ,co.year
      ,co.schoolid
      ,co.grade_level
      ,co.student_web_id
      ,ROW_NUMBER() OVER(
         PARTITION BY co.student_number, co.year
           ORDER BY CONVERT(DATE,lex.activity_timestamp) DESC) AS rn_curr
      
      ,enr.teacher_name
      ,enr.SECTION_NUMBER

      ,g.target_units
      ,g.grade_level_target
      ,g.other_level_target

      ,lex.*
      ,ISNULL(g.target_units,0) - ISNULL(lex.units_to_target,0) AS units_completed
      ,(ISNULL(g.target_units,0) - ISNULL(lex.units_to_target,0)) / g.target_units AS pct_to_target

      ,pw.week_time AS prev_week_time
FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
LEFT OUTER JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  ON co.student_number = enr.student_number
 AND co.year = enr.academic_year
 AND enr.COURSE_NUMBER = 'HR'
 AND CONVERT(DATE,GETDATE()) BETWEEN enr.dateenrolled AND enr.dateleft
JOIN KIPP_NJ..AUTOLOAD$LEXIA_detail lex WITH(NOLOCK)
  ON co.student_web_id = lex.username
 AND co.year = KIPP_NJ.dbo.fn_DateToSY(lex.activity_timestamp)
LEFT OUTER JOIN student_goals g
  ON co.student_number = g.STUDENT_NUMBER
 AND co.year = g.academic_year
LEFT OUTER JOIN prev_week_time pw
  ON co.student_web_id = pw.username
 AND co.year = pw.academic_year
 AND pw.rn = 1
WHERE co.year >= 2015
  AND co.grade_level <= 8
  AND co.rn = 1
  AND co.enroll_status = 0