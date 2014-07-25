USE KIPP_NJ
GO

ALTER VIEW AR$on_track#wide AS
WITH cur_term AS
    (SELECT schoolid
           ,time_per_name
     FROM KIPP_NJ..REPORTING$dates
     WHERE identifier = 'HEX'
        OR (school_level = 'HS' AND identifier = 'RT_IR')
       AND start_date <= GETDATE()
       AND end_date >= GETDATE()
     )
  ,ar_stats AS
   (SELECT cohort.studentid
          ,CAST(cohort.grade_level AS NVARCHAR) AS grade_level
          ,cohort.lastfirst
          ,SUBSTRING(s.first_name, 1, 1) + '. ' + s.last_name AS stu_name
          ,cohort.schoolid
          ,sch.abbreviation AS school          
          ,dense.reporting_hash
          ,CAST(DATEPART(month, dense.week_start) AS VARCHAR) + '/' + CAST(DATEPART(day, dense.week_start) AS VARCHAR) AS week_start
          ,dense.week_start AS week_start_full
          ,dense.week_end AS week_end_full
          ,dense.time_period_name
          ,dense.words_goal
          ,dense.dense_running_words
          ,dense.target_words
          ,CAST(dense.on_track_status_words AS FLOAT) AS on_track_status_words
          ,CAST(dense.on_track_status_points AS FLOAT) AS on_track_status_points
          ,dense.dense_running_mastery
          ,dense.dense_running_fiction_pct
          ,dense.dense_running_weighted_lexile_avg
          ,dense.dense_running_books_passed
          ,dense.dense_running_books_attempted
    FROM KIPP_NJ..AR$time_series_dense#static dense
    JOIN KIPP_NJ..COHORT$comprehensive_long#static cohort
      ON dense.studentid = cohort.studentid
     AND cohort.year = dbo.fn_Global_Academic_Year()
     AND cohort.rn = 1
    JOIN KIPP_NJ..STUDENTS s
      ON dense.studentid = s.id
     --AND s.schoolid = 73253
     --AND s.grade_level = 9
    JOIN KIPP_NJ..SCHOOLS sch
      ON cohort.schoolid = sch.school_number
    --WHERE dense.on_track_status_words IS NOT NULL
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

SELECT *
FROM
      (SELECT sub.*
             ,disambig.students
             ,disambig.N
       FROM
           (SELECT sub.school
                  ,'WORDS' AS row_type
                  ,CASE GROUPING(sub.grade_level)
                     WHEN 1 THEN 'All Grades'
                     ELSE CAST(sub.grade_level AS NVARCHAR)
                   END AS grade_level
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,sub.time_period_name
                  ,sub.week_start
                  ,CAST(ROUND(AVG(sub.on_track_status_words) * 100, 0) AS VARCHAR) AS pct_on_track
             FROM
                   (SELECT ar_stats.school
                          ,ar_stats.grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.course_name + ': ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_words
                    FROM ar_stats
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    WHERE time_period_name = 'Year'
                    --current term
                    UNION ALL
                    SELECT ar_stats.school
                          ,ar_stats.grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.course_name + ': ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_words
                    FROM ar_stats
                    JOIN cur_term
                      ON ar_stats.time_period_name = cur_term.time_per_name
                     AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    ) sub
            GROUP BY sub.school
                     ,CUBE(
                        sub.grade_level
                       ,sub.eng_enr)
                     ,sub.week_start
                     ,sub.time_period_name
                   ) sub
       LEFT OUTER JOIN 
           (SELECT school
                  ,CASE GROUPING(sub.grade_level)
                     WHEN 1 THEN 'All Grades'
                     ELSE CAST(sub.grade_level AS NVARCHAR)
                   END AS grade_level
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,dbo.GROUP_CONCAT_DS(sub.stu_name, '|', 1) AS students
                  ,COUNT(*) AS N
            FROM
                  (SELECT school
                         ,grade_level
                         ,enr.course_name + ': ' + enr.section_number AS eng_enr
                         ,stu_name
                   FROM enr
                  ) sub
             GROUP BY school
                     ,CUBE(
                       sub.grade_level
                      ,sub.eng_enr)
           ) disambig
       ON sub.school = disambig.school
       AND sub.eng_enr = disambig.eng_enr
       AND sub.grade_level = disambig.grade_level
       
       UNION ALL
       
       --POINTS/GRADE LEVEL CUTS
       SELECT sub.*
             ,disambig.students
             ,disambig.N
       FROM
           (SELECT sub.school
                  ,'POINTS' AS row_type
                  ,CASE GROUPING(sub.grade_level)
                     WHEN 1 THEN 'All Grades'
                     ELSE CAST(sub.grade_level AS NVARCHAR)
                   END AS grade_level
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,sub.time_period_name
                  ,sub.week_start
                  ,CAST(ROUND(AVG(sub.on_track_status_points) * 100, 0) AS VARCHAR) AS pct_on_track
             FROM
                   (SELECT ar_stats.school
                          ,ar_stats.grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.course_name + ': ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_points
                    FROM ar_stats
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    WHERE time_period_name = 'Year'
                    --current term
                    UNION ALL
                    SELECT ar_stats.school
                          ,ar_stats.grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.course_name + ': ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_points
                    FROM ar_stats
                    JOIN cur_term
                      ON ar_stats.time_period_name = cur_term.time_per_name
                     AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    ) sub
            GROUP BY sub.school
                     ,CUBE(
                        sub.grade_level
                       ,sub.eng_enr)
                     ,sub.week_start
                     ,sub.time_period_name
                   ) sub
       LEFT OUTER JOIN 
           (SELECT school
                  ,CASE GROUPING(sub.grade_level)
                     WHEN 1 THEN 'All Grades'
                     ELSE CAST(sub.grade_level AS NVARCHAR)
                   END AS grade_level
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,dbo.GROUP_CONCAT_DS(sub.stu_name, '|', 1) AS students
                  ,COUNT(*) AS N
            FROM
                  (SELECT school
                         ,grade_level
                         ,enr.course_name + ': ' + enr.section_number AS eng_enr
                         ,stu_name
                   FROM enr
                  ) sub
             GROUP BY school
                     ,CUBE(
                       sub.grade_level
                      ,sub.eng_enr)
           ) disambig
       ON sub.school = disambig.school
       AND sub.eng_enr = disambig.eng_enr
       AND sub.grade_level = disambig.grade_level
   
       UNION ALL

       --teacher enrollment cuts, NO GRADE LEVEL (for NCA)
       SELECT sub.*
             ,disambig.students
             ,disambig.N
       FROM
           (SELECT sub.school
                  ,'POINTS' AS row_type
                  ,sub.grade_level                  
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,sub.time_period_name
                  ,sub.week_start
                  ,CAST(ROUND(AVG(sub.on_track_status_points) * 100, 0) AS VARCHAR) AS pct_on_track
             FROM
                   (SELECT ar_stats.school
                          ,enr.teacher AS grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_points
                    FROM ar_stats
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    WHERE time_period_name = 'Year'
                    --current term
                    UNION ALL
                    SELECT ar_stats.school
                          ,enr.teacher AS grade_level
                          ,enr.course_number
                          ,enr.section_number
                          ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
                          ,ar_stats.week_start
                          ,ar_stats.time_period_name
                          ,ar_stats.on_track_status_points
                    FROM ar_stats
                    JOIN cur_term
                      ON ar_stats.time_period_name = cur_term.time_per_name
                     AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
                    JOIN enr
                      ON ar_stats.studentid = enr.studentid
                    ) sub
            GROUP BY sub.school
                    ,sub.grade_level
                    ,CUBE(sub.eng_enr)
                    ,sub.week_start
                    ,sub.time_period_name
                   ) sub
       LEFT OUTER JOIN 
           (SELECT school
                  ,grade_level
                  ,CASE GROUPING(sub.eng_enr)
                     WHEN 1 THEN 'All'
                     ELSE sub.eng_enr
                   END AS eng_enr
                  ,dbo.GROUP_CONCAT_DS(sub.stu_name, '|', 1) AS students
                  ,COUNT(*) AS N
            FROM
                  (SELECT school
                         ,enr.teacher AS grade_level
                         ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
                         ,stu_name
                   FROM enr
                  ) sub
             GROUP BY school
                     ,sub.grade_level
                     ,CUBE(sub.eng_enr)
           ) disambig
       ON sub.school = disambig.school
       AND sub.grade_level = disambig.grade_level
       AND sub.eng_enr = disambig.eng_enr
       ) sub

PIVOT (
  MAX(pct_on_track)
  FOR week_start
  IN (
    [8/5]
   ,[8/12]
   ,[8/19]
   ,[8/26]
   ,[9/2]
   ,[9/9]
   ,[9/16]
   ,[9/23]
   ,[9/30]
   ,[10/7]
   ,[10/14]
   ,[10/21]
   ,[10/28]
   ,[11/4]
   ,[11/11]
   ,[11/18]
   ,[11/25]
   ,[12/2]
   ,[12/9]
   ,[12/16]
   ,[12/23]
   ,[12/29]
   ,[1/6]
   ,[1/13]
   ,[1/20]
   ,[1/27]
   ,[2/3]
   ,[2/10]
   ,[2/17]
   ,[2/24]
   ,[3/3]
   ,[3/10]
   ,[3/17]
   ,[3/24]
   ,[3/31]
   ,[4/7]
   ,[4/14]
   ,[4/21]
   ,[4/28]
   ,[5/5]
   ,[5/12]
   ,[5/19]
   ,[5/26]
   ,[6/2]
   ,[6/9]
   ,[6/16]
   ,[6/23]
  )
) AS foo
