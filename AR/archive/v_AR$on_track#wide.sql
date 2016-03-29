USE [KIPP_NJ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [AR$on_track#wide] AS

WITH ar_stats AS (
  SELECT co.school_name AS school
        ,co.grade_level
        ,co.studentid
        ,LEFT(co.first_name,1) + '.' + co.last_name AS stu_name
        ,enr.teacher_name AS teacher
        ,enr.course_number
        ,enr.course_name
        ,enr.section_number      
        ,CONVERT(VARCHAR,DATEPART(MONTH,ar_stats.week_start)) + '/' + CONVERT(VARCHAR,DATEPART(DAY,ar_stats.week_start)) AS week_start
        --,ar_stats.week_start
        ,ar_stats.time_period_name
        ,CONVERT(FLOAT,ar_stats.on_track_status_points) AS on_track_status_points
        ,CONVERT(FLOAT,ar_stats.on_track_status_words) AS on_track_status_words
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN KIPP_NJ..PS$course_enrollments#static enr WITH(NOLOCK)
    ON co.studentid = enr.studentid
   AND enr.dateenrolled <= CONVERT(DATE,GETDATE())
   AND enr.dateleft >= CONVERT(DATE,GETDATE())
   AND enr.credittype = 'ENG'
  JOIN KIPP_NJ..AR$time_series_dense#static ar_stats WITH(NOLOCK)
    ON co.studentid = ar_stats.studentid 
  WHERE co.year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND co.rn = 1
    AND co.enroll_status = 0
    AND co.schoolid IN (73252,133570965) -- currently only used by TEAM and Rise
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
        ,dbo.GROUP_CONCAT_DS(sub.stu_name, ' | ', 1) AS students
        ,COUNT(*) AS N
  FROM
      (
       SELECT DISTINCT 
              school
             ,grade_level
             ,course_name + ': ' + section_number AS eng_enr
             ,stu_name
       FROM ar_stats WITH(NOLOCK)
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
       SELECT DISTINCT 
              school
             ,teacher AS grade_level
             ,teacher + '|' + course_number + ' ' + section_number AS eng_enr
             ,stu_name
       FROM ar_stats WITH(NOLOCK)
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
                  ,ar_stats.course_number
                  ,ar_stats.section_number
                  ,ar_stats.course_name + ': ' + ar_stats.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_words
            FROM ar_stats WITH(NOLOCK)            
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
                  ,ar_stats.course_number
                  ,ar_stats.section_number
                  ,ar_stats.course_name + ': ' + ar_stats.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)            
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
   
  --/*
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
                  ,ar_stats.teacher AS grade_level
                  ,ar_stats.course_number
                  ,ar_stats.section_number
                  ,ar_stats.teacher + '|' + ar_stats.course_number + ' ' + ar_stats.section_number AS eng_enr
                  ,ar_stats.week_start
                  ,ar_stats.time_period_name
                  ,ar_stats.on_track_status_points
            FROM ar_stats WITH(NOLOCK)            
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
  --*/
 )

SELECT *
FROM all_data
PIVOT(
  MAX(pct_on_track)
  FOR week_start IN ([8/10]
                    ,[8/17]
                    ,[8/24]
                    ,[8/31]
                    ,[9/7]
                    ,[9/14]
                    ,[9/21]
                    ,[9/28]
                    ,[10/5]
                    ,[10/12]
                    ,[10/19]
                    ,[10/26]
                    ,[11/2]
                    ,[11/9]
                    ,[11/16]
                    ,[11/23]
                    ,[11/30]
                    ,[12/7]
                    ,[12/14]
                    ,[12/21]
                    ,[12/28]
                    ,[1/4]
                    ,[1/11]
                    ,[1/18]
                    ,[1/25]
                    ,[2/1]
                    ,[2/8]
                    ,[2/15]
                    ,[2/22]
                    ,[3/1]
                    ,[3/8]
                    ,[3/15]
                    ,[3/22]
                    ,[3/29]
                    ,[4/5]
                    ,[4/12]
                    ,[4/19]
                    ,[4/26]
                    ,[5/3]
                    ,[5/10]
                    ,[5/17]
                    ,[5/24]
                    ,[5/31]
                    ,[6/7]
                    ,[6/14]
                    ,[6/21]
                    ,[6/28])
 ) p