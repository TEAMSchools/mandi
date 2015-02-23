USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[AR$on_track#wide] AS

WITH cur_term AS (
  SELECT schoolid
        ,time_per_name
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE ((school_level = 'MS' AND identifier = 'HEX') OR (school_level = 'HS' AND identifier = 'RT_IR'))
    AND start_date <= CONVERT(DATE,GETDATE())
    AND end_date >= CONVERT(DATE,GETDATE())
 )

,ar_stats AS (
  SELECT cohort.studentid
        ,CAST(cohort.grade_level AS NVARCHAR) AS grade_level
        ,cohort.lastfirst
        ,SUBSTRING(cohort.first_name, 1, 1) + '. ' + cohort.last_name AS stu_name
        ,cohort.schoolid
        ,cohort.school_name AS school          
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
  FROM KIPP_NJ..AR$time_series_dense#static dense WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$identifiers_long#static cohort WITH(NOLOCK)
    ON dense.studentid = cohort.studentid
   AND cohort.year = dbo.fn_Global_Academic_Year()
   AND cohort.rn = 1
   --WHERE dense.on_track_status_words IS NOT NULL
 )
   
,enr AS (
  SELECT enr.termid AS termid
        ,enr.studentid        
        ,SUBSTRING(co.first_name, 1, 1) + '. ' + co.last_name AS stu_name
        ,enr.sectionid
        ,enr.section_number        
        ,enr.teacher_name AS teacher
        ,enr.course_number
        ,enr.course_name
        ,enr.grade_level
        ,co.school_name AS school
  FROM KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
  JOIN KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
    ON enr.STUDENTID = co.studentid
   AND enr.academic_year = co.year
   AND co.rn = 1
   AND co.enroll_status = 0
  WHERE enr.dateenrolled <= CONVERT(DATE,GETDATE())
    AND enr.dateleft >= CONVERT(DATE,GETDATE())
    AND enr.credittype = 'ENG'
 )

,disambig AS (
  SELECT 'CLASS' AS type
        ,school
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
      (
       SELECT school
             ,grade_level
             ,enr.course_name + ': ' + enr.section_number AS eng_enr
             ,stu_name
       FROM enr WITH(NOLOCK)
      ) sub
  GROUP BY school
          ,CUBE(sub.grade_level
               ,sub.eng_enr)

  UNION ALL

  SELECT 'TEACHER' AS type
        ,school
        ,grade_level
        ,CASE GROUPING(sub.eng_enr)
          WHEN 1 THEN 'All'
          ELSE sub.eng_enr
         END AS eng_enr
        ,KIPP_NJ.dbo.GROUP_CONCAT_DS(sub.stu_name, '|', 1) AS students
        ,COUNT(*) AS N
  FROM
      (
       SELECT school
             ,enr.teacher AS grade_level
             ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
             ,stu_name
       FROM enr WITH(NOLOCK)
      ) sub
  GROUP BY school
          ,sub.grade_level
          ,CUBE(sub.eng_enr)
 )

,all_data AS (
  SELECT sub.*
        ,disambig.students
        ,disambig.N
  FROM
      (
       SELECT sub.school
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
           (
            SELECT ar_stats.school
                  ,ar_stats.grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.course_name + ': ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_words
            FROM ar_stats WITH(NOLOCK)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
            WHERE time_period_name = 'Year'
                              
            UNION ALL
               
            --current term
            SELECT ar_stats.school
                  ,ar_stats.grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.course_name + ': ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_words
            FROM ar_stats WITH(NOLOCK)
            JOIN cur_term WITH(NOLOCK)
              ON ar_stats.time_period_name = cur_term.time_per_name
             AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
           ) sub
       GROUP BY sub.school
               ,CUBE(sub.grade_level
                    ,sub.eng_enr)
               ,sub.week_start
               ,sub.time_period_name
      ) sub
  LEFT OUTER JOIN disambig WITH(NOLOCK)
               ON sub.school = disambig.school
              AND sub.eng_enr = disambig.eng_enr
              AND sub.grade_level = disambig.grade_level
              AND disambig.type = 'CLASS'
       
  UNION ALL
       
  --POINTS/GRADE LEVEL CUTS
  SELECT sub.*
        ,disambig.students
        ,disambig.N
  FROM
      (
       SELECT sub.school
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
           (
            SELECT ar_stats.school
                  ,ar_stats.grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.course_name + ': ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
            WHERE time_period_name = 'Year'
             
            UNION ALL
             
            --current term
            SELECT ar_stats.school
                  ,ar_stats.grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.course_name + ': ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)
            JOIN cur_term WITH(NOLOCK)
              ON ar_stats.time_period_name = cur_term.time_per_name
             AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
           ) sub
       GROUP BY sub.school
               ,CUBE(sub.grade_level
                    ,sub.eng_enr)
               ,sub.week_start
               ,sub.time_period_name
      ) sub
  LEFT OUTER JOIN disambig WITH(NOLOCK)
               ON sub.school = disambig.school
              AND sub.eng_enr = disambig.eng_enr
              AND sub.grade_level = disambig.grade_level
              AND disambig.type = 'CLASS'
   
  UNION ALL

  --teacher enrollment cuts, NO GRADE LEVEL (for NCA)
  SELECT sub.*
        ,disambig.students
        ,disambig.N
  FROM
      (
       SELECT sub.school
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
           (
            SELECT ar_stats.school
                  ,enr.teacher AS grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
            WHERE time_period_name = 'Year'
                        
            UNION ALL
            
            --current term
            SELECT ar_stats.school
                  ,enr.teacher AS grade_level
                  ,enr.course_number
                  ,enr.section_number
                  ,enr.teacher + '|' + enr.course_number + ' ' + enr.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)
            JOIN cur_term WITH(NOLOCK)
              ON ar_stats.time_period_name = cur_term.time_per_name
             AND CAST(ar_stats.schoolid AS INT) = CAST(cur_term.schoolid AS INT)
            JOIN enr WITH(NOLOCK)
              ON ar_stats.studentid = enr.studentid
           ) sub
       GROUP BY sub.school
               ,sub.grade_level
               ,CUBE(sub.eng_enr)
               ,sub.week_start
               ,sub.time_period_name
      ) sub
  LEFT OUTER JOIN disambig WITH(NOLOCK)
               ON sub.school = disambig.school
              AND sub.grade_level = disambig.grade_level
              AND sub.eng_enr = disambig.eng_enr
              AND disambig.type = 'TEACHER'
 )

SELECT *
FROM all_data
PIVOT(
  MAX(pct_on_track)
  FOR week_start IN ([8/4]
                    ,[8/11]
                    ,[8/18]
                    ,[8/25]
                    ,[9/1]
                    ,[9/8]
                    ,[9/15]
                    ,[9/22]
                    ,[9/29]
                    ,[10/6]
                    ,[10/13]
                    ,[10/20]
                    ,[10/27]
                    ,[11/3]
                    ,[11/10]
                    ,[11/17]
                    ,[11/24]
                    ,[12/1]
                    ,[12/8]
                    ,[12/15]
                    ,[12/22]
                    ,[1/5]
                    ,[1/12]
                    ,[1/19]
                    ,[1/26]
                    ,[2/2]
                    ,[2/9]
                    ,[2/16]
                    ,[2/23]
                    ,[3/2]
                    ,[3/9]
                    ,[3/16]
                    ,[3/23]
                    ,[3/30]
                    ,[4/6]
                    ,[4/13]
                    ,[4/20]
                    ,[4/27]
                    ,[5/4]
                    ,[5/11]
                    ,[5/18]
                    ,[5/25]
                    ,[6/1]
                    ,[6/8]
                    ,[6/15]
                    ,[6/22])
 ) p
GO


