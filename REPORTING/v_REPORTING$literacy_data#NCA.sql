USE KIPP_NJ
GO

ALTER VIEW REPORTING$literacy_data#NCA AS
WITH cur_term AS
    (SELECT schoolid
           ,time_per_name
           ,CASE
              WHEN time_per_name = 'Reporting Term 1' THEN 'RT1'
              WHEN time_per_name = 'Reporting Term 2' THEN 'RT2'
              WHEN time_per_name = 'Reporting Term 3' THEN 'RT3'
              WHEN time_per_name = 'Reporting Term 4' THEN 'RT4'
            END AS cur_term_abbrev
     FROM KIPP_NJ..REPORTING$dates rd
     WHERE CAST(start_date AS date) <= GETDATE()
       AND CAST(end_date AS date) >= GETDATE()
       AND (identifier = 'HEX' OR (school_level = 'HS' AND identifier = 'RT_IR'))
     )
  ,ar_stats AS
   (SELECT cohort.lastfirst
          ,SUBSTRING(s.first_name, 1, 1) + '. ' + s.last_name AS stu_name
          ,ar.*
    FROM KIPP_NJ..COHORT$comprehensive_long#static cohort
    JOIN KIPP_NJ..AR$progress_to_goals_long#static ar
      ON cohort.studentid = ar.studentid
     AND cohort.year = 2013
     AND cohort.rn = 1
     AND ar.yearid = dbo.fn_Global_Term_Id()
    JOIN KIPP_NJ..STUDENTS s
      ON cohort.studentid = s.id
     AND s.SCHOOLID = 73253
     AND s.ENROLL_STATUS = 0
    JOIN KIPP_NJ..SCHOOLS sch
      ON cohort.schoolid = sch.school_number
    )
   ,enr AS
      (SELECT cc.termid AS termid
             ,cc.studentid
             ,SUBSTRING(s.first_name, 1, 1) + '. ' + s.last_name AS stu_name
             ,sections.id AS sectionid
             ,sections.section_number
             ,teachers.first_name + ' ' + teachers.last_name AS teacher
             ,courses.course_number
             ,courses.course_name
             ,s.grade_level
             ,sch.abbreviation AS school
       FROM KIPP_NJ..CC
       JOIN KIPP_NJ..SECTIONS
         ON cc.sectionid = sections.id
        AND cc.termid >= dbo.fn_Global_Term_Id()
       JOIN KIPP_NJ..TEACHERS
         ON sections.teacher = teachers.id
       JOIN KIPP_NJ..COURSES
         ON sections.course_number = courses.course_number
        AND courses.credittype LIKE '%ENG%'
       JOIN KIPP_NJ..STUDENTS s
         ON cc.studentid = s.id
        AND s.enroll_status = 0
       JOIN KIPP_NJ..SCHOOLS sch
         ON s.schoolid = sch.school_number
       WHERE cc.dateenrolled <= GETDATE()
         AND cc.dateleft >= GETDATE()
      )
     ,base_enr AS (
      SELECT c.studentid
            ,s.lastfirst AS sort_name
            ,s.FIRST_NAME + ' ' + s.last_name AS stu_name
            ,c.GRADE_LEVEL AS grade
      FROM KIPP_NJ..COHORT$comprehensive_long#static c
      JOIN KIPP_NJ..STUDENTS s
        ON s.id = c.studentid
       AND s.enroll_status = 0
      WHERE year = 2013
        AND c.schoolid = 73253
        AND c.rn = 1
      )
     ,lexile AS
      (SELECT map.ps_studentid
             ,map.teststartdate
             ,map.testritscore
             ,map.rittoreadingscore
             ,ROW_NUMBER() OVER
                (PARTITION BY map.ps_studentid
                             ,map.map_year_academic
                             ,map.measurementscale
                 ORDER BY map.teststartdate DESC) AS rn_recent
             ,ROW_NUMBER() OVER
                (PARTITION BY map.ps_studentid
                             ,map.map_year_academic
                             ,map.measurementscale
                 ORDER BY map.teststartdate ASC) AS rn_base
       FROM KIPP_NJ..MAP$comprehensive#identifiers map
       WHERE map.map_year_academic = 2013
         AND map.measurementscale = 'Reading'
         AND map.rn = 1
       )
SELECT TOP 10000000000 base_enr.stu_name
      ,base_enr.grade

      ,'ENG ENR ->' AS '_'
      ,enr.course_number + '|' + enr.section_number AS eng_enr
      ,enr.teacher

      ,lexile_base.rittoreadingscore AS base_lexile
      ,lexile_cur.rittoreadingscore AS cur_lexile
 
      ,'YEAR AR STATS ->' AS '__'
      ,ar_stats_yr.points AS points_year
      ,ar_stats_yr.points_goal AS goal_year
      ,ar_stats_yr.mastery AS mastery_year
      ,ar_stats_yr.avg_lexile AS avg_lexile_year
      ,ar_stats_yr.rank_points_overall_in_school AS rank_in_sch_year
      ,ar_stats_yr.rank_points_grade_in_school AS rank_in_gr_year
      ,ar_stats_yr.rank_points_overall_in_network AS rank_in_network_year
   
      ,'CUR TERM STATS ->' AS '___'
      ,ar_stats_cur.points AS points_cur
      ,ar_stats_cur.points_goal AS goal_cur
      ,ar_stats_cur.stu_status_points
      ,CAST(ROUND(ar_stats_cur.ontrack_points, 1) AS FLOAT) AS ontrack_points
      ,CAST(ROUND(ar_stats_cur.points_needed, 1) AS FLOAT) AS points_needed
      ,ar_stats_cur.mastery AS mastery_cur
      ,ar_stats_cur.avg_lexile AS av_lexile_cur
      ,ar_stats_cur.rank_points_overall_in_school AS rank_in_sch_cur
      ,ar_stats_cur.rank_points_grade_in_school AS rank_in_gr_cur

      ,'LAST BOOK ->' AS '____'
      ,DATEDIFF(day, ar_stats_yr.last_book_date, GETDATE()) - 1 AS days_ago
      ,ar_stats_yr.last_book
FROM base_enr
LEFT OUTER JOIN enr
  ON base_enr.studentid = enr.studentid
LEFT OUTER JOIN lexile lexile_base
  ON base_enr.studentid = lexile_base.ps_studentid
 AND lexile_base.rn_base = 1
LEFT OUTER JOIN lexile lexile_cur
  ON base_enr.studentid = lexile_cur.ps_studentid
 AND lexile_cur.rn_recent = 1
LEFT OUTER JOIN ar_stats ar_stats_yr
  ON base_enr.studentid = ar_stats_yr.studentid
 AND ar_stats_yr.time_hierarchy = 1
LEFT OUTER JOIN cur_term
  ON cur_term.schoolid = 73253
 AND 1=1
LEFT OUTER JOIN ar_stats ar_stats_cur
  ON base_enr.studentid = ar_stats_cur.studentid
 AND ar_stats_cur.time_hierarchy = 2
 AND ar_stats_cur.time_period_name = cur_term.cur_term_abbrev
ORDER BY enr.teacher
        ,enr.course_number + '|' + enr.section_number 
        ,base_enr.sort_name